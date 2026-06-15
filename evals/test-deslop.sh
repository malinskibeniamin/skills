# Evals for /deslop liability gate.

SKILL_DIR="$REPO_ROOT/deslop"
SKILL="$SKILL_DIR/SKILL.md"
REF="$SKILL_DIR/REFERENCE.md"

run_file_eval "$SKILL" "deslop skill exists"
run_content_eval "$SKILL" "Code is liability|code is liability" "deslop states code liability principle"
run_content_eval "$SKILL" "product value.*defensive.*test|test.*defensive.*product value" "deslop uses value/defensive/test admission gate"
run_content_eval "$SKILL" "/simplify" "deslop runs simplify under the hood"
run_content_eval "$SKILL" "commit.*push.*merge|push.*merge" "deslop blocks commit push merge when uncertain"
run_content_eval "$SKILL" "Delete.*Inline.*Justify|delete.*inline.*justify" "deslop has delete-inline-justify loop"
run_content_eval "$SKILL" "standard library|native platform|already-installed|one-line" "deslop checks reuse-first ladder before owning new code"
run_content_eval "$SKILL" "evals changed|matching evals|eval evidence" "deslop requires eval evidence for skill and harness changes"
run_content_eval "$SKILL" "RED.*GREEN|failing.*passing" "deslop preserves TDD evidence before commit push PR"
run_content_eval "$SKILL" "blocking finding|NEEDS_CHANGES|block" "deslop can block low-value changes"
run_content_eval "$SKILL" "REFERENCE.md" "deslop links reference"
run_content_eval "$REF" "Surface-area budget" "deslop reference defines surface-area budget"
run_content_eval "$REF" "Keep when.*product value|Keep when.*defensive|Keep when.*test" "deslop reference defines keep rules"
run_content_eval "$REF" "standard library|native platform|already-installed|one-line" "deslop reference documents reuse-first ladder"

run_content_eval "$REPO_ROOT/.claude/hooks/intent-detect.sh" "CODE-LIABILITY|Code is liability" "intent-detect injects liability reminder"
run_content_eval "$REPO_ROOT/.claude/hooks/intent-detect.sh" "/deslop" "intent-detect invokes deslop on code changes"
run_content_eval "$REPO_ROOT/.claude/hooks/intent-detect.sh" "REUSE-FIRST" "intent-detect injects reuse-first ladder"
run_content_eval "$REPO_ROOT/shared/intent-detect.sh" "/deslop" "shared intent-detect invokes deslop on code changes"
run_content_eval "$REPO_ROOT/shared/intent-detect.sh" "REUSE-FIRST" "shared intent-detect injects reuse-first ladder"
run_content_eval "$REPO_ROOT/agents/self-reviewer.md" "Code is liability|surface-area" "self-reviewer audits liability"
run_content_eval "$REPO_ROOT/agents/self-reviewer.md" "standard library|native platform|already-installed" "self-reviewer audits reuse-first alternatives"
run_content_eval "$REPO_ROOT/agents/code-reviewer.md" "low-value|surface-area|Code is liability" "code-reviewer blocks low-value sprawl"
run_content_eval "$REPO_ROOT/agents/code-reviewer.md" "standard library|native platform|already-installed" "code-reviewer audits reuse-first alternatives"
run_content_eval "$REPO_ROOT/ETHOS.md" "Code Is Liability" "ETHOS records code liability principle"

if jq -e '.skills[] | select(. == "./deslop/")' "$REPO_ROOT/.claude-plugin/plugin.json" >/dev/null 2>&1; then
  echo "  PASS  Claude plugin registers deslop"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Claude plugin registers deslop"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Claude plugin registers deslop"
fi

if jq -e '.skills[] | select(. == "./simplify/")' "$REPO_ROOT/.claude-plugin/plugin.json" >/dev/null 2>&1; then
  echo "  FAIL  Claude plugin does not register simplify shim"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Claude plugin still registers simplify shim"
else
  echo "  PASS  Claude plugin does not register simplify shim"
  PASS=$((PASS + 1))
fi
