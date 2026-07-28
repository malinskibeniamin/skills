# Operations and recovery

## Connections and admission

Build one end-to-end connection budget across services, workers, replicas,
admin, migrations, CDC, and failover headroom. Bound each pool and queue.
Observe active/idle/waiting sessions, age, pool wait, churn, and saturation.

Choose direct, session pooling, transaction pooling, HTTP, or WebSocket access
from semantics. Transaction pooling can conflict with session state, temporary
objects, some prepared statements, advisory-lock assumptions, and `LISTEN`.
Test the deployed pooler/version rather than assuming compatibility.

Protect capacity before saturation with statement/lock/idle-transaction
timeouts, bounded queues, per-workload concurrency/rate budgets, query tags,
cancellation, circuit breakers, and graceful degradation. Preserve an admin
path. PlanetScale Traffic Control is one provider implementation; express the
portable objective, not its product API.

## MVCC and vacuum

Track churn, live/dead tuples, last vacuum/analyze, vacuum progress, oldest
`xmin`, transaction/freeze age, and table/index growth. Find long or
idle-in-transaction snapshots that pin cleanup. Tune hot tables from measured
size/change rate. Keep autovacuum enabled; it supports tuple reuse, statistics,
visibility maps, and wraparound safety. See
[routine vacuuming](https://www.postgresql.org/docs/18/routine-vacuuming.html).

Treat bloat estimates as estimates. Use rewrites, `VACUUM FULL`, or bulk-delete
machinery only after measuring reclaim need, locks, disk/WAL, duration, replicas,
and a lower-risk alternative.

## WAL, checkpoints, replication

- Trend WAL bytes/rate, full-page images, checkpoint frequency/time, archiver
  failures/backlog, slot retention, and disk headroom.
- Separate send/write/flush/replay lag from business freshness.
- Monitor sender/receiver state, slots, conflicts, replay cancellation, and
  retained WAL. Bound slot failure.
- Define the read consistency contract before routing to replicas.
- Rehearse primary and subscriber failover; account for cache coldness,
  fencing, connection recovery, extension/config parity, and slots.

## Backup, PITR, and HA

Replicas are not backups. A created backup is not proven recovery.

1. Define RPO/RTO and data/config/roles/extensions scope.
2. Choose logical export versus physical base/incremental backup plus WAL.
3. Encrypt, restrict, retain, and separate failure domains.
4. Monitor continuity and restore prerequisites.
5. Run timed restore drills and application invariant checks.
6. Record achieved RPO/RTO and remediate gaps.

`pg_dump` is logical and not a substitute for WAL-based PITR. Use the official
[continuous archiving/PITR](https://www.postgresql.org/docs/18/continuous-archiving.html)
contract. Provider branches/snapshots can accelerate recovery but need an exit
and portable recovery plan.

## Upgrades and incidents

Run the latest minor of a supported major after reading release notes. Major
upgrades require dump/restore, `pg_upgrade`, or logical migration; inspect every
intervening major's notes. Rehearse extensions, collations, replicas, slots,
plans/statistics, rollback/fail-forward, and application compatibility.

During an incident:

1. Preserve access and evidence; identify user impact and limiting resource.
2. Contain the workload with the smallest targeted reversible control.
3. Avoid broad kills/restarts/config changes without impact and recovery.
4. Diagnose query/lock/I/O/WAL/connection/replication evidence.
5. Verify recovery and watch recurrence.
6. Record trigger, timeline, containment, cause, and prevention.

Complete operations work with owner, SLO/RPO/RTO, thresholds, alerts,
runbook/approval boundaries, last drill, current risk, and verified recovery.
