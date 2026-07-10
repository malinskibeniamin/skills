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
run_content_eval "$DESLOP" "ponytail, lazy mode, YAGNI" "deslop description carries ponytail trigger words"
run_content_eval "$DESLOP" "Write mode" "deslop has write mode"
run_content_eval "$DESLOP" "Gate mode" "deslop keeps gate mode"

# Upstream 2026-07 additions ported with the merge.
run_content_eval "$DESLOP" "Already in this codebase" "ladder has reuse-in-codebase rung (upstream 2026-07)"
run_content_eval "$DESLOP" "root cause, not symptom" "write mode fixes root cause, not symptom"
run_content_eval "$DESLOP" "grep every caller" "root-cause rule greps callers before editing"
run_content_eval "$DESLOP" "Understand first" "ladder runs after comprehension, never instead"

# Ponytail behaviors preserved.
run_content_eval "$DESLOP" "lite\|full\|ultra" "intensity levels preserved"
run_content_eval "$DESLOP" "ponytail: global lock" "shortcut markers keep ceiling + trigger format"
run_content_eval "$DESLOP" "Debt ledger" "debt ledger preserved"
run_content_eval "$DESLOP" "No ponytail: debt. Clean ledger." "clean-ledger output preserved"
run_content_eval "$DESLOP" "/tdd.*wins|tdd.*failing test first" "local TDD-wins rule preserved"
run_content_eval "$DESLOP" "never tag it for deletion" "self-check is never flagged as bloat"

# Review integration (ponytail-review conventions live in /review's complexity hat).
run_content_eval "$REPO_ROOT/review/SKILL.md" "net: -<N> lines possible" "review complexity hat scores net lines"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Lean already. Ship." "review complexity hat has lean-already outcome"
run_content_eval "$REPO_ROOT/review/SKILL.md" "self-check is never bloat" "review never flags the minimal self-check"

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

# Callers route to the merged skill.
run_content_eval "$REPO_ROOT/work/SKILL.md" "/deslop full" "work routes to deslop write mode"
run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "/deslop full" "lifecycle plans with deslop write mode"
run_content_eval "$REPO_ROOT/prototype/SKILL.md" "/deslop ultra" "prototype uses deslop ultra"
run_content_eval "$REPO_ROOT/swarm/SKILL.md" "/deslop.*write mode" "swarm worker lanes start in deslop write mode"
run_content_eval "$REPO_ROOT/tdd/SKILL.md" "/deslop.*write mode" "tdd green phase runs deslop write mode"
