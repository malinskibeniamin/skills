#!/bin/bash
set -eo pipefail

# Enforce explicit routing policy before a switch, then hand the active model
# the current routing contract. Both events feed later hook metrics.
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
source=$(printf '%s' "$input" | jq -r '.source // "unknown"')
routing_file="${MODEL_ROUTING_FILE:-$(dirname "$0")/../../config/model-routing.json}"
route_status=""
route_work=""
if [ -n "$to_model" ] && [ -f "$routing_file" ]; then
  route_status=$(jq -r --arg model "$to_model" '.models[$model].status // empty' "$routing_file" 2>/dev/null || true)
  route_work=$(jq -r --arg model "$to_model" '.models[$model].work // [] | join(", ")' "$routing_file" 2>/dev/null || true)
fi

if [ "$event" = "PostModelSwitch" ] && [ -n "$to_model" ]; then
  printf '%s\n' "$to_model" > "$session_dir/current-model" 2>/dev/null || true
elif [ -n "$from_model" ] && [ ! -s "$session_dir/current-model" ]; then
  printf '%s\n' "$from_model" > "$session_dir/current-model" 2>/dev/null || true
fi

if [ "${HOOK_METRICS_DISABLED:-0}" != "1" ]; then
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

if [ "$event" = "PreModelSwitch" ] && [ -n "$route_status" ] \
  && jq -e --arg status "$route_status" \
    '(.model_switch.deny_statuses // []) | index($status) != null' \
    "$routing_file" >/dev/null 2>&1; then
  reason="Model $to_model is marked $route_status in config/model-routing.json."
  jq -cn --arg reason "$reason" '{
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
  if [ -n "$route_status" ]; then
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
