# stay-within-limits: quota-aware review and planning routing.
LIMITS_DIR="$REPO_ROOT/stay-within-limits"
CAPTURE="$LIMITS_DIR/capture-rate-limits.sh"
SELECT="$LIMITS_DIR/select-review-profile.sh"

run_file_eval "$LIMITS_DIR/SKILL.md" "skill exists"
run_file_eval "$LIMITS_DIR/REFERENCE.md" "rate-limit setup reference exists"
run_executable_eval "$CAPTURE" "statusline quota capture is executable"
run_executable_eval "$SELECT" "review profile selector is executable"
run_content_eval "$LIMITS_DIR/SKILL.md" "five_hour.*seven_day|5-hour.*7-day" "uses both Claude quota windows"
run_content_eval "$LIMITS_DIR/SKILL.md" "higher|maximum|max\\(" "routes from the higher quota usage"
run_content_eval "$LIMITS_DIR/SKILL.md" "<20%.*Fable low" "routes low-usage reviews to Fable low"
run_content_eval "$LIMITS_DIR/SKILL.md" "20-<50%.*Opus high" "routes 20-49% reviews to Opus high"
run_content_eval "$LIMITS_DIR/SKILL.md" "50-<75%.*Opus low" "routes 50-74% reviews to Opus low"
run_content_eval "$LIMITS_DIR/SKILL.md" "75-<90%.*Sonnet low" "routes 75-89% reviews to Sonnet low"
run_content_eval "$LIMITS_DIR/SKILL.md" "90%.*no Claude|no Claude.*90%" "disables Claude review at 90%"
run_content_eval "$LIMITS_DIR/SKILL.md" "missing|stale" "fails safely on unavailable quota data"
run_content_eval "$LIMITS_DIR/SKILL.md" "Sol.*xhigh" "always keeps the Sol xhigh review"
run_content_eval "$LIMITS_DIR/SKILL.md" "[Bb]efore (each|every).*wave" "re-checks usage before each wave"
run_content_eval "$LIMITS_DIR/SKILL.md" "Codex and Claude are separate budgets" "documents separate provider budgets"
run_content_eval "$LIMITS_DIR/SKILL.md" "ccusage" "names ccusage only to reject it as quota evidence"
run_content_eval "$LIMITS_DIR/SKILL.md" "subscription-quota evidence" "does not treat ccusage as quota evidence"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"./stay-within-limits/"' "registered in plugin"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "/stay-within-limits" "efficient-frontier delegates the usage loop"
run_content_eval "$REPO_ROOT/swarm/SKILL.md" "/stay-within-limits" "swarm gates lanes on the usage window"

if [ -x "$CAPTURE" ] && [ -x "$SELECT" ]; then
  _limits_tmp=$(mktemp -d)
  _snapshot="$_limits_tmp/rate-limits.json"
  printf '%s' '{"rate_limits":{"five_hour":{"used_percentage":12,"resets_at":2000},"seven_day":{"used_percentage":61,"resets_at":9000}}}' |
    CLAUDE_RATE_LIMIT_SNAPSHOT="$_snapshot" CLAUDE_USAGE_NOW=1000 "$CAPTURE"

  if jq -e '.captured_at == 1000 and .five_hour.used_percentage == 12 and .seven_day.used_percentage == 61' "$_snapshot" >/dev/null; then
    echo "  PASS  capture persists exact 5-hour and 7-day percentages"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  capture persists exact 5-hour and 7-day percentages"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: quota capture output"
  fi

  _assert_profile() {
    local five="$1" seven="$2" model="$3" effort="$4" enabled="$5"
    jq -n --argjson now 1000 --argjson five "$five" --argjson seven "$seven" \
      '{captured_at:$now,five_hour:{used_percentage:$five},seven_day:{used_percentage:$seven}}' >"$_snapshot"
    local profile
    profile=$(CLAUDE_RATE_LIMIT_SNAPSHOT="$_snapshot" CLAUDE_USAGE_NOW=1000 "$SELECT")
    if jq -e --arg model "$model" --arg effort "$effort" --argjson enabled "$enabled" \
      '.claude_enabled == $enabled and (.claude_model // "") == $model and (.claude_effort // "") == $effort and .codex_model == "gpt-5.6-sol" and .codex_effort == "xhigh"' \
      <<<"$profile" >/dev/null; then
      echo "  PASS  usage max($five,$seven) selects ${model:-no Claude}/${effort:-fallback}"
      PASS=$((PASS + 1))
    else
      echo "  FAIL  usage max($five,$seven) selects ${model:-no Claude}/${effort:-fallback}: $profile"
      FAIL=$((FAIL + 1))
      ERRORS="$ERRORS\n  FAIL: usage profile max($five,$seven)"
    fi
  }

  _assert_profile 0 19 "claude-fable-5" "low" true
  _assert_profile 20 5 "claude-opus-5" "high" true
  _assert_profile 49 50 "claude-opus-5" "low" true
  _assert_profile 75 3 "claude-sonnet-5" "low" true
  _assert_profile 89 90 "" "" false

  jq -n '{captured_at:1,five_hour:{used_percentage:0},seven_day:{used_percentage:0}}' >"$_snapshot"
  _stale_profile=$(CLAUDE_RATE_LIMIT_SNAPSHOT="$_snapshot" CLAUDE_USAGE_NOW=1000 CLAUDE_RATE_LIMIT_MAX_AGE=120 "$SELECT")
  if jq -e '.claude_enabled == false and .reason == "missing_or_stale_claude_usage" and .codex_effort == "xhigh"' <<<"$_stale_profile" >/dev/null; then
    echo "  PASS  stale quota snapshot falls back to Sol xhigh only"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  stale quota snapshot falls back to Sol xhigh only: $_stale_profile"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: stale quota fallback"
  fi
  rm -rf "$_limits_tmp"
fi
