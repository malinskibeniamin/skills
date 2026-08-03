#!/bin/sh
set -eu

# Resolve the fixed point for the current PR layer. Explicit user or caller
# intent wins, then the GitHub PR base, local gh-stack state, and remote trunk.

if [ -n "${PR_BASE_REF:-}" ]; then
  printf '%s\n' "$PR_BASE_REF"
  exit 0
fi

normalize_branch() {
  candidate=$1
  case "$candidate" in
    refs/*)
      printf '%s\n' "$candidate"
      return
      ;;
  esac

  if git show-ref --verify --quiet "refs/remotes/origin/$candidate"; then
    printf 'origin/%s\n' "$candidate"
  elif git show-ref --verify --quiet "refs/heads/$candidate"; then
    printf '%s\n' "$candidate"
  else
    printf '%s\n' "$candidate"
  fi
}

if command -v gh >/dev/null 2>&1; then
  pr_base=$(gh pr view --json baseRefName --jq '.baseRefName // empty' 2>/dev/null || true)
  if [ -n "$pr_base" ]; then
    normalize_branch "$pr_base"
    exit 0
  fi

  stack_json=$(gh stack view --json 2>/dev/null || true)
  if [ -n "$stack_json" ] && command -v jq >/dev/null 2>&1; then
    current_branch=$(git branch --show-current)
    stack_base=$(printf '%s' "$stack_json" | jq -r --arg branch "$current_branch" \
      '.branches[]? | select(.isCurrent == true or .name == $branch) | .base // empty' \
      | head -n 1)
    if [ -n "$stack_base" ]; then
      normalize_branch "$stack_base"
      exit 0
    fi
  fi
fi

remote_head=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)
if [ -n "$remote_head" ]; then
  printf '%s\n' "$remote_head"
  exit 0
fi

for fallback in origin/main origin/master; do
  if git show-ref --verify --quiet "refs/remotes/$fallback"; then
    printf '%s\n' "$fallback"
    exit 0
  fi
done

printf 'Unable to resolve a PR base. Set PR_BASE_REF explicitly.\n' >&2
exit 1
