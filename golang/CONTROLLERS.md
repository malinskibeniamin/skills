# Kubernetes controllers

Catalog: [rule catalog](../golang-review/RULES.md).

- **controller-requeue-is-the-retry-loop** -- requeueing owns retries; inner retry loops
  around apply/status fight backoff, cancellation, and resource-version semantics.
- **controllers-converge-with-server-side-apply** -- SSA patches for controller-owned
  resources; create/update special cases and whole-object writes lose field ownership
  and idempotency.
- **controller-errors-preserve-last-good-state** -- propagate reconciliation and
  status-write errors; a transient dependency failure is never proof that observed
  state was deleted or advanced. Wrong handling converts unavailability into
  destructive drift.
- **controller-failures-are-visible-in-status** -- publish failure/in-progress through
  status, events, or the operation record before returning the error; logs alone leave
  users unable to tell active from stuck.
- **kubernetes-ownership-matches-resource-scope** -- owner references and watches for
  namespaced children; explicit finalizer cleanup when owned resources can be
  cluster-scoped (they outlive their namespace owner).
- **kubernetes-teardown-waits-for-finalizers** -- delete ownership layers in reverse
  dependency order; keep providers available until dependents and finalizers are gone,
  or teardown becomes manual finalizer surgery.
- **controller-tests-use-production-wiring-and-public-readiness** -- exercise the real
  manager wiring and assert convergence through the resource's public readiness
  contract; render-helper tests pass with the reconciler unwired.
- **reconcile-only-semantic-state-changes** -- see [CONCURRENCY.md](CONCURRENCY.md);
  hash desired state, skip no-ops, coalesce.
