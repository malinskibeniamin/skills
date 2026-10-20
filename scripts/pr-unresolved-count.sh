#!/bin/bash
set -eo pipefail

# Count every unresolved PR review thread, including bots and outdated lines.
# Wraps the one GraphQL call that `gh pr view` cannot replace:
# GitHub's REST API exposes review comments but NOT thread-level
# isResolved state. GraphQL reviewThreads is the only source of truth.
#
# Usage:
#   scripts/pr-unresolved-count.sh           # auto-detect PR from branch
#   scripts/pr-unresolved-count.sh 123       # explicit PR number
#   scripts/pr-unresolved-count.sh --verbose # print summary per thread
#
# Exit codes:
#   0 — ran successfully (stdout = integer count)
#   1 — no PR found for current branch
#   2 — gh CLI missing or unauthenticated

verbose=false
pr=""
for arg in "$@"; do
  case "$arg" in
    -v|--verbose) verbose=true ;;
    --include-bots) export PR_FEEDBACK_INCLUDE_BOTS=1 ;;
    *) pr="$arg" ;;
  esac
done

command -v gh >/dev/null 2>&1 || { echo "gh CLI required" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "jq required" >&2; exit 2; }

if [ -z "$pr" ]; then
  pr=$(gh pr view --json number -q .number 2>/dev/null || true)
  [ -z "$pr" ] && { echo "no PR found for current branch" >&2; exit 1; }
fi

owner_repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
owner="${owner_repo%/*}"
repo="${owner_repo#*/}"

resp=$(gh api graphql --paginate --slurp \
  -f query='query($o:String!,$r:String!,$n:Int!,$endCursor:String){repository(owner:$o,name:$r){pullRequest(number:$n){reviewThreads(first:100,after:$endCursor){pageInfo{hasNextPage endCursor} nodes{isResolved isOutdated comments(first:100){nodes{author{login} body path line}}}}}}}' \
  -f o="$owner" -f r="$repo" -F n="$pr")

if ! printf '%s' "$resp" | jq -e '
  type == "array" and length > 0 and all(.[];
    .errors == null and (.data.repository.pullRequest.reviewThreads.nodes | type) == "array" and
    all(.data.repository.pullRequest.reviewThreads.nodes[]; (.isResolved | type) == "boolean"))
' >/dev/null 2>&1; then
  echo "Could not verify PR feedback completeness" >&2
  exit 2
fi

if [ "$verbose" = true ]; then
  echo "$resp" | jq -r '
    .[].data.repository.pullRequest.reviewThreads.nodes[]
    | select(.isResolved==false)
    | "  • \(.comments.nodes[0].path):\(.comments.nodes[0].line // "?") — \(.comments.nodes[0].author.login): \(.comments.nodes[0].body[:100])"' >&2
fi

echo "$resp" | jq '[.[].data.repository.pullRequest.reviewThreads.nodes[]
  | select(.isResolved==false)]
  | length'
