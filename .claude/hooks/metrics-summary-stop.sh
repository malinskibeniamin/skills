#!/bin/bash
set -eo pipefail

# Stop hook: aggregate session JSONL log into compact summary.
# Persists to ~/.claude/hook-metrics/ for /hook-audit skill.
# No source code stored — just rule names, counts, and decisions.

session_dir="/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}"
log_file="$session_dir/structured.jsonl"

# Nothing logged this session — skip silently
if [ ! -f "$log_file" ] || [ ! -s "$log_file" ]; then
  exit 0
fi

# Ensure jq available (metrics are best-effort, don't block on missing jq)
if ! command -v jq &>/dev/null; then
  exit 0
fi

metrics_dir="$HOME/.claude/hook-metrics"
mkdir -p "$metrics_dir" 2>/dev/null || exit 0

# Session metadata
session_date=$(date +%Y-%m-%d)
session_id="${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-unknown}}"
total_entries=$(wc -l < "$log_file" | tr -d ' ')

# Compute session duration from first/last timestamps
first_ts=$(head -1 "$log_file" | jq -r '.ts // 0')
last_ts=$(tail -1 "$log_file" | jq -r '.ts // 0')
duration_minutes=$(( (last_ts - first_ts) / 60 ))

# Count files touched this session
touched_file="$session_dir/session-touched-files"
files_touched=0
if [ -f "$touched_file" ]; then
  files_touched=$(sort -u "$touched_file" | wc -l | tr -d ' ')
fi

# Aggregate by decision type and rule
blocks=$(jq -r 'select(.decision=="block") | .rule' "$log_file" | sort | uniq -c | sort -rn | head -10 | while read -r count rule; do
  printf '"%s":%d,' "$rule" "$count"
done | sed 's/,$//')

warns=$(jq -r 'select(.decision=="warn") | .rule' "$log_file" | sort | uniq -c | sort -rn | head -10 | while read -r count rule; do
  printf '"%s":%d,' "$rule" "$count"
done | sed 's/,$//')

denies=$(jq -r 'select(.decision=="deny") | .rule' "$log_file" | sort | uniq -c | sort -rn | head -10 | while read -r count rule; do
  printf '"%s":%d,' "$rule" "$count"
done | sed 's/,$//')

# Count unique hooks that fired
hooks_fired=$(jq -r '.hook' "$log_file" | sort -u | wc -l | tr -d ' ')

# Build summary JSON
cat > "$metrics_dir/${session_date}-${session_id:0:8}.json" <<EOF
{
  "date": "$session_date",
  "session_id": "${session_id:0:8}",
  "duration_minutes": $duration_minutes,
  "files_touched": $files_touched,
  "total_entries": $total_entries,
  "hooks_fired": $hooks_fired,
  "blocks": {${blocks}},
  "warns": {${warns}},
  "denies": {${denies}}
}
EOF

exit 0
