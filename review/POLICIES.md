# Automatic review policies

Use for standing instructions such as "going forward, review this contributor's UI
changes every five minutes", changing reporting/approval rules, or pausing reviews.
One-off `/review` remains read-only unless posting was requested.

Policy controls review discovery and publication; the original feature session keeps
repair ownership.

## Say the rule; inspect the stored policy

Translate the person's instruction into a local policy file. Resolve the exact
GitHub login, repository origin and real area paths; do not guess from a person's
name or an acronym. Read `policy list` before modifying existing scope. "Only"
replaces excluded rules within the named scope, not unrelated repositories.

From a stable harness checkout with `bun install --frozen-lockfile`, authenticated
`gh`, `jq`, and the supported Codex CLI available:

```sh
bun <harness>/scripts/pr-review-auto.ts policy set --file <policy.json>
bun <harness>/scripts/pr-review-auto.ts policy list
bun <harness>/scripts/pr-review-auto.ts policy explain --id contributor-ui --pr 42
bun <harness>/scripts/pr-review-auto.ts configure --reviewer <verified-reviewer-login>
bun <harness>/scripts/pr-review-auto.ts tick --dry-run
bun <harness>/scripts/pr-review-auto.ts enable
bun <harness>/scripts/pr-review-auto.ts status
```

`set` validates/resolves and stores scope; it neither launches models nor installs
a scheduler. `configure` enables finite ticks (existing trusted sender lists are preserved when omitted); `enable` installs the one local
macOS launchd job, on an explicitly authorized setup request only. Other hosts may
schedule the finite `tick` command every 300 seconds through their authorized scheduler.
A configured policy is not evidence that scheduling is installed, awake or online.

Policy input (replace example identity, repository, checkout and paths):

```json
{
  "version": 1,
  "id": "contributor-ui",
  "repo": "example/project",
  "author": "contributor",
  "worktree": "/absolute/path/to/project",
  "paths": ["apps/web/**"],
  "publish": ["P0", "P1"],
  "autoApprove": true,
  "enabled": true,
  "model": "gpt-6.1-sol",
  "effort": "xhigh"
}
```

The compiled rule retains the resolved numeric GitHub author id and a revision.
Use one explicit policy per matching candidate; overlapping active policies fail
visibly rather than apply an undocumented precedence. Separate author/area rules
allow different reporting, approval and model settings. Models must be explicit
GPT routes in `config/model-routing.json`; unsupported providers fail without silent fallback.
Cadence is five minutes, with no model call for an unchanged candidate/rubric.

## What runs

A tick discovers all pages of open PRs in configured repositories. Drafts, other
authors, forks, and changes outside the selected paths do not launch workers.
Renames include the previous path. A partial file inventory cannot qualify.

Paths determine eligibility, not approval coverage: a matching PR gets a full,
pinned review including backend/CI changes outside its UI area. Review runs in a
separate detached no-hardlinks clone, never by checking out another person's branch in the
feature owner's worktree. CLI workers start from a private Git root above that snapshot,
not from the candidate project: its startup hooks/MCP files are not launcher configuration. The shared gate catalogue supplies skills and required
path signals; the primary reviewer records semantic applicability for every lens.
Applicable named specialist roles receive separate read-only CLI passes, at most
one per role; no nested delegation. This is normal review with specialists, not
cross-provider council. Consumer-specific `.review-gates.json` additions at either
pinned revision fail visibly before model dispatch; use the native gate workflow
until a consumer-gate executor is available. An empty shared-defaults opt-in is supported. Council needs its own explicitly supported host execution;
never label these runs council or silently downgrade a council request.

New head, base, policy revision, or rubric starts a fresh review with prior findings
as context. A prior finding must remain open by id or have an evidence-bearing
`fixed`/`refuted` disposition; silent omissions become blocking verification gaps. Unchanged candidates reuse their receipts; clean reviews waiting for CI
can gain approval when checks pass without paying for another model review.
Review execution is serialized; a long review/maintenance turn can delay the next
sweep. The five-minute launch interval is not an offline or fixed-latency guarantee.

The deterministic publisher validates version-2 findings, falsification challenges
and complete coverage. Specialist challenges stay in the synthesized receipt;
unresolved challenges withhold approval. Older receipts are not relabeled or supplied
with invented evidence.
Only selected severities are posted; unchanged unresolved findings are retained without duplicate finding comments. Hidden P2/P3 defects still withhold approval.
Approval additionally needs a clean supported verdict, no testing gaps, no unavailable
coverage, and at least one observed check with every current check passing. CI is
read from paginated check runs/statuses on the immutable head, not a truncated rollup.
Missing, pending, skipped or failed CI is not green. Use a review account different
from the PR author; automated approval is neither human endorsement nor merge authority.
Existing hosted protections remain unchanged.

## Observe, stop, recover

`status` reports enablement, scheduler health (`disabled`, `uninstalled`, `overdue`,
`blocked`, `running`), attempt/progress/finish timestamps, exact original-owner
bindings, per-binding blockers, policies and candidate receipts. A 30-second heartbeat
marks awaited local maintenance; freshness expires after 600 seconds. Health and
delivery acknowledgements are not proof of green CI or completed fixes. `policy list` includes full findings,
coverage, checks, worker roles, publisher identity, requested model/effort and run status. Actual model
provenance is recorded only when the provider reports it; otherwise it stays null.
Diff/prompt/output/log artifacts live beside each receipt in the user-only state
root `${PR_REVIEW_AUTO_HOME:-${XDG_STATE_HOME:-$HOME/.local/state}/frontend-skills/pr-review-auto}`.

```sh
bun <harness>/scripts/pr-review-auto.ts policy disable --id contributor-ui
bun <harness>/scripts/pr-review-auto.ts disable
```

Disable/change revokes queued dispatch and is rechecked before publication. A hosted
write already in flight can complete; this is sampled local enforcement, not an
atomic GitHub lock or sandbox around every integration on the machine. Other review
bots remain separately managed.

### Review worker boundary

Automatic review currently requires Darwin kernel 27 and Codex 0.167.0 from the
trusted Homebrew installation. Set `PR_REVIEW_CODEX_HOME` to an existing, dedicated
auth-only Codex home: no `config.toml`, `managed_config.toml` or enabled MCP servers.
Use provider-supported authentication; do not copy publisher credentials there.
System/launcher configuration, unsupported versions/platforms/providers, unknown
integrations or failed capability probes stop dispatch before a model call.

The trusted Codex backend retains provider authentication. Model shell tools get a
separate read-only permission profile for the pinned source, diff and trusted
guidance, with network disabled, a sanitized environment, publisher/auth/state
paths denied, and ambient hooks/plugins/MCP/delegation disabled. A real no-model
probe checks permitted reads, denied secrets/symlink escapes/writes and blocked
loopback before every worker. Isolation provenance is recorded in worker receipts.
This verified shell boundary is not a universal process/host security guarantee:
Keychain, Mach/Unix-socket side channels and hostile administrators are unverified.
Nor can a sandbox guarantee review completeness or semantic repair quality.

Transient GitHub verification reads retry from a completed review without another
model pass. Failed workers/incomplete results stay visible and do not loop paid retries on the
same candidate. Fix the blocker, then `policy retry --id <id>`. An uncertain GitHub
write is reconciled by its unique review marker, pinned head, event and publisher identity before another publication; do not
clear uncertain evidence to force a retry. If head/base/policy/rubric advances, the
frozen historical authority and coverage are validated before acknowledging the old
marker; a separate fresh review is still required. Legacy uncertain receipts without
frozen authority require manual reconciliation, never automatic re-publication. Crashed runner locks require confirming
that the recorded process is no longer running before removing only its own lock.

Temporary source clones are removed after each run; diff and review receipts remain.

Controller-published findings also wake a bound original owner when ordinary
feedback excludes the dispatcher's own account. The original session reads private
ledger findings without broadening the public severity filter. This does not create
an owner binding for another contributor or replace an unavailable original session.

Review workers never become repair owners. For unattended fixes, use the
[original-session maintenance binding](../resolve-pr-feedback/AUTO-REVIEW.md).

Sources: [GitHub review API](https://docs.github.com/en/rest/pulls/reviews#create-a-review-for-a-pull-request),
[paginated check runs](https://docs.github.com/en/rest/checks/runs#list-check-runs-for-a-git-reference).

Isolation implementation reference: [Codex 0.167 sandbox configuration](https://github.com/openai/codex/blob/rust-v0.167.0/codex-rs/cli/src/debug_sandbox.rs).
