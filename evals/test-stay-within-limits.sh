# stay-within-limits: quota-aware taste, implementation, and review routing.
LIMITS_DIR="$REPO_ROOT/stay-within-limits"
CAPTURE="$LIMITS_DIR/capture-rate-limits.sh"
SELECT="$LIMITS_DIR/select-review-profile.sh"

run_file_eval "$LIMITS_DIR/SKILL.md" "skill exists"
run_file_eval "$LIMITS_DIR/REFERENCE.md" "rate-limit setup reference exists"
run_executable_eval "$CAPTURE" "statusline quota capture is executable"
run_executable_eval "$SELECT" "review profile selector is executable"
run_content_eval "$LIMITS_DIR/SKILL.md" "five_hour.*seven_day|5-hour.*7-day" "uses both Claude quota windows"
run_content_eval "$LIMITS_DIR/SKILL.md" "higher|maximum|max\\(" "routes from the higher quota usage"
run_content_eval "$LIMITS_DIR/SKILL.md" "0-20%.*Fable high" "routes 0-20% taste work to Fable high"
run_content_eval "$LIMITS_DIR/SKILL.md" "21-35%.*Fable medium" "routes 21-35% taste work to Fable medium"
run_content_eval "$LIMITS_DIR/SKILL.md" "36-50%.*Fable low" "routes 36-50% taste work to Fable low"
run_content_eval "$LIMITS_DIR/SKILL.md" "51-75%.*Opus 5 xhigh" "routes 51-75% taste work to Opus 5 xhigh"
run_content_eval "$LIMITS_DIR/SKILL.md" "76-90%.*Opus 5 medium" "routes 76-90% taste work to Opus 5 medium"
run_content_eval "$LIMITS_DIR/SKILL.md" "91-95%.*Opus 5 low" "routes 91-95% taste work to Opus 5 low"
run_content_eval "$LIMITS_DIR/SKILL.md" "96-100%.*no Claude|no Claude.*96-100%" "disables Claude above 95%"
run_content_eval "$LIMITS_DIR/SKILL.md" "missing|stale" "fails safely on unavailable quota data"
run_content_eval "$LIMITS_DIR/SKILL.md" "Opus 5 xhigh.*Sol xhigh|Sol xhigh.*Opus 5 xhigh" "pairs Opus 5 and Sol xhigh for implementation"
run_content_eval "$LIMITS_DIR/SKILL.md" "Sol high.*adversarial|adversarial.*Sol high" "uses Sol high for Opus adversarial review"
run_content_eval "$LIMITS_DIR/SKILL.md" "Sol xhigh only" "falls back to Sol xhigh only without Claude"
run_content_eval "$LIMITS_DIR/SKILL.md" "[Bb]efore (each|every).*wave" "re-checks usage before each wave"
run_content_eval "$LIMITS_DIR/SKILL.md" "Codex and Claude are separate budgets" "documents separate provider budgets"
run_content_eval "$LIMITS_DIR/SKILL.md" "ccusage" "names ccusage only to reject it as quota evidence"
run_content_eval "$LIMITS_DIR/SKILL.md" "subscription-quota evidence" "does not treat ccusage as quota evidence"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"./stay-within-limits/"' "registered in plugin"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "/stay-within-limits" "efficient-frontier delegates the usage loop"
run_content_eval "$REPO_ROOT/swarm/SKILL.md" "/stay-within-limits" "swarm gates lanes on the usage window"
run_content_eval "$REPO_ROOT/swarm/SKILL.md" "95%" "swarm stops Claude only above 95%"

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
      '.claude_enabled == $enabled
      and (.claude_model // "") == $model
      and (.claude_effort // "") == $effort
      and .codex_model == "gpt-5.6-sol"
      and .codex_effort == "xhigh"
      and (
        if $enabled then
          .implementation_claude_model == "claude-opus-5"
          and .implementation_claude_effort == "xhigh"
          and .adversarial_codex_model == "gpt-5.6-sol"
          and .adversarial_codex_effort == "high"
        else
          (.implementation_claude_model // "") == ""
          and (.implementation_claude_effort // "") == ""
          and (.adversarial_codex_model // "") == ""
          and (.adversarial_codex_effort // "") == ""
        end
      )' \
      <<<"$profile" >/dev/null; then
      echo "  PASS  usage max($five,$seven) selects ${model:-no Claude}/${effort:-fallback}"
      PASS=$((PASS + 1))
    else
      echo "  FAIL  usage max($five,$seven) selects ${model:-no Claude}/${effort:-fallback}: $profile"
      FAIL=$((FAIL + 1))
      ERRORS="$ERRORS\n  FAIL: usage profile max($five,$seven)"
    fi
  }

  _assert_profile 0 20 "claude-fable-5" "high" true
  _assert_profile 21 0 "claude-fable-5" "medium" true
  _assert_profile 0 35 "claude-fable-5" "medium" true
  _assert_profile 36 0 "claude-fable-5" "low" true
  _assert_profile 0 50 "claude-fable-5" "low" true
  _assert_profile 51 0 "claude-opus-5" "xhigh" true
  _assert_profile 0 75 "claude-opus-5" "xhigh" true
  _assert_profile 76 0 "claude-opus-5" "medium" true
  _assert_profile 0 90 "claude-opus-5" "medium" true
  _assert_profile 91 0 "claude-opus-5" "low" true
  _assert_profile 0 95 "claude-opus-5" "low" true
  _assert_profile 96 0 "" "" false

  jq -n '{captured_at:1,five_hour:{used_percentage:0},seven_day:{used_percentage:0}}' >"$_snapshot"
  _stale_profile=$(CLAUDE_RATE_LIMIT_SNAPSHOT="$_snapshot" CLAUDE_USAGE_NOW=1000 CLAUDE_RATE_LIMIT_MAX_AGE=120 "$SELECT")
  if jq -e '.claude_enabled == false
    and .reason == "missing_or_stale_claude_usage"
    and .codex_effort == "xhigh"
    and (.implementation_claude_model // "") == ""
    and (.adversarial_codex_model // "") == ""' <<<"$_stale_profile" >/dev/null; then
    echo "  PASS  stale quota snapshot falls back to Sol xhigh only"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  stale quota snapshot falls back to Sol xhigh only: $_stale_profile"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: stale quota fallback"
  fi
  rm -rf "$_limits_tmp"
fi
