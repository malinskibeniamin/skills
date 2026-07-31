# Eval-backed model routing and Codex mechanics.

ROUTING="$REPO_ROOT/config/model-routing.json"

run_file_eval "$ROUTING" "model-routing config exists"
run_file_eval "$REPO_ROOT/codex/SKILL.md" "codex skill exists"
run_content_eval "$REPO_ROOT/CLAUDE.md" "config/model-routing.json" "ambient context points to routing data"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "config/model-routing.json" "efficient-frontier reads the routing source"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "context-ablation" "routing promotion is eval-backed"

if jq -e '.policy == "quality-first"
  and .quality_first.default.model == "gpt-5.6-sol"
  and .quality_first.default.effort == "xhigh"
  and (.quality_first.hard.efforts | index("max"))
  and (.quality_first.ui_owners | index("gpt-5.6-sol"))
  and .quality_first.ultra.requires_explicit_delegation
  and .models["gpt-5.6-terra"].status == "eval-gated"
  and .models["gpt-5.6-luna"].status == "eval-gated"
  and .selection.single_owner
  and .selection.cross_family_review_for_non_trivial_pr' "$ROUTING" >/dev/null; then
  echo "  PASS  routing config encodes quality-first GPT-5.6 policy"
  PASS=$((PASS + 1))
else
  echo "  FAIL  routing config encodes quality-first GPT-5.6 policy"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: model-routing quality policy"
fi

if jq -e '.review.hat_owners["claude-family"] == ["product/spec", "complexity/value", "visual/design", "adversarial"]
  and .review.hat_owners["gpt-5.6-sol"] == ["engineering-standards", "resilience", "dogfood", "test/perf", "aip", "golang", "database/SQL"]
  and .review.claude_lane.max_calls_per_review == 1
  and .review.claude_lane.requires_explicit_delegation == true
  and .review.claude_lane.requires_fresh_capacity == true
  and .review.claude_lane.capacity_command == "bash stay-within-limits/select-review-profile.sh"
  and .review.claude_lane.missing_delegation_fallback == "gpt-5.6-sol"
  and .review.claude_lane.unknown_or_ineligible_fallback == "gpt-5.6-sol"
  and .review.claude_lane.ineligible_takeover.runtime == "codex"
  and .review.claude_lane.ineligible_takeover.model == "gpt-5.6-sol"
  and .review.claude_lane.ineligible_takeover.scope == "complete-review"
  and .review.claude_lane.ineligible_takeover.claude_calls == 0
  and .review.execution.batch_by_family == true
  and .review.execution.max_external_calls_per_family == 1
  and .review.trivial_owner == "gpt-5.6-sol"' "$ROUTING" >/dev/null; then
  echo "  PASS  review routing batches four Claude hats and seven Sol hats"
  PASS=$((PASS + 1))
else
  echo "  FAIL  review routing batches four Claude hats and seven Sol hats"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: review 4/7 family routing"
fi

run_content_eval "$REPO_ROOT/review/SKILL.md" "claude_eligible.*false.*entire review.*Codex" "ineligible Claude capacity triggers complete Codex takeover"
run_content_eval "$REPO_ROOT/review/SKILL.md" "every applicable hat.*dogfood.*synthesis.*final verdict" "Codex takeover owns the complete review contract"
run_content_eval "$REPO_ROOT/review/SKILL.md" "zero Claude calls" "Codex takeover makes no Claude calls"

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
run_content_eval "$REPO_ROOT/codex/SKILL.md" 'model_reasoning_effort="xhigh"' "codex gives an executable xhigh override"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "max.*eval-backed|eval-backed.*max" "codex gates max on evidence"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Sol may own user-facing" "Sol can own visible work"
run_content_eval "$REPO_ROOT/codex/REFERENCE.md" "ultra.*explicit delegation" "ultra requires delegation"
run_content_eval "$REPO_ROOT/codex/REFERENCE.md" "API-only" "API-only features are labeled"
run_content_eval "$REPO_ROOT/review/SKILL.md" "different-family" "review prefers a different family"
run_content_eval "$REPO_ROOT/go/SKILL.md" "clean-context Sol" "shipping has a truthful review fallback"
run_content_eval "$REPO_ROOT/agents/code-reviewer.md" "never starts a recursive model call" "reviewer leaves model dispatch to coordinator"

if grep -qE 'Terra and Luna never|Terra/Luna never' \
  "$REPO_ROOT/CLAUDE.md" "$REPO_ROOT/codex/SKILL.md" "$REPO_ROOT/go/SKILL.md"; then
  echo "  FAIL  eval-gated variants are hard-banned without evidence"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: model variant hard ban"
else
  echo "  PASS  eval-gated variants are not permanently hard-banned"
  PASS=$((PASS + 1))
fi

# No agent definition may use the retired cheap reviewer.
if grep -l "model: haiku" "$REPO_ROOT/agents/"*.md >/dev/null 2>&1; then
  echo "  FAIL  an agent definition still uses haiku"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: agent definition uses haiku"
else
  echo "  PASS  no agent definition uses haiku"
  PASS=$((PASS + 1))
fi
