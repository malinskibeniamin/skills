# stay-within-limits: capacity evidence, separate from model routing.
LIMITS_DIR="$REPO_ROOT/stay-within-limits"
CAPTURE="$LIMITS_DIR/capture-rate-limits.sh"
SELECT="$LIMITS_DIR/select-review-profile.sh"

run_file_eval "$LIMITS_DIR/SKILL.md" "skill exists"
run_file_eval "$LIMITS_DIR/REFERENCE.md" "rate-limit setup reference exists"
run_executable_eval "$CAPTURE" "statusline quota capture is executable"
run_executable_eval "$SELECT" "capacity selector is executable"
run_content_eval "$LIMITS_DIR/SKILL.md" "explicit-use" "capacity check is explicit-use"
run_content_eval "$LIMITS_DIR/SKILL.md" "ccusage.*not subscription" "ccusage is rejected as quota evidence"
run_content_eval "$LIMITS_DIR/SKILL.md" "config/model-routing.json" "routing stays in the shared config"
run_content_eval "$LIMITS_DIR/REFERENCE.md" "never selects a model or effort" "capacity and routing stay separate"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "/stay-within-limits" "efficient-frontier owns the optional capacity gate"

_limits_tmp=$(mktemp -d)
_snapshot="$_limits_tmp/rate-limits.json"
printf '%s' '{"rate_limits":{"five_hour":{"used_percentage":12,"resets_at":2000},"seven_day":{"used_percentage":61,"resets_at":9000}}}' |
  CLAUDE_RATE_LIMIT_SNAPSHOT="$_snapshot" CLAUDE_USAGE_NOW=1000 "$CAPTURE"

if jq -e '.captured_at == 1000 and .five_hour.used_percentage == 12 and .seven_day.used_percentage == 61' "$_snapshot" >/dev/null; then
  echo "  PASS  capture persists exact quota windows"
  PASS=$((PASS + 1))
else
  echo "  FAIL  capture persists exact quota windows"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: quota capture output"
fi

_capacity=$(CLAUDE_RATE_LIMIT_SNAPSHOT="$_snapshot" CLAUDE_USAGE_NOW=1000 "$SELECT")
if jq -e '.claude_capacity == "available"
  and .claude_eligible == true
  and .usage_percentage == 61
  and .five_hour_percentage == 12
  and .seven_day_percentage == 61
  and (has("primary_model") | not)
  and (has("claude_model") | not)' <<<"$_capacity" >/dev/null; then
  echo "  PASS  fresh snapshot reports capacity without routing"
  PASS=$((PASS + 1))
else
  echo "  FAIL  fresh snapshot reports capacity without routing: $_capacity"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: quota capacity separation"
fi

jq -n '{captured_at:1000,five_hour:{used_percentage:96},seven_day:{used_percentage:20}}' >"$_snapshot"
_exhausted=$(CLAUDE_RATE_LIMIT_SNAPSHOT="$_snapshot" CLAUDE_USAGE_NOW=1000 "$SELECT")
if jq -e '.claude_capacity == "exhausted" and .claude_eligible == false and .reason == "claude_usage_above_95"' <<<"$_exhausted" >/dev/null; then
  echo "  PASS  exhausted capacity removes Claude"
  PASS=$((PASS + 1))
else
  echo "  FAIL  exhausted capacity removes Claude: $_exhausted"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: exhausted Claude capacity"
fi

jq -n '{captured_at:1,five_hour:{used_percentage:0},seven_day:{used_percentage:0}}' >"$_snapshot"
_unknown=$(CLAUDE_RATE_LIMIT_SNAPSHOT="$_snapshot" CLAUDE_USAGE_NOW=1000 CLAUDE_RATE_LIMIT_MAX_AGE=120 "$SELECT")
if jq -e '.claude_capacity == "unknown" and .claude_eligible == false and .reason == "missing_or_stale_claude_usage"' <<<"$_unknown" >/dev/null; then
  echo "  PASS  stale evidence remains unknown"
  PASS=$((PASS + 1))
else
  echo "  FAIL  stale evidence remains unknown: $_unknown"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: stale Claude capacity"
fi
rm -rf "$_limits_tmp"
