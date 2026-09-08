# Authorized merge

Use only for explicit permission naming a PR or a bounded, unambiguous set. An endorsement
of model capability is not permission. Resolve repository, PR, target branch, and allowed
merge method from the request and repository policy. Ask only for missing reserved choices.

## Verify the merge candidate

- Inspect the current head and base, full diff, dependencies/stack order, acceptance
  evidence, required reviews/checks, unresolved threads, and mergeability. Bind evidence
  to the head SHA and base revision. A changed head or base invalidates affected evidence.
- Require current real-entrypoint verification for runnable changes. Missing CI is not
  green CI; missing checks, failed checks, unresolved feedback, or unknown mergeability
  block execution until resolved under repository policy. Never self-approve to satisfy
  a required independent review.
- Inspect deployment consequences. Confirm merging lands in the intended integration or
  staging path. If it triggers production or another reserved irreversible action not
  covered by permission, ask before merging. Identify recovery/revert procedure; do not
  promise an automatic rollback of migrations or external side effects.

## Execute and confirm

Re-read PR state immediately before the merge. Use the repository's protected hosted
merge path and expected-head guard, such as `gh pr merge <number> --repo <owner/repo>
--match-head-commit <verified-sha>` with the permitted method for a non-queue target.
Never bypass protection with `--admin`, force-push the target, delete branches, or enable
auto-merge as a fallback. Respect required merge queues; enqueue only if the authorized
endpoint permits it, otherwise report the queue decision needed.

The expected-head guard does not pin the base. Require the hosted up-to-date check or
merge queue to protect against a base race; if neither can protect the verified result,
report the missing gate rather than claim a preflight read makes the merge atomic.

After the attempt, read the hosted state and merge commit. Distinguish **merged**, **queued**,
and **not merged**; command success or enqueue success alone does not prove merge. On
timeout, read before retrying. A changed head, base, or policy requires fresh assessment;
an unknown outcome stops further mutations. Report the actual result and remaining
deployment checks. Production promotion and ongoing monitoring are separate endpoints.

GitHub CLI flag and queue semantics: [official merge manual](https://cli.github.com/manual/gh_pr_merge).
