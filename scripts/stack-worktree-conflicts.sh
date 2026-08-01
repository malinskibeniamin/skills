#!/bin/bash
set -euo pipefail

# Print stack branches checked out by another worktree. Exit 2 when conflicts
# exist so callers can distinguish ownership from ordinary command failures.

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required to inspect stack state." >&2
  exit 1
fi

if ! stack_json=$(gh stack view --json 2>/dev/null); then
  echo "Current branch is not in a locally tracked stack." >&2
  exit 1
fi

stack_branches=$(mktemp)
trap 'rm -f "$stack_branches"' EXIT
printf '%s' "$stack_json" | jq -er '.branches | arrays | .[].name' > "$stack_branches"

current_path=$(git rev-parse --show-toplevel)
worktree_path=""
worktree_branch=""
has_conflict=0

inspect_worktree() {
  local branch
  if [ -z "$worktree_path" ] || [ -z "$worktree_branch" ]; then
    return
  fi

  branch=${worktree_branch#refs/heads/}
  if [ "$worktree_path" != "$current_path" ] && grep -Fqx "$branch" "$stack_branches"; then
    printf '%s\t%s\n' "$branch" "$worktree_path"
    has_conflict=1
  fi
}

while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    worktree\ *)
      inspect_worktree
      worktree_path=${line#worktree }
      worktree_branch=""
      ;;
    branch\ *)
      worktree_branch=${line#branch }
      ;;
    "")
      inspect_worktree
      worktree_path=""
      worktree_branch=""
      ;;
  esac
done < <(git worktree list --porcelain)
inspect_worktree

if [ "$has_conflict" -eq 1 ]; then
  exit 2
fi
