# Transactions and orchestration

## Protect one invariant

- State the invariant and smallest transaction that protects it.
- Keep transactions short. Do not wait for users, networks, queues, or
  unbounded computation while holding a snapshot or lock.
- Acquire shared resources in a consistent order.
- Use the weakest lock/isolation level that actually protects the invariant.
- Set bounded `lock_timeout`, `statement_timeout`, and
  `idle_in_transaction_session_timeout` for the workload/role.
- Keep external effects idempotent or behind an outbox; a database rollback
  cannot retract an already-sent email or API call.
- Use the transaction handle for every operation protecting the invariant. A
  call through an outer database handle escapes the transaction. Treat nested
  transaction helpers as savepoints unless the pinned integration proves a
  different contract.
- Route read-after-write and other consistency-sensitive reads through the
  primary, the transaction connection, or the write's `RETURNING` data. Assume
  an asynchronous replica can be stale.

PostgreSQL defaults to Read Committed. Repeatable Read gives a stable
transaction snapshot but can abort on conflicts. Serializable prevents
serialization anomalies by aborting work, so retry the **whole transaction** on
SQLSTATE `40001`. Retry deadlocks (`40P01`) similarly with a bounded, jittered
policy and idempotent effects. Never retry arbitrary errors.

Review exact behavior in [transaction isolation](https://www.postgresql.org/docs/18/transaction-iso.html)
and [explicit locking](https://www.postgresql.org/docs/18/explicit-locking.html).

## Prefer atomic state transitions

Use constraints, conditional DML, `INSERT ... ON CONFLICT`, and `RETURNING`
instead of read-then-write checks. Verify affected-row count/postcondition.
Place retry logic outside the transaction so each attempt starts clean.

## PostgreSQL-backed queue

Use PostgreSQL as a queue only with bounded work and recoverability:

1. Index the eligible-state, availability, priority, and stable FIFO key.
2. Claim a bounded batch with `FOR UPDATE SKIP LOCKED`.
3. Move state and write an expiring lease in the same short transaction.
4. Make processing and callbacks idempotent; delivery is at-least-once.
5. Requeue expired leases; cap retries; preserve a dead-letter state.
6. Apply per-workload concurrency/rate/token budgets during claim.
7. Partition/archive when churn and retention justify it; watch vacuum.

```sql
WITH claim AS (
  SELECT id
  FROM jobs
  WHERE status = 'queued'
    AND available_at <= clock_timestamp()
  ORDER BY priority DESC, available_at, id
  FOR UPDATE SKIP LOCKED
  LIMIT $1
)
UPDATE jobs AS job
SET status = 'running',
    lease_expires_at = clock_timestamp() + $2::interval,
    worker_id = $3
FROM claim
WHERE job.id = claim.id
RETURNING job.id, job.status, job.lease_expires_at, job.worker_id;
```

Measure queue depth and oldest age by priority, claim/service/end-to-end time,
lease expiry, retries, dead letters, saturation, fairness/starvation, and vacuum
pressure. Use `LISTEN/NOTIFY` only as a low-latency hint with durable polling as
fallback. The pattern is illustrated by Databricks'
[Lakebase orchestration write-up](https://www.databricks.com/blog/simplify-ai-agent-orchestration-lakebase-postgres);
its provider/scale claims are not portable evidence.

Complete when the invariant, isolation/locks, retry boundary, idempotency,
bounds, crash recovery, metrics, and failure test are explicit.
