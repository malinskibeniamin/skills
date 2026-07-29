#!/bin/bash
set -eo pipefail

# Skill-fire telemetry for /hook-audit's zero-fire-skills report (dead weight
# or bad trigger descriptions -- both actionable). Never blocks. /dogfood also
# records a session checkpoint consumed by dogfood-stop.sh.
# Two feeds, one log:
#   PreToolUse Skill      -- model-invoked skills (tool_input.skill)
#   UserPromptExpansion   -- user-typed /slash commands expanding to a prompt
# Without the second feed, user-invoked skills look dead in the audit even
# when used daily.

input=$(cat 2>/dev/null || echo '{}')
event=$(echo "$input" | jq -r '.hook_event_name // empty' 2>/dev/null)

case "$event" in
  UserPromptExpansion)
    skill=$(echo "$input" | jq -r '.skill_name // .command_name // .command // .matcher // empty' 2>/dev/null)
    source="expansion"
    ;;
  *)
    tool=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null)
    [ "$tool" = "Skill" ] || exit 0
    skill=$(echo "$input" | jq -r '.tool_input.skill // empty' 2>/dev/null)
    source="tool"
    ;;
esac
[ -n "$skill" ] || exit 0

session="${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}"
[ -n "$session" ] || session=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)

dir="$HOME/.claude/hook-metrics"
mkdir -p "$dir" 2>/dev/null || true
printf '{"ts":"%s","skill":"%s","session":"%s","source":"%s"}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$skill" "${session:-unknown}" "$source" \
  >> "$dir/skill-fires.jsonl" 2>/dev/null || true

case "$skill" in
  dogfood|*/dogfood|*:dogfood)
    if [ -n "$session" ]; then
      session_dir="/tmp/hook-session-${session}"
      mkdir -p "$session_dir" 2>/dev/null || true
      state_lib="$(dirname "$0")/dogfood-state.sh"
      fingerprint=""
      if [ -f "$state_lib" ]; then
        # shellcheck source=dogfood-state.sh
        source "$state_lib"
        fingerprint=$(dogfood_state_fingerprint 2>/dev/null || true)
      fi
      printf '{"fingerprint":"%s"}\n' "$fingerprint" \
        > "$session_dir/dogfood-invocation" 2>/dev/null || true
    fi
    ;;
  resolve-pr-feedback|*/resolve-pr-feedback|*:resolve-pr-feedback)
    if [ -n "$session" ]; then
      session_dir="/tmp/hook-session-${session}"
      mkdir -p "$session_dir" 2>/dev/null || true
      touch "$session_dir/pr-feedback-active" 2>/dev/null || true
    fi
    ;;
esac

exit 0
