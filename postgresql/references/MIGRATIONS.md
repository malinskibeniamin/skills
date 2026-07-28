# Safe migrations

## Choreograph compatibility

Prefer:

1. **Expand:** add a backward-compatible shape.
2. **Migrate:** backfill in bounded, resumable, observable batches.
3. **Switch:** deploy compatible writers/readers; change traffic deliberately.
4. **Validate:** compare counts/invariants and validate constraints.
5. **Contract:** remove the old shape only after a measured quiet window.

Keep ordered migrations as the durable schema history. Database branches/clones
are rehearsal environments, not schema sources to merge.

## Preflight

Record exact target/version, table/index bytes and row estimate, dependencies,
long/idle transactions, required lock mode, scan/rewrite behavior, WAL/replica
lag and disk headroom, pooler/rolling-deploy compatibility, duration estimate,
timeouts, abort criteria, recovery, and verification.

Useful PostgreSQL choreography:

- Build large indexes with `CREATE INDEX CONCURRENTLY` when its weaker blocking
  profile is worth extra work. It cannot run in a transaction block, permits
  only one concurrent build per table, waits on old transactions, and can leave
  an invalid index after failure. Inspect/repair it. See
  [CREATE INDEX](https://www.postgresql.org/docs/18/sql-createindex.html).
- Add supported foreign/check constraints as `NOT VALID`, then `VALIDATE
  CONSTRAINT` separately when that lock/scan profile fits.
- Backfill by a stable indexed key with small commits, throttling, progress,
  retry, and replica/WAL observation. Avoid one unbounded update.
- Treat type/default/nullability changes as version- and expression-sensitive;
  prove whether they rewrite or scan rather than relying on folklore.
- Preserve data recoverability. A syntactic down migration cannot restore
  dropped or transformed data.

## Generated migration tools

Use schema tools and ORMs as diff assistants. Keep one applied-history owner and
one serialized deployment path; never let ordinary application startup race to
apply schema changes.

1. Pin the exact version.
2. Generate SQL without applying it.
3. Review every statement, ordering, transaction boundary, lock/rewrite, enum,
   constraint, policy, view, index/opclass, default, casing, and schema filter.
4. Rehearse against production-shaped schema/data.
5. Apply through a controlled migration role/path.
6. Verify catalog, data, application behavior, and migration history.

Drizzle's release history motivated this guardrail: escaping, introspection,
constraint, enum, index, view-order, schema-filter, and migration-history
defects have changed across releases. Prefer reviewed `generate` plus one
controlled `migrate` deployment; reserve direct production `push` for an
explicit, inspected decision with equivalent approval and recovery. Consult the
pinned [Drizzle migration docs](https://orm.drizzle.team/docs/migrations) and
release notes rather than encoding its current API here.

Stop automation on unresolved rename, data-loss, or destructive prompts.
Structured output makes the decision machine-readable; it does not authorize
the change.

## Migration output

Provide exact ordered SQL; transaction boundaries; lock/scan/rewrite and
resource impact; backward-compatibility window; timeout and abort thresholds;
backup/restore or forward-fix; observation queries; and final cleanup trigger.

Complete when rehearsal uses representative volume/concurrency, rolling
versions coexist, recovery is credible, and database plus application
postconditions are verified.
