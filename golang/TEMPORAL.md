# Temporal

Catalog: [rule catalog](../golang-review/RULES.md).

## Determinism

- **temporal-code-uses-deterministic-runtime-apis** -- `workflow.Now`, `workflow.Sleep`,
  the test environment's clock; never wall-clock or unmodeled control flow. Check every
  workflow edit for replay nondeterminism.
- **temporal-external-calls-run-as-activities** -- external service calls happen in
  worker-owned activities, which own retry/timeout semantics and keep replay deterministic.

## Versioning and lifecycle

- **version-temporal-workflow-history-then-retire-safely** -- behavior changes to live
  workflows get version markers while deployed histories can replay them; keep input
  changes additive (deprecate + add, handle both); remove stale version branches
  deliberately once no compatible history remains. Both halves matter: unversioned
  changes break running workflows, permanent obsolete branches rot the code.
- **serialize-reentrant-workflows-by-stable-id** -- one stable workflow ID per resource
  plus a reuse policy that allows recovery after failure without overlapping runs.
- **continue-as-new-preserves-and-coalesces-signals** -- before Continue-As-New, drain
  or carry pending signals and coalesce replaceable snapshots to the newest value;
  rotate before history limits.

## Failure handling

- **temporal-retries-at-the-failing-activity** -- bounded activities, retry at the
  failing activity; never rerun the whole workflow for one transient step or hide a
  long poll inside an activity.
- **deterministic-temporal-failures-are-nonretryable** -- validation errors, immutable
  artifacts, and other deterministic failures are non-retryable; retrying identical
  input only delays the terminal failure.
- **resource-lifecycle-operations-are-idempotent** -- activities repeat: see
  [CONCURRENCY.md](CONCURRENCY.md).
