# Author delivery

The author path owns verification, publication, and requested follow-through. Use it from
[development-lifecycle](../development-lifecycle/SKILL.md), `/go`, or `/full-send`.
Run applicable steps yourself; the user does not need to invoke each helper.
Keep a single owner in the primary context. A different model requires explicit user authorization.
Delegation, background wake-ups and broader scope need their existing explicit authorization. Reuse current receipts instead of repeating work.

Delivery never waits for CI, reviews or approvals, including ship and `/go`, in any
repository. Verify locally, publish the requested scope, report one status snapshot and
stop. Monitoring, CI repair and feedback resolution need an explicit request; ship/merge
intent alone does not authorize watching. [Hosted merge policy](review-enforcement.md)
remains separate: no-wait delivery neither grants merge permission nor bypasses protections.

## Exit contract

| Endpoint | Stop only after |
|---|---|
| Local | Requested changes and local verification |
| Commit | Verified scope committed, no push |
| Push / ordinary implementation | Verified scope committed and remote HEAD matches |
| PR / draft PR | PR created or updated in requested draft state, body read back, one CI snapshot |
| Ship / `/go` / full stop / `--no-merge` | Locally verified candidate published, PR body read back, one CI snapshot; no wait or merge |
| Explicit merge / full send | Policy-compliant hosted merge confirmed, or exact current blocker reported; no implicit waiting |

Earlier narrower stops win. A request to discuss a command is not an invocation. Bare
`/work` resumes the current task or owned diff, defaulting to push under repository policy;
if neither identifies an outcome, ask for the target. It grants no PR or merge permission.
A review request alone returns findings without edits or hosted comments. When repairs are
explicitly requested, retain its exact target and enter this author path only for those repairs.

For an explicit batch request (all your open PRs), run the
[batch procedure](../pr-shepherd/REFERENCE.md) once in the current repository: repair only
this workspace, route other owners, never merge or install background polling.

## Verify and prepare

Inspect -> verify -> repair -> repeat until current evidence passes.

1. Inspect the original request, complete diff, branch/worktree ownership, real PR base,
   and existing PR/stack. Keep follow-ups in that PR; whole-stack delivery uses [stacked-prs](../stacked-prs/SKILL.md) only when explicitly requested.
   On a default branch, use `scripts/mux-worktree.sh` for isolation before edits, following
   repository naming rules. [ETHOS: Worktree Isolation]
   Preserve feature branch names and unrelated work. On an owned feature, routine repairs,
   rebases, commits, pushes and `--force-with-lease` need no extra prompt. Preserve default/shared/foreign/concurrent branches unless explicitly authorized.
2. For new behavior or repairs, use [TDD](../tdd/SKILL.md) and [check loops](check-loop.md). Run repository-native focused
   tests, lint, types, build/integration checks; retain warnings, skips and limits.
   Resolve commands and scope from the target's current instructions and scripts using
   [repo navigation](repo-navigation.md). Its package manager, checker and test
   runner outrank harness defaults; preserve documented changed-files gates rather than
   expanding them into prohibited repo-wide checks.
3. Load [change evidence](change-evidence.md) and applicable specialist instructions.
   Exercise runnable work with [dogfood](../dogfood/SKILL.md): real user or public entrypoint, intended use and
   a credible failure/recovery path. Static docs/config use the relevant consumer/validator instead.
4. Load [review](../review/SKILL.md) and apply its diagnostic axes inline. Its read-only
   contract governs that assessment; this author request owns repairing concrete findings.
   Stop when clean, not after a prescribed number of passes. Repeated unchanged failures
   need a new hypothesis, not an endless retry or reviewer ping-pong loop.
5. Dependency version upgrades verify lockfile, clean install/build, and every
   affected call site against current primary documentation. When the change claims measurable impact,
   repeat the same baseline/candidate scenario under [quantify-impact](../quantify-impact/SKILL.md).
6. Bind verification and captures to the head SHA and base revision and scenario. Any relevant
   edit or base movement invalidates affected receipts; replay those before claiming success.

Stop self-review as soon as it is clean. Repeated noisy findings need diagnosis; hand off only at a genuine
external blocker, not after scheduled rounds.

## Publish within the endpoint

Use [commit-push-pr](../commit-push-pr/SKILL.md), including consumer safeguards, explicit
staging, remote scope verification, draft state, impact assessment and [pr](../pr/SKILL.md).
That publication skill owns Git commands, evidence hosting and the PR body. Load dependencies
through [skill mechanics](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
For an already-open session PR, apply [existing PR upkeep](../pr/SKILL.md#existing-pr)
on follow-ups and before handoff, including push-only endpoints.

Reviewer-friendly value, focus, risk, rollback and useful visuals are automatic.
Extra recap artifacts and history reordering/folding require an explicit request; no automatic rewrite
just to make a PR look tidy. Public repositories need the publication skill's privacy scrub.
Commit/push/PR-only requests stop at their table row, even if CI is pending or failing; report
it accurately. Push every local CI fix or rebase after verification, then refresh affected evidence before stopping.

## Explicit CI repair, feedback or monitoring

A request to fix CI authorizes inspecting the failed logs, reproducing, repairing,
verifying, committing and pushing the fix. It does not authorize waiting for the next
run. Missing CI is not green CI; report pending, failing or absent checks accurately.

For requested feedback resolution, load [resolve-pr-feedback](../resolve-pr-feedback/SKILL.md).
Human feedback has no cap; `pr-feedback-completeness-stop` enforces that explicitly requested
workflow, not ordinary publication. Read all relevant pages; fix or rebut findings with
evidence, reply and verify resolution.
Do not solicit another review or wait for future comments/approvals. Keep native approval
requirements distinct from diagnostic evidence; never invent independent sign-off.

Only an explicit watch/monitor/babysit request selects
[tstack monitoring](../tstack-skills/babysit-pr/SKILL.md) and
[native context](T3CODE-NATIVE.md#resolve-context). Keep one watcher, no duplicate polling,
and unwatch before handoff. For readiness diagnostics, resume checkpoints or explicitly
delegated review, load the applicable [full-send reference](../full-send/REFERENCE.md).
A diagnostic failure is not a delivery gate or authority to alter hosted settings.

## Authorized merge and receipt

Before an authorized merge, make a final verification pass on the exact head/base. Honor
required checks/reviews under native policy unless the owner explicitly permits an override.
State the user's instruction authorizing this specific merge, then load the
[protected merge contract](../commit-push-pr/references/merge.md). Use its expected-head guard
and the repository's native protections or explicit owner-approved override; never auto-merge as fallback.
Neither queued nor accepted means merged. Report a pending queue entry without waiting unless monitoring was explicitly requested;
failures or moved head/base invalidate affected verification. Unknown mutation outcomes require readback before retrying.
Production promotion and ongoing monitoring are separate authorization, not merge side effects.

Return outcome/PR URL, verified head (and merge commit when merged), checks, review/thread
state and genuine limits. High confidence needs observed behavior, current passing gates,
resolved feedback and understood recovery, not a guessed percentage. Use the repository's
intent/impact/status contract. Preserve pending evidence in an untracked checkpoint before
context limits; do not hand back an unfinished endpoint as done.
