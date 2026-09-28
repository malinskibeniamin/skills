#!/bin/sh
set -eu

base_ref=${1:-}
if [ -z "$base_ref" ]; then
  printf 'Usage: %s <base-ref>\n' "$0" >&2
  exit 2
fi

base=$(git rev-parse --verify "$base_ref^{commit}")
fork=$(git merge-base HEAD "$base")
commits=$(git rev-list --count --no-merges "$fork..HEAD")
merges=$(git rev-list --count --merges "$fork..HEAD")

printf 'Pre-rebase: %s commit' "$commits"
[ "$commits" -eq 1 ] || printf 's'
printf ' ahead of %s.\n' "$base_ref"

if [ "$merges" -gt 0 ]; then
  printf 'History contains %s merge commit(s); inspect topology before any squash.\n' "$merges"
fi

if [ "$commits" -lt 2 ]; then
  exit 0
fi

repeated=$(
  git log --no-merges --format= --name-only "$fork..HEAD" |
    sed '/^$/d' |
    LC_ALL=C sort |
    uniq -c |
    awk '$1 > 1 { count=$1; $1=""; sub(/^ */, ""); printf "- %s (%s commits)\n", $0, count }'
)

if [ -z "$repeated" ]; then
  printf 'No files changed by multiple commits.\n'
  exit 0
fi

printf 'Files changed by multiple commits (heuristic; not measured conflict or token cost):\n%s\n' "$repeated"
printf 'Inspect these commits for fixups before rebasing. Squash only coherent work on a branch you own; preserve useful history. This check never rewrites commits.\n'
