# Acceptance contract for behavior-based testing, without mechanical quotas.

for pattern in \
  "coverage-summary.json" \
  "SOURCE CHANGED WITHOUT TEST CHANGE" \
  "NEW SOURCE WITHOUT TEST"; do
  if grep -Rq -- "$pattern" \
    "$REPO_ROOT/.claude/hooks/lifecycle-stop.sh" \
    "$REPO_ROOT/.claude/hooks/orchestration-stop.sh"; then
    echo "  FAIL  mechanical test gate removed: $pattern"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: mechanical test gate remains: $pattern"
  else
    echo "  PASS  mechanical test gate removed: $pattern"
    PASS=$((PASS + 1))
  fi
done

run_content_eval "$REPO_ROOT/exemplars/e2e.spec.ts" "test\\.step" \
  "structured test.step exemplar is preserved"
