# Evals for lifecycle auto-remediation and intent injection.

HOOKS_DIR="$REPO_ROOT/.claude/hooks"


# ── lifecycle-stop.sh: no mechanical test quota ─────────────────

run_file_eval "$HOOKS_DIR/lifecycle-stop.sh" "lifecycle-stop.sh exists"
run_executable_eval "$HOOKS_DIR/lifecycle-stop.sh" "lifecycle-stop.sh is executable"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "Commit the requested scope" "lifecycle-stop prescribes scoped commit for external endpoints"

for pattern in "coverage-summary.json" "SOURCE CHANGED WITHOUT TEST CHANGE" "NEW SOURCE WITHOUT TEST"; do
  if grep -Rq -- "$pattern" "$HOOKS_DIR/lifecycle-stop.sh" "$HOOKS_DIR/orchestration-stop.sh"; then
    echo "  FAIL  mechanical test gate absent: $pattern"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: mechanical test gate remains: $pattern"
  else
    echo "  PASS  mechanical test gate absent: $pattern"
    PASS=$((PASS + 1))
  fi
done

# ── lifecycle-stop.sh: auto-remediation messages ────────────────

run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "Run:.*git push" "lifecycle-stop prescribes exact push command"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "Create one NOW" "lifecycle-stop prescribes PR creation"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "Requested PR endpoint is complete" "PR endpoint stops after CI snapshot"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "explicit ship loop" "ship endpoint alone owns CI monitoring"
if grep -q "consider: gh pr edit" "$HOOKS_DIR/lifecycle-stop.sh"; then
  echo "  FAIL  lifecycle-stop adds unrequested reviewer work"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: lifecycle-stop adds reviewer work"
else
  echo "  PASS  lifecycle-stop adds no unrequested reviewer work"
  PASS=$((PASS + 1))
fi

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

run_content_eval "$REPO_ROOT/CLAUDE.md" "## Work" "CLAUDE.md keeps a compact work contract"
run_content_eval "$REPO_ROOT/CLAUDE.md" 'Use `/development-lifecycle`' "CLAUDE.md points to progressive lifecycle guidance"
run_content_eval "$REPO_ROOT/CLAUDE.md" 'meaningful behavior RED -> GREEN -> REFACTOR' "CLAUDE.md scopes TDD to meaningful behavior"
run_content_eval "$REPO_ROOT/CLAUDE.md" "smallest obvious" "CLAUDE.md starts with the smallest design"
run_content_eval "$REPO_ROOT/CLAUDE.md" "/commit-push" "CLAUDE.md mandates /commit-push in ship phase"
