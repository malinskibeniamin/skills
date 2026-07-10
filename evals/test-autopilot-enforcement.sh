# Evals for autopilot enforcement: TDD hard block, lifecycle auto-remediation, intent injection

HOOKS_DIR="$REPO_ROOT/.claude/hooks"


# ── lifecycle-stop.sh: test coverage gate (step 0) ─────────────

run_file_eval "$HOOKS_DIR/lifecycle-stop.sh" "lifecycle-stop.sh exists"
run_executable_eval "$HOOKS_DIR/lifecycle-stop.sh" "lifecycle-stop.sh is executable"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "Coverage gap analysis" "lifecycle-stop has coverage gap analysis (step 0)"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "coverage-summary.json" "lifecycle-stop parses vitest coverage JSON"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "threshold" "lifecycle-stop has coverage threshold"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "coverage analysis unavailable" "lifecycle-stop falls back when coverage not available"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "hook_stop_block.*coverage analysis unavailable" "lifecycle-stop blocks missing tests when coverage unavailable"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "Add tests with /tdd before finishing" "lifecycle-stop blocks missing tests when no runner exists"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "/tdd" "lifecycle-stop prescribes /tdd for coverage gaps"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "/simplify" "lifecycle-stop prescribes /simplify in remediation"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "/commit-push" "lifecycle-stop prescribes /commit-push for uncommitted changes"

run_content_eval "$HOOKS_DIR/orchestration-stop.sh" "SOURCE CHANGED WITHOUT TEST CHANGE" "orchestration-stop blocks source changes without test changes"
run_content_eval "$HOOKS_DIR/orchestration-stop.sh" "NEW SOURCE WITHOUT TEST" "orchestration-stop blocks new source without tests"

# ── lifecycle-stop.sh: auto-remediation messages ────────────────

run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "Run:.*git push" "lifecycle-stop prescribes exact push command"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "Create one NOW" "lifecycle-stop prescribes PR creation"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "Monitor tool" "lifecycle-stop prescribes Monitor for CI"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "Do not stop until CI green" "lifecycle-stop mandates CI fix loop"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "consider: gh pr edit" "lifecycle-stop nudges (not blocks) review request -- audit demotion"

# ── intent-detect.sh: dynamic-context-only policy (2026-07 audit) ──
# Static rule restatements ([LIFECYCLE], [TDD], [MINIMAL], [CLI-FIRST])
# were removed: they duplicated CLAUDE.md verbatim. intent-detect now
# injects only environment-derived context (PR numbers, branch state,
# installed tools, once-per-session markers, risk tier).

run_file_eval "$HOOKS_DIR/intent-detect.sh" "intent-detect.sh exists"
run_executable_eval "$HOOKS_DIR/intent-detect.sh" "intent-detect.sh is executable"
run_content_eval "$HOOKS_DIR/intent-detect.sh" "RISK:" "intent-detect has risk tier classification"
run_content_eval "$HOOKS_DIR/intent-detect.sh" "PR-CONTEXT" "intent-detect injects PR-number branch context"
run_content_eval "$HOOKS_DIR/intent-detect.sh" "SCOPE-LOCK" "intent-detect injects feature-branch scope lock"

run_hook_eval "$HOOKS_DIR/intent-detect.sh" \
  '{"hook_event_name":"UserPromptSubmit","prompt":"fix ci on pr #4321"}' \
  0 \
  "intent-detect injects PR context for PR-number prompt" \
  "PR-CONTEXT"

# Verify implementation prompts do NOT get static rule restatements
_eval_stderr=$(mktemp)
echo '{"hook_event_name":"UserPromptSubmit","prompt":"implement dark mode toggle"}' | "$HOOKS_DIR/intent-detect.sh" 2>"$_eval_stderr" || true
if grep -qE "LIFECYCLE|CODE-LIABILITY|REUSE-FIRST|CLI-FIRST" "$_eval_stderr"; then
  echo "  FAIL  implementation prompt should NOT get static CLAUDE.md restatements"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: implementation prompt should NOT get static CLAUDE.md restatements"
else
  echo "  PASS  implementation prompt gets no static CLAUDE.md restatement"
  PASS=$((PASS + 1))
fi
rm -f "$_eval_stderr"

# ── CLAUDE.md: imperative lifecycle language ────────────────────

run_content_eval "$REPO_ROOT/CLAUDE.md" "MANDATORY.*hooks enforce" "CLAUDE.md lifecycle section is marked MANDATORY"
run_content_eval "$REPO_ROOT/CLAUDE.md" "Hooks block skipped steps" "CLAUDE.md uses imperative enforcement language"
run_content_eval "$REPO_ROOT/CLAUDE.md" "/tdd.*every" "CLAUDE.md mandates /tdd for new files"
run_content_eval "$REPO_ROOT/CLAUDE.md" "/simplify" "CLAUDE.md mandates /simplify before commit"
run_content_eval "$REPO_ROOT/CLAUDE.md" "/commit-push" "CLAUDE.md mandates /commit-push in ship phase"
