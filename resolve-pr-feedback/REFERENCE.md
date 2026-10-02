# Resolve PR Feedback -- Reference

## GraphQL: Fetch Inline Review Threads

```bash
gh api graphql --paginate --slurp -f query='
  query($owner:String!, $repo:String!, $number:Int!, $endCursor:String) {
    repository(owner:$owner, name:$repo) {
      pullRequest(number:$number) {
        reviewThreads(first:100, after:$endCursor) {
          pageInfo { hasNextPage endCursor }
          nodes {
            id
            isResolved
            isOutdated
            comments(first:100) {
              pageInfo { hasNextPage endCursor }
              nodes { id body author { login } path line }
            }
          }
        }
      }
    }
  }
' -f owner=OWNER -f repo=REPO -F number=$pr_number
```

`--paginate` advances the outer thread connection. If a thread's comments have
`hasNextPage=true`, fetch that thread's remaining comments separately using
`node(id:THREAD_ID) { ... on PullRequestReviewThread { comments(first:100,
after:$endCursor) { pageInfo { hasNextPage endCursor } nodes { id body author
{ login } path line } } } }` with `--paginate --slurp`. Do not infer completeness
from the first comment page.

## GraphQL: Reply and Resolve Thread

```bash
# Reply
gh api graphql -f query='
  mutation($threadId:ID!, $body:String!) {
    addPullRequestReviewComment(input:{
      pullRequestReviewThreadId:$threadId,
      body:$body
    }) { comment { id } }
  }
' -f threadId=THREAD_ID -f body="Fixed -- [brief explanation]"

# Resolve
gh api graphql -f query='
  mutation($threadId:ID!) {
    resolveReviewThread(input:{threadId:$threadId}) {
      thread { isResolved }
    }
  }
' -f threadId=THREAD_ID
```

## Fetch Top-Level Comments and Reviews

```bash
gh api "repos/OWNER/REPO/issues/$pr_number/comments" --paginate --slurp
gh api "repos/OWNER/REPO/pulls/$pr_number/reviews" --paginate --slurp
```

## Summary Comment Template

```markdown
## Review feedback addressed

- **[Root cause]**: [correction]. Verified: [evidence].
- **[Root cause]**: [correction]. Verified: [evidence].

[Observed thread state]. [Observed CI state].
```

## Completeness Verification

Stop hook `pr-feedback-completeness-stop.sh` re-fetch threads + reviews. Block session exit if any true:

- Any `reviewThread` with `isResolved=false` AND `isOutdated!=true` AND ≥1 non-`[bot]` comment.
- Any reviewer latest `review` state `CHANGES_REQUESTED` (no later `APPROVED`/`DISMISSED` same author).

Automatic repair sets `PR_FEEDBACK_INCLUDE_BOTS=1`: every unresolved, non-outdated
thread counts, including bot-only findings. Reply with evidence and resolve findings
that are not applicable. Thread and review pages are fetched with pagination;
GitHub fetch failures block automatic completeness instead of claiming success.

Escape hatches (use sparingly, document why):

- `PR_FEEDBACK_ENFORCEMENT=off` -- disable entirely (incident response only).
- Reply on thread "not actionable -- [reason]" + resolve. Hook count resolved as done.

Self-check command (run before declaring done):

```bash
bash scripts/pr-unresolved-count.sh            # prints integer (0 = clean)
bash scripts/pr-unresolved-count.sh --verbose  # lists threads on stderr
bash scripts/pr-unresolved-count.sh --include-bots # automatic repair, must print 0
```

Why not plain `gh pr view`: GitHub REST expose review comments but NOT thread-level `isResolved`. `reviewThreads` with `isResolved`/`isOutdated` only in GraphQL API. Wrapper script isolate that detail.
