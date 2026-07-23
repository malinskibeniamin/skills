#!/usr/bin/env bash
set -euo pipefail

snapshot="${CLAUDE_RATE_LIMIT_SNAPSHOT:-$HOME/.claude/rate-limits.json}"
now="${CLAUDE_USAGE_NOW:-$(date +%s)}"
max_age="${CLAUDE_RATE_LIMIT_MAX_AGE:-120}"
[[ "$now" =~ ^[0-9]+$ ]] || now=$(date +%s)
[[ "$max_age" =~ ^[0-9]+$ ]] || max_age=120

fallback() {
  jq -nc '{
    claude_enabled: false,
    reason: "missing_or_stale_claude_usage",
    codex_model: "gpt-5.6-sol",
    codex_effort: "xhigh"
  }'
}

if [[ ! -r "$snapshot" ]]; then
  fallback
  exit 0
fi

if ! profile=$(jq -ce --argjson now "$now" --argjson max_age "$max_age" '
  select((.captured_at | type) == "number")
  | select((.five_hour.used_percentage | type) == "number")
  | select((.seven_day.used_percentage | type) == "number")
  | select(.five_hour.used_percentage >= 0 and .five_hour.used_percentage <= 100)
  | select(.seven_day.used_percentage >= 0 and .seven_day.used_percentage <= 100)
  | select(($now - .captured_at) >= 0 and ($now - .captured_at) <= $max_age)
  | ([.five_hour.used_percentage, .seven_day.used_percentage] | max) as $usage
  | {
      claude_enabled: ($usage < 90),
      claude_usage_percentage: $usage,
      claude_model: (
        if $usage < 20 then "claude-fable-5"
        elif $usage < 75 then "claude-opus-4-8"
        elif $usage < 90 then "claude-sonnet-5"
        else null
        end
      ),
      claude_effort: (
        if $usage < 20 then "low"
        elif $usage < 50 then "high"
        elif $usage < 90 then "low"
        else null
        end
      ),
      reason: (if $usage >= 90 then "claude_usage_at_or_above_90" else null end),
      codex_model: "gpt-5.6-sol",
      codex_effort: "xhigh"
    }
' "$snapshot" 2>/dev/null); then
  fallback
  exit 0
fi

printf '%s\n' "$profile"
