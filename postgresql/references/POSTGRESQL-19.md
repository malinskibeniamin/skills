# PostgreSQL 19: version-aware assistance and review

Read when either client/server is 19, or a change targets an upgrade to 19.
Use [version discovery](VERSIONS-PROVIDERS.md#automatic-version-discovery)
first; apply only relevant checks alongside the owning domain reference.

## Release status and RC-specific evidence

Checked **2026-11-10**: the official [beta page](https://www.postgresql.org/developer/beta/)
lists **19 RC1**, not GA. The [RC1 announcement](https://www.postgresql.org/about/news/postgresql-19-rc-1-released-3409/)
was published October 15; RC2 is planned for November 12 and GA for November 19.
These are plans, not proof of release. Recheck the announcement, beta page,
[19 release notes](https://www.postgresql.org/docs/19/release-19.html), and
[open items](https://wiki.postgresql.org/wiki/PostgreSQL_19_Open_Items) each time.
Keep RC testing isolated from production; revalidate provider/extension support
and the actual RC-to-RC/GA upgrade procedure rather than assuming compatibility.

RC1 fixes since Beta 4 cover concurrent REPACK, plan advice, nullability-based
planner transformations, automatic logical replication, parallel autovacuum,
FDW statistics-import ownership, and JSON COPY query aliases. When reproducing
one of these failures, record the exact build and retest a current candidate;
do not generalize a beta bug or a proposed open-item fix to every 19 build.

The checked open-items page also lists fixes **after RC1, before RC2**, including
upgrade-related text-search/pg_trgm index omissions, volatile-clause eager
aggregation, and psql catalog commands with translated messages/non-UTF-8
encoding. A resolved item on that page is not evidence that RC1 contains its
fix: match the fix commit to the tested build and reproduce the affected query,
upgrade, or client-encoding case before claiming compatibility.

## Upgrade compatibility checks

The [19 migration section](https://www.postgresql.org/docs/19/release-19.html#RELEASE-19-MIGRATION)
changes these review decisions:

- Audit legacy string escaping/dumps: `standard_conforming_strings` is always
  on; `escape_string_warning` is removed. Dumps made with older tools and the
  former setting off need compatible regeneration.
- RADIUS authentication is removed; successful MD5 auth warns. Review the
  authentication migration rather than suppressing warnings as the fix.
- Upgrade preflight must catch CR/LF in object names and `btree_gist`
  inet/cidr indexes; these can block `pg_upgrade`. `MULE_INTERNAL` requires
  dump/restore with a different encoding.
- Assert empty `json_array()` results, FDW read-only behavior, COPY WHERE
  system-column usage, and extension hook/API compatibility.
- Update monitoring for `sync_error_count` becoming `sync_table_error_count`
  and wait type `BUFFERPIN` becoming `BUFFER`.
- Revisit explicit `max_locks_per_transaction` settings: allocation units
  changed; the default doubles from 64 to 128.

## New capabilities: review consequences, not automatic recommendations

| Surface | What to check on a 19 target |
|---|---|
| [Window functions](https://www.postgresql.org/docs/19/functions-window.html) / [INSERT](https://www.postgresql.org/docs/19/sql-insert.html) | Gate `IGNORE NULLS`/`RESPECT NULLS` and `ON CONFLICT DO SELECT ... RETURNING` on 19. Test window-frame/empty/null cases and conflict visibility/locking under concurrency; keep a tested older-server path when required. |
| [Constraints](https://www.postgresql.org/docs/19/sql-altertable.html) | CHECK constraints can change enforcement with `ALTER CONSTRAINT ... [NOT] ENFORCED`; review actual enforcement/validation state, existing rows, and migration-runner compatibility rather than treating declaration as proof. |
| [REPACK](https://www.postgresql.org/docs/19/sql-repack.html) | Core command is distinct from extension `pg_repack`. Concurrent mode still needs an exclusive final swap lock, extra disk/WAL/decoding capacity, suitable replica identity, and no transaction block. Check eligibility, timeout/abort, and recovery before approved maintenance. |
| [Plan advice](https://www.postgresql.org/docs/19/pgplanadvice.html) / [stored advice](https://www.postgresql.org/docs/19/pgstashadvice.html) | Confirm extension/provider availability and configuration; compare representative plans before pinning advice. Treat advice as workload-specific, not a substitute for statistics/schema diagnosis. |
| [WAIT](https://www.postgresql.org/docs/19/sql-wait.html) | Read-your-writes requires the correct WAL LSN, standby routing, wait mode, and bounded timeout/failure handling. It does not make every replica read automatically consistent. |
| [Logical replication settings](https://www.postgresql.org/docs/19/logical-replication-config.html) / [sequences](https://www.postgresql.org/docs/19/logical-replication-sequences.html) | `wal_level=replica` can enable logical replication without restart; check slots, senders, permissions, and capacity. Sequence synchronization is explicit, not continuous `nextval()` streaming; test refresh/cutover and mixed-version peers. |
| [Vacuum](https://www.postgresql.org/docs/19/runtime-config-vacuum.html) / [I/O](https://www.postgresql.org/docs/19/runtime-config-resource.html) | Parallel index autovacuum, scoring, and adaptive I/O workers change resource competition. Measure waits, maintenance progress, and workload latency before changing limits. |
| [Query settings](https://www.postgresql.org/docs/19/runtime-config-query.html) | JIT defaults off. Retest analytical workloads and actual settings; do not carry old tuning defaults or assume planner improvements guarantee a faster query. |
| [EXPLAIN](https://www.postgresql.org/docs/19/sql-explain.html) | Gate asynchronous-I/O reporting (`ANALYZE, IO`) on 19 and confirm the active I/O method. ANALYZE executes the statement; keep write queries and unbounded plans behind the live gate. |
| [COPY](https://www.postgresql.org/docs/19/sql-copy.html) | JSON output/array mode, partitioned-table export, multiple skipped headers, and `ON_ERROR SET_NULL` need exact syntax plus shape, row-count, nullability, and rejected-input assertions. Silent coercion can change data meaning. |

## psql 19 is a separate compatibility axis

The [19 client manual](https://www.postgresql.org/docs/19/app-psql.html)
adds `%S` search-path prompts (server 18+), `%i` standby prompts, boolean display
settings `display_true`/`display_false`, and `SERVICEFILE`. Gate these on the
client and any documented server minimum, not `server_version_num` alone.
Retest scripts that consume human-formatted output: `\crosstabview` now honors
`\pset null`, and catalog descriptions/tab completion changed. Use explicit
machine-readable output for automation instead of parsing interactive tables.

Complete with exact client/server/build evidence, oldest supported target,
relevant migration/feature checks, current primary sources, and a reproducible
verification on disposable representative data. Unknown/live-unavailable
behavior remains a stated gap, not a compatibility claim.
