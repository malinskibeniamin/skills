#!/bin/bash
set -eo pipefail
trap 'exit 0' ERR

# Restore volatile session state after compaction. Static repository rules stay in
# CLAUDE.md and skills; repeating them here costs context and creates drift.

input=$(cat)
[ "$(echo "$input" | jq -r '.hook_event_name // empty')" = "PostCompact" ] || exit 0

sid="${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}"
[ -z "$sid" ] && sid=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null || true)
[ -n "$sid" ] || exit 0

session_dir="/tmp/hook-session-${sid}"
branch=$(git branch --show-current 2>/dev/null || echo detached)
context="[POST-COMPACTION] Branch: $branch"

if [ -f "$session_dir/task-endpoint" ]; then
  context="$context\nEndpoint: $(head -1 "$session_dir/task-endpoint")"
fi

if [ -f "$session_dir/session-touched-files" ]; then
  touched=$(sort -u "$session_dir/session-touched-files" | wc -l | tr -d '[:space:]')
  context="$context\nSession-touched files: ${touched:-0}"
fi

if [ -f "$session_dir/last-stop" ]; then
  context="$context\nLast stop: $(head -1 "$session_dir/last-stop")"
fi

if [ -f ".context/implementation-notes.md" ]; then
  context="$context\nWorking notes: .context/implementation-notes.md"
fi

escaped=$(printf '%s' "$context" | jq -Rs . 2>/dev/null) || exit 0
echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PostCompact\",\"additionalContext\":$escaped}}"
