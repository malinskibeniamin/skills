# Performance diagnosis

## Build the loop

1. Define the affected user/workload, SLO, baseline, and regression window.
2. Rank normalized queries by **total impact** and **per-call/tail harm**.
3. Correlate query changes with deploys, data/statistics, waits/locks, CPU,
   memory, I/O, temp spill, WAL/checkpoints, connections, and replication.
4. Capture a representative plan and bindings safely.
5. Form one falsifiable hypothesis; make the smallest reversible change.
6. Re-run with representative volume, skew, concurrency, cache, and prepared
   statement mode.
7. Compare database and user outcomes; retain a regression guard.

`pg_stat_statements` supplies calls, planning/execution time, rows, blocks/temp
I/O, WAL, JIT, and parallel metrics, but aggregates do not replace request-level
p95/p99. Statistics can lag, reset, and be transaction-cached; preserve the
observation window. See [pg_stat_statements](https://www.postgresql.org/docs/18/pgstatstatements.html)
and the [statistics system](https://www.postgresql.org/docs/18/monitoring-stats.html).

## Read plans, not one cost number

Use `EXPLAIN` estimates first. `EXPLAIN (ANALYZE, ...)` executes the statement:
run it only where the statement and potential runtime are safe. For writes, use
a representative non-production environment or an explicitly approved
transaction/rollback plan that accounts for side effects and locks.

Inspect:

- estimated versus actual rows and loops;
- join/scan method, filters and rows removed;
- heap fetches, buffers, I/O timing, temp spill, WAL;
- sort/hash memory and batches;
- planning/execution time, JIT/parallelism, settings;
- lock/wait/concurrency behavior outside the plan.

Large row-estimate errors point first to stale/insufficient/correlated
statistics, skew, parameter sensitivity, or predicate shape, not automatically
a missing index. Use extended statistics when the measured correlation requires
them. Official guides: [EXPLAIN](https://www.postgresql.org/docs/18/using-explain.html)
and [planner statistics](https://www.postgresql.org/docs/18/planner-stats.html).

## Tune the limiting resource

- Query/schema/statistics before global knobs.
- Calculate multiplicative memory across sessions, plan nodes, and parallel
  workers; `work_mem` is not a server-wide cap.
- Bound active concurrency. More connections can reduce throughput.
- Consider write amplification, WAL, vacuum, cache, storage, and build cost for
  every read optimization.
- Reproduce cold/warm and provider cache behavior separately.
- Keep plan forcing/hints exceptional, versioned, and removable.

## Benchmark honestly

Preserve correctness; use representative schema, volume/distribution, working
set, transaction mix, concurrency, network, versions, and configuration.
Report throughput with p50/p95/p99, errors, CPU, memory, I/O, WAL, storage, and
cost. Repeat runs and publish commands. Label vendor benchmarks with their
method/date; PlanetScale's [benchmark methodology](https://planetscale.com/blog/benchmarking-postgres)
is a useful shape, not independent proof of its results.

Complete with a before/after bundle: fingerprint, bindings/data shape, plan,
latency/throughput, calls/total time, rows, buffers/I/O/temp/WAL, locks/waits,
resources, concurrent load, and rollback threshold.
