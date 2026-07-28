# Versions and providers

## Version policy

PostgreSQL supports a major for five years and recommends the current minor.
Major upgrades require dump/restore, `pg_upgrade`, or logical migration; read
all intervening major release notes. Minor upgrades still require their release
notes. Re-check the live [version policy](https://www.postgresql.org/support/versioning/)
and [security notices](https://www.postgresql.org/support/security/).

Snapshot on 2026-07-28:

| Major | Current minor | Treatment |
|---|---:|---|
| 14 | 14.23 | Supported until 2026-11-12; warn and plan upgrade |
| 15 | 15.18 | Supported |
| 16 | 16.14 | Supported; includes `pg_stat_io` |
| 17 | 17.10 | Supported; includes incremental base backup and `JSON_TABLE` |
| 18 | 18.4 | Current; verify new optimizer, async I/O, temporal, OAuth, and compatibility behavior |
| 19 | Beta 2 | **Preview only**; re-check before every use |

Do not infer features from the current manual for an older target. Important
examples: `MERGE` and `NULLS NOT DISTINCT` are 15+; `pg_stat_io` is 16+;
`JSON_TABLE` and incremental base backup are 17+. Treat PostgreSQL 19 material
as preview, not production guidance.

## Provider contract

Record:

- stock PostgreSQL version/fork and extension/config allowlist;
- compute/storage architecture and cache behavior;
- direct/pooler endpoints and pooling mode;
- connection/autoscaling/scale-to-zero limits;
- backup/PITR retention, restore primitive, HA/failover/RPO/RTO;
- branching/cloning semantics and sensitive-data controls;
- metrics/logs/query-insight retention and export;
- maintenance/upgrade cadence, region/network/egress, support boundaries.

Managed-service behavior is not PostgreSQL behavior:

- Neon/Lakebase compute-storage separation enables provider-specific branching,
  cache, autoscaling, and failover trade-offs.
- PlanetScale Traffic Control and Query Insights are provider controls; express
  portable admission/observability goals when they are absent.
- Supabase adds PostgREST, Supavisor, Auth/RLS helpers, extensions, and its own
  upgrade/support policy.
- Databricks SQL/Spark SQL syntax and optimizer are not PostgreSQL SQL. Lakebase
  articles mix PostgreSQL patterns with provider guarantees.

Keep serverless and branch claims conditional. Measure cold starts, connection
storms, working-set recovery, scale lag, price/performance, PII copying, TTL,
ownership, and exit/recovery.

## Abstraction/version boundaries

For any driver, ORM, migration tool, or builder:

1. Read the lockfile/module version and matching release notes/source.
2. Capture actual parameterized SQL and runtime mappings.
3. Review transaction/pooler, migration, escaping, and type behavior.
4. Re-check prerelease APIs at use time.

Drizzle's corpus is evidence for these generic guardrails, not a separate
timeless PostgreSQL contract. Its stable and prerelease lines have differed in
escaping, codecs, migration tracking/diffs, casing, RLS helpers, and prepared
queries. Consult the pinned [release](https://github.com/drizzle-team/drizzle-orm/releases),
inspect generated SQL, and route the concern to the matching domain reference.

Complete when every recommendation identifies the exact version/provider,
portable versus provider-specific behavior, current source, and fallback.
