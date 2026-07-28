# SQL authoring and review

## Establish semantics

Before syntax, state:

- one row's grain for every input and output;
- required versus optional values and intended `NULL` behavior;
- keys, invariants, transaction boundary, and expected cardinality;
- representative parameter values, skew, ordering, and result-size bound;
- whether syntax is portable SQL, PostgreSQL-specific, or provider-specific.

Use database constraints for invariants the database owns. Keep business effects
atomic where possible; avoid read-then-write races.

## Write safely

- Bind every dynamic value. Whitelist dynamic identifiers/operators before
  composing SQL; placeholders cannot bind identifiers.
- Treat raw SQL fragments as an injection boundary. Allow only trusted constants
  or mechanically allowlisted identifiers, operators, and directions.
- Name columns. Avoid `SELECT *` across stable API, mapping, or high-volume
  boundaries.
- Qualify ambiguous columns and aliases. Make join cardinality intentional;
  prove that a one-to-many join cannot multiply an aggregate accidentally.
- Treat `NULL` with three-valued logic: use `IS [NOT] NULL`, `IS [NOT]
  DISTINCT FROM`, deliberate `NULLS FIRST/LAST`, and explicit aggregate
  expectations.
- Pair `LIMIT` with deterministic `ORDER BY`. Add a unique tie-breaker.
- Bound reads, writes, and returned payloads. Batch large work by a stable key,
  not arbitrary physical order.
- Prefer `EXISTS` for existence, not `COUNT(*) > 0`. Avoid `NOT IN` with a
  nullable subquery; use `NOT EXISTS` or eliminate nulls deliberately.
- Keep time semantics explicit: `timestamptz` for instants, named zones for
  presentation/business rules, and half-open ranges for intervals.
- Use exact numeric types for money/precision; define rounding ownership.
- Verify the actual SQL and parameters emitted by an ORM or builder, including
  aliases, casts, nulls, ordering, limits, locks, and conflict targets. Static
  result annotations do not perform runtime conversion or prove cardinality,
  isolation, index use, or mapping.

## Common shapes

Keyset pagination preserves stable work better than deep offset scans:

```sql
SELECT id, created_at, status
FROM jobs
WHERE (created_at, id) < ($1::timestamptz, $2::bigint)
ORDER BY created_at DESC, id DESC
LIMIT $3;
```

An atomic conditional transition removes a read-then-write race:

```sql
UPDATE jobs
SET status = 'running', started_at = clock_timestamp()
WHERE id = $1
  AND status = 'queued'
RETURNING id, status, started_at;
```

Use `INSERT ... ON CONFLICT` only after naming the required conflict invariant.
`MERGE` exists in PostgreSQL 15+, but its concurrency contract is not identical
to `ON CONFLICT`; choose from the invariant, not surface similarity. See the
[transaction isolation documentation](https://www.postgresql.org/docs/18/transaction-iso.html).

## Review

Check, in order:

1. Injection, authorization, tenant predicate, and sensitive output.
2. Row grain, nulls, duplicate multiplication, write postconditions.
3. Transaction/isolation behavior and retryable errors.
4. Result bound, representative plan, I/O/WAL/lock cost.
5. Deterministic ordering, portability, readability.

Complete when actual parameterized SQL, expected rows/postconditions, relevant
indexes/constraints, transaction boundary, and a representative verification
query or test are present.
