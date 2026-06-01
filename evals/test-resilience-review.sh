# Evals for resilience-review resilience skill + lifecycle/hook wiring.

SKILL_DIR="$REPO_ROOT/resilience-review"
HOOK="$REPO_ROOT/.claude/hooks/resilience-review-nudge.sh"
INTENT_SCRIPT="$REPO_ROOT/shared/intent-detect.sh"

run_file_eval "$SKILL_DIR/SKILL.md" "resilience-review SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "resilience-review REFERENCE.md exists"
if [ ! -e "$SKILL_DIR/EXAMPLES.md" ]; then echo "  PASS  examples folded into REFERENCE.md"; PASS=$((PASS+1)); else echo "  FAIL  EXAMPLES.md should be folded into REFERENCE.md"; FAIL=$((FAIL+1)); ERRORS="$ERRORS\n  FAIL: EXAMPLES.md should be folded into REFERENCE.md"; fi
run_content_eval "$SKILL_DIR/SKILL.md" "^name: resilience-review" "resilience-review has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "description has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "resilience" "skill is resilience-focused"
run_content_eval "$SKILL_DIR/SKILL.md" "Failure matrix" "skill outputs failure matrix"
run_content_eval "$SKILL_DIR/SKILL.md" "Finding queue" "skill outputs finding queue"
run_content_eval "$SKILL_DIR/SKILL.md" "/diagnose.*(/tdd|TDD).*/visual-review" "skill chains diagnose tdd visual-review"
if grep -RqiE "defensive check|defensive-check" "$SKILL_DIR"; then echo "  FAIL  old defensive-check naming removed"; FAIL=$((FAIL+1)); ERRORS="$ERRORS\n  FAIL: old defensive-check naming removed"; else echo "  PASS  old defensive-check naming removed"; PASS=$((PASS+1)); fi
run_content_eval "$SKILL_DIR/SKILL.md" "PASS \| NEEDS_GUARDS \| BLOCKED" "skill has verdict contract"
run_content_eval "$SKILL_DIR/SKILL.md" "REFERENCE.md" "skill links reference"
if ! grep -q "EXAMPLES.md" "$SKILL_DIR/SKILL.md"; then echo "  PASS  skill has one-level reference link only"; PASS=$((PASS+1)); else echo "  FAIL  skill should not link EXAMPLES.md"; FAIL=$((FAIL+1)); ERRORS="$ERRORS\n  FAIL: skill should not link EXAMPLES.md"; fi

for path in "$SKILL_DIR/SKILL.md:50" "$SKILL_DIR/REFERENCE.md:90" "$HOOK:50"; do
  file=${path%:*}; max=${path#*:}; lines=$(wc -l < "$file" 2>/dev/null | tr -d ' ' || echo 999)
  if [ "$lines" -le "$max" ]; then echo "  PASS  ${file#$REPO_ROOT/} compact ($lines <= $max)"; PASS=$((PASS+1)); else echo "  FAIL  ${file#$REPO_ROOT/} too verbose ($lines > $max)"; FAIL=$((FAIL+1)); ERRORS="$ERRORS\n  FAIL: ${file#$REPO_ROOT/} too verbose"; fi
done

if [ ! -e "$REPO_ROOT/agents/resilience-reviewer.md" ]; then echo "  PASS  no resilience-reviewer agent"; PASS=$((PASS+1)); else echo "  FAIL  resilience-reviewer agent should not exist"; FAIL=$((FAIL+1)); ERRORS="$ERRORS\n  FAIL: resilience-reviewer exists"; fi
if ! grep -q "resilience-reviewer" "$REPO_ROOT/.claude-plugin/plugin.json"; then echo "  PASS  plugin does not register resilience-reviewer"; PASS=$((PASS+1)); else echo "  FAIL  plugin registers resilience-reviewer"; FAIL=$((FAIL+1)); ERRORS="$ERRORS\n  FAIL: resilience-reviewer registered"; fi

run_content_eval "$SKILL_DIR/REFERENCE.md" "Murphy" "reference frames Murphy law"
run_content_eval "$SKILL_DIR/REFERENCE.md" "empty.*null.*duplicate.*stale" "reference probes unhappy path values"
run_content_eval "$SKILL_DIR/REFERENCE.md" "user.*wrong|wrong.*user" "reference probes user mistakes"
run_content_eval "$SKILL_DIR/REFERENCE.md" "should not be allowed|prevent.*block.*recover" "reference states prevent/block/recover rule"
run_content_eval "$SKILL_DIR/REFERENCE.md" "/diagnose.*feedback loop" "reference sends findings to diagnose"
run_content_eval "$SKILL_DIR/REFERENCE.md" "/tdd.*RED" "reference sends findings to TDD RED tests"
run_content_eval "$SKILL_DIR/REFERENCE.md" "/visual-review" "reference finishes with visual review"
run_content_eval "$SKILL_DIR/REFERENCE.md" "loading.*empty.*error.*success" "reference covers UI states"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Precondition.*Postcondition.*Fallback" "reference covers checks and fallback"
run_content_eval "$SKILL_DIR/REFERENCE.md" "observability" "reference covers observability"
run_content_eval "$SKILL_DIR/REFERENCE.md" "## Examples" "reference contains examples"
run_content_eval "$SKILL_DIR/REFERENCE.md" "form validation" "examples cover form validation"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Missing required fields" "examples cover missing fields"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Stale enabled button" "examples cover disabled button edge"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Diagnose" "examples show diagnose handoff"
run_content_eval "$SKILL_DIR/REFERENCE.md" "TDD" "examples show TDD conversion"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Visual review" "examples show visual review validation"
run_content_eval "$SKILL_DIR/REFERENCE.md" "partial outage" "examples cover partial outage"
run_content_eval "$SKILL_DIR/REFERENCE.md" "double submit" "examples cover double submit"

run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "/resilience-review" "development-lifecycle wires resilience-review"
run_content_eval "$REPO_ROOT/development-lifecycle/REFERENCE.md" "Resilience Review" "lifecycle reference documents Resilience Review"
run_content_eval "$REPO_ROOT/development-lifecycle/REFERENCE.md" "/diagnose.*/tdd.*/visual-review" "lifecycle chains diagnose tdd visual-review"
run_content_eval "$REPO_ROOT/tdd/SKILL.md" "resilience-review" "tdd consumes resilience-review findings"
run_content_eval "$REPO_ROOT/go/SKILL.md" "Resilience Review" "go requires resilience review evidence"
run_content_eval "$REPO_ROOT/go/REFERENCE.md" "Resilience Review Evidence" "go reference documents evidence"
run_content_eval "$REPO_ROOT/go/REFERENCE.md" "Finding queue" "go asks for finding queue"
run_content_eval "$REPO_ROOT/agents/self-reviewer.md" "Resilience Review Evidence" "self-reviewer checks evidence"
run_content_eval "$REPO_ROOT/agents/code-reviewer.md" "Resilience Review Evidence" "code-reviewer checks evidence"
run_content_eval "$REPO_ROOT/agents/self-reviewer.md" "Finding queue" "self-reviewer checks finding queue"
run_content_eval "$REPO_ROOT/agents/code-reviewer.md" "Finding queue" "code-reviewer checks finding queue"

run_file_eval "$HOOK" "resilience-review nudge hook exists"
run_executable_eval "$HOOK" "resilience-review nudge hook executable"
run_content_eval "$REPO_ROOT/skill-manifest.json" "resilience-review-nudge.sh" "manifest wires hook"
run_content_eval "$REPO_ROOT/.claude/settings.json" "resilience-review-nudge.sh" "settings include hook"
run_content_eval "$REPO_ROOT/hooks/hooks.json" "resilience-review-nudge.sh" "plugin hooks include hook"

_tmpdir=$(mktemp -d); _tmpfile="$_tmpdir/CreateForm.tsx"; echo 'export function CreateForm(){return <form><button>Save</button></form>}' > "$_tmpfile"
run_hook_eval "$HOOK" "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$_tmpfile\",\"content\":\"export function CreateForm(){return <form onSubmit={handleSubmit}><button>Save</button></form>}\"}}" 0 "hook nudges on form submit" "/resilience-review"
rm -rf "$_tmpdir"

_tmpdir=$(mktemp -d); _tmpfile="$_tmpdir/safe.ts"; echo 'export const sum=(a:number,b:number)=>a+b' > "$_tmpfile"
_no_risk=$(mktemp); echo "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$_tmpfile\",\"content\":\"export const sum=(a:number,b:number)=>a+b\"}}" | "$HOOK" 2>"$_no_risk" || true
if [ -s "$_no_risk" ]; then echo "  FAIL  hook noisy on pure helper"; FAIL=$((FAIL+1)); ERRORS="$ERRORS\n  FAIL: hook noisy on pure helper"; else echo "  PASS  hook quiet on pure helper"; PASS=$((PASS+1)); fi
rm -rf "$_tmpdir" "$_no_risk"

run_hook_eval "$INTENT_SCRIPT" '{"hook_event_name":"UserPromptSubmit","prompt":"add a form with async validation and error handling"}' 0 "intent-detect nudges resilience-review" "/resilience-review"
run_content_eval "$REPO_ROOT/README.md" "/resilience-review" "README documents resilience-review"
