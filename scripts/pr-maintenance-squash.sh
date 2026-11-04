#!/bin/sh
set -eu

# Caller owns authorization/coherence and verifies the published SHA before use.
# This helper never fetches, rebases, pushes, resets, stashes, or edits the tree.
fail() { printf 'PR consolidation: %s\n' "$1" >&2; exit 1; }

[ "$#" -eq 3 ] || fail "Usage: $0 <base-ref> <expected-head> <commit-message>"
base_ref=$1
expected=$2
message=$3
[ -n "$message" ] || fail 'A coherent feature commit message is required'
case "$expected" in
  *[!a-f0-9]*|'') fail 'Expected HEAD must be a full commit SHA' ;;
esac
[ "${#expected}" -eq 40 ] || [ "${#expected}" -eq 64 ] || fail 'Expected HEAD must be a full commit SHA'

branch=$(git symbolic-ref --quiet --short HEAD) || fail 'Detached HEAD is not eligible'
case "$branch" in
  main|master|develop) fail 'Default/shared branches are not eligible' ;;
esac
default=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)
[ "origin/$branch" != "$default" ] || fail 'Default branch is not eligible'
case "$base_ref" in
  "$branch"|"refs/heads/$branch"|"origin/$branch"|"refs/remotes/origin/$branch")
    fail 'The base branch is not eligible' ;;
esac
head=$(git rev-parse --verify HEAD)
[ "$head" = "$expected" ] || fail 'HEAD changed; inspect concurrent work before retrying'
base=$(git rev-parse --verify --end-of-options "$base_ref^{commit}")
fork=$(git merge-base "$head" "$base")

guard() {
  [ "$(git symbolic-ref --quiet --short HEAD)" = "$branch" ] || fail 'Branch changed'
  [ "$(git rev-parse HEAD)" = "$expected" ] || fail 'HEAD changed'
  [ -z "$(git status --porcelain --untracked-files=normal)" ] || fail 'Dirty worktree; preserve user work'
  for marker in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-apply rebase-merge sequencer BISECT_LOG; do
    [ ! -e "$(git rev-parse --git-path "$marker")" ] || fail 'An active git operation must finish first'
  done
  worktrees=$(git worktree list --porcelain)
  count=$(printf '%s\n' "$worktrees" | grep -F -x -c "branch refs/heads/$branch" || true)
  [ "$count" -eq 1 ] || fail 'Branch has another worktree owner'
}
guard
[ "$(git rev-list --count --merges "$fork..$head")" -eq 0 ] || fail 'Merge topology requires owner inspection; not consolidated'
commits=$(git rev-list --count "$fork..$head")
if [ "$commits" -lt 2 ]; then
  printf 'PR consolidation: %s feature commit(s); unchanged\n' "$commits"
  exit 0
fi

email=$(git config user.email) || fail 'Configure the owning git identity first'
[ -n "$email" ] || fail 'Configure the owning git identity first'
# Identity is a conservative ownership guard, not proof of task authorization.
identities=$(git log --format='%ae%n%ce' "$fork..$head")
foreign=$(printf '%s\n' "$identities" | grep -F -x -v -- "$email" || true)
[ -z "$foreign" ] || fail 'Foreign author/committer found; preserve their history'
tree=$(git rev-parse "$head^{tree}")
coauthors=$(git log --format='%(trailers:key=Co-authored-by,only)' "$fork..$head" | sed '/^[[:space:]]*$/d' | LC_ALL=C sort -u)
commit_message() {
  printf '%s\n' "$message"
  [ -z "$coauthors" ] || printf '\n%s\n' "$coauthors"
}
if [ "$(git config --bool commit.gpgSign || true)" = true ]; then
  candidate=$(commit_message | git commit-tree -S "$tree" -p "$fork")
else
  candidate=$(commit_message | git commit-tree "$tree" -p "$fork")
fi
guard
# Compare-and-swap; reflog retains the original tip for recovery.
git update-ref --create-reflog -m 'pr-maintenance: consolidate owned feature' "refs/heads/$branch" "$candidate" "$expected"
printf 'PR consolidation: %s -> 1 feature commit; HEAD %s; previous %s\n' "$commits" "$candidate" "$expected"
