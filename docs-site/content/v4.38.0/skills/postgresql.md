---
title: "/postgresql"
description: "Engineer PostgreSQL from workload evidence. Use for SQL pull requests, schemas, indexes, transactions, migrations, performance, security/RLS, backup/PITR, reports, and generated Drizzle or Jet SQL."
type: skill
sidebar:
  label: "/postgresql"
---
![Diagram of the /postgresql skill](/diagrams/skills/postgresql.svg)

[Open the editable Excalidraw source](/diagrams/skills/postgresql.excalidraw)

Treat "best SQL" as a measured fit to one workload, version, provider, and
recovery contract. Raw PostgreSQL semantics and actual emitted SQL outrank an
ORM, query builder, provider abstraction, or vendor claim.

## Workflow

1. **Choose the mode:** author/review SQL; model schema/indexes; orchestrate
   transactions/queues; migrate; diagnose/tune; operate/recover; secure/tenant;
   report; or integrate Jet.
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
| Review a SQL pull request or database diff | [SQL-PR-REVIEW.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/SQL-PR-REVIEW.md) plus every domain reference touched by the diff |
| Query semantics, joins, pagination, DML | [SQL-AUTHORING.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/SQL-AUTHORING.md) |
| Types, constraints, indexes, partitioning | [SCHEMA-INDEXES.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/SCHEMA-INDEXES.md) |
| Isolation, retries, locks, queues, budgets | [TRANSACTIONS-ORCHESTRATION.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/TRANSACTIONS-ORCHESTRATION.md) |
| Online DDL, backfills, generated migrations | [MIGRATIONS.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/MIGRATIONS.md) |
| Plans, statistics, benchmarking, regressions | [PERFORMANCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/PERFORMANCE.md) |
| Pooling, vacuum, WAL, replication, HA, PITR | [OPERATIONS-RECOVERY.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/OPERATIONS-RECOVERY.md) |
| Roles, RLS, tenant isolation, sensitive copies | [SECURITY-TENANCY.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/SECURITY-TENANCY.md) |
| Operational recap or database health report | [WEEKLY-REPORT.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/WEEKLY-REPORT.md) |
| Supported features, managed-provider boundaries | [VERSIONS-PROVIDERS.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/VERSIONS-PROVIDERS.md) |
| Drizzle-generated SQL or migrations | [SQL-AUTHORING.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/SQL-AUTHORING.md), [MIGRATIONS.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/MIGRATIONS.md), and [VERSIONS-PROVIDERS.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/VERSIONS-PROVIDERS.md) |
| Go code using `go-jet/jet` | [GO-JET.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/GO-JET.md) |
| Evidence strength or corpus refresh | [EVIDENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/EVIDENCE.md) |

Treat PostgreSQL 19 as preview. Re-check current documentation before using
version-, extension-, provider-, Drizzle-, or Jet-specific behavior.

## Output contract

Return: **context -> evidence -> recommendation -> exact SQL/code -> impact and
risks -> rollout/approval gate -> rollback/forward-fix -> verification**. For a
review, report correctness and safety findings before style. For missing live
evidence, provide bounded collection queries and stop at a hypothesis.
