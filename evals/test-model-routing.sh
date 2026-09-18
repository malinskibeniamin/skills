# Eval-backed model routing and Codex mechanics.

ROUTING="$REPO_ROOT/config/model-routing.json"

run_file_eval "$ROUTING" "model-routing config exists"
run_file_eval "$REPO_ROOT/codex/SKILL.md" "codex skill exists"
run_content_eval "$REPO_ROOT/CLAUDE.md" "config/model-routing.json" "ambient context points to routing data"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "config/model-routing.json" "efficient-frontier reads the routing source"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "context-ablation" "routing promotion is eval-backed"

if jq -e '.policy == "quality-first"
  and .quality_first.default.model == "gpt-6-astra"
  and .quality_first.default.effort == "high"
  and .quality_first.hard.model == "gpt-6-astra"
  and (.quality_first.hard.efforts | index("max"))
  and (.quality_first.ui_owners | index("gpt-6-astra"))
  and (.quality_first.ui_owners | index("claude-fable-5-1"))
  and .quality_first.ultra.requires_explicit_delegation
  and .models["gpt-6-astra"].status == "primary"
  and .models["gpt-6-astra"].starting_effort == "high"
  and ([.models | keys[] | select(startswith("gpt-"))] == ["gpt-6-astra"])
  and .models["claude-fable-5-1"].status == "quality-alternative"
  and .model_switch.deny_statuses == ["retired", "unsupported"]
  and .model_switch.warm_cache_confirmation_usd == 1
  and (.models | has("claude-fable-5") | not)
  and .selection.single_owner
  and (.selection.cross_family_review_for_non_trivial_pr | not)' "$ROUTING" >/dev/null; then
  echo "  PASS  routing config uses GPT-6 Astra as the only GPT route"
  PASS=$((PASS + 1))
else
  echo "  FAIL  routing config uses GPT-6 Astra as the only GPT route"
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
run_content_eval "$REPO_ROOT/codex/SKILL.md" 'model_reasoning_effort="high"' "codex gives an executable high override"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "max.*eval-backed|eval-backed.*max" "codex gates max on evidence"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Astra may own user-facing" "Astra can own visible work"
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
