# Evals for worktree isolation + branch-safety.
# Covers:
#   - hook-lib helpers: _hook_current_worktree_root, _hook_file_outside_current_worktree
#   - _hook_assert_bound_worktree drift → exit 0 no-op
#   - session-env.sh writes bound-worktree + bound-branch
#   - session-env.sh deterministic fallback session id (md5 of worktree)
#   - branch-safety-check.sh deny/pass/rebind cases

HOOKS="$REPO_ROOT/.claude/hooks"
SHARED="$REPO_ROOT/shared"

run_file_eval "$HOOKS/branch-safety-check.sh" "branch-safety-check.sh exists"
run_executable_eval "$HOOKS/branch-safety-check.sh" "branch-safety-check.sh executable"
run_content_eval "$REPO_ROOT/.claude/hooks/pre-bash.sh" "branch-safety-check.sh" \
  "pre-bash dispatcher routes git branch commands to branch-safety-check"
run_content_eval "$REPO_ROOT/hooks/hooks.json" "pre-bash.sh" \
  "hooks.json registers the pre-bash dispatcher"
run_content_eval "$REPO_ROOT/.claude/settings.json" "pre-bash.sh" \
  "settings.json registers the pre-bash dispatcher"

# ── Hook-lib helpers defined ────────────────────────────────────
run_content_eval "$SHARED/hook-lib.sh" "_hook_current_worktree_root" \
  "hook-lib.sh defines _hook_current_worktree_root"
run_content_eval "$SHARED/hook-lib.sh" "_hook_file_outside_current_worktree" \
  "hook-lib.sh defines _hook_file_outside_current_worktree"
run_content_eval "$SHARED/hook-lib.sh" "_hook_assert_bound_worktree" \
  "hook-lib.sh defines _hook_assert_bound_worktree"
run_content_eval "$HOOKS/_hook-lib.sh" "_hook_file_outside_current_worktree" \
  "_hook-lib.sh (plugin copy) mirrors the helper"
run_content_eval "$HOOKS/_hook-lib.sh" "_hook_assert_bound_worktree" \
  "_hook-lib.sh (plugin copy) mirrors assert_bound_worktree"

# ── session-env.sh writes bound-worktree + bound-branch ──────────
run_content_eval "$HOOKS/session-env.sh" "bound-worktree" \
  "session-env.sh writes bound-worktree"
run_content_eval "$HOOKS/session-env.sh" "bound-branch" \
  "session-env.sh writes bound-branch"
run_content_eval "$HOOKS/session-env.sh" "MUX_" \
  "session-env.sh reads /mux session-hint"
run_content_eval "$HOOKS/session-env.sh" "md5" \
  "session-env.sh has deterministic session_id fallback"

# ── branch-safety-check.sh: unit tests ───────────────────────────
_setup_bs() {
  export CLAUDE_SESSION_ID="eval-bs-$$"
  local d="/tmp/hook-session-$CLAUDE_SESSION_ID"
  mkdir -p "$d"
  echo "$1" > "$d/bound-branch"
  _BS_DIR="$d"
}
_teardown_bs() {
  find /tmp -maxdepth 1 -name "hook-session-eval-bs-*" -exec rm -rf {} + 2>/dev/null || true
  unset CLAUDE_SESSION_ID _BS_DIR
}
_run_bs() {
  local stderr_file
  stderr_file=$(mktemp)
  local exit_code=0
  echo "$1" | bash "$HOOKS/branch-safety-check.sh" 2>"$stderr_file" > /dev/null || exit_code=$?
  _last_stderr=$(cat "$stderr_file")
  _last_exit=$exit_code
  rm -f "$stderr_file"
}
_run_bs_in_repo() {
  local repo="$1"
  local input="$2"
  local stderr_file stdout_file
  stderr_file=$(mktemp)
  stdout_file=$(mktemp)
  local exit_code=0
  (cd "$repo" && echo "$input" | bash "$HOOKS/branch-safety-check.sh" 2>"$stderr_file" >"$stdout_file") || exit_code=$?
  # Denies ride stderr (exit 2); the rebound notice rides stdout (exit 0).
  _last_stderr=$(cat "$stderr_file" "$stdout_file")
  _last_exit=$exit_code
  rm -f "$stderr_file" "$stdout_file"
}
_assert_bs() {
  local desc="$1" expected="$2" pattern="${3:-}"
  local ok=true
  [ "$_last_exit" -ne "$expected" ] && ok=false
  if [ -n "$pattern" ] && ! echo "$_last_stderr" | grep -qF -- "$pattern"; then ok=false; fi
  if [ "$ok" = true ]; then
    echo "  PASS  $desc"; PASS=$((PASS + 1))
  else
    echo "  FAIL  $desc (exit=$_last_exit expected=$expected)"
    [ -n "$pattern" ] && echo "        pattern missing: $pattern"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: $desc"
  fi
}

# Branch-safety must be tested in a normal branched repo. The skills repo may
# be checked out as detached HEAD in Codex worktrees, and the hook intentionally
# no-ops there.
_bs_repo=$(mktemp -d)
git -C "$_bs_repo" init -q
git -C "$_bs_repo" checkout -q -b eval-current
git -C "$_bs_repo" config user.email "eval@example.com"
git -C "$_bs_repo" config user.name "Eval"
git -C "$_bs_repo" commit -q --allow-empty -m "init"

# Same branch → pass (exit 0)
_setup_bs "eval-current"
_run_bs_in_repo "$_bs_repo" '{"tool_name":"Bash","tool_input":{"command":"git commit -m foo"}}'
_assert_bs "branch-safety: same branch passes" 0
_teardown_bs

# Drift to another existing branch → deny (exit 2)
git -C "$_bs_repo" branch eval-other
_setup_bs "eval-other"
_run_bs_in_repo "$_bs_repo" '{"tool_name":"Bash","tool_input":{"command":"git commit -m foo"}}'
_assert_bs "branch-safety: drift denies" 2 "Refusing this git call"
_teardown_bs

# A bound branch that no longer exists was renamed. Rebind automatically.
_setup_bs "feat/renamed-away-$RANDOM"
_run_bs_in_repo "$_bs_repo" '{"tool_name":"Bash","tool_input":{"command":"git commit -m foo"}}'
_assert_bs "branch-safety: renamed branch auto-rebinds" 0 "auto-rebound"
if [ "$(cat "$_BS_DIR/bound-branch" 2>/dev/null)" = "eval-current" ]; then
  echo "  PASS  branch-safety: auto-rebind persists current branch"
  PASS=$((PASS + 1))
else
  echo "  FAIL  branch-safety: auto-rebind persists current branch"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: branch-safety auto-rebind persistence"
fi
_teardown_bs

# Returning to the bound branch is the positive recovery path.
git -C "$_bs_repo" branch eval-bound
_setup_bs "eval-bound"
_run_bs_in_repo "$_bs_repo" '{"tool_name":"Bash","tool_input":{"command":"git checkout eval-bound"}}'
_assert_bs "branch-safety: return to bound branch passes" 0 "return-to-bound"
_teardown_bs

# Rebind env → pass (exit 0) and update bound-branch
_setup_bs "feat/drift-$RANDOM"
CLAUDE_BRANCH_REBIND=1 _run_bs_in_repo "$_bs_repo" '{"tool_name":"Bash","tool_input":{"command":"git commit -m foo"}}'
_assert_bs "branch-safety: rebind env passes" 0 "rebound"
unset CLAUDE_BRANCH_REBIND
_teardown_bs

# Non-git command → pass
_setup_bs "feat/irrelevant"
_run_bs '{"tool_name":"Bash","tool_input":{"command":"ls -la"}}'
_assert_bs "branch-safety: non-git command passes" 0
_teardown_bs

# Detached HEAD / empty current → pass (do not gate)
_setup_bs ""
_run_bs '{"tool_name":"Bash","tool_input":{"command":"git push"}}'
_assert_bs "branch-safety: empty bound passes" 0
_teardown_bs

# No bound file → pass (first turn)
export CLAUDE_SESSION_ID="eval-bs-unbound-$$"
mkdir -p "/tmp/hook-session-$CLAUDE_SESSION_ID"
_run_bs '{"tool_name":"Bash","tool_input":{"command":"git commit -m foo"}}'
_assert_bs "branch-safety: unbound session passes" 0
find /tmp -maxdepth 1 -name "hook-session-eval-bs-unbound-*" -exec rm -rf {} + 2>/dev/null || true
unset CLAUDE_SESSION_ID
rm -rf "$_bs_repo"
