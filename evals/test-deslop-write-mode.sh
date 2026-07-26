# Evals for the ponytail -> deslop merge (wave 6). Write mode absorbed from
# DietrichGebert/ponytail at its 2026-07-09 head; ponytail/ dir must stay dead.

DESLOP="$REPO_ROOT/deslop/SKILL.md"

# The ponytail skill directory is gone; deslop is the single owner.
if [ -e "$REPO_ROOT/ponytail" ]; then
  echo "  FAIL  ponytail/ still exists after merge into deslop"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: ponytail/ still exists"
else
  echo "  PASS  ponytail/ removed after merge into deslop"
  PASS=$((PASS + 1))
fi

run_content_eval "$DESLOP" "vendored_from.*DietrichGebert/ponytail" "deslop credits ponytail upstream"
run_content_eval "$DESLOP" "ponytail.*lazy mode.*YAGNI" "deslop description carries ponytail trigger words"
run_content_eval "$DESLOP" "Write mode" "deslop has write mode"
run_content_eval "$DESLOP" "Gate mode" "deslop keeps gate mode"

# Upstream 2026-07 additions ported with the merge.
run_content_eval "$DESLOP" "Reuse the codebase" "ladder has reuse-in-codebase rung"
run_content_eval "$DESLOP" "root cause, not symptoms" "write mode fixes root cause, not symptoms"
run_content_eval "$DESLOP" "grep every caller" "root-cause rule greps callers before editing"
run_content_eval "$DESLOP" "Understand the full" "ladder runs after comprehension, never instead"

# Useful intensity controls remain; forced debt markers do not.
run_content_eval "$DESLOP" "lite\|full\|ultra" "intensity levels preserved"
if grep -qE "ponytail:|Debt ledger" "$DESLOP"; then
  echo "  FAIL  deslop has no forced shortcut debt ceremony"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: deslop retains shortcut debt ceremony"
else
  echo "  PASS  deslop has no forced shortcut debt ceremony"
  PASS=$((PASS + 1))
fi
run_content_eval "$DESLOP" "Meaningful behavior.*public-contract test" "deslop preserves meaningful test proof"
run_content_eval "$DESLOP" "Never cut:" "deslop names hard safety floors"
run_content_eval "$DESLOP" "trust-boundary validation" "deslop preserves trust-boundary validation"
run_content_eval "$DESLOP" "security" "deslop preserves security"
run_content_eval "$DESLOP" "accessibility" "deslop preserves accessibility"

# Review integration (ponytail-review conventions live in /review's complexity hat).
run_content_eval "$REPO_ROOT/review/SKILL.md" "semantic density" "review owns semantic-density checks directly"
run_content_eval "$REPO_ROOT/review/SKILL.md" "never optimize LOC or reward code golf" "review rejects LOC gaming"

# No stale /ponytail invocations anywhere outside history/docs.
_stale=$(grep -rln '`/ponytail' "$REPO_ROOT" --include='*.md' 2>/dev/null | grep -v CHANGELOG | grep -v "$REPO_ROOT/docs/" || true)
if [ -n "$_stale" ]; then
  echo "  FAIL  stale /ponytail invocation in: $_stale"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: stale /ponytail references"
else
  echo "  PASS  no stale /ponytail invocations outside history"
  PASS=$((PASS + 1))
fi

# Normal authoring applies the principle directly without invoking the fallback.
for file in work/SKILL.md development-lifecycle/SKILL.md prototype/SKILL.md swarm/SKILL.md tdd/SKILL.md go/SKILL.md; do
  if grep -q "/deslop" "$REPO_ROOT/$file"; then
    echo "  FAIL  $file does not invoke fallback deslop"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $file invokes fallback deslop"
  else
    echo "  PASS  $file does not invoke fallback deslop"
    PASS=$((PASS + 1))
  fi
done
