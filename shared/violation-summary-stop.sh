#!/bin/bash
set -eo pipefail

# Stop hook: report aggregated violation summary + session LOC delta.
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
session_files="$session_dir/files"

# ── Session LOC delta (code-is-liability visibility) ─────────────
# Net lines added to session-touched source files vs HEAD. Info only:
# awareness pressure toward smaller diffs, enforcement stays with
# /deslop and the review value gate.
loc_note=""
if [ -f "$session_files" ] && git rev-parse --git-dir >/dev/null 2>&1; then
  touched=$(cut -d: -f2- "$session_files" 2>/dev/null | sort -u | head -100 || true)
  if [ -n "$touched" ]; then
    stat=$(echo "$touched" | tr '\n' '\0' | xargs -0 git diff HEAD --shortstat -- 2>/dev/null | head -1 || true)
    added=$(echo "$stat" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)
    removed=$(echo "$stat" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo 0)
    if [ "${added:-0}" -gt 0 ] || [ "${removed:-0}" -gt 0 ]; then
      net=$((added - removed))
      loc_note=" Session LOC delta: +${added}/-${removed} (net ${net}). Code is liability — prefer the smallest passing diff."
    fi
  fi
fi

summary=""
total=0
if [ -f "$violations_file" ] && [ -s "$violations_file" ]; then
  # Aggregate violation counts
  summary=$(sort "$violations_file" | uniq -c | sort -rn | head -10 | while read -r count label; do
    echo "${count}x ${label}"
  done | paste -sd ", " -)
  total=$(wc -l < "$violations_file" | tr -d ' ')
fi

if [ -z "$summary" ] && [ -z "$loc_note" ]; then
  exit 0
fi

msg=""
[ -n "$summary" ] && msg="Session violation summary ($total total): $summary."
msg="${msg}${loc_note}"

# Report as additional context (don't block — just inform)
echo "{\"hookSpecificOutput\":{\"additionalContext\":\"$msg\"}}"

# Clean up
rm -f "$violations_file"

exit 0
