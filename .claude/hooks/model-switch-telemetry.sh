#!/bin/bash
set -eo pipefail

# Observe model transitions without changing or blocking the switch. The
# successful PostModelSwitch event becomes the source for later hook metrics.
input=$(cat 2>/dev/null || echo '{}')
command -v jq >/dev/null 2>&1 || exit 0
printf '%s' "$input" | jq -e 'type == "object"' >/dev/null 2>&1 || exit 0

event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty')
case "$event" in
  PreModelSwitch | PostModelSwitch) ;;
  *) exit 0 ;;
esac

session="${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}"
[ -n "$session" ] || session=$(printf '%s' "$input" | jq -r '.session_id // empty')
[ -n "$session" ] || exit 0

session_dir="/tmp/hook-session-${session}"
mkdir -p "$session_dir" 2>/dev/null || true
from_model=$(printf '%s' "$input" | jq -r '.from_model // .previous_model // empty')
to_model=$(printf '%s' "$input" | jq -r '.to_model // .new_model // .model // empty')

if [ "$event" = "PostModelSwitch" ] && [ -n "$to_model" ]; then
  printf '%s\n' "$to_model" > "$session_dir/current-model" 2>/dev/null || true
elif [ -n "$from_model" ] && [ ! -s "$session_dir/current-model" ]; then
  printf '%s\n' "$from_model" > "$session_dir/current-model" 2>/dev/null || true
fi

[ "${HOOK_METRICS_DISABLED:-0}" = "1" ] && exit 0
metrics_dir="${HOOK_METRICS_DIR:-$HOME/.claude/hook-metrics}"
mkdir -p "$metrics_dir" 2>/dev/null || exit 0

harness_version="${HARNESS_VERSION:-}"
if [ -z "$harness_version" ]; then
  manifest="$(dirname "$0")/../../skill-manifest.json"
  [ -f "$manifest" ] && harness_version=$(jq -r '.version // empty' "$manifest" 2>/dev/null || true)
fi
harness_version="${harness_version:-unknown}"
session_id=$(printf '%s' "$session" | cksum | awk '{print $1"-"$2}')

printf '%s' "$input" | jq -c \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg event "$event" \
  --arg session_id "$session_id" \
  --arg harness_version "$harness_version" \
  --arg run_kind "${HOOK_METRICS_RUN_KIND:-real}" \
  --arg from_model "$from_model" \
  --arg to_model "$to_model" '
  {
    schema_version: 1,
    ts: $ts,
    event: $event,
    session_id: $session_id,
    harness_version: $harness_version,
    run_kind: $run_kind,
    from_model: $from_model,
    to_model: $to_model,
    requested_model: (.requested_model // null),
    source: (.source // "unknown"),
    context_tokens: (.context_tokens // null),
    prompt_cache_warm: (if has("prompt_cache_warm") then .prompt_cache_warm else null end),
    cache_ttl: (.cache_ttl // null),
    estimated_cache_write_usd: (.estimated_cache_write_usd // null),
    pricing: (.pricing // null)
  }' >> "$metrics_dir/model-switches.jsonl" 2>/dev/null || true

exit 0
