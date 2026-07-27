# Evals for resilience-review resilience skill + lifecycle/hook wiring.

SKILL_DIR="$REPO_ROOT/resilience-review"
INTENT_SCRIPT="$REPO_ROOT/shared/intent-detect.sh"

run_file_eval "$SKILL_DIR/SKILL.md" "resilience-review SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "resilience-review REFERENCE.md exists"
if [ ! -e "$SKILL_DIR/EXAMPLES.md" ]; then echo "  PASS  examples folded into REFERENCE.md"; PASS=$((PASS+1)); else echo "  FAIL  EXAMPLES.md should be folded into REFERENCE.md"; FAIL=$((FAIL+1)); ERRORS="$ERRORS\n  FAIL: EXAMPLES.md should be folded into REFERENCE.md"; fi
run_content_eval "$SKILL_DIR/SKILL.md" "^name: resilience-review" "resilience-review has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "credible failure" "description has evidence-based trigger"
run_content_eval "$SKILL_DIR/SKILL.md" "Credible findings" "skill outputs ranked findings"
run_content_eval "$SKILL_DIR/SKILL.md" "No evidence means no finding" "skill rejects hypothetical findings"
run_content_eval "$SKILL_DIR/SKILL.md" "/diagnosing-bugs" "skill verifies real defects"
run_content_eval "$SKILL_DIR/SKILL.md" "one RED regression test" "skill creates one regression test"
run_content_eval "$SKILL_DIR/SKILL.md" "/visual-review" "skill uses visual review for recovery UI"
if grep -RqiE "defensive check|defensive-check" "$SKILL_DIR"; then echo "  FAIL  old defensive-check naming removed"; FAIL=$((FAIL+1)); ERRORS="$ERRORS\n  FAIL: old defensive-check naming removed"; else echo "  PASS  old defensive-check naming removed"; PASS=$((PASS+1)); fi
run_content_eval "$SKILL_DIR/SKILL.md" "PASS \| NEEDS_GUARDS \| BLOCKED" "skill has verdict contract"
run_content_eval "$SKILL_DIR/SKILL.md" "REFERENCE.md" "skill links reference"
if ! grep -q "EXAMPLES.md" "$SKILL_DIR/SKILL.md"; then echo "  PASS  skill has one-level reference link only"; PASS=$((PASS+1)); else echo "  FAIL  skill should not link EXAMPLES.md"; FAIL=$((FAIL+1)); ERRORS="$ERRORS\n  FAIL: skill should not link EXAMPLES.md"; fi

for path in "$SKILL_DIR/SKILL.md:50" "$SKILL_DIR/REFERENCE.md:90"; do
  file=${path%:*}; max=${path#*:}; lines=$(wc -l < "$file" 2>/dev/null | tr -d ' ' || echo 999)
  if [ "$lines" -le "$max" ]; then echo "  PASS  ${file#$REPO_ROOT/} compact ($lines <= $max)"; PASS=$((PASS+1)); else echo "  FAIL  ${file#$REPO_ROOT/} too verbose ($lines > $max)"; FAIL=$((FAIL+1)); ERRORS="$ERRORS\n  FAIL: ${file#$REPO_ROOT/} too verbose"; fi
done

if [ ! -e "$REPO_ROOT/agents/resilience-reviewer.md" ]; then echo "  PASS  no resilience-reviewer agent"; PASS=$((PASS+1)); else echo "  FAIL  resilience-reviewer agent should not exist"; FAIL=$((FAIL+1)); ERRORS="$ERRORS\n  FAIL: resilience-reviewer exists"; fi
if ! grep -q "resilience-reviewer" "$REPO_ROOT/.claude-plugin/plugin.json"; then echo "  PASS  plugin does not register resilience-reviewer"; PASS=$((PASS+1)); else echo "  FAIL  plugin registers resilience-reviewer"; FAIL=$((FAIL+1)); ERRORS="$ERRORS\n  FAIL: resilience-reviewer registered"; fi

run_content_eval "$SKILL_DIR/REFERENCE.md" "Murphy" "reference frames Murphy law"
run_content_eval "$SKILL_DIR/REFERENCE.md" "ranked by evidence" "reference ranks risks by evidence"
run_content_eval "$SKILL_DIR/REFERENCE.md" "empty.*null.*duplicate.*stale" "reference probes unhappy path values"
run_content_eval "$SKILL_DIR/REFERENCE.md" "/diagnosing-bugs.*feedback loop" "reference sends findings to diagnose"
run_content_eval "$SKILL_DIR/REFERENCE.md" "/tdd.*RED" "reference sends findings to TDD RED tests"
run_content_eval "$SKILL_DIR/REFERENCE.md" "/visual-review" "reference finishes with visual review"
run_content_eval "$SKILL_DIR/REFERENCE.md" "loading.*empty.*error.*success" "reference covers UI states"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Precondition" "reference covers preconditions"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Fallback" "reference covers fallback"
run_content_eval "$SKILL_DIR/REFERENCE.md" "[Oo]bservability" "reference covers observability"
run_content_eval "$SKILL_DIR/REFERENCE.md" "## Examples" "reference contains examples"
run_content_eval "$SKILL_DIR/REFERENCE.md" "form validation" "examples cover form validation"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Missing required fields" "examples cover missing fields"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Stale enabled button" "examples cover disabled button edge"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Diagnose" "examples show diagnose handoff"
run_content_eval "$SKILL_DIR/REFERENCE.md" "TDD" "examples show TDD conversion"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Visual review" "examples show visual review validation"
run_content_eval "$SKILL_DIR/REFERENCE.md" "partial outage" "examples cover partial outage"
run_content_eval "$SKILL_DIR/REFERENCE.md" "double submit" "examples cover double submit"
run_content_eval "$SKILL_DIR/REFERENCE.md" "registered array.*boolean.*useFieldArray|useFieldArray.*registered array.*boolean" "reference covers dirtyFields shape variants"
run_content_eval "$SKILL_DIR/REFERENCE.md" "stale async validation" "reference probes stale validation results"
run_content_eval "$SKILL_DIR/REFERENCE.md" "[Dd]ependent-field cleanup" "reference probes dependent-field cleanup"
run_content_eval "$SKILL_DIR/REFERENCE.md" "criteriaMode.*all|all validation errors" "reference probes all-errors rendering"

run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "/resilience-review" "development-lifecycle wires resilience-review"
run_content_eval "$REPO_ROOT/development-lifecycle/REFERENCE.md" "Resilience Review" "lifecycle reference documents Resilience Review"
run_content_eval "$REPO_ROOT/go/SKILL.md" "Resilience Review" "go requires resilience review evidence"
run_content_eval "$REPO_ROOT/go/REFERENCE.md" "Resilience Review Evidence" "go reference documents evidence"
run_content_eval "$REPO_ROOT/go/REFERENCE.md" "smallest guard" "go asks for minimal evidence"
run_content_eval "$REPO_ROOT/agents/self-reviewer.md" "review-evidence.md" "self-reviewer applies shared evidence reference"
run_content_eval "$REPO_ROOT/agents/code-reviewer.md" "review-evidence.md" "code-reviewer applies shared evidence reference"
run_content_eval "$REPO_ROOT/agents/references/review-evidence.md" "credible failure" "shared evidence reference requires credible risk"


# The per-edit resilience nudge hook was retired; the lifecycle (/go phase 4b)
# owns the resilience-review trigger now. Guard: no ghost hook resurrects.
if ls "$REPO_ROOT/.claude/hooks/"*resilience* >/dev/null 2>&1; then
  echo "  FAIL  a resilience hook reappeared -- lifecycle owns the trigger"
  FAIL=$((FAIL+1)); ERRORS="$ERRORS\n  FAIL: resilience hook resurrected"
else
  echo "  PASS  no resilience hook (lifecycle owns the trigger)"
  PASS=$((PASS+1))
fi

run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "/resilience-review" "generated catalog documents resilience-review"
