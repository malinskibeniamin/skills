# go-jet/jet

Jet is a type-safe SQL builder, schema-driven code generator, and query result
mapper, not an ORM. Start from the pinned `go.mod` version and matching
[release notes](https://github.com/go-jet/jet/releases).

## Hard fit limits

At reviewed commit `10d3623`, released statement/QRM execution uses
`database/sql` rows and results; native pgx remained a separate
[workstream](https://github.com/go-jet/jet/pull/523). A pgx-native service can
call `stmt.Sql()` and execute the text/arguments itself, but loses Jet's direct
result mapper. Pilot representative queries before adopting Jet service-wide.

The default generator maps PostgreSQL `jsonb` and user-defined/unsupported
types to string-like builder columns. PostGIS `geography` and specialized JSONB
operators therefore need generator customization plus typed custom/raw
expressions. Prefer handwritten SQL if escape hatches dominate the complex
queries Jet was meant to clarify.

Generated tables provide per-value `FromSchema`. Package-level `UseSchema`
mutates generated globals and is documented for one-time startup. A
schema-per-tenant service must authorize schema identifiers, keep tenant schemas
structurally identical, and clone table values per query rather than switching
global schema state concurrently.

Evidence:
[statement interfaces](https://github.com/go-jet/jet/blob/10d3623ccad6a3a696367ca93314ff96427908e6/internal/jet/statement.go),
[default type mappings](https://github.com/go-jet/jet/blob/10d3623ccad6a3a696367ca93314ff96427908e6/generator/template/sql_builder_template.go#L163-L238), and
[generated schema APIs](https://github.com/go-jet/jet/blob/10d3623ccad6a3a696367ca93314ff96427908e6/generator/template/file_templates.go#L51-L111).

## Generation ownership

- Generate from an already-running schema through a least-privilege metadata
  connection.
- Put only generated files in the generated destination. The Jet generator
  deletes the destination schema folder before regeneration.
- Wrap generated models from another package; do not mix custom code into the
  generated tree.
- Commit/review deterministic output and regenerate in CI to detect schema
  drift.
- Pin the generator version to the runtime module version; avoid `@latest` in
  reproducible builds.

See Jet's [generator contract](https://github.com/go-jet/jet/wiki/Generator)
and [generated-folder issue](https://github.com/go-jet/jet/issues/509).

## Actual SQL is ground truth

Builder expression types prevent many type mismatches, not bad joins,
cardinality, isolation, unsafe transaction scope, missing indexes, or slow
plans. Capture `stmt.Sql()` SQL plus bound arguments for review/verification.
`DebugSql()` is presentation-only and can differ from executable parameter
semantics.

Use typed expressions for custom functions/operators. Use `RawStatement` only
when necessary with bound named arguments; never concatenate untrusted input.
See [Statements](https://github.com/go-jet/jet/wiki/Statements).

## Transactions and pooling

Transactions belong to `database/sql`: pass `*sql.Tx` to
`QueryContext`/`ExecContext`, propagate context, handle rollback/commit
explicitly, and keep whole-transaction retry outside the transaction attempt.
Bound prepared-statement caching; hard-coded raw parameters can create
unbounded entries, and transaction-pooler compatibility depends on the deployed
pooler/version.

## QRM is a correctness surface

Query Result Mapping (QRM) maps aliases and groups nested objects by selected
primary keys. Missing/incorrect aliases, absent keys, nulls, self-joins, views,
or custom types can silently alter object grouping.

- Select the keys required for each grouped object.
- Give self-joins distinct aliases.
- Add explicit `primary_key` tags for view/grouping models when required.
- Enable `StrictScan` and `StrictFieldMapping` where compatible.
- Test empty, null, duplicate-child, self-join, array, UUID/custom-key,
  long-identifier, and large-result cases.
- Use direct `sql.Rows` scanning only when measurement justifies bypassing
  reflection mapping.

Current `v2.15.0` changes generated `DECIMAL`/`NUMERIC` to
`shopspring/decimal`, adds strict field mapping, and fixes serialization. Treat
regeneration as an API change; prefer the pinned release over stale wiki prose.

Complete when generator/runtime versions match, generated ownership is clean,
actual SQL/arguments and plans are reviewed, transaction/pooler behavior is
tested, and QRM postconditions cover the result shape.
