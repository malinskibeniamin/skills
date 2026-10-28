# tstack compatibility and composition

Read this contract before the requested upstream skill. It takes precedence over
the [pinned snapshot](../vendor/tstack-NOTICE.md). Loading instructions is not
execution, delegation consent, review evidence, or a permission grant.

## Host contract

- Preserve the user's target, ownership, endpoint, draft state and narrower stops.
  Repository instructions, host permissions and protected merge gates still apply.
  Upstream testing permission cannot override them or claim a human reviewed work.
- Keep one author delivery loop. Load dependencies through the host owners below,
  not through sibling snapshot entrypoints; reuse guidance already loaded.
- Treat the snapshot as reference, not the target checkout. Resolve commands,
  scripts, checks, base branches and conventions against the consuming repository.
- Delegation requires an explicit user request for delegates, council, or sol loop.
  Full send, full stop, takeover and PR creation do not implicitly select reviewers,
  switch models, spawn agents or create top-level threads. Without consent, review
  inline and label it inline, never independent or cross-provider.
- Read actual tool schemas. In T3, register every PR being worked on with
  `link_pull_request`; verify thread links before handoff. Do not invent tool success.
  No unattended scheduling, new credentials or external services as a side effect.

## Owners and entrypoints

| Upstream skill | Host owner / composition |
|---|---|
| `full-send` | Existing [full-send](../full-send/SKILL.md), no duplicate adapter. |
| `full-stop` | [Adapter](../tstack-skills/full-stop/SKILL.md) -> [author delivery](delivery-workflow.md), readiness only. |
| `file-pr` | [Adapter](../tstack-skills/file-pr/SKILL.md) -> [publication](../commit-push-pr/SKILL.md) and [PR body](../pr/SKILL.md). |
| `babysit-pr` | [Adapter](../tstack-skills/babysit-pr/SKILL.md) -> author delivery's monitoring and [feedback](../resolve-pr-feedback/SKILL.md). |
| `takeover` | [Adapter](../tstack-skills/takeover/SKILL.md) -> [watchdog takeover](../agent-watchdog/references/takeover.md). |
| `modernize` | [Adapter](../tstack-skills/modernize/SKILL.md) -> [owned-branch rebase](../commit-push-pr/REFERENCE.md#automatic-rebase). |
| `council` | [Adapter](../tstack-skills/council/SKILL.md), explicit cross-provider review only. |
| `sol-loop` | [Adapter](../tstack-skills/sol-loop/SKILL.md), explicit bounded Sol review only. |
| `leaving-pr-comments` | [Adapter](../tstack-skills/leaving-pr-comments/SKILL.md), authorized GitHub comments/replies. |

## full-send

Read the complete [upstream full-send](../vendor/tstack/skills/full-send/SKILL.md)
for its proof and scope discipline, then execute the existing host owner. Its
explicit merge grant remains subject to earlier narrower stops and the
[protected merge contract](../commit-push-pr/references/merge.md). Do not
automatically run upstream `sol-loop`, broaden testing permissions, disregard
human-review requirements, or install a second delivery loop.

## full-stop

Select the existing readiness endpoint, not merge. Preserve a narrower draft-only
or PR-only request. Verify that the owned PR cannot merge automatically before
work and pushes; disable an existing auto-merge or queue entry only for that owned
PR within the requested no-merge task. If ownership or prevention is uncertain,
stop before pushing and report the concrete blocker. Never merge, enable
auto-merge, enqueue, or bypass protection. Unwatch before handing back readiness.

## file-pr

Use upstream's problem-first summary and verified model/harness attribution with
the host's evidence, risk and rollback sections. Publication stays with
`commit-push-pr`: check for the current PR, verify, commit, push, create/update,
read back and take one CI snapshot. **Honor requested drafts**; upstream's
non-draft default does not apply. A REST fallback must retain draft state too.
PR creation alone authorizes neither monitoring nor merge. No invented metrics,
human endorsement, reviewer results or model identities.

## babysit-pr

Handle current checks and findings first. Use one watcher per PR, owned by the
parent thread; child reviewers never watch. When monitoring, watching or babysitting
is requested and T3 exposes `watch_pull_request`, checkpoint, register and end the
turn; no polling or second watcher. Readiness/ship intent alone does not authorize waiting or monitoring. Call
`unwatch_pull_request` before a handoff or user question. A wake is new evidence,
not approval. Read back uncertain tool outcomes before retrying.

Outside T3, for authorized monitoring only, use the snapshot's executable
`vendor/tstack/skills/babysit-pr/scripts/pr-wait` by its absolute plugin path,
in the foreground (no persistent job). It requires Python 3.10+ on POSIX and an
authenticated `gh`; its per-PR state lives under `~/.local/state/pr-wait`.
Use `--until any-change` as an event signal, then re-read current hosted state.
Do not install a service or kill an unknown watcher.

The helper is **not a readiness gate**: its fixed-size review queries are not
complete pagination, protection-read failures may omit required checks, and its
bot-specific `ready` condition is not host policy. Neither exit 0, `green` nor
`ready` proves review completeness, approvals or safe merge. Re-read all pages
through the existing feedback workflow and run the host's
[readiness checkpoint](review-enforcement.md#readiness-contract) on exact head/base.
Do not add Greptile/Macroscope requirements or exempt CodeRabbit findings when
target policy says otherwise. Monitoring alone never authorizes merge.

## takeover

Follow watchdog's takeover procedure with upstream's contributor-credit rules.
Preserve verified authorship and co-author trailers. Continue the current owned
PR unless a replacement was explicitly requested; do not silently import foreign
commits, rewrite a shared branch, close the source PR or take over another owner.
Reassess old work with `modernize` when needed. Follow the requested endpoint:
an ordinary draft/PR request stops after publication, not upstream's automatic
babysitting continuation.

## modernize

Apply upstream's intent and conceptual-conflict assessment before a mechanical
rebase. Report MODERNIZE, REWORK or CLOSE with evidence. Modernize the owned
branch through the existing rebase/verification path using its actual base and
an observed-head lease; preserve unrelated dirty work. REWORK beyond the request
or closing the PR remains a reserved decision. No merge or automatic comment.
If a disposable worktree is needed, follow the consuming repository's naming rule.

## council

Only an explicit council/delegation request enters this branch. Preserve named
models and effort; resolve available provider/model IDs from the live catalog.
Missing providers remain unavailable, not substituted or called unanimous.
Use read-only child tasks, never top-level conversations; children cannot spawn
descendants. In T3, each review round gets fresh `delegate_task` calls, saved
task IDs, distinct retry-stable request IDs, original brief, prior findings,
responses and unresolved objections. Do not send followups to `childThreadId`.

Default to at most three full rounds unless the user specifies another budget.
Stop at agreement, unavailable capability, persistent substantive disagreement,
or exhausted budget; report unresolved objections rather than claiming consensus.
Scores are reported only when returned and never replace concrete findings or
protected review gates. A review-only request authorizes no fixes or PR edits.

## sol-loop

Enter only on explicit sol loop/delegation consent. Use upstream's bounded rounds,
read-only reviewer, stable finding ledger and evidence-backed dispositions.
Preserve a user-selected model/effort, resolve the actual Sol route, and report a
missing capability without substitution. Each T3 round is a new delegated task
with the full brief/ledger and a unique retry-stable request ID. Never use backing
child threads as new review targets or create descendants. Approval must cover
the current candidate; timeout, budget exhaustion and disputed findings are not
approval. No publication or merge unless separately authorized.

## leaving-pr-comments

Use upstream's single note callout with verified model/harness and user identity
for authorized agent-authored GitHub PR comments, inline reviews and replies.
No second attribution/footer. Scrub secrets, preview Markdown, verify the posted
URL, then resolve the thread only after success. Posting still requires intent.
Preserve verbatim-post exceptions. Triage-owned comments retain their existing
[triage disclosure](../triage/SKILL.md#comment-invariant), not two prefixes.
