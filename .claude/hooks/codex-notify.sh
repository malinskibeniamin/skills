#!/bin/bash
set -eo pipefail
trap 'exit 0' ERR

# Codex `notify` adapter. Codex has no SessionEnd lifecycle event; its
# `notify` mechanism invokes an external command with ONE JSON argument on
# agent-turn-complete. Wire in ~/.codex/config.toml:
#
#   notify = ["bash", "/path/to/repo/.claude/hooks/codex-notify.sh"]
#
# Logs to the same hook-metrics feed session-end.sh writes on Claude, so
# /hook-audit session retros see Codex turns instead of a Claude-only view.

payload="${1:-}"
[ -n "$payload" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

type=$(printf '%s' "$payload" | jq -r '.type // empty' 2>/dev/null)
[ "$type" = "agent-turn-complete" ] || exit 0

thread=$(printf '%s' "$payload" | jq -r '."thread-id" // empty' 2>/dev/null)
cwd=$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null)
last=$(printf '%s' "$payload" | jq -r '."last-assistant-message" // empty' 2>/dev/null | head -c 200)

dir="$HOME/.claude/hook-metrics"
mkdir -p "$dir" 2>/dev/null || true
jq -cn --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg thread "$thread" \
  --arg cwd "$cwd" --arg last "$last" \
  '{ts: $ts, source: "codex-notify", event: "agent-turn-complete", thread: $thread, cwd: $cwd, last: $last}' \
  >> "$dir/codex-turns.jsonl" 2>/dev/null || true

# Maintain a schema-compatible session summary so /hook-audit's existing
# "read every *.json in hook-metrics" pass sees Codex sessions without a
# separate reader: one file per thread, turn count incremented per event.
_date=$(date -u +%Y-%m-%d)
_thread8=$(printf '%s' "${thread:-unknown}" | tr -cd 'a-zA-Z0-9-' | cut -c1-8)
_summary="$dir/${_date}-codex-${_thread8:-unknown}.json"
if [ -f "$_summary" ]; then
  jq '.turns = ((.turns // 0) + 1)' "$_summary" > "$_summary.tmp" 2>/dev/null \
    && mv "$_summary.tmp" "$_summary" 2>/dev/null || rm -f "$_summary.tmp"
else
  jq -cn --arg date "$_date" --arg sid "codex-${_thread8:-unknown}" '
    {schema_version: 2, source: "codex", date: $date, session_id: $sid,
     turns: 1, hooks_fired: 0, blocks: {}, warns: {}, denies: {},
     nudges: {}, infos: {}, diagnostics: {}, perf_ms: {}}' \
    > "$_summary" 2>/dev/null || true
fi

exit 0
