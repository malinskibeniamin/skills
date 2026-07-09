# CLAUDE.md and AGENTS.md must agree on the load-bearing shared rules.
# Full single-source generation is future work; this guard stops silent drift.

for pat in "NEVER Haiku" "intelligence > taste > cost" "hinker/executor split" "Fable-5" "GPT-5.6 (codex) 8/9/6" "author model never solely reviews its own work"; do
  if grep -qF "$pat" "$REPO_ROOT/CLAUDE.md" && grep -qF "$pat" "$REPO_ROOT/AGENTS.md"; then
    echo "  PASS  rule in both CLAUDE.md and AGENTS.md: $pat"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  rule drifted between CLAUDE.md and AGENTS.md: $pat"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: rule drift: $pat"
  fi
done
