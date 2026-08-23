# Package layout & structure

Catalog: [rule catalog](../golang-review/RULES.md). For interface design depth, `/codebase-design`.

- **server-files-wire-deep-subsystem-packages** -- `server.go` and bootstrap files do
  construction and wiring only; business orchestration lives behind cohesive package
  APIs. And the inverse smell: do not mint a "service" for logic that belongs inside an
  existing component -- reviewers repeatedly folded needless service structs back into
  their callers.
- **persistence-concerns-stay-in-storage-layer** -- SQL, storage representations, and
  serialization stay in storage; services receive domain-facing types.
- **storage-access-uses-repository-generators** -- storage contracts live in
  repository-owned generator inputs (go-jet et al.); no handwritten parallel query and
  mapping layers.
- **equivalent-cross-provider-behavior-has-one-implementation** -- identical
  provider/API-version behavior has one shared implementation with branches only at
  real semantic differences; parallel handlers drift.
- **validation-has-one-early-owner** -- each domain invariant validates and defaults
  once at the earliest authoritative boundary; duplicate downstream guards survive only
  when they protect a distinct contract.
- **accept-focused-interfaces-return-concrete-types** -- narrow interfaces at dependency
  seams, concrete returns when callers need no substitution. Closures fit stateless
  behavior; interfaces fit substitutable stateful dependencies.
- **comments-change-with-behavior** -- a comment describing an old value or failure
  scope is false documentation; update it in the same diff.
- **prefer-official-maintained-protocol-clients** -- official SDKs, runtimes, and serde
  implementations over parallel custom or deprecated clients; wire compatibility and
  protocol evolution are exactly what local adapters lose.

For Go 1.27 generic methods on exported SDK or library types, read
[GO-1.27.md](GO-1.27.md) before choosing the receiver, interface seam, compatibility
path, or supported consumer floor.
