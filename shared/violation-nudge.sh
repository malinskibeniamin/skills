#!/bin/bash
set -eo pipefail

# PreToolUse hook: mid-session violation nudge.
# Reads accumulated violations. If same rule triggered 3+ times,
# injects a nudge so Claude adjusts approach instead of repeating.
# Target: <10ms (file read + awk).

# Session state needs a stable id: env first, Codex stdin second. With
# neither, every hook run has a fresh PID, so a bare $$ dir can never be
# shared across invocations and can collide after PID wrap -- skip.
_hook_sid="${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}"
if [ -z "$_hook_sid" ] && [ ! -t 0 ]; then
  _hook_sid=$(jq -r '.session_id // empty' 2>/dev/null || true)
fi
[ -z "$_hook_sid" ] && exit 0
_session_dir="/tmp/hook-session-${_hook_sid}"
_violations_file="$_session_dir/violations"

# No violations yet — nothing to do
if [ ! -f "$_violations_file" ] || [ ! -s "$_violations_file" ]; then
  exit 0
fi

# Count violations per rule, find repeaters (3+)
repeaters=$(sort "$_violations_file" | uniq -c | awk '$1 >= 3 { printf "%dx %s, ", $1, $2 }' | sed 's/, $//')

if [ -z "$repeaters" ]; then
  exit 0
fi

# Only nudge once per rule set — hash current repeaters, skip if already nudged
_nudge_hash=$(echo "$repeaters" | cksum | cut -d' ' -f1)
_nudge_marker="$_session_dir/nudge-$_nudge_hash"

if [ -f "$_nudge_marker" ]; then
  exit 0
fi

touch "$_nudge_marker" 2>/dev/null || true

echo "{\"hookSpecificOutput\":{\"additionalContext\":\"[VIOLATION PATTERN] Repeated blocks: $repeaters. Adjust approach — read the block messages and change strategy instead of retrying the same pattern.\"}}"

exit 0
