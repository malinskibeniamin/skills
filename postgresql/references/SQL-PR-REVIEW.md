# SQL pull request review

Review the database transition, application contract, and operational proof, not
only the changed `.sql` lines. Read the other reference files named by
`SKILL.md` for every domain the diff touches.

## Contents

- [Map the change](#map-the-change)
- [Review migration history](#review-migration-history)
- [Prove compatibility on populated data](#prove-compatibility-on-populated-data)
- [Review authored queries](#review-authored-queries)
- [Review constraints and indexes](#review-constraints-and-indexes)
- [Review tenancy and roles](#review-tenancy-and-roles)
- [Review generated SQL](#review-generated-sql)
- [Review CDC and outbox effects](#review-cdc-and-outbox-effects)
- [Demand a proof bundle](#demand-a-proof-bundle)
- [Report findings](#report-findings)

## Map the change

1. Identify the deployed PostgreSQL version/provider, migration runner, whether
   each migration is transactional, schema owner, runtime roles, pooler, and
   oldest application version that can overlap the rollout.
2. Classify every artifact:
   - immutable migration history;
   - hand-authored queries;
   - schema declaration or model annotations;
   - generated DDL, query bindings, mappers, and table models;
   - schema snapshots or golden files;
   - integration, migration, authorization, and plan tests.
3. Name the source of truth for the end-state schema and the owner of applied
   migration history. Treat generated artifacts as evidence, not a second
   authoring surface.
4. Trace each changed field through create, get, list, update, delete, mapper,
   cache/event, and API serialization paths. A column that exists but is never
   persisted or returned is an incomplete feature.
5. State the row grain and invariant before reviewing syntax. Include lifecycle
   state, tenant boundary, null/empty/zero meaning, identifier stability, and
   expected cardinality.
6. Separate **end-state correctness** from **transition correctness**. A clean
   final schema can still fail on old rows, mixed application versions, or an
   interrupted migration.

## Review migration history

- Refresh the target branch before assigning an ordered migration number.
  Recheck uniqueness after every merge or rebase. Duplicate versions stop the
  migration chain; renumber the unapplied file and regenerate derived headers
  or snapshots.
- Treat any migration applied in any durable environment as immutable. Add a
  forward repair. Amend a failed migration only when evidence proves it never
  completed anywhere and the dirty-state recovery is documented.
- Follow the repository's migration policy. A missing down file can be
  intentional; a syntactic down file does not restore transformed or deleted
  data.
- Keep one schema-history owner and one serialized apply path. Do not mix
  startup migration, direct schema push, and a second deploy job.
- Review the actual runner boundary. `CREATE INDEX CONCURRENTLY` cannot run in
  a transaction block. Session settings, extensions, procedures, and provider
  commands may have their own boundaries.
- Fail loudly on unexpected schema state. Use `IF [NOT] EXISTS` only when
  convergence is intentional and follow it with a catalog assertion; do not
  mask drift.
- Preserve exact owner, grants, comments, policies, triggers, defaults,
  generated expressions, indexes, constraints, publications, and replica
  identity. Table shape alone is not the schema contract.
- For a rename generated from a declarative model, verify it emits `RENAME`
  rather than drop-plus-add. Retain any compatibility annotation until every
  environment has crossed the migration.
- Keep a migration focused enough that its name describes the change, while
  keeping inseparable end-state changes together. Splitting does not improve
  safety unless the rollout or lock boundary is genuinely separate.

## Prove compatibility on populated data

Review each transition against old rows and old binaries:

- **Add:** Decide whether old rows mean absent, empty, false, or a real default.
  Prefer nullable when absence activates different behavior. Use a default only
  when it is valid for every existing row and future omitted insert.
- **Add `NOT NULL`:** Prove the table is empty or use expand, bounded backfill,
  verification, and constraint validation. Do not rely on an empty-database CI
  run.
- **Change a default:** Verify every insert path. Remove temporary backfill
  defaults after compatible writers deploy when omission should fail.
- **Change a check or enum:** Prove existing values pass and old binaries can
  still read/write during overlap. Avoid renaming enum values for aesthetics.
- **Change a primary/unique key:** Query for collisions under the new key
  before adding it. If formerly distinct rows collapse, define a lossless
  mapping or explicit aggregate/deduplication and test representative populated
  rows.
- **Rename/drop a column or table:** Use expand -> dual-read/write or backfill
  -> switch -> quiet window -> contract. Delay destructive cleanup until old
  binaries cannot reference the object and rollback no longer needs it.
- **Change a type:** Prove cast behavior, invalid-value handling, rewrite/lock
  cost, index/constraint rebuilds, and driver/generated-model compatibility.
- **Backfill:** Bound by a stable indexed key, make progress resumable, expose
  counts, throttle WAL/replica impact, and define abort criteria.
- **Partition:** Include the partition key in required unique constraints,
  ensure required partitions exist before inserts, preserve parent
  privileges/RLS, and bound lookup predicates for pruning.

Exercise the oldest supported schema plus realistic rows: nulls, empty
collections, soft-deleted rows, duplicate candidates, maximum-width values,
skewed tenants, and active foreign-key/CDC relationships.

## Review authored queries

- Apply tenant scope to customer-facing get, update, delete, and list queries.
  Prefer database enforcement plus explicit predicates; do not depend on a
  service lookup being correct.
- Apply one lifecycle definition consistently. Check every query for the chosen
  `deleted_at`, state, or status rule, including list, uniqueness, foreign-key
  guards, and background jobs.
- Update audit timestamps on every mutation, including soft delete. Keep
  immutable definition fields out of state-only updates.
- Use named parameters when positional parameters are numerous or evolving.
  Check casts and nullable parameters in the actual generated SQL.
- Express optional filters as a true no-filter branch, such as
  `$value IS NULL OR column = $value`. Test null explicitly; SQL three-valued
  logic can otherwise remove every row.
- Verify join direction and cardinality. An accidental inner join can hide a
  valid row; an accidental one-to-many join can multiply it.
- Return the smallest contract needed. Use affected-row count or `RETURNING` to
  distinguish not found, stale state, and successful mutation.
- Put guarded transitions in SQL: match both identity and expected state in the
  `WHERE` clause rather than trusting a caller-provided status.
- Verify every new persisted field appears in create and update paths, unless
  the database owns it. Prefer generated mutable-column sets so future fields
  cannot be silently omitted.
- Preserve deterministic ordering with a unique tie-breaker. For keyset
  pagination, make cursor encoding, comparison direction, null ordering, and
  index order identical. Benchmark a deep page, not only page one.
- Bound substring search and fanout. Record when a deliberately unindexed path
  is acceptable and what usage threshold triggers follow-up work.

## Review constraints and indexes

- Put durable invariants in constraints when PostgreSQL owns them. Test both
  acceptance and rejection, including delete/update actions.
- For tenant-scoped relationships, include tenant identity in the foreign key
  or otherwise prove cross-tenant references are impossible. RLS does not scope
  foreign-key lookup.
- Index a foreign-key child key when parent updates/deletes or joins need it.
  Verify a primary/unique/leading index does not already provide the coverage.
- Avoid duplicate indexes: primary keys and unique constraints already create
  indexes.
- Use partial uniqueness to exclude retired rows only when that matches the
  lifecycle contract.
- Prove that the exact query predicate implies a partial-index predicate. An
  equivalent-looking `OR`, nullable branch, cast, or operator can prevent
  planner use. Confirm with the real parameterized query and representative
  `EXPLAIN (ANALYZE, BUFFERS)`.
- Match JSON/expression indexes to the exact expression and operator. A
  containment operator is not equality; an empty object can make containment
  unexpectedly broad.
- Include before/after plans, row counts, selectivity/skew, build method, index
  size, write/WAL cost, and removal criteria. Revert or omit an index that the
  intended query cannot use.
- Add large existing-table foreign keys or checks with `NOT VALID` followed by
  a deliberate `VALIDATE CONSTRAINT` step when that lock profile fits.

## Review tenancy and roles

- Treat tenant scoping as a schema invariant. Include tenant keys in primary
  keys, uniqueness, indexes, and relationships where identities are
  tenant-local.
- Verify runtime queries under the actual non-owner role. Table owners and
  `BYPASSRLS` roles can make an isolation test pass while policies are absent.
- When RLS depends on transaction-local settings, prove every operation uses
  the scoped transaction and that missing settings fail closed.
- Test cross-tenant and, when applicable, cross-user reads and writes. Also
  assert that RLS is enabled in the catalog.
- Keep privileged admin/migration paths explicit. Document why any table is
  exempt, and test that ordinary request paths cannot reach the privileged
  pool.
- Align policies, grants, schema ownership, and default privileges for future
  partitions/tables. Query predicates remain useful defense in depth even with
  RLS.

## Review generated SQL

1. Change the declarative source, not generated output.
2. Pin and run the repository generator.
3. Review generated SQL, mapper types, mutable/default columns, nullability,
   comments, ordering, indexes, and constraints as production code.
4. Generate or hand-author the forward migration from the previously deployed
   schema.
5. Apply the complete migration chain to a fresh database and compare its
   structural catalog with the canonical generated DDL.
6. Apply the new migration to a populated previous-version database. Empty
   drift checks cannot reveal duplicate-key collapse, cast failures, or bad
   backfills.
7. Require a clean regeneration diff. Commit every expected derived artifact;
   investigate unrelated churn.

Check generator inference against database truth: a default must satisfy its
check; nil must not collapse into empty unless that is the contract; immutable
fields must not enter generated updates; stored generated columns must be
recomputed rather than copied; renames must preserve data.

## Review CDC and outbox effects

- Trace column/table changes through outbox payloads, publications, replica
  identity, decoding, mappings, and consumers. Update schemas and consumers in
  a compatible order.
- Verify insert, update, and delete semantics. Hard deletes, cascades, and soft
  deletes produce different observable events.
- Ensure outbox state is written atomically with the business row and has a
  stable key and event time. Prevent replay from duplicating effects.
- Verify publication membership and creation order with the consumer/slot
  lifecycle. Account for retained WAL, inactive slots, rollback, and restore.
- Test representative old and new events. A database change is incomplete if
  downstream decoding silently drops or misreads it.

## Demand a proof bundle

Require the pull request to include:

- invariant, row grain, null/lifecycle/tenant semantics;
- exact migration order and applied-state assumption;
- current table/index sizes, row counts, skew, and duplicate/null preflight;
- lock, scan, rewrite, WAL, replica-lag, and duration expectations;
- old/new application compatibility and cleanup trigger;
- fresh-database migration plus structural drift result;
- populated previous-version migration result;
- repository/generator diff and focused integration tests;
- representative plans for changed hot queries and indexes;
- cross-tenant/RLS and CDC/outbox tests when applicable;
- abort criteria, rollback or forward-fix, dirty-migration recovery, and final
  catalog/data/application verification.

Do not accept "CI passed" as migration evidence when CI only creates empty
tables.

## Report findings

Report correctness and rollout hazards before style:

1. **Block:** duplicate migration version; modification of applied history;
   destructive mixed-version break; tenant escape; generated-schema drift;
   constraint/index creation that fails on existing rows; unbounded backfill;
   unrecoverable data loss; or a migration tested only on an empty database
   despite a credible populated-data failure.
2. **Require evidence:** new index without the exact plan; changed null/default
   semantics without old-row proof; RLS tested only as owner; CDC change without
   consumer proof; or unclear lock/rewrite behavior.
3. **Suggest:** naming, organization, and readability improvements after safety
   is established.

For each finding, cite the exact statement/path, affected workload or rollout
phase, failure mechanism, smallest safe change, and verification that closes
the finding. If no actionable finding remains, state which migration,
populated-data, compatibility, tenancy, generated-drift, plan, and recovery
evidence was actually checked.
