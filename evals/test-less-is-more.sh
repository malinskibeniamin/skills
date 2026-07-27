# Acceptance contract for less-is-more authoring.

run_content_eval "$REPO_ROOT/ETHOS.md" "Less Code, More Meaning" \
  "ETHOS makes less code more meaning a permanent principle"
run_content_eval "$REPO_ROOT/ETHOS.md" "Deletion is delivery|deletion is delivery" \
  "ETHOS treats deletion as delivery"
run_content_eval "$REPO_ROOT/CONTEXT.md" "Semantic density" \
  "domain glossary defines semantic density"
run_content_eval "$REPO_ROOT/CONTEXT.md" "Credible risk" \
  "domain glossary defines credible risk"
run_content_eval "$REPO_ROOT/CONTEXT.md" "Demonstrated scale" \
  "domain glossary defines demonstrated scale"

run_content_eval "$REPO_ROOT/CLAUDE.md" "smallest obvious|smallest clear" \
  "project rules require the smallest clear design from the start"
run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "demonstrated scale|current scale" \
  "lifecycle designs for known scale"
run_content_eval "$REPO_ROOT/tdd/SKILL.md" "meaningful behavior|meaningful contract" \
  "TDD protects meaningful behavior"
run_content_eval "$REPO_ROOT/deslop/SKILL.md" "[Ff]allback" \
  "deslop is an explicit fallback"
run_content_eval "$REPO_ROOT/deslop/SKILL.md" "[Ss]emantic density" \
  "deslop advocates semantic density"
run_content_eval "$REPO_ROOT/deslop/SKILL.md" 'bundled `/simplify`' \
  "deslop keeps Claude built-in simplify available on demand"
run_content_eval "$REPO_ROOT/review/SKILL.md" "semantic density" \
  "review evaluates semantic density directly"
run_content_eval "$REPO_ROOT/agents/plan-engineering-hat.md" "demonstrated scale|current scale" \
  "engineering plans against demonstrated scale"

for file in \
  "$REPO_ROOT/CLAUDE.md" \
  "$REPO_ROOT/development-lifecycle/SKILL.md" \
  "$REPO_ROOT/go/SKILL.md"; do
  if grep -qE '/deslop (full|write)|Run `/deslop`|`/simplify` -> `/deslop`' "$file"; then
    echo "  FAIL  $(basename "$file") does not require cleanup ceremony"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $(basename "$file") requires cleanup ceremony"
  else
    echo "  PASS  $(basename "$file") does not require cleanup ceremony"
    PASS=$((PASS + 1))
  fi
done

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
