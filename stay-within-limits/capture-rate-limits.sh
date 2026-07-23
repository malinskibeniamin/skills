#!/usr/bin/env bash
set -euo pipefail

snapshot="${CLAUDE_RATE_LIMIT_SNAPSHOT:-$HOME/.claude/rate-limits.json}"
now="${CLAUDE_USAGE_NOW:-$(date +%s)}"
[[ "$now" =~ ^[0-9]+$ ]] || now=$(date +%s)
input=$(cat)

if ! payload=$(jq -ce --argjson captured_at "$now" '
  .rate_limits as $limits
  | select(($limits.five_hour.used_percentage | type) == "number")
  | select(($limits.seven_day.used_percentage | type) == "number")
  | select($limits.five_hour.used_percentage >= 0 and $limits.five_hour.used_percentage <= 100)
  | select($limits.seven_day.used_percentage >= 0 and $limits.seven_day.used_percentage <= 100)
  | {
      captured_at: $captured_at,
      five_hour: {
        used_percentage: $limits.five_hour.used_percentage,
        resets_at: ($limits.five_hour.resets_at // null)
      },
      seven_day: {
        used_percentage: $limits.seven_day.used_percentage,
        resets_at: ($limits.seven_day.resets_at // null)
      }
    }
' <<<"$input" 2>/dev/null); then
  exit 0
fi

snapshot_dir=$(dirname "$snapshot")
mkdir -p "$snapshot_dir"
tmp=$(mktemp "${snapshot}.tmp.XXXXXX")
trap 'rm -f "$tmp"' EXIT
printf '%s\n' "$payload" >"$tmp"
chmod 600 "$tmp"
mv "$tmp" "$snapshot"
trap - EXIT
