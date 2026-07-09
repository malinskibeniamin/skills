#!/bin/bash
set -eo pipefail

# PreToolUse Skill: log every skill invocation to hook-metrics so
# /hook-audit can report zero-fire skills (dead weight or bad trigger
# descriptions -- both actionable). Observe-only: never blocks.

input=$(cat 2>/dev/null || echo '{}')
tool=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null)
[ "$tool" = "Skill" ] || exit 0
skill=$(echo "$input" | jq -r '.tool_input.skill // empty' 2>/dev/null)
[ -n "$skill" ] || exit 0

dir="$HOME/.claude/hook-metrics"
mkdir -p "$dir" 2>/dev/null || true
printf '{"ts":"%s","skill":"%s","session":"%s"}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$skill" "${CLAUDE_SESSION_ID:-unknown}" \
  >> "$dir/skill-fires.jsonl" 2>/dev/null || true

exit 0
