# Configuration & staged rollout

Catalog: [rule catalog](../golang-review/RULES.md).

## Configuration

- **configuration-uses-semantic-types** -- reuse the repo's typed config
  (`config.TLS`, `RegexpOrLiteral`, durations, enums); strings, `map[string]any`, and
  related bool sets move invalid states from compile time to production.
- **configuration-reuses-repository-standard-package** -- extend the existing config
  package; parallel plumbing forks parsing, defaults, and validation.
- **positive-configuration-booleans-unless-zero-must-fail-safe** -- name booleans for
  the enabled action, no double negatives -- except security paths where the zero value
  must fail closed (see [SECURITY.md](SECURITY.md)).
- **pointers-only-for-semantic-optionality** -- a pointer field means nil is a real
  third state; required values stay non-pointer.
- **operational-timing-policy-is-configurable** -- timeouts, retry/backoff, and polling
  windows are named configuration, not literals in control flow.
- **retry-backoff-fits-the-operation-lifetime** -- jitter where appropriate, bounded
  maximum, cumulative horizon that fits the owning timeout; unbounded schedules
  synchronize load and eat the caller's deadline.
- **provider-specific-settings-come-from-provider-owned-config** -- provider annotations,
  ports, and API options come from provider-owned config; no AWS defaults hardcoded
  into shared controllers.
- **mirrored-control-values-have-one-authoritative-source** -- values consumed across
  code and config have one authoritative definition; unavoidable mirrors are generated
  or drift-checked.

## Feature flags

- **feature-flag-risky-mixed-version-rollouts** -- risky control-plane/dataplane
  behavior gets an independent dark flag, experimental components default off, and
  mixed-version fleets keep working mid-rollout.
- Flags are migration tools, not architecture: graduate or delete them once the fleet
  converges and rollback windows close.
- **disabled-features-clear-dependent-state** -- disable is reversible and idempotent:
  preserve explicit off, clear dependent persisted config and owned resources in
  lifecycle order, or stale state re-enables itself on the next reconciliation.
- **feature-surfaces-change-and-retire-together** -- declarations, defaulting, install
  packs, tests, dispatch, implementation, and duplicated constants move as one; a stale
  layer exposes disabled behavior or invokes an unregistered workflow.

## Staged removal

- **stage-destructive-contract-and-schema-removals** -- the sequence, always: add
  compatibility, migrate consumers, deploy removal-tolerant code, then delete the old
  endpoint/version/field/setting/column. Old clients and old application instances
  coexist during every rollout.
- **reserve-removed-proto-number-and-name** -- the proto-specific case; enforced by the
  `go-proto-reserved` hook.
- **separable-breaking-changes-get-separate-prs** -- deployment-breaking policy or
  provisioning changes ship apart from unrelated fixes; blast radius stays attributable.
- **migration-classification-uses-authoritative-full-shape** -- classify migrations from
  the full authoritative shape (machine, storage, profile, topology), not one attribute
  two clusters happen to share.
