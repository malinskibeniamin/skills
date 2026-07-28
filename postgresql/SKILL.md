---
name: postgresql
description: "Engineer and operate PostgreSQL from workload evidence. Use for SQL, schemas, indexes, transactions, migrations, performance, security/RLS, backup/PITR, reports, and Drizzle- or Jet-generated SQL."
---

# Workload-informed PostgreSQL

Treat "best SQL" as a measured fit to one workload, version, provider, and
recovery contract. Raw PostgreSQL semantics and actual emitted SQL outrank an
ORM, query builder, provider abstraction, or vendor claim.

## Workflow

1. **Choose the mode:** author/review SQL; model schema/indexes; orchestrate
   transactions/queues; migrate; diagnose/tune; operate/recover; secure/tenant;
   report; or integrate Drizzle or Jet.
2. **Establish the contract:** PostgreSQL major/minor and provider/fork;
   extensions/topology/pooler; workload shape; data volume/skew/growth;
   concurrency; latency/throughput SLO; RPO/RTO; security; change window.
   Mark unknowns. Never invent production facts.
3. **Capture ground truth:** actual SQL and parameter shape, transaction
   boundary, schema/catalog state, representative data, plan/statistics, waits,
   locks, resource telemetry, and relevant deploy/config history.
4. **Propose the smallest reversible change:** state evidence, hypothesis,
   expected effect, write/storage/lock/WAL cost, unhappy paths, version/provider
   caveats, rollback or forward-fix, abort criteria, and verification.
5. **Gate live effects:** production diagnosis is read-only, bounded, and
   time-limited by default. Get explicit approval before writes, DDL,
   cancellation, role/policy/config changes, failover, restore, or destructive
   commands. Reconfirm the target.
6. **Execute one measured change:** preserve exact SQL and transaction
   boundaries. Observe during rollout; stop on abort criteria.
7. **Finish on evidence:** verify database and user outcomes, record the
   before/after window, check recovery, and name any remaining uncertainty.

## Route

| Work | Read |
|---|---|
| Query semantics, joins, pagination, DML | [SQL-AUTHORING.md](references/SQL-AUTHORING.md) |
| Types, constraints, indexes, partitioning | [SCHEMA-INDEXES.md](references/SCHEMA-INDEXES.md) |
| Isolation, retries, locks, queues, budgets | [TRANSACTIONS-ORCHESTRATION.md](references/TRANSACTIONS-ORCHESTRATION.md) |
| Online DDL, backfills, generated migrations | [MIGRATIONS.md](references/MIGRATIONS.md) |
| Plans, statistics, benchmarking, regressions | [PERFORMANCE.md](references/PERFORMANCE.md) |
| Pooling, vacuum, WAL, replication, HA, PITR | [OPERATIONS-RECOVERY.md](references/OPERATIONS-RECOVERY.md) |
| Roles, RLS, tenant isolation, sensitive copies | [SECURITY-TENANCY.md](references/SECURITY-TENANCY.md) |
| Operational recap or database health report | [WEEKLY-REPORT.md](references/WEEKLY-REPORT.md) |
| Supported features, managed-provider boundaries | [VERSIONS-PROVIDERS.md](references/VERSIONS-PROVIDERS.md) |
| TypeScript using Drizzle ORM or Drizzle Kit | [DRIZZLE.md](references/DRIZZLE.md) |
| Go code using `go-jet/jet` | [GO-JET.md](references/GO-JET.md) |
| Evidence strength or corpus refresh | [EVIDENCE.md](references/EVIDENCE.md) |

Treat PostgreSQL 19 as preview. Re-check current documentation before using
version-, extension-, provider-, Drizzle-, or Jet-specific behavior.

## Output contract

Return: **context -> evidence -> recommendation -> exact SQL/code -> impact and
risks -> rollout/approval gate -> rollback/forward-fix -> verification**. For a
review, report correctness and safety findings before style. For missing live
evidence, provide bounded collection queries and stop at a hypothesis.
