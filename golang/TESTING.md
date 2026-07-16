# Go testing

Catalog: [rule catalog](../golang-review/RULES.md).

## What a test proves

- **integration-tests-cross-real-boundaries** -- a test claiming boundary compatibility
  (billing, credentials, serialization, storage roles, providers) crosses the real
  protocol/provider/container. Mocks at the boundary prove nothing there -- and a test
  gated on env vars nobody sets never ran.
- **unit-tests-stay-offline-with-injected-fakes** -- the complement: unit logic uses
  `httptest`, injected fakes, or no-op clients. Live network in unit tests confuses
  execution coverage with verified compatibility.
- **tests-assert-stable-observable-behavior** -- assert what a regression would break;
  never pin incidental error text, keep dead assertions, or merely execute a path.
- **new-behavior-variants-get-targeted-regressions** -- every new failure class,
  classification branch, or bug fix gets its own positive or negative test; the happy
  path proves nothing about the new branch.
- **test-upgrades-from-existing-deployments** -- compatibility changes deploy the
  pre-change version first, then upgrade and force reconciliation; fresh-create tests
  cannot see persisted-state incompatibilities.

## Mechanics

- **bounded-eventual-tests-poll-observable-state** -- eventual consistency is tested by
  polling the completion condition under a context deadline sized to the real
  stabilization window. Fixed sleeps flake; unbounded loops hang.
- **canonicalize-unordered-values-before-comparison** -- sort or canonicalize map,
  database, and Kubernetes values before comparing; iteration order is not a contract.
- **parallel-integration-tests-own-distinct-resources** -- parallel tests get distinct
  external identities and resource names; shared mutable fixtures make outcomes
  order-dependent and can authorize one test with another's principal.
- **tests-delegate-lifecycle-to-testing-t** -- `t.TempDir()`, `t.Setenv()`,
  `t.Context()`, `t.Cleanup()`, `t.Log()`; T-scoped facilities isolate parallel tests
  and guarantee cleanup on failure.
- **test-service-images-use-supported-pins** -- enforced by the `go-test-image-pin`
  hook: pin supported release tags, never `:latest`/`:main`/`:master`.

## CI

- **ci-tests-the-artifact-from-current-change** -- smoke and relaunchable CI consume the
  artifact built from the PR head; green against a stale main artifact validates nothing.
- **ci-exceptions-are-narrow-and-visible** -- skips and ignored failures scope to the
  known case and carry a visible annotation; broad ignores become permanent coverage loss.
- **deterministic-temporal-failures-are-nonretryable** and workflow test determinism:
  see [TEMPORAL.md](TEMPORAL.md). Controller test wiring: see [CONTROLLERS.md](CONTROLLERS.md).
