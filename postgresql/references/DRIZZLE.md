# Drizzle with PostgreSQL

Drizzle is a typed SQL construction and migration layer, not the PostgreSQL
correctness boundary. Start from pinned `drizzle-orm`, `drizzle-kit`, driver,
provider adapter, and relations-generation versions. Review the actual emitted
SQL against the deployed PostgreSQL and pooler.

## Migration ownership

Choose one source of truth:

- **Code first:** commit the TypeScript schema, generated SQL migrations, and
  snapshots. Review rename prompts and the SQL artifact.
- **Database first:** apply reviewed SQL with the chosen migration tool, then
  introspect Drizzle declarations.

Prefer `generate` plus one controlled `migrate` deployment job for production.
Do not use `push` for production or application startup by default: it
introspects, generates, and applies changes immediately. Use it there only when
one serialized, explicitly approved deployment step accepts that reduced
review/recovery boundary.

Rewrite or add custom SQL when a safe rollout needs `NOT VALID` plus
`VALIDATE CONSTRAINT`, `CREATE INDEX CONCURRENTLY`, phased backfill,
mixed-version compatibility, or provider-specific DDL. Run `drizzle-kit check`
after merging migration histories. Never edit or reorder an applied migration.

The v1 migration format changes folder structure and removes the v0
`journal.json` convention. Use the pinned upgrade guide; do not hand-merge v0
and v1 histories.

See [migration workflows](https://orm.drizzle.team/docs/migrations),
[`generate`](https://orm.drizzle.team/docs/drizzle-kit-generate),
[`migrate`](https://orm.drizzle.team/docs/drizzle-kit-migrate),
[`push`](https://orm.drizzle.team/docs/drizzle-kit-push), and
[`check`](https://orm.drizzle.team/docs/drizzle-kit-check).

## Database invariants

Declare `NOT NULL`, primary, unique, check, foreign-key, and exclusion behavior
in PostgreSQL schema/migrations. Drizzle `relations` are query metadata and do
not create foreign keys. For same-database relationships, use relations plus
deliberate constraints, actions, nullability, uniqueness, and indexes.

Express PostgreSQL index method, expressions, operator classes, ordering, null
ordering, predicates, included columns, and storage parameters where required.
Generated valid DDL is not proof that an index fits representative plans.

For RLS, separate `USING` from `WITH CHECK`, preserve provider-owned roles,
test as the real non-owner role, and index policy access paths. A Drizzle type
for pgvector, PostGIS, or another extension does not provision that extension.

See [relations and foreign keys](https://orm.drizzle.team/docs/relations#foreign-keys),
[indexes and constraints](https://orm.drizzle.team/docs/indexes-constraints),
[RLS](https://orm.drizzle.team/docs/rls), and
[extensions](https://orm.drizzle.team/docs/extensions).

## Generated SQL and runtime mapping

- Prefer Drizzle operators and the `sql` tagged template, which parameterizes
  interpolated data and escapes schema objects.
- Treat `sql.raw()` as an injection boundary. Accept only trusted constant SQL
  or mechanically allowlisted identifiers/directions.
- Remember `sql<T>` is a compile-time annotation, not runtime conversion. Use
  `.mapWith()` or a tested driver/type adapter when conversion matters.
- Inspect `toSQL()` or dialect output in tests: text, parameters, aliases,
  casts, nulls, ordering, limits, locks, and conflict targets.
- Snapshot representative relational-query SQL across relations v1/v2 changes.
- Require at least stable `drizzle-orm` 0.45.2 on the 0.x line because it fixed
  escaping in `sql.identifier()` and `sql.as()`; verify the corresponding fix
  separately for v1 prereleases.

See the [`sql` template contract](https://orm.drizzle.team/docs/sql),
[relations v1-to-v2 guide](https://orm.drizzle.team/docs/relations-v1-v2), and
[0.45.2 security release](https://github.com/drizzle-team/drizzle-orm/releases/tag/0.45.2).

## Transactions, pools, and replicas

Keep every operation in one invariant on the transaction object passed to the
callback; a query on outer `db` is outside that transaction. Keep callbacks
short, propagate cancellation, and retry only a whole idempotent transaction
after SQLSTATE classification. Nested Drizzle transactions are savepoints, not
independently committed units.

Verify prepared-statement behavior against the exact driver and pooler.
`postgres.js` enables prepared statements by default in current Drizzle docs;
transaction poolers may require different configuration.

With `withReplicas()`, route read-after-write and other
consistency-sensitive reads through `$primary`, the transaction connection, or
`RETURNING`. Asynchronous replicas remain stale-capable.

See [transactions](https://orm.drizzle.team/docs/transactions),
[PostgreSQL drivers](https://orm.drizzle.team/docs/get-started-postgresql), and
[read replicas](https://orm.drizzle.team/docs/read-replicas).

Complete when versions are pinned, generated migration/query SQL is reviewed,
database constraints protect invariants, production migration ownership is
singular, and transaction/pooler/replica behavior is tested against PostgreSQL.
