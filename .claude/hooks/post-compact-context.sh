#!/bin/bash
set -eo pipefail
trap 'exit 0' ERR

# Restore volatile session state after compaction. Static repository rules stay in
# CLAUDE.md and skills; repeating them here costs context and creates drift.
# Claude Code and Codex take post-compaction context only from SessionStart with
# source "compact"; neither accepts hookSpecificOutput on PostCompact.

input=$(cat)
[ "$(echo "$input" | jq -r '.hook_event_name // empty')" = "SessionStart" ] || exit 0
[ "$(echo "$input" | jq -r '.source // empty')" = "compact" ] || exit 0

sid="${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}"
[ -z "$sid" ] && sid=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null || true)
[ -n "$sid" ] || exit 0

session_dir="/tmp/hook-session-${sid}"
branch=$(git branch --show-current 2>/dev/null || echo detached)
context="[POST-COMPACTION] Branch: $branch"
add() { context="$context"$'\n'"$1"; }

if [ -f "$session_dir/current-model" ] \
  && [ "$(head -1 "$session_dir/current-model")" = "claude-fable-5-2" ]; then
  source "$(dirname "$0")/../../shared/model-prompting.sh"
  add "$(harness_model_prompting_context)"
fi

if [ -f "$session_dir/task-endpoint" ]; then
  add "Endpoint: $(head -1 "$session_dir/task-endpoint")"
fi

if [ -f "$session_dir/session-touched-files" ]; then
  touched=$(sort -u "$session_dir/session-touched-files" | wc -l | tr -d '[:space:]')
  add "Session-touched files: ${touched:-0}"
fi

if [ -f "$session_dir/last-stop" ]; then
  add "Last stop: $(head -1 "$session_dir/last-stop")"
fi

if [ -f ".context/implementation-notes.md" ]; then
  add "Working notes: .context/implementation-notes.md -- reread its checklist before continuing"
fi

jq -nc --arg ctx "$context" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
