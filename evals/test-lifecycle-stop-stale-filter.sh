# Evals for lifecycle-stop.sh step-0 stale-entry filter.
#
# Regression guard: step 0 must not block on stale session-touched-files
# entries (files that don't exist, live outside current worktree, or
# aren't in the current branch's diff). Must still block on real
# untested new source.

HOOK="$REPO_ROOT/.claude/hooks/lifecycle-stop.sh"

# Skip entire suite if gh missing — hook quick-exits at gh gate and
# every case would pass for the wrong reason.
if ! command -v gh &>/dev/null; then
  echo "  SKIP  lifecycle-stop stale-filter evals (gh not installed)"
  SKIP=$((SKIP + 4))
  return 0 2>/dev/null || true
fi

# ── Helpers ─────────────────────────────────────────────────────

_ls_setup_temp_repo() {
  # Prints a fresh temp repo path on stdout; initial commit on `main`.
  local d
  d=$(mktemp -d)
  (
    cd "$d" || exit 1
    git init -q -b main
    git config user.email eval@test
    git config user.name eval
    git commit -q --allow-empty -m "init"
    git checkout -q -b feature/test
  ) >/dev/null 2>&1
  printf '%s' "$d"
}

_ls_run_case() {
  # Args: description expected_exit expected_pattern setup_fn
  local description="$1" expected_exit="$2" expected_pattern="$3" setup_fn="$4"
  local repo session_id session_dir actual_exit=0 out
  repo=$(_ls_setup_temp_repo)
  session_id="ls-eval-$$-$RANDOM"
  session_dir="/tmp/hook-session-${session_id}"
  mkdir -p "$session_dir"
  touch "$session_dir/dirty-files-baseline"

  # Run setup in subshell to isolate cwd
  (
    cd "$repo" || exit 1
    "$setup_fn" "$repo" "$session_dir"
  )

  out=$(cd "$repo" && CLAUDE_SESSION_ID="$session_id" bash "$HOOK" <<< '{}' 2>&1) || actual_exit=$?

  local passed=true
  if [ "$actual_exit" -ne "$expected_exit" ]; then
    passed=false
  fi
  if [ -n "$expected_pattern" ] && ! grep -qF -- "$expected_pattern" <<< "$out"; then
    passed=false
  fi

  if [ "$passed" = true ]; then
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $description (exit=$actual_exit expected=$expected_exit)"
    echo "        output: $out"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
  fi

  rm -rf "$session_dir" 2>/dev/null || true
  rm -rf "$repo" 2>/dev/null || true
}

# ── Case 1: stale entry (file does not exist) → exit 0 ────────────
_case_stale_nonexistent() {
  local repo="$1" session_dir="$2"
  printf '%s\n' "$repo/src/routes/ghost.tsx" > "$session_dir/session-touched-files"
}
_ls_run_case \
  "lifecycle-stop skips stale entry for non-existent file" \
  0 "" _case_stale_nonexistent

# ── Case 2: real untracked untested source → exit 2, prescribes /tdd
_case_real_untested() {
  local repo="$1" session_dir="$2"
  mkdir -p "$repo/src/routes"
  printf 'export const X = 1\n' > "$repo/src/routes/demo.tsx"
  printf '%s\n' "$repo/src/routes/demo.tsx" > "$session_dir/session-touched-files"
}
_ls_run_case \
  "lifecycle-stop blocks on real untested untracked source" \
  2 "/tdd" _case_real_untested

# ── Case 3: committed source on feature branch, no tests → exit 2
# Ensures branch-diff detection catches files already committed.
_case_committed_untested() {
  local repo="$1" session_dir="$2"
  mkdir -p "$repo/src/routes"
  printf 'export const Y = 2\n' > "$repo/src/routes/committed.tsx"
  (cd "$repo" && git add -A && git commit -q -m "add route")
  printf '%s\n' "$repo/src/routes/committed.tsx" > "$session_dir/session-touched-files"
}
_ls_run_case \
  "lifecycle-stop blocks on committed-but-untested source" \
  2 "/tdd" _case_committed_untested

# ── Case 4: real source WITH adjacent test → exit 0 ───────────────
_case_real_with_adjacent_test() {
  local repo="$1" session_dir="$2"
  mkdir -p "$repo/src/routes"
  printf 'export const Z = 3\n' > "$repo/src/routes/tested.tsx"
  printf 'test("x", () => {})\n' > "$repo/src/routes/tested.test.tsx"
  printf '%s\n%s\n' \
    "$repo/src/routes/tested.tsx" \
    "$repo/src/routes/tested.test.tsx" \
    > "$session_dir/session-touched-files"
}
_ls_run_case \
  "lifecycle-stop skips when adjacent test exists" \
  0 "" _case_real_with_adjacent_test

# ── Case 5: path outside current worktree → exit 0 ────────────────
# Simulates sibling-worktree leakage / session-id collision by
# pointing session-touched-files at another repo entirely.
_case_outside_worktree() {
  local repo="$1" session_dir="$2"
  local other
  other=$(_ls_setup_temp_repo)
  mkdir -p "$other/src/routes"
  printf 'export const X = 1\n' > "$other/src/routes/sibling.tsx"
  printf '%s\n' "$other/src/routes/sibling.tsx" > "$session_dir/session-touched-files"
  # cleanup the sibling repo after the run via session_dir marker
  printf '%s\n' "$other" > "$session_dir/.cleanup-extra"
}
_ls_run_case \
  "lifecycle-stop skips path outside current worktree" \
  0 "" _case_outside_worktree
