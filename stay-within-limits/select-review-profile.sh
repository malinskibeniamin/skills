#!/usr/bin/env bash
set -euo pipefail

# Capacity evidence only. Model and effort selection belong to
# config/model-routing.json and the behavioral ablation gate.

snapshot="${CLAUDE_RATE_LIMIT_SNAPSHOT:-$HOME/.claude/rate-limits.json}"
now="${CLAUDE_USAGE_NOW:-$(date +%s)}"
max_age="${CLAUDE_RATE_LIMIT_MAX_AGE:-120}"
[[ "$now" =~ ^[0-9]+$ ]] || now=$(date +%s)
[[ "$max_age" =~ ^[0-9]+$ ]] || max_age=120

unknown() {
  jq -nc '{
    claude_capacity: "unknown",
    claude_eligible: false,
    reason: "missing_or_stale_claude_usage"
  }'
}

if [[ ! -r "$snapshot" ]]; then
  unknown
  exit 0
fi

if ! capacity=$(jq -ce --argjson now "$now" --argjson max_age "$max_age" '
  select((.captured_at | type) == "number")
  | select((.five_hour.used_percentage | type) == "number")
  | select((.seven_day.used_percentage | type) == "number")
  | select(.five_hour.used_percentage >= 0 and .five_hour.used_percentage <= 100)
  | select(.seven_day.used_percentage >= 0 and .seven_day.used_percentage <= 100)
  | select(($now - .captured_at) >= 0 and ($now - .captured_at) <= $max_age)
  | ([.five_hour.used_percentage, .seven_day.used_percentage] | max) as $usage
  | {
      claude_capacity: (if $usage <= 95 then "available" else "exhausted" end),
      claude_eligible: ($usage <= 95),
      usage_percentage: $usage,
      five_hour_percentage: .five_hour.used_percentage,
      seven_day_percentage: .seven_day.used_percentage,
      reason: (if $usage > 95 then "claude_usage_above_95" else null end)
    }
' "$snapshot" 2>/dev/null); then
  unknown
  exit 0
fi

printf '%s\n' "$capacity"
