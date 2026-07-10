# AGENTS.md is now GENERATED from CLAUDE.md + .agents/codex-appendix.md.
if bash "$REPO_ROOT/scripts/generate-agents-md.sh" --check >/dev/null 2>&1; then
  echo "  PASS  AGENTS.md matches generated output (single source: CLAUDE.md)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  AGENTS.md drifted from generated output -- run scripts/generate-agents-md.sh --apply"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: AGENTS.md generation drift"
fi

# Belt-and-braces: load-bearing phrases present in both files.

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
