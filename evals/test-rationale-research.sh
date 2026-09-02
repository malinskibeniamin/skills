# Evals for evidence-first design-rationale research.

RESEARCH="$REPO_ROOT/research/SKILL.md"
RATIONALE="$REPO_ROOT/research/DESIGN-RATIONALE.md"

run_file_eval "$RATIONALE" "research design-rationale reference exists"
run_content_eval "$RESEARCH" 'DESIGN-RATIONALE.md' \
  "research routes rationale archaeology through its existing owner"
run_content_eval "$RATIONALE" 'source control.*first|Start.*source control' \
  "rationale research anchors in code and source-control history"
run_content_eval "$RATIONALE" 'Issue tracker|Long-form docs|Real-time chat' \
  "rationale research expands into available decision records"
run_content_eval "$RATIONALE" 'observability|error tracking|product analytics' \
  "rationale research supports runtime and data-backed evidence"
run_content_eval "$RATIONALE" 'Direct evidence' \
  "rationale research separates direct evidence from interpretation"
run_content_eval "$RATIONALE" 'Inference' \
  "rationale research labels inferred conclusions"
run_content_eval "$RATIONALE" 'Contradictions|Unknowns' \
  "rationale research preserves conflicting and missing evidence"
run_content_eval "$RATIONALE" 'Sources consulted|coverage list' \
  "rationale research reports source coverage"
run_content_eval "$RATIONALE" 'explicit delegation|`/swarm`' \
  "rationale research keeps parallel agents opt-in"

if grep -Eqi 'spawn (an |the )?agent|mandatory (parallel|fan-out)' "$RATIONALE"; then
  echo "  FAIL  rationale research does not impose pstack orchestration"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: rationale research imposes agent orchestration"
else
  echo "  PASS  rationale research does not impose pstack orchestration"
  PASS=$((PASS + 1))
fi
