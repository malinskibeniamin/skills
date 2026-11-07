#!/bin/bash
set -eo pipefail

# Enforce explicit routing policy before a switch, then hand the active model
# the current routing contract. Both events feed later hook metrics.
input=$(cat 2>/dev/null || echo '{}')
command -v jq >/dev/null 2>&1 || { echo 'Model policy: jq is required to verify admission.' >&2; exit 2; }
printf '%s' "$input" | jq -e 'type == "object"' >/dev/null 2>&1 || { echo 'Model policy: invalid hook input.' >&2; exit 2; }

event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty')
case "$event" in
  PreModelSwitch | PostModelSwitch) ;;
  *) exit 0 ;;
esac

session="${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}"
[ -n "$session" ] || session=$(printf '%s' "$input" | jq -r '.session_id // empty')
session_dir=""
if [ -n "$session" ]; then
  session_dir="/tmp/hook-session-${session}"
  mkdir -p "$session_dir" 2>/dev/null || true
fi
from_model=$(printf '%s' "$input" | jq -r '.from_model // .previous_model // empty')
to_model=$(printf '%s' "$input" | jq -r '.to_model // .new_model // .model // empty')
effort=$(printf '%s' "$input" | jq -r '
  if .effort != null and (.effort | type) != "object" then ""
  elif .effort.level != null then
    if (.effort.level | type) == "string" then .effort.level else "" end
  else env.CLAUDE_EFFORT // empty end')
source=$(printf '%s' "$input" | jq -r '.source // "unknown"')
routing_file="${MODEL_ROUTING_FILE:-$(dirname "$0")/../../config/model-routing.json}"
route_status=""
route_work=""
deny_reason=""
if [ ! -f "$routing_file" ] || ! jq -e '
    (.selection.preferred_models | type == "array" and length > 0)
    and (.efforts.allowed // [.quality_first.default.effort]) == ["xhigh"]
  ' "$routing_file" >/dev/null 2>&1; then
  deny_reason="Model policy: cannot verify the approved models and xhigh effort in config/model-routing.json."
else
  route_status=$(jq -r --arg model "$to_model" '.models[$model].status // empty' "$routing_file" 2>/dev/null || true)
  route_work=$(jq -r --arg model "$to_model" '.models[$model].work // [] | join(", ")' "$routing_file" 2>/dev/null || true)
  if [ -n "$route_status" ] && jq -e --arg status "$route_status" \
    '(.model_switch.deny_statuses // []) | index($status) != null' \
    "$routing_file" >/dev/null 2>&1; then
    deny_reason="Model $to_model is marked $route_status in config/model-routing.json."
  elif ! jq -e --arg model "$to_model" \
    '.selection.preferred_models | index($model) != null' \
    "$routing_file" >/dev/null 2>&1; then
    deny_reason="Model $to_model is prohibited; only the configured Opus 5.5 and GPT-6.1 Sol routes are allowed."
  elif [ "$effort" != "xhigh" ]; then
    deny_reason="Model $to_model requires xhigh effort; reported effort is ${effort:-unknown}."
  fi
fi

if [ -n "$session_dir" ] && [ "$event" = "PostModelSwitch" ] && [ -n "$to_model" ]; then
  printf '%s\n' "$to_model" > "$session_dir/current-model" 2>/dev/null || true
elif [ -n "$session_dir" ] && [ -n "$from_model" ] && [ ! -s "$session_dir/current-model" ]; then
  printf '%s\n' "$from_model" > "$session_dir/current-model" 2>/dev/null || true
fi

if [ -n "$session" ] && [ "${HOOK_METRICS_DISABLED:-0}" != "1" ]; then
  metrics_dir="${HOOK_METRICS_DIR:-$HOME/.claude/hook-metrics}"
  if mkdir -p "$metrics_dir" 2>/dev/null; then
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
  fi
fi

if [ "$event" = "PreModelSwitch" ] && [ -n "$deny_reason" ]; then
  jq -cn --arg reason "$deny_reason" '{
    hookSpecificOutput: {
      hookEventName: "PreModelSwitch",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
fi

if [ "$event" = "PreModelSwitch" ] && [ -f "$routing_file" ]; then
  confirmation_usd=$(jq -r '.model_switch.warm_cache_confirmation_usd // empty' "$routing_file" 2>/dev/null || true)
  if [ -n "$confirmation_usd" ] && printf '%s' "$input" | jq -e --argjson threshold "$confirmation_usd" '
      .prompt_cache_warm == true
      and ((.estimated_cache_write_usd // null) | type == "number" and . >= $threshold)
      and (.source // "unknown") != "sdk"' >/dev/null 2>&1; then
    estimated_usd=$(printf '%s' "$input" | jq -r '.estimated_cache_write_usd')
    estimated_usd=$(printf '%.2f' "$estimated_usd")
    reason="Switching now forfeits a warm prompt cache and is estimated to write \$$estimated_usd of cache data. Continue?"
    case "$source" in
      picker)
        jq -cn --arg reason "$reason" '{
          hookSpecificOutput: {
            hookEventName: "PreModelSwitch",
            permissionDecision: "ask",
            permissionDecisionReason: $reason
          }
        }'
        exit 0
        ;;
      command)
        jq -cn --arg reason "$reason" '{systemMessage:$reason}'
        exit 0
        ;;
    esac
  fi
fi

if [ "$event" = "PostModelSwitch" ] && [ -n "$to_model" ]; then
  context="Active model changed from ${from_model:-unknown} to $to_model (source: $source). This supersedes earlier model-switch notices."
  if [ -n "$deny_reason" ]; then
    context="$context $deny_reason Select an approved model at xhigh before continuing."
  elif [ -n "$route_status" ]; then
    work_label="qualified work"
    [ "$route_status" = "eval-gated" ] && work_label="candidate work"
    context="$context Routing record: $route_status${route_work:+; $work_label: $route_work}."
  else
    context="$context No routing record exists for this model; do not infer a ban."
  fi
  context="$context Use /efficient-frontier to validate the active model against config/model-routing.json for the current lifecycle phase; preserve the current owner and delivery endpoint."
  if [ "$source" = "resume" ]; then
    context="$context If repository state is stale after resume, use /prime; otherwise do not re-prime."
  fi

  jq -cn --arg context "$context" '{
    hookSpecificOutput: {
      hookEventName: "PostModelSwitch",
      additionalContext: $context
    }
  }'
fi

exit 0
