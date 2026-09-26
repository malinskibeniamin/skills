# Eval-backed model routing and Codex mechanics.

ROUTING="$REPO_ROOT/config/model-routing.json"

run_file_eval "$ROUTING" "model-routing config exists"
run_file_eval "$REPO_ROOT/codex/SKILL.md" "codex skill exists"
run_content_eval "$REPO_ROOT/CLAUDE.md" "config/model-routing.json" "ambient context points to routing data"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "config/model-routing.json" "efficient-frontier reads the routing source"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "context-ablation" "routing promotion is eval-backed"

if jq -e '.policy == "quality-first"
  and .quality_first.default.model == "claude-opus-5-5"
  and .quality_first.default.effort == "high"
  and .quality_first.secondary.model == "gpt-6-sol"
  and .quality_first.secondary.effort == "medium"
  and .quality_first.hard.model == "claude-opus-5-5"
  and .quality_first.hard.efforts == ["xhigh"]
  and .efforts.never == ["max"]
  and ([.. | strings | select(. == "max")] | length == 1)
  and .quality_first.ui_owners == ["claude-opus-5-5", "claude-fable-5-1"]
  and .quality_first.ui_policy.min_taste == 8
  and .quality_first.ui_policy.non_claude_fallback == "gpt-6-astra"
  and ([.quality_first.ui_owners[] as $m | .models[$m].scores.taste >= 8] | all)
  and ([.models | to_entries[] | select(.value.scores.taste < 8) | .key] | sort == ["gpt-6-luna", "gpt-6-sol"])
  and ([.models[] | .scores | has("cost") and has("intelligence") and has("speed") and has("taste")] | all)
  and ([.models | to_entries[] | select(.key != "gpt-6-luna") | .value.scores.review] | all(type == "number"))
  and ([.models | to_entries[] | select(.value.scores.review != null)] | max_by(.value.scores.review) | .key) == "gpt-6-astra"
  and .quality_first.review.primary == {"model": "gpt-6-astra", "effort": "high"}
  and .quality_first.review.secondary == {"model": "claude-opus-5-5", "effort": "high"}
  and .quality_first.review.escalation.effort == "xhigh"
  and .quality_first.review.escalation.min_codex_remaining_pct == 50
  and (.models["gpt-6-sol"].work | index("review") | not)
  and (.models["gpt-6-astra"].work | index("review"))
  and .quality_first.ultra.requires_explicit_delegation
  and .models["claude-opus-5-5"].status == "primary"
  and .models["claude-opus-5-5"].starting_effort == "high"
  and .models["gpt-6-sol"].status == "secondary"
  and .models["gpt-6-sol"].starting_effort == "medium"
  and ([.models[] | select(.status == "primary")] | length == 1)
  and ([.models | keys[] | select(startswith("gpt-"))] | sort == ["gpt-6-astra", "gpt-6-luna", "gpt-6-sol"])
  and .models["gpt-6-luna"].status == "utility"
  and (.models["gpt-6-luna"].work | index("chores"))
  and .models["gpt-6-astra"].status == "quality-alternative"
  and .models["claude-fable-5-1"].status == "reserve"
  and .models["claude-fable-5-1"].starting_effort == "high"
  and .model_switch.deny_statuses == ["retired", "unsupported"]
  and .model_switch.warm_cache_confirmation_usd == 1
  and (.models | has("claude-fable-5") | not)
  and (.models | has("claude-opus-5") | not)
  and .selection.single_owner
  and (.selection.cross_family_review_for_non_trivial_pr | not)' "$ROUTING" >/dev/null; then
  echo "  PASS  routing config drives Opus 5.5 high, then GPT-6 Sol medium, with Claude-only UI"
  PASS=$((PASS + 1))
else
  echo "  FAIL  routing config drives Opus 5.5 high, then GPT-6 Sol medium, with Claude-only UI"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: model-routing quality policy"
fi

if jq -e 'has("review") | not' "$ROUTING" >/dev/null; then
  echo "  PASS  routing config does not encode a review panel"
  PASS=$((PASS + 1))
else
  echo "  FAIL  routing config does not encode a review panel"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: review panel remains in model routing"
fi

run_content_eval "$REPO_ROOT/review/SKILL.md" "do not add automatic agents" "review keeps one owner"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "explicitly authorizes a different-family pass" "cross-family work requires user authorization"

if ! grep -qE '1/10/9|5/8/9|8/9/6|Rank cost/intel/taste' \
  "$REPO_ROOT/CLAUDE.md" "$REPO_ROOT/efficient-frontier/SKILL.md"; then
  echo "  PASS  routing omits subjective score tables"
  PASS=$((PASS + 1))
else
  echo "  FAIL  routing omits subjective score tables"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: subjective model scores remain"
fi

run_content_eval "$REPO_ROOT/codex/SKILL.md" "codex exec" "codex skill uses codex exec"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "-s read-only" "codex documents read-only mode"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "self-contained" "codex requires self-contained prompts"
run_content_eval "$REPO_ROOT/codex/SKILL.md" 'gpt-6-sol -c .model_reasoning_effort="medium"' "codex gives an executable Sol medium command"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "never .max." "codex never routes max effort"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "never .max." "efficient-frontier never routes max effort"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Codex models do not own user-facing" "codex leaves visible work to Claude"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "gpt-6-luna" "codex routes chores to Luna"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Review:.*Astra" "codex reviews with Astra"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "Astra .high. reviews" "efficient-frontier routes PR review to Astra"
run_content_eval "$REPO_ROOT/agents/code-reviewer.md" "Astra" "reviewer routing names Astra"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "taste >= 8" "efficient-frontier gates UI on taste"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "Opus 5.5 .high." "efficient-frontier names the primary driver"
run_content_eval "$REPO_ROOT/codex/REFERENCE.md" "ultra.*explicit delegation" "ultra requires delegation"
run_content_eval "$REPO_ROOT/codex/REFERENCE.md" "API-only" "API-only features are labeled"
run_content_eval "$REPO_ROOT/review/SKILL.md" "inspect -> verify -> classify -> synthesize" "review stays with one evidence loop"
run_content_eval "$REPO_ROOT/go/SKILL.md" "different model.*explicit user authorization" "shipping does not silently change models"
run_content_eval "$REPO_ROOT/agents/code-reviewer.md" "never starts a recursive model call" "reviewer leaves model dispatch to coordinator"

# No agent definition may use the retired cheap reviewer.
if grep -l "model: haiku" "$REPO_ROOT/agents/"*.md >/dev/null 2>&1; then
  echo "  FAIL  an agent definition still uses haiku"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: agent definition uses haiku"
else
  echo "  PASS  no agent definition uses haiku"
  PASS=$((PASS + 1))
fi
