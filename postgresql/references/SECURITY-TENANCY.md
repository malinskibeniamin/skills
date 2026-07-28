# Security and tenancy

## Bound access

- Separate owner, migration, runtime, read-only, replication, and operator
  roles. Runtime roles do not own application tables.
- Grant only required database/schema/table/sequence/function privileges;
  configure default privileges deliberately.
- Parameterize values and whitelist dynamic identifiers. Redact query literals,
  credentials, tokens, and sensitive rows from plans/logs/reports.
- Encrypt connections, rotate referenced secrets, restrict network/HBA rules,
  and audit elevated access. `pg_hba.conf` is first-match with no fallthrough;
  pre-check with `pg_hba_file_rules`.
- Pin and review extensions; they add code, privileges, upgrade, backup, and
  provider constraints.

Official contracts: [privileges](https://www.postgresql.org/docs/18/ddl-priv.html)
and [client authentication](https://www.postgresql.org/docs/18/client-authentication.html).

## Decide tenancy before RLS

Compare shared-schema, schema-per-tenant, database-per-tenant, and
cluster-per-tenant using tenant count/skew, isolation, schema variation,
migration fanout, connections, noisy-neighbor/resource control, restore
granularity, residency, operations, and cost.

For shared tables, make tenant identity part of keys/constraints where required.
Every request/job/session establishes tenant context through an authenticated,
tested path. Resource isolation still needs admission/rate/concurrency controls.

## Use RLS conditionally

RLS can protect against application query omissions. It also adds policy,
ownership/bypass, pooling, planner/per-row, testing, and denial-of-service
complexity. Choose it from a threat model, neither always nor never.

When using RLS:

1. Identify table owner, superuser, `BYPASSRLS`, migration, runtime, and support
   roles. Owners usually bypass unless `FORCE ROW LEVEL SECURITY` applies.
2. Cover reads with `USING` and writes with `WITH CHECK`.
3. Ensure tenant context fails closed when missing/invalid.
4. Index policy predicates when workload evidence justifies it.
5. Test every role, owner/bypass paths, cross-tenant read/write, empty/malicious
   context, functions/security definer, views, pooler mode, and plans/load.
6. Keep admission limits outside RLS; authorization is not resource isolation.

With RLS enabled and no applicable policy, PostgreSQL is default-deny. Verify
the exact version contract in [row security](https://www.postgresql.org/docs/18/ddl-rowsecurity.html).
The differing Supabase and PlanetScale positions are preserved as vendor
evidence in the [Supabase agent-skill announcement](https://supabase.com/blog/postgres-best-practices-for-ai-agents)
and [PlanetScale RLS critique](https://planetscale.com/blog/rls-sounds-great-until-it-isnt).

## Protect production-shaped copies

Branches/clones containing production data require classification,
masking/tokenization validation, least privilege, network separation, audit,
TTL/owner/cost, deletion evidence, and drift control. A convenient branch is
another sensitive database. Keep production protection and hotfix paths
explicit.

Complete when threat model, role/ownership matrix, tenant boundary, pooler
identity, negative tests, performance evidence, audit/recovery, and incident
path are verified.
