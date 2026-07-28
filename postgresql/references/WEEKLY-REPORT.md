# Weekly PostgreSQL report

Treat the report as a triage interface, not auto-remediation. Compare the
current window with the prior window and a representative baseline. Annotate
deploys, migrations, incidents, traffic mix, statistics resets, failovers, and
maintenance. Use rates, percentiles, deltas, and workload-normalized values.

PlanetScale's supplied [weekly report](https://planetscale.com/changelog/postgres-weekly-database-reports)
provides the starting shape: anomalies; expensive queries by total time with
calls, p99, and cache-hit ratio; schema suggestions; throttles; storage delta;
CPU and memory. Add the operational/recovery evidence below.

## Report contract

1. **Executive:** SLO/RPO/RTO state; healthy/watch/action; material user
   regressions; risk; cost/capacity; decisions needed.
2. **Workload:** transactions/queries, reads/writes, rows/bytes, concurrency,
   connections/pool wait, peak windows, tenant/job mix, queue depth/age.
3. **Latency/reliability:** request and query p50/p95/p99; timeout, cancellation,
   error, deadlock, serialization, and availability rates.
4. **Top SQL:** redacted fingerprint/query ID by total time and calls plus
   external tail latency, rows, I/O/temp, WAL, errors, and plan change.
5. **Contention:** wait distribution, blocked time/chains, long and
   idle-in-transaction sessions, oldest transaction.
6. **Tables/indexes:** growth/churn, dead tuples, vacuum/analyze/freeze age, scan
   mix, bloat evidence, duplicate/unused candidates with observation window.
7. **I/O/WAL/checkpoints:** bytes/latency, temp spill, WAL/full-page images,
   checkpoint/archiver health, disk headroom.
8. **Replication/recovery:** lag dimensions, slot retention/conflicts, latest
   successful backup, WAL continuity, last restore drill and achieved RPO/RTO.
9. **Changes/security:** deploy/DDL/config/extensions/version, current minor and
   EOL, live security-notice check, privilege/network/RLS exceptions.
10. **Actions:** evidence -> hypothesis -> change -> expected impact -> risk ->
    owner/date -> verification and rollback. Carry unresolved actions forward.

Avoid treating one cache-hit ratio, average latency, total connection count,
bloat estimate, or "unused index" count as a verdict.

## Bounded read-only collection

Run against the intended database with a short statement timeout. Statistics
are cumulative and can reset; snapshot and calculate interval deltas.

```sql
BEGIN READ ONLY;
SET LOCAL statement_timeout = '5s';

SELECT current_database(), current_setting('server_version'),
       current_setting('server_version_num')::integer;

SELECT stats_reset, xact_commit, xact_rollback,
       blks_read, blks_hit, temp_files, temp_bytes,
       deadlocks, checksum_failures
FROM pg_stat_database
WHERE datname = current_database();

SELECT state, wait_event_type, wait_event, count(*) AS sessions
FROM pg_stat_activity
WHERE datname = current_database()
GROUP BY state, wait_event_type, wait_event
ORDER BY sessions DESC;

SELECT queryid, calls, total_exec_time, mean_exec_time, max_exec_time,
       rows, shared_blks_read, shared_blks_hit, temp_blks_written,
       wal_bytes
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

SELECT schemaname, relname, n_live_tup, n_dead_tup,
       last_autovacuum, last_autoanalyze,
       autovacuum_count, autoanalyze_count
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 20;

SELECT slot_name, slot_type, active,
       pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) AS retained_wal_bytes
FROM pg_replication_slots
ORDER BY retained_wal_bytes DESC NULLS LAST;

COMMIT;
```

`pg_stat_statements` requires the extension and privileges; tail percentiles
usually come from application/provider histograms rather than its aggregates.
`pg_stat_io` is PostgreSQL 16+; version-gate any I/O query. Provider CPU,
memory, storage, network/egress, pool, and backup evidence must come from that
provider's current metrics contract.

Redact literals/secrets and link to a time-bounded evidence window. A
recommendation in the report is a hypothesis until plan/workload evidence and
change safety are reviewed.

Complete when the report names the comparison windows and resets, explains user
impact, distinguishes symptoms from hypotheses, records restore confidence,
and gives every action an owner, verification, and recovery path.
