#!/bin/bash
set -eo pipefail

[ "${HOOK_METRICS_DISABLED:-0}" = "1" ] && exit 0

# SessionEnd: aggregate session JSONL into summary. Runs ONCE per session
# (replaces metrics-summary-stop.sh which ran on every turn end = wasteful).
# Also writes a memory summary for next-session context.

_input=$(cat 2>/dev/null || echo '{}')

# Session state needs a stable id: env first, Codex stdin second. With
# neither, every hook run has a fresh PID, so a bare $$ dir can never be
# shared across invocations and can collide after PID wrap -- skip.
_hook_sid="${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}"
if [ -z "$_hook_sid" ] && [ ! -t 0 ]; then
  _hook_sid=$(printf '%s' "$_input" | jq -r '.session_id // empty' 2>/dev/null || true)
fi
[ -z "$_hook_sid" ] && exit 0
session_dir="/tmp/hook-session-${_hook_sid}"
log_file="$session_dir/structured.jsonl"

[ -f "$log_file" ] && [ -s "$log_file" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

metrics_dir="${HOOK_METRICS_DIR:-$HOME/.claude/hook-metrics}"
mkdir -p "$metrics_dir" 2>/dev/null || exit 0

session_date=$(date +%Y-%m-%d)
session_id=$(printf '%s' "$_hook_sid" | cksum | awk '{print $1"-"$2}')
total_entries=$(wc -l < "$log_file" | tr -d ' ')

first_ts=$(head -1 "$log_file" | jq -r '.ts // 0')
last_ts=$(tail -1 "$log_file" | jq -r '.ts // 0')
duration_minutes=$(( (last_ts - first_ts) / 60 ))

touched_file="$session_dir/session-touched-files"
files_touched=0
[ -f "$touched_file" ] && files_touched=$(sort -u "$touched_file" | wc -l | tr -d ' ')

_top() {
  local dec="$1"
  jq -s --arg decision "$dec" '
    map(select(.decision == $decision))
    | sort_by(.rule)
    | group_by(.rule)
    | map({key: .[0].rule, value: length})
    | sort_by(-.value)
    | .[:10]
    | from_entries
  ' "$log_file"
}

blocks=$(_top "block")
warns=$(_top "warn")
denies=$(_top "deny")
nudges=$(_top "nudge")
infos=$(_top "info")
diagnostics=$(_top "diagnostic")
shadow_blocks=$(_top "shadow-block")
shadow_warns=$(_top "shadow-warn")
shadow_nudges=$(_top "shadow-nudge")

perf_ms=$(jq -r 'select(.ms != null) | [.hook, .ms] | @tsv' "$log_file" 2>/dev/null \
  | awk -F'\t' '
      { hook=$1; ms=$2+0; times[hook] = (times[hook] ? times[hook] "," ms : ms); count[hook]++ }
      END {
        for (h in times) {
          n = split(times[h], arr, ",")
          for (i=1; i<=n; i++) for (j=i+1; j<=n; j++) if (arr[j]<arr[i]) { t=arr[i]; arr[i]=arr[j]; arr[j]=t }
          p50 = arr[int(n/2)+1]
          p95 = arr[int(n*0.95)+1]
          if (p95 == "") p95 = arr[n]
          printf "\"%s\":{\"p50\":%d,\"p95\":%d,\"n\":%d},", h, p50, p95, n
        }
      }
    ' | sed 's/,$//')

hooks_fired=$(jq -r '.hook' "$log_file" | sort -u | wc -l | tr -d ' ')

endpoint="unknown"
[ -f "$session_dir/task-endpoint" ] && endpoint=$(head -1 "$session_dir/task-endpoint")
outcome=$(printf '%s' "$_input" | jq -r '.outcome // .reason // empty' 2>/dev/null || true)
if [ -z "$outcome" ]; then
  if [ -f "$session_dir/task-completed" ]; then
    outcome="completed"
  elif [ -f "$session_dir/last-stop" ]; then
    outcome="stopped-with-findings"
  else
    outcome="ended"
  fi
fi

harness_version="${HARNESS_VERSION:-}"
if [ -z "$harness_version" ]; then
  manifest="$(dirname "$0")/../../skill-manifest.json"
  [ -f "$manifest" ] && harness_version=$(jq -r '.version // empty' "$manifest" 2>/dev/null || true)
fi
harness_version="${harness_version:-unknown}"
run_kind="${HOOK_METRICS_RUN_KIND:-real}"
input_model=$(printf '%s' "$_input" | jq -r '.model // .model_name // empty' 2>/dev/null || true)
session_model=""
[ -f "$session_dir/current-model" ] && session_model=$(head -1 "$session_dir/current-model" 2>/dev/null || true)
model="${input_model:-${session_model:-${CODEX_MODEL:-${ANTHROPIC_MODEL:-${CLAUDE_MODEL:-unknown}}}}}"
source="claude"
[ -n "${CODEX_SESSION_ID:-}" ] && source="codex"

perf_json="{${perf_ms}}"
jq -n \
  --arg source "$source" \
  --arg harness_version "$harness_version" \
  --arg run_kind "$run_kind" \
  --arg model "$model" \
  --arg date "$session_date" \
  --arg session_id "$session_id" \
  --arg endpoint "$endpoint" \
  --arg outcome "$outcome" \
  --argjson duration_minutes "$duration_minutes" \
  --argjson files_touched "$files_touched" \
  --argjson total_entries "$total_entries" \
  --argjson hooks_fired "$hooks_fired" \
  --argjson blocks "$blocks" \
  --argjson warns "$warns" \
  --argjson denies "$denies" \
  --argjson nudges "$nudges" \
  --argjson infos "$infos" \
  --argjson diagnostics "$diagnostics" \
  --argjson shadow_blocks "$shadow_blocks" \
  --argjson shadow_warns "$shadow_warns" \
  --argjson shadow_nudges "$shadow_nudges" \
  --argjson perf_ms "$perf_json" '
  {
    schema_version: 4,
    source: $source,
    harness_version: $harness_version,
    run_kind: $run_kind,
    model: $model,
    date: $date,
    session_id: $session_id,
    endpoint: $endpoint,
    outcome: $outcome,
    duration_minutes: $duration_minutes,
    files_touched: $files_touched,
    total_entries: $total_entries,
    hooks_fired: $hooks_fired,
    blocks: $blocks,
    warns: $warns,
    denies: $denies,
    nudges: $nudges,
    infos: $infos,
    diagnostics: $diagnostics,
    shadow_blocks: $shadow_blocks,
    shadow_warns: $shadow_warns,
    shadow_nudges: $shadow_nudges,
    perf_ms: $perf_ms
  }
' > "$metrics_dir/${session_date}-${session_id}.json"

exit 0
