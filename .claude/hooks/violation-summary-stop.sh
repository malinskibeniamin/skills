#!/bin/bash
set -eo pipefail

# Stop hook: report aggregated violations.
# Reads violations tracked by hook_block/hook_warn/hook_deny in hook-lib.sh.
# Note: set -u removed — CLAUDE_SESSION_ID may be unset in some contexts.

# Session state needs a stable id: env first, Codex stdin second. With
# neither, every hook run has a fresh PID, so a bare $$ dir can never be
# shared across invocations and can collide after PID wrap -- skip.
_hook_sid="${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}"
if [ -z "$_hook_sid" ] && [ ! -t 0 ]; then
  _hook_sid=$(jq -r '.session_id // empty' 2>/dev/null || true)
fi
[ -z "$_hook_sid" ] && exit 0
session_dir="/tmp/hook-session-${_hook_sid}"
violations_file="$session_dir/violations"

summary=""
total=0
if [ -f "$violations_file" ] && [ -s "$violations_file" ]; then
  # Aggregate violation counts
  summary=$(sort "$violations_file" | uniq -c | sort -rn | head -10 | while read -r count label; do
    echo "${count}x ${label}"
  done | paste -sd ", " -)
  total=$(wc -l < "$violations_file" | tr -d ' ')
fi

if [ -z "$summary" ]; then
  exit 0
fi

msg="Session violation summary ($total total): $summary."

# Report as additional context (don't block — just inform)
echo "{\"hookSpecificOutput\":{\"additionalContext\":\"$msg\"}}"

# Clean up
rm -f "$violations_file"

exit 0
