# Orchestrators

Start with the existing delivery loop. GitHub Actions is a plausible first remote
orchestrator for this GitHub-hosted harness; it is not a reason to deploy a new service.
This is an initial survey, checked 2026-10-22, not a product ranking or setup authorization.
Recheck current APIs, plans, limits, and security documentation before choosing.

An orchestrator receives triggers, records run state, and starts execution on a runner.
It is not the runner, agent model, ticket tracker, or skill, even when one product fills
several roles. Select by the failure semantics needed for one real task.

## Choices

| Type | Fits when | Trade-off and evidence to obtain |
| --- | --- | --- |
| Existing interactive host | A person dispatches and inspects one task at a time | Cheapest pilot; verify lifecycle and tool availability. A desktop session is not evidence of unattended remote operation. |
| Git-host CI | Repository events and finite tasks dominate | Reuse identities and run pages; verify event chaining, queue behavior, timeouts, and scoped writes. |
| Managed agent platform | Its triggers, model, and execution environment already fit | Less infrastructure; verify cancellation, replay, audit export, permissions, and whether it can preserve this harness's gates. |
| Durable workflow engine | Cross-service state, recovery, and long-lived coordination are demonstrated needs | More operational and workflow-code ownership; verify side-effect retry semantics, not merely persistence. |
| Small custom service plus queue/store | A proven integration gap cannot be filled above | Own webhook authentication, durable claims, recovery, reconciliation, and upgrades. Avoid building another tracker. |

### GitHub Actions

Actions supports repository events, explicit dispatch, and schedules; choose manual dispatch
first for a proposed remote pilot. Its default token suppresses most follow-on workflow
events; dispatch events are exceptions, and certain PR events can require approval.
Do not assume a pushed PR will start the next review without human intervention.
Pick and test explicit dispatch or an appropriately scoped app identity when a chain is
needed; do not create credentials during planning.
[Event and token semantics](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows).

Concurrency groups constrain simultaneous execution, but are not a durable work ledger.
Pending runs can be replaced by newer ones, and ordering is not guaranteed. Keep a stable
task/ticket key, completed-result lookup, and crash recovery separate from serialization.
Do not cancel a writing run just to process a newer duplicate without reconciling its
side effects. [Concurrency semantics](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency).

Keep orchestration instructions on a trusted revision. Treat issue text and patches as
data; scope tokens by job and keep untrusted execution away from privileged credentials.
Never combine privileged event handling with executing untrusted PR code in that job.
[Secure use](https://docs.github.com/en/actions/reference/security/secure-use).

### Durable engines and custom services

Temporal distinguishes workflow definitions from durable executions. It is a candidate
when recoverable coordination is actually required, not an automatic upgrade from CI.
Recovery does not make external PR creation exactly-once: side effects still need stable
keys and reconciliation. [Workflow concepts](https://docs.temporal.io/workflows),
[activity idempotency](https://docs.temporal.io/activity-definition#idempotency).

## T3 host capabilities

This thread exposed `delegate_task`, `task_status`, `task_cancel`, `schedule_task`, and
`watch_pull_request` during research. Availability is host-specific, not a promise that
every installation supports a remote factory. Inspect live schemas and provider/model
catalogs; do not infer durable queues, claim semantics, or uptime from tool names.

Delegated child work is distinct from a top-level conversation, recurring schedule, or
PR watcher. Each needs its own explicit scope/authorization. Keep existing native
[composition and monitoring](../shared/T3CODE-NATIVE.md) rather than adding a second loop.
No child task, schedule, or watcher is started by `/software-factory`.

## Before committing to a product

Answer from primary docs and a disposable test: how are triggers authenticated and
acknowledged; can delivery repeat or reorder; where do claims and completed results live;
what happens after a crash, timeout, cancellation, or credential revocation; which actor
can retry; how are limits, costs, and the kill switch enforced?

Choose only after a repeated event yields one intended artifact and a crash after that
artifact is created can be reconciled without another artifact. A successful happy-path
demo alone does not establish readiness for unattended operation.
