# Eval-backed model routing and Codex mechanics.

ROUTING="$REPO_ROOT/config/model-routing.json"

run_file_eval "$ROUTING" "model-routing config exists"
run_file_eval "$REPO_ROOT/codex/SKILL.md" "codex skill exists"
run_content_eval "$REPO_ROOT/CLAUDE.md" "config/model-routing.json" "ambient context points to routing data"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "config/model-routing.json" "efficient-frontier reads the routing source"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "context-ablation" "routing promotion is eval-backed"

if jq -e '. as $routing | .policy == "quality-first"
  and .quality_first.default == {"model": "claude-opus-5-5", "effort": "xhigh"}
  and .quality_first.secondary.model == "gpt-6.1-sol"
  and .quality_first.secondary.effort == "xhigh"
  and .quality_first.hard.model == "claude-opus-5-5"
  and .quality_first.hard.efforts == ["xhigh"]
  and .quality_first.chores.model == "claude-opus-5-5"
  and .quality_first.chores.effort == "xhigh"
  and .quality_first.review.primary == {"model": "gpt-6.1-sol", "effort": "xhigh"}
  and .quality_first.review.secondary == {"model": "claude-opus-5-5", "effort": "xhigh"}
  and (.quality_first.review | has("escalation") | not)
  and .selection.preferred_models == ["claude-opus-5-5", "gpt-6.1-sol"]
  and ([.quality_first | .. | objects | select(has("model")) | .model]
    | all(. == "claude-opus-5-5" or . == "gpt-6.1-sol"))
  and .quality_first.ui_owners == ["claude-opus-5-5"]
  and .quality_first.ui_policy.min_taste == 8
  and (.quality_first.ui_policy | has("non_claude_fallback") | not)
  and ([.quality_first.ui_owners[] as $m | .models[$m].scores.taste >= 8] | all)
  and .efforts.never == ["max"]
  and ([del(.models[].score_evidence) | .. | strings | select(. == "max")] | length == 1)
  and .models["claude-opus-5-5"].status == "primary"
  and .models["claude-opus-5-5"].starting_effort == "xhigh"
  and .models["claude-opus-5-5"].scores.cost == null
  and .models["claude-opus-5-5"].score_evidence.cost == {"effort": "high", "score": 2, "status": "Historical high-effort rating; xhigh task cost is unmeasured."}
  and .models["gpt-6.1-sol"].status == "secondary"
  and .models["gpt-6.1-sol"].starting_effort == "xhigh"
  and (.models["gpt-6.1-sol"].work | index("review"))
  and ([.models[] | select(.status == "primary")] | length == 1)
  and ([.models | keys[] | select(startswith("gpt-"))] | sort == ["gpt-6-astra", "gpt-6-luna", "gpt-6.1-sol"])
  and (["gpt-6-astra", "claude-fable-5-1", "gpt-6-luna"]
    | all(. as $m | $routing.models[$m].status == "reserve"
      and $routing.models[$m].starting_effort == "high"
      and ($routing.models[$m].use | contains("only on explicit user request"))))
  and ([.models[] | .scores | has("cost") and has("intelligence") and has("speed") and has("taste") and has("allowance")] | all)
  and ([.models | to_entries[] | select(.value.scores.taste != null and .value.scores.taste < 8) | .key] | sort == ["gpt-6-luna"])
  and ([.models | to_entries[] | select(.key | startswith("claude-")) | .value.scores.allowance] | max) == .models["claude-opus-5-5"].scores.allowance
  and .models["claude-fable-5-1"].scores.allowance < .models["claude-opus-5-5"].scores.allowance
  and (.scoring.allowance | contains("$200"))
  and ([.models | to_entries[] | select(.key != "gpt-6-luna" and .key != "gpt-6.1-sol") | .value.scores.review] | all(type == "number"))
  and ([.models | to_entries[] | select(.value.scores.review != null)] | max_by(.value.scores.review) | .key) == "gpt-6-astra"
  and .quality_first.ultra.requires_explicit_delegation
  and .model_switch.deny_statuses == ["retired", "unsupported"]
  and .model_switch.warm_cache_confirmation_usd == 1
  and (.models | has("claude-fable-5") | not)
  and (.models | has("claude-opus-5") | not)
  and .selection.single_owner
  and (.selection.cross_family_review_for_non_trivial_pr | not)' "$ROUTING" >/dev/null; then
  echo "  PASS  owner-selected Opus and Sol xhigh are the only automatic routes"
  PASS=$((PASS + 1))
else
  echo "  FAIL  owner-selected Opus and Sol xhigh are the only automatic routes"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: owner-selected two-model routing"
fi

if jq -e 'has("review") | not' "$ROUTING" >/dev/null; then
  echo "  PASS  routing config does not encode a review panel"
  PASS=$((PASS + 1))
else
  echo "  FAIL  routing config does not encode a review panel"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: review panel remains in model routing"
fi

if jq -e '.models["gpt-6.1-sol"] as $sol
  | $sol.status == "secondary"
  and $sol.work == ["review", "implementation", "computer-use", "investigation"]
  and $sol.starting_effort == "xhigh"
  and $sol.scores == {"cost": null, "intelligence": 8, "speed": null, "taste": null, "review": null, "allowance": null}
  and $sol.score_evidence.measured == "2026-10-01"
  and $sol.score_evidence.source == "https://artificialanalysis.ai/models/releases/gpt-6-1-sol"
  and $sol.score_evidence.cost.effort == "medium"
  and $sol.score_evidence.cost.score == 6
  and $sol.score_evidence.cost.usd_per_task == 0.21
  and $sol.score_evidence.cost.min_usd_per_task == 0.03
  and $sol.score_evidence.cost.max_usd_per_task == 3.91
  and ($sol.score_evidence.cost as $cost
    | $sol.score_evidence.cost.score == ([1, ([10,
      (10 - 9 * (($cost.usd_per_task / $cost.min_usd_per_task) | log)
        / (($cost.max_usd_per_task / $cost.min_usd_per_task) | log) | floor)
    ] | min)] | max))
  and $sol.score_evidence.intelligence.effort == "max"
  and $sol.score_evidence.intelligence.index == 52
  and $sol.scores.intelligence == ((1 + 9 * (52 - 30) / (58 - 30)) | round)
  and ($sol.score_evidence.taste | contains("Owner prefers Opus 5.5 for UI"))
  and (.scoring.cost | contains("floor"))
  and (.scoring.intelligence | contains("round"))
  and (.sources | index($sol.score_evidence.source))
  and ($sol.effort_selection | contains("context-ablation"))
  and (.sources | index("https://developers.openai.com/api/docs/models/gpt-6.1-sol"))
  and .quality_first.secondary.model == "gpt-6.1-sol"
  and (.models | has("gpt-6-sol") | not)
  and ([.. | strings | select(contains("gpt-6-sol"))] | length == 0)
  and ($sol.unavailable | contains("claude-opus-5-5"))' "$ROUTING" >/dev/null; then
  echo "  PASS  GPT-6.1 Sol preserves historical measurements without mislabeling xhigh cost"
  PASS=$((PASS + 1))
else
  echo "  FAIL  GPT-6.1 Sol preserves historical measurements without mislabeling xhigh cost"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: GPT-6.1 Sol catalog entry"
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
run_content_eval "$REPO_ROOT/codex/SKILL.md" 'gpt-6.1-sol -c .model_reasoning_effort="xhigh"' "codex gives an executable Sol xhigh command"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "never .max." "codex never routes max effort"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "never .max." "efficient-frontier never routes max effort"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Codex models do not own user-facing" "codex leaves visible work to Claude"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Other models require an explicit user request" "codex has no automatic third-model fallback"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Review:.*Sol.*xhigh" "codex reviews with Sol xhigh"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "Sol .xhigh. reviews" "efficient-frontier routes PR review to Sol xhigh"
run_content_eval "$REPO_ROOT/agents/code-reviewer.md" "Sol .xhigh." "reviewer routing names Sol xhigh"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "taste >= 8" "efficient-frontier gates UI on taste"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "Opus 5.5 .xhigh." "efficient-frontier names the primary driver"
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
