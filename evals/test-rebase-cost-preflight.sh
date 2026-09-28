# Exercise the pre-rebase advisory at its public CLI boundary.

PREFLIGHT="$REPO_ROOT/scripts/rebase-cost-preflight.sh"
run_file_eval "$PREFLIGHT" "rebase cost preflight exists"
run_executable_eval "$PREFLIGHT" "rebase cost preflight is executable"

_rebase_tmp=$(mktemp -d)
git -C "$_rebase_tmp" init -q
git -C "$_rebase_tmp" config user.name Test
git -C "$_rebase_tmp" config user.email test@example.com
printf 'base\n' > "$_rebase_tmp/shared.txt"
git -C "$_rebase_tmp" add shared.txt
git -C "$_rebase_tmp" commit -qm base
git -C "$_rebase_tmp" tag base

_assert_preflight() {
  local description="$1" pattern="$2" output="$3"
  if printf '%s\n' "$output" | grep -qF -- "$pattern"; then
    echo "  PASS  $description"; PASS=$((PASS + 1))
  else
    echo "  FAIL  $description (missing: $pattern)"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: $description"
  fi
}

if [ -x "$PREFLIGHT" ]; then
  _zero=$(cd "$_rebase_tmp" && "$PREFLIGHT" base)
  _assert_preflight "zero commits gives no squash advice" "0 commits" "$_zero"

  printf 'one\n' >> "$_rebase_tmp/shared.txt"
  git -C "$_rebase_tmp" add shared.txt
  git -C "$_rebase_tmp" commit -qm 'feat(test): one'
  _one=$(cd "$_rebase_tmp" && "$PREFLIGHT" base)
  _assert_preflight "one commit gives no repeated-path warning" "1 commit" "$_one"

  printf 'two\n' >> "$_rebase_tmp/shared.txt"
  git -C "$_rebase_tmp" add shared.txt
  git -C "$_rebase_tmp" commit -qm 'fix(test): two'
  printf 'three\n' >> "$_rebase_tmp/shared.txt"
  git -C "$_rebase_tmp" add shared.txt
  git -C "$_rebase_tmp" commit -qm 'fix(test): three'
  _before=$(git -C "$_rebase_tmp" rev-parse HEAD)
  _many=$(cd "$_rebase_tmp" && "$PREFLIGHT" base)
  _after=$(git -C "$_rebase_tmp" rev-parse HEAD)
  _assert_preflight "repeated file reported across commits" "shared.txt (3 commits)" "$_many"
  _assert_preflight "advisory does not claim a token saving" "heuristic" "$_many"
  if [ "$_before" = "$_after" ] && [ -z "$(git -C "$_rebase_tmp" status --porcelain)" ]; then
    echo "  PASS  preflight leaves history and worktree untouched"; PASS=$((PASS + 1))
  else
    echo "  FAIL  preflight changed history or worktree"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: preflight is read-only"
  fi

  git -C "$_rebase_tmp" checkout -qb disjoint base
  printf 'a\n' > "$_rebase_tmp/a.txt"
  git -C "$_rebase_tmp" add a.txt
  git -C "$_rebase_tmp" commit -qm 'feat(test): a'
  printf 'b\n' > "$_rebase_tmp/b.txt"
  git -C "$_rebase_tmp" add b.txt
  git -C "$_rebase_tmp" commit -qm 'feat(test): b'
  _disjoint=$(cd "$_rebase_tmp" && "$PREFLIGHT" base)
  _assert_preflight "disjoint commits do not trigger fixup advice" "No files changed by multiple commits." "$_disjoint"

  if (cd "$_rebase_tmp" && "$PREFLIGHT" missing-ref >/dev/null 2>&1); then
    echo "  FAIL  invalid base must fail"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: invalid base must fail"
  else
    echo "  PASS  invalid base fails"; PASS=$((PASS + 1))
  fi
fi

rm -rf "$_rebase_tmp"
