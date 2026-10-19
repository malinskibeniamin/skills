---
name: full-send
description: Own fixes, verification, CI and review babysitting through an authorized endpoint. Use for full send; full stop or --no-merge retains the merge decision.
---

Own the outcome, not just the diff. Keep going through routine repairs; return only when
the requested endpoint is confirmed or an external blocker needs the user.

## Authorization and scope

- An explicit `full send <task or PR>` authorizes fixes, commit, push, PR creation,
  CI/review babysitting, and merge of that one unambiguous deliverable. A request to
  explain, create, or review this skill is not an invocation. Discovery is not consent.
- Resolve repository, objective, owned branch/worktree, PR/base, acceptance evidence,
  and stop condition. Reuse the existing PR; keep its branch checked out in Conductor.
  If the target is ambiguous, ask for the target rather than choosing another PR.
- Earlier stop instructions win: `--no-merge`, no push, local only, draft only, or a
  PR-ready endpoint narrow authorization. Babysitting alone does not authorize merge.
  Before merging, state which user instruction authorizes this specific PR.
- Preserve unrelated work, branch names, repository protections, and user-reserved
  production/destructive/security decisions. Use the current owned feature branch.
  Scope escalation needs a decision; routine fixes and lease-pushes do not.
- Work inline unless the user explicitly authorizes delegation. Use only authorized
  tools, accounts, and isolated browser sessions; any means necessary is not a bypass.

Load dependencies through [skill mechanics](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
For full stop, hosted checkpoints, blocker notification, resume recovery or an explicitly
requested Sol loop, read [REFERENCE.md](REFERENCE.md).

## Fix and prove

1. Inspect the full branch diff and request, not just the PR description. Establish
   the failing public-contract test before changing behavior; use [TDD](../tdd/SKILL.md).
2. Make the smallest root-cause repair. Run repository-native focused tests, lint,
   types, and required build/integration checks. Keep warnings and skipped coverage visible.
3. Use [dogfood](../dogfood/SKILL.md) at the real entrypoint: intended journey plus a
   credible failure/recovery path. For visible changes, capture and inspect the
   [PR visual evidence](../commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5).
4. Apply [review](../review/SKILL.md) inline. Fix concrete defects; evidence, not a
   model's enthusiasm or reviewer praise, decides readiness.
5. Bind receipts to the head SHA and base revision. Any edit, push, rebase, or changed
   base invalidates affected evidence; replay it before claiming success.

## Publish and babysit

Use [commit-push-pr](../commit-push-pr/SKILL.md) for publication; require a fresh [consumer hosted checkpoint](../shared/review-enforcement.md) for readiness.
Continue past its single CI snapshot; confirm committed scope and remote HEAD match local HEAD.

- Watch the current PR's checks and requested reviews in this foreground session.
  Pending means continue waiting, not done. Missing CI is not green CI; resolve
  required checks from repository policy rather than inventing an all-green receipt.
- Inspect failed job logs, reproduce, repair, verify, commit, push, and watch the new
  head. Retry an infrastructure failure only with evidence; repeated unchanged
  failures need diagnosis, not an endless rerun loop. Never weaken gates to get green.
- Use [resolve-pr-feedback](../resolve-pr-feedback/SKILL.md) for human and actionable
  automated feedback. Paginate threads/comments/reviews; fix or rebut with evidence,
  reply, and re-read resolved state. Stale approvals and bot silence are not fresh reviews.
- Require completed required checks and reviews, no applicable unresolved feedback,
  and no outstanding change requests on the candidate. Do not self-approve or invent
  endorsement. If a reviewer/permission/service remains unavailable with no agent
  action possible, notify through a supported question/input tool; if unavailable, end
  with a conspicuous blocked receipt and exact needed input. Never substitute identity,
  credentials or permission while waiting.
- Rebase a behind-base owned branch when required; verify and `--force-with-lease`.
  Keep follow-ups in this PR. Persist head/base, pending run/thread IDs, evidence, and
  next action in an untracked checkpoint before context limits; no surprise daemon,
  cron, auto-review setup, or promise to keep working after the session ends.

## Final verification and confidence

After CI and feedback settle, refresh head/base, complete diff, checks, review decision,
threads, draft state, and mergeability. Run one final verification pass on that exact
candidate: acceptance checks, affected real-entrypoint journeys, and inline risk review.
If it changes, return to the loop; green evidence from an older candidate is insufficient.

Report **high confidence** only when behavior is observed, required gates pass,
feedback is handled, no material defect/unknown remains, and rollout/recovery is understood.
Name limits; never fabricate a percentage or guarantee the PR can never regress.
Lower confidence means gather evidence or repair, not ask the user to redo routine review.

## Close the loop

For an authorized merge, load the [protected merge contract](../commit-push-pr/references/merge.md)
and execute its expected-head guarded hosted path. Respect the base-race/up-to-date gate
or merge queue; never use admin bypass or auto-merge as a fallback. Confirm hosted state:
**merged** is not **queued**. Watch an authorized queue entry to its terminal result;
queue failure or head/base movement returns to verification. Unknown mutation outcome
requires readback before any retry.

Confirm any repository-required post-merge checks before done. Separate production
promotion and ongoing monitoring need their own authorization. An earlier no-merge
stop ends at verified PR readiness; a pending check/review/queue never counts as that.

Return a short receipt: outcome/PR URL, verified head (and merge commit when merged),
checks, review/thread state, confidence with evidence, and genuine limits/blockers.
Use the repository's intent/impact/status contract. Do not hand back an unfinished PR
as completed work or promise perpetual supervision.

Inspiration and research limits: [SOURCES.md](SOURCES.md). This is an original local
workflow, not a copied or endorsed Theo skill.
