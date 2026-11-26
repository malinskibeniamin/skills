#!/bin/bash
set -eo pipefail
trap 'exit 0' ERR

# PreCompact: snapshot critical session state before compaction wipes
# in-context working memory. post-compact-context.sh restores context after
# compaction. Print nothing: Claude Code reads PreCompact stdout as
# compaction-summary instructions, Codex ignores it, and neither accepts
# hookSpecificOutput here.

input=$(cat)
hook_event=$(echo "$input" | jq -r '.hook_event_name // empty')
[ "$hook_event" = "PreCompact" ] || exit 0

# Session state needs a stable id: env first, Codex stdin second. With
# neither, every hook run has a fresh PID, so a bare $$ dir can never be
# shared across invocations and can collide after PID wrap -- skip.
_hook_sid="${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}"
[ -z "$_hook_sid" ] && _hook_sid=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null || true)
[ -z "$_hook_sid" ] && exit 0
session_dir="/tmp/hook-session-${_hook_sid}"
[ -d "$session_dir" ] || exit 0

snapshot="$session_dir/pre-compact-snapshot.json"

# Capture: violation counts, touched files, timing totals
_violations=""
vfile="$session_dir/violations"
if [ -f "$vfile" ] && [ -s "$vfile" ]; then
  _violations=$(sort "$vfile" | uniq -c | sort -rn | head -10 \
    | awk '{printf "\"%s\":%d,", $2, $1}' | sed 's/,$//')
fi

_touched_count=0
tfile="$session_dir/session-touched-files"
[ -f "$tfile" ] && _touched_count=$(sort -u "$tfile" | wc -l | tr -d ' ')

_log_entries=0
lfile="$session_dir/structured.jsonl"
[ -f "$lfile" ] && _log_entries=$(wc -l < "$lfile" | tr -d ' ')

cat > "$snapshot" <<EOF
{
  "ts": $(date +%s),
  "touched_files": $_touched_count,
  "log_entries": $_log_entries,
  "violations": {${_violations}}
}
EOF

exit 0
