#!/bin/bash
set -eo pipefail

# Skill-fire telemetry for /hook-audit's zero-fire-skills report (dead weight
# or bad trigger descriptions -- both actionable). Observe-only: never blocks.
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

dir="$HOME/.claude/hook-metrics"
mkdir -p "$dir" 2>/dev/null || true
printf '{"ts":"%s","skill":"%s","session":"%s","source":"%s"}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$skill" "${CLAUDE_SESSION_ID:-unknown}" "$source" \
  >> "$dir/skill-fires.jsonl" 2>/dev/null || true

exit 0
