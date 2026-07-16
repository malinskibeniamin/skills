# Concurrency & lifecycle

Catalog: [rule catalog](../golang-review/RULES.md).

## Bounds

- **bound-workload-and-attacker-controlled-growth** -- the catalog's highest-support rule (28 examples):
  every tenant- or workload-controlled path gets explicit memory, cardinality, fan-out,
  concurrency, and response-size bounds. Unbounded slices, caches, channels, label sets,
  and streams turn ordinary input into OOM and latency incidents.

## Context

- **propagate-caller-context-and-deadline** -- pass the caller's context through the
  chain; its cancellation and deadline govern. No `context.Background()` mid-request,
  no shorter library deadlines that steal the caller's budget.
- **context-lifetime-matches-operation-owner** -- workers, monitors, watchers, and
  cleanup derive their context from the owning lifecycle, not from the request that
  happened to start them. Request cancellation must not kill durable work; shutdown
  must still stop it deterministically.

## Shared state

- **shared-mutable-initialization-has-one-sync-owner** -- one synchronization owner per
  shared mutable value; expensive process-wide state initializes lazily behind a single
  `sync.Once`-style path. Mixed locking plus casual lazy init duplicates clients and
  publishes partial state.
- **publish-cache-snapshots-atomically** -- swap shared cache/policy state only after a
  complete successful refresh; on partial failure keep the last good snapshot. A
  filtered or failed refresh must not shrink a complete cache.
- **mutable-buffer-ownership-is-explicit** -- document who owns a message/buffer, copy
  only at ownership boundaries, publish cached state as owned deep clones. Aliasing
  races and reflexive copying both hide the lifetime contract.
- **blocking-hooks-stay-outside-critical-locks** -- no blocking I/O, teardown, or user
  callbacks under a lock or inside a protocol progress loop; one slow callback becomes
  global starvation.

## Shutdown and progress

- **async-resource-lifetime-waits-for-all-users** -- close channels, processors, and
  shared resources only after every producer, callback, and worker reached a defined
  happens-before boundary. Shutdown by intent instead of synchronization sends into
  abandoned channels.
- **commit-progress-only-after-durable-processing** -- offsets, checkpoints, and drop
  eligibility advance only after required side effects are durable; committing first
  turns a crash into acknowledged data loss.
- **resource-lifecycle-operations-are-idempotent** -- retriable create/delete mutate
  directly and classify `AlreadyExists`/`NotFound` as success (`errors.Is`), instead
  of read-before-write preflights that race concurrent actors.
- **best-effort-batches-preserve-item-results** -- independent batch items each get
  attempted (bounded), order preserved, per-item failures returned. Fail-fast hides
  useful results; unbounded fan-out is the opposite failure.

## Performance

- **reconcile-only-semantic-state-changes** -- hash or diff desired state, skip no-op
  reconciliations, coalesce related changes; identical re-applies are pure churn.
