# Security & tenancy

Catalog: [rule catalog](../golang-review/RULES.md).

## Fail closed

- **security-state-and-predicates-fail-closed** -- missing config, partial policy
  snapshots, an errored license or authz backend: deny, or fail startup. "If
  `GetEnterpriseFeatures` fails we default to no violation" is how a customer turns
  off enforcement by breaking an endpoint. This is the justified exception to
  positive-boolean naming: a negative `disabled` field is right when the zero value
  must stay secure.
- **cross-cutting-gates-cover-every-entrypoint** -- authorization and feature gates
  cover every RPC, interceptor, proxy, hook, attach path, and raw HTTP entrypoint;
  partial enforcement means behavior depends on which door the request used.
- **authorization-policy-has-one-central-source** -- one source of truth for permission
  requirements; duplicated maps and handler checks drift.
- **authorization-schema-changes-migrate-existing-relations** -- authz model changes
  ship with sync/backfill/deletion handling for existing tenants, or they end up
  under- or over-authorized.

## Tenant isolation

- **tenant-egress-routes-through-safedial** -- every tenant-controlled outbound
  destination goes through safedial: SDK transports, redirects, nested references,
  DNS, cluster-internal CIDRs. Anything else is SSRF surface on a shared gateway.
- **tenant-database-isolation-uses-sessionrunner-and-rls** -- tenant DB access runs in
  transaction-scoped SessionRunner context backed by RLS, and tests use the
  non-privileged application role (superuser tests bypass the very protection under test).

## Secrets

- **secrets-are-references-with-minimal-exposure** -- accept and store references, never
  plaintext; never return stored secret material; expose the minimum
  environment/capability needed to resolve.
- **secret-bearing-log-values-are-redacted** -- redact credential-shaped values; never
  dump whole config or request objects that can carry tokens.
- **rotate-credentials-with-overlap** -- two-key overlap: add the new credential, switch
  readers, then retire the old; in-flight consumers finish on the old key.

## Destructive operations

- **destructive-tools-require-explicit-scope-and-intent** -- destructive CLI/cleanup
  requires explicit environment, scope, and confirmation; defaults never mutate.
- **destructive-safeguards-cover-exact-resource-set** -- safeguards cover every managed
  instance and only those: gaps destroy data, wildcards block valid cleanup.
- **referential-checks-precede-resource-deletion** -- check authoritative references
  before entering deletion or calling the provider; late checks strand resources
  mid-delete.
- **dynamic-deletion-safeguards-follow-feature-state** -- safeguards for optional
  resources derive from desired feature state across both enable and disable
  transitions, not a static allowlist.

Break-glass overrides exist but stay narrow, explicit, expiring, and documented for
one operational recovery case -- "safety checks have overrides" is not a convention.
