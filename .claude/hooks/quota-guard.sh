#!/bin/bash
set -euo pipefail

# Opt-in only. This must stay independent of frontend project detection.
case "${HARNESS_QUOTA_GUARD:-0}" in
  ""|0) exit 0 ;;
esac

hook_dir=$(cd "$(dirname "$0")" && pwd)
input=$(cat)
# This fallback must work even when neither JSON parser can start. Host events
# use literal checkpoint names; Python validates the full JSON on the normal path.
event=""
if [[ $input =~ \"hook_event_name\"[[:space:]]*:[[:space:]]*\"(UserPromptSubmit|PreToolUse|PostToolUse)\" ]]; then
  event="${BASH_REMATCH[1]}"
fi
unavailable() {
  local reason="Quota guard unavailable: verify Python 3 and the installed collector."
  case "$event" in
    PostToolUse) printf '{"continue":false,"stopReason":"%s"}\n' "$reason" ;;
    PreToolUse) printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason" ;;
    *) printf '{"decision":"block","reason":"%s"}\n' "$reason" ;;
  esac
}
if ! command -v python3 >/dev/null 2>&1; then
  unavailable
  exit 0
fi
if output=$(printf '%s' "$input" | python3 "$hook_dir/../../scripts/quota-guard.py" "${1:-claude}" "$event" 2>/dev/null); then
  [ -z "$output" ] || printf '%s\n' "$output"
else
  unavailable
fi
