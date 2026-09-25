---
title: "/postgresql"
description: "Engineer PostgreSQL from workload evidence. Use for SQL pull requests, schemas, indexes, transactions, migrations, performance, security/RLS, backup/PITR, reports, and generated Drizzle or Jet SQL."
type: skill
sidebar:
  label: "/postgresql"
---
![Diagram of the /postgresql skill](/diagrams/skills/postgresql.svg)

[Open the editable Excalidraw source](/diagrams/skills/postgresql.excalidraw)


Fit SQL to one measured workload, version, provider, and recovery contract. PostgreSQL semantics and actual SQL outrank ORM/query-builder/provider claims.

## Workflow

1. **Mode:** author/review SQL; schema/index; transactions/queues; migration; tune; operate/recover; secure/tenant; report; or Jet.
2. **Contract:** version/fork/provider, extensions/topology/pooler, workload, volume/skew/growth, concurrency, SLO, RPO/RTO, security, and change window. Mark unknowns; never invent production facts.
3. **Ground truth:** exact SQL/parameters, transaction boundary, schema/catalog, representative data, plan/stats, waits/locks, resources, and deploy/config history.
4. **Smallest reversible change:** evidence, hypothesis, expected effect, write/storage/lock/WAL cost, unhappy paths, version/provider caveats, rollback/forward-fix, abort criteria, verification.
5. **Live gate:** production diagnosis defaults read-only, bounded, time-limited. Get explicit approval for writes, DDL, cancellation, role/policy/config changes, failover, restore, or destructive commands; reconfirm target.
6. **Execute once:** preserve exact SQL/transaction boundaries; observe rollout and stop on abort criteria.
7. **Evidence:** verify DB and user outcomes, record before/after window, check recovery, name uncertainty.

## Route

| Work | Read |
|---|---|
| SQL PR/diff | [SQL-PR-REVIEW.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/postgresql/references/SQL-PR-REVIEW.md) plus touched domains |
| Queries, joins, pagination, DML | [SQL-AUTHORING.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/postgresql/references/SQL-AUTHORING.md) |
| Types, constraints, indexes, partitions | [SCHEMA-INDEXES.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/postgresql/references/SCHEMA-INDEXES.md) |
| Isolation, retries, locks, queues | [TRANSACTIONS-ORCHESTRATION.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/postgresql/references/TRANSACTIONS-ORCHESTRATION.md) |
| DDL, backfills, generated migrations | [MIGRATIONS.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/postgresql/references/MIGRATIONS.md) |
| Plans, stats, benchmarks | [PERFORMANCE.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/postgresql/references/PERFORMANCE.md) |
| Pooling, vacuum, WAL, HA, PITR | [OPERATIONS-RECOVERY.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/postgresql/references/OPERATIONS-RECOVERY.md) |
| Roles, RLS, tenant isolation | [SECURITY-TENANCY.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/postgresql/references/SECURITY-TENANCY.md) |
| Health/weekly report | [WEEKLY-REPORT.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/postgresql/references/WEEKLY-REPORT.md) |
| Versions/providers | [VERSIONS-PROVIDERS.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/postgresql/references/VERSIONS-PROVIDERS.md) |
| Drizzle | [SQL-AUTHORING.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/postgresql/references/SQL-AUTHORING.md), migrations, versions/providers |
| `go-jet/jet` | [GO-JET.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/postgresql/references/GO-JET.md) |
| Evidence/corpus refresh | [EVIDENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/postgresql/references/EVIDENCE.md) |

PostgreSQL 19 is preview. Recheck current docs for version-, extension-, provider-, Drizzle-, or Jet-specific behavior.

## Output

**context -> evidence -> recommendation -> exact SQL/code -> impact/risks -> approval/rollout -> rollback/forward-fix -> verification**. Reviews put correctness/safety before style. Without live evidence, give bounded collection queries and stop at hypothesis.
