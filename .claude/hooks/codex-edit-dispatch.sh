#!/bin/bash
set -euo pipefail

# Codex exposes per-call PostToolUse, not Claude's PostToolBatch. Adapt one call
# into the batch protocol so all edit checks run in one shell process.

input=$(cat 2>/dev/null || echo '{}')
script_dir=$(cd "$(dirname "$0")" && pwd)
dispatcher="$script_dir/post-tool-batch.sh"
[ -x "$dispatcher" ] || exit 0

batch=$(printf '%s' "$input" | jq -c '
  if (.tool_calls | type) == "array" then .
  else {
    hook_event_name: "PostToolBatch",
    session_id: (.session_id // null),
    tool_calls: [{
      tool_name: (.tool_name // .tool // ""),
      tool_input: (.tool_input // .input // {})
    }]
  } end
' 2>/dev/null || echo '{"tool_calls":[]}')

input_file=$(mktemp)
out_file=$(mktemp)
err_file=$(mktemp)
trap 'rm -f "$input_file" "$out_file" "$err_file"' EXIT
printf '%s' "$batch" >"$input_file"

status=0
"$dispatcher" <"$input_file" >"$out_file" 2>"$err_file" || status=$?

if [ "$status" -eq 2 ]; then
  cat "$err_file" >&2
  exit 2
fi

if [ "$status" -ne 0 ]; then
  cat "$err_file" >&2
  exit 0
fi

if [ -s "$out_file" ]; then
  jq -c '
    if .hookSpecificOutput then
      .hookSpecificOutput.hookEventName = "PostToolUse"
    else . end
  ' "$out_file" 2>/dev/null || cat "$out_file"
fi
