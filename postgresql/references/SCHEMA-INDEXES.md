# Schema and indexes

## Model correctness

- State table grain, identity, lifecycle, ownership, and deletion/retention.
- Choose types that express the domain. Prefer `NOT NULL`, primary/unique keys,
  `CHECK`, foreign keys, ranges, or exclusion constraints over application-only
  invariants when PostgreSQL owns the invariant.
- Remember that a `CHECK` passes on true or null. Do not use a `CHECK` to enforce
  cross-row state; PostgreSQL assumes check expressions are stable for
  dump/restore.
- Model nullability deliberately. PostgreSQL 15+ supports `NULLS NOT DISTINCT`
  for unique constraints when nulls must collide.
- Index the referencing side of a foreign key when its deletes/updates or joins
  justify it; PostgreSQL does not create that index automatically.
- Normalize for correctness first. Denormalize/materialize only for a measured
  path with explicit freshness, repair, and write-amplification ownership.
- Treat extensions, collations, generated columns, enums, domains, and provider
  types as versioned dependencies.

See the official [constraint](https://www.postgresql.org/docs/18/ddl-constraints.html)
and [data type](https://www.postgresql.org/docs/18/datatype.html) contracts.

## Derive indexes from work

For every proposed index record:

1. Query fingerprints, predicates, joins, ordering, and expected cardinality.
2. Why the access method and column order support those operators.
3. Expected plan change and latency/total-impact target.
4. Build lock/load, bytes, write/WAL/vacuum/cache cost.
5. Duplicate/overlap check, observation window, and removal condition.

Choose among B-tree, hash, GiST, SP-GiST, GIN, and BRIN by supported operator
and data distribution, not popularity. For multicolumn B-tree, lead from the
measured equality/range/order shape. Use:

- partial indexes only when query predicates imply the index predicate;
- expression indexes only with stable expressions;
- `INCLUDE` only when index-only scans are plausible and width pays for itself;
- specialized operator classes only with a pinned semantic requirement.

After expression/statistics-sensitive changes, run `ANALYZE` or verify
auto-analyze completed. Validate representative parameter values and skew.
Official index behavior: [Indexes](https://www.postgresql.org/docs/18/indexes.html).

Do not drop an "unused" index from a short statistics window. Check resets,
constraint ownership, replicas, rare critical jobs, seasons, alternate plans,
and duplicate candidates first.

## Partition only for a named operation

Partition for lifecycle/drop, pruning, maintenance isolation, or demonstrated
scale. Account for partition-key restrictions on uniqueness, object count,
planning time, default partition safety, routing, foreign keys, migration fanout,
and per-partition vacuum/index work. Prefer a plain table until one of those
operations requires partitioning.

Complete when the model expresses invariants, each index maps to measured query
work, write/maintenance costs are stated, migration choreography exists, and
plans/tests verify the expected behavior.
