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
_diverged_repo=$(mktemp -d /tmp/lifecycle-diverged-repo-XXXXXX)
_diverged_remote=$(mktemp -d /tmp/lifecycle-diverged-remote-XXXXXX)
git -C "$_diverged_remote" init --bare -q
git -C "$_diverged_repo" init -q
git -C "$_diverged_repo" config user.email eval@example.com
git -C "$_diverged_repo" config user.name Eval
printf 'base\n' > "$_diverged_repo/file.txt"
git -C "$_diverged_repo" add file.txt
git -C "$_diverged_repo" commit -qm base
git -C "$_diverged_repo" branch -m feature/diverged
git -C "$_diverged_repo" remote add origin "$_diverged_remote"
git -C "$_diverged_repo" push -qu origin feature/diverged
_diverged_base=$(git -C "$_diverged_repo" rev-parse HEAD)
printf 'old\n' >> "$_diverged_repo/file.txt"
git -C "$_diverged_repo" commit -qam old
git -C "$_diverged_repo" push -q
git -C "$_diverged_repo" reset -q --hard "$_diverged_base"
printf 'rewritten\n' >> "$_diverged_repo/file.txt"
git -C "$_diverged_repo" commit -qam rewritten
_diverged_sid="lifecycle-diverged-eval-$$"
_diverged_session="/tmp/hook-session-${_diverged_sid}"
mkdir -p "$_diverged_session"
: > "$_diverged_session/session-touched-files"
printf 'push\n' > "$_diverged_session/task-endpoint"
_diverged_out=$(mktemp)
_diverged_err=$(mktemp)
_diverged_exit=0
(cd "$_diverged_repo" && printf '%s' '{"hook_event_name":"Stop","stop_hook_active":false}' \
  | CLAUDE_SESSION_ID="$_diverged_sid" "$HOOKS_DIR/lifecycle-stop.sh" >"$_diverged_out" 2>"$_diverged_err") \
  || _diverged_exit=$?
if [ "$_diverged_exit" -eq 2 ] \
  && grep -q -- '--force-with-lease' "$_diverged_out" "$_diverged_err"; then
  echo "  PASS  lifecycle-stop prescribes force-with-lease for rewritten upstream history"
  PASS=$((PASS + 1))
else
  echo "  FAIL  lifecycle-stop misses force-with-lease for rewritten upstream history"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: diverged lifecycle push recovery"
fi
rm -rf "$_diverged_repo" "$_diverged_remote" "$_diverged_session" "$_diverged_out" "$_diverged_err"
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
# installed tools, and once-per-session markers).

run_file_eval "$HOOKS_DIR/intent-detect.sh" "intent-detect.sh exists"
run_executable_eval "$HOOKS_DIR/intent-detect.sh" "intent-detect.sh is executable"
if grep -qE 'RISK:|\[BROWSER\]|\[CI-FIX\]' "$HOOKS_DIR/intent-detect.sh"; then
  echo "  FAIL  intent-detect contains workflow coaching"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: intent-detect workflow coaching"
else
  echo "  PASS  intent-detect contains only endpoint and repository context"
  PASS=$((PASS + 1))
fi
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
run_content_eval "$REPO_ROOT/CLAUDE.md" "outcome contract" "CLAUDE.md defines the high-level work contract"
run_content_eval "$REPO_ROOT/CLAUDE.md" 'Meaningful behavior starts with' "CLAUDE.md scopes TDD to meaningful behavior"
run_content_eval "$REPO_ROOT/CLAUDE.md" 'failing public-contract test' "CLAUDE.md requires a failing public-contract test"
run_content_eval "$REPO_ROOT/CLAUDE.md" "smallest obvious" "CLAUDE.md starts with the smallest design"
run_content_eval "$REPO_ROOT/CLAUDE.md" "/commit-push" "CLAUDE.md mandates /commit-push in ship phase"
