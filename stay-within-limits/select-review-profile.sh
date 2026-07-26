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
    implementation_claude_model: null,
    implementation_claude_effort: null,
    feedback_claude_model: null,
    feedback_claude_effort: null,
    adversarial_codex_model: null,
    adversarial_codex_effort: null,
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
      claude_enabled: ($usage <= 95),
      claude_usage_percentage: $usage,
      claude_model: (
        if $usage <= 50 then "claude-fable-5"
        elif $usage <= 95 then "claude-opus-5"
        else null
        end
      ),
      claude_effort: (
        if $usage <= 20 then "high"
        elif $usage <= 35 then "medium"
        elif $usage <= 50 then "low"
        elif $usage <= 75 then "xhigh"
        elif $usage <= 90 then "medium"
        elif $usage <= 95 then "low"
        else null
        end
      ),
      implementation_claude_model: (if $usage <= 95 then "claude-opus-5" else null end),
      implementation_claude_effort: (if $usage <= 95 then "xhigh" else null end),
      feedback_claude_model: (if $usage <= 95 then "claude-opus-5" else null end),
      feedback_claude_effort: (if $usage <= 95 then "xhigh" else null end),
      adversarial_codex_model: (if $usage <= 95 then "gpt-5.6-sol" else null end),
      adversarial_codex_effort: (if $usage <= 95 then "high" else null end),
      reason: (if $usage > 95 then "claude_usage_above_95" else null end),
      codex_model: "gpt-5.6-sol",
      codex_effort: "xhigh"
    }
' "$snapshot" 2>/dev/null); then
  fallback
  exit 0
fi

printf '%s\n' "$profile"
