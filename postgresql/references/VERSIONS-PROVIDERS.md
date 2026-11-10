# Versions and providers

## Automatic version discovery

Run discovery before version-sensitive authoring, review, or diagnosis. Resolve
the runtime first: host, container, remote shell, and CI can select different
clients. Use the intended runtime's `command -v psql` and the helper (paths below
are relative to the skill directory):

```sh
bun scripts/detect-version.ts
bun scripts/detect-version.ts --psql /path/to/psql
# Only after confirming this libpq service selects the authorized target:
bun scripts/detect-version.ts --psql /path/to/psql --service project-readonly
```

The default reads only `psql --version`; it never connects. `--service` selects
an existing libpq service, uses `-X` (skip startup scripts), `-w` (no password
prompt), `ON_ERROR_STOP`, a read-only transaction, query/lock timeouts, and a
10-second process deadline. Authentication uses existing libpq configuration;
do not print credentials, connection URLs, service files, or raw connection
errors. It does not create a service, install tools, or retry failures.
Nonzero exit means discovery failed, not a compatible/default server.

Without Bun/psql, use the existing authorized database connector/session:

```sql
SELECT pg_catalog.current_setting('server_version') AS server_version,
       pg_catalog.current_setting('server_version_num') AS server_version_num,
       pg_catalog.version() AS build;
```

Keep that query read-only and bounded under the same live gate. Never connect
to an implicit localhost/default database to fill a missing target. If no
connection is authorized, inspect image tags/digests, Compose/Helm/Terraform,
CI service versions, and provider config; label them **intended**, not deployed.
Ask only for the missing target/evidence that changes the recommendation.

Interpret evidence separately:

- Server version governs SQL, catalogs, locks, and server settings; client
  version governs psql options/backslash commands. An older client against a
  newer server can fail catalog commands. Prefer a matching/newer supported
  client, but do not install/upgrade automatically. See the
  [psql manual](https://www.postgresql.org/docs/19/app-psql.html).
- Preserve the version text and `version()` build/fork evidence. For 10+,
  `server_version_num / 10000` (integer division) gives the major; before 10,
  the first two components form the major (9.6.24 = 90624).
  `19beta4`, `19rc1`, and `19.0` can all have numeric version 190000: retain the
  text's channel and RC/beta number. An unrecognized banner stays unknown;
  a parseable fork version is not proof of stock compatibility. See
  [version functions](https://www.postgresql.org/docs/19/functions-info.html#FUNCTIONS-INFO-VERSION).
- Detect each relevant endpoint in mixed-version rollouts/replication; a pooler
  or proxy's advertised version may not prove every backend's capabilities.
  Inspect extension/driver/ORM/tool versions independently; `psql --version`
  does not identify the application's libpq, `pg_dump`, or `pg_restore`.
- Use `/docs/<major>/` plus exact release notes, not `/current/` or `/devel/`.
  For 19, load [POSTGRESQL-19.md](POSTGRESQL-19.md). For newer/unknown majors,
  research their official release notes and compatibility section at use time;
  report unverified behavior instead of extrapolating 19 guarantees.

## Version policy

PostgreSQL supports a major for five years and recommends the current minor.
Major upgrades require dump/restore, `pg_upgrade`, or logical migration; read
all intervening major release notes. Minor upgrades still require their release
notes. Re-check the live [version policy](https://www.postgresql.org/support/versioning/)
and [security notices](https://www.postgresql.org/support/security/).

Snapshot checked on **2026-11-10**; not a permanent latest-version table:

| Major | Current minor | Treatment |
|---|---:|---|
| 14 | 14.24 | Supported until 2026-11-12; warn and plan upgrade |
| 15 | 15.19 | Supported |
| 16 | 16.15 | Supported; includes `pg_stat_io` |
| 17 | 17.11 | Supported; includes incremental base backup and `JSON_TABLE` |
| 18 | 18.6 | Current stable; verify optimizer, async I/O, temporal, OAuth, and compatibility behavior |
| 19 | RC1 | **Prerelease testing only**; see [19 guidance](POSTGRESQL-19.md); re-check before every use |

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
