#!/bin/bash
set -eo pipefail

# Stop hook: action turns may not end silently or leave subagents behind.
# Semantic completion stays the model's responsibility; this hook enforces
# only the visible status contract and one deterministic cleanup checkpoint.

input=$(cat 2>/dev/null || echo '{}')

if [ -z "${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}" ]; then
  CODEX_SESSION_ID=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)
  export CODEX_SESSION_ID
fi

[ -n "${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}" ] || exit 0

source "$(dirname "$0")/../../shared/hook-lib.sh" 2>/dev/null || true

active_dir="$_hook_session_dir/active-subagents"
if [ -d "$active_dir" ]; then
  active_count=0
  for active_file in "$active_dir"/*; do
    [ -f "$active_file" ] || continue
    active_count=$((active_count + 1))
  done
  if [ "$active_count" -gt 0 ]; then
    hook_stop_block "${active_count} active subagent(s) remain. Collect or stop them before final status; no background agent may outlive the turn."
  fi
fi

# Artifact-only turns do not owe an action status, but cleanup above is universal.
endpoint_file="$_hook_session_dir/task-endpoint"
[ -s "$endpoint_file" ] || exit 0

# Reject an ambiguous final message at most once, but never waive cleanup.
if printf '%s' "$input" | jq -e '.stop_hook_active == true' >/dev/null 2>&1; then
  exit 0
fi

last_message=$(printf '%s' "$input" | jq -r '.last_assistant_message // empty' 2>/dev/null)
last_line=$(printf '%s\n' "$last_message" | awk 'NF { line=$0 } END { print line }')

has_visible_detail() {
  printf '%s' "$1" | grep -q '[^[:space:]]'
}

case "$last_line" in
  "🟢 done — "*)
    detail=${last_line#"🟢 done — "}
    if has_visible_detail "$detail"; then
      touch "$_hook_session_dir/task-completed" 2>/dev/null || true
      exit 0
    fi
    ;;
  "🟡 awaiting decision — "*)
    detail=${last_line#"🟡 awaiting decision — "}
    has_visible_detail "$detail" && exit 0
    ;;
  "🔴 blocked — "*)
    detail=${last_line#"🔴 blocked — "}
    has_visible_detail "$detail" && exit 0
    ;;
esac

hook_stop_block "Silent or ambiguous stop rejected. Reread the active request and continue if work remains. Otherwise end with exactly one evidence-bearing status line: 🟢 done — <evidence>, 🟡 awaiting decision — <specific decision>, or 🔴 blocked — <external blocker and needed input>."
