# Resolve PR Feedback — Reference

## GraphQL: Fetch Inline Review Threads

```bash
gh api graphql -f query='
  query($owner:String!, $repo:String!, $number:Int!) {
    repository(owner:$owner, name:$repo) {
      pullRequest(number:$number) {
        reviewThreads(first:100) {
          nodes {
            isResolved
            isOutdated
            comments(first:10) {
              nodes { body author { login } path line }
            }
          }
        }
      }
    }
  }
' -f owner=OWNER -f repo=REPO -F number=$pr_number
```

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
' -f threadId=THREAD_ID -f body="Fixed — [brief explanation]"

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
gh pr view $pr_number --json comments -q '.comments[]'
gh pr view $pr_number --json reviews -q '.reviews[]'
```

## Summary Comment Template

```markdown
## Review feedback addressed

- **[Thread 1 summary]**: [what was fixed]
- **[Thread 2 summary]**: [what was fixed]
- **[Cluster summary]**: [what was fixed across N files]

All review threads resolved. CI is green.
```
