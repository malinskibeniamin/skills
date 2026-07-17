# Proto & API implementation

`/aip` owns resource design (name/parent/mask shape). This file is the Go and proto
contract around it. Catalog: [rule catalog](../golang-review/RULES.md).

## Proto contracts

- **proto-getters-for-nil-safe-traversal** -- `rp.GetSpec().GetNodePools().GetFlag()`,
  never `if rp.Spec != nil && rp.Spec.NodePools != nil ...`. Getters preserve zero-value
  semantics through partially-set messages; ladders break during migrations. The single
  highest-support proto correction in the catalog (27 independent examples).
- **proto-annotations-own-field-contracts** -- requiredness, format, enum membership, and
  numeric bounds live in `field_behavior` + `buf.validate`, driving validation and docs
  for every consumer. Hand checks in handlers drift from the descriptor.
- **proto-optional-only-for-semantic-presence** -- use `optional` only when unset
  means something different from zero, such as inheriting a default or leaving a
  value unchanged.
- **dedicated-resource-write-and-read-shapes** -- `ConnectionCreate` / `ConnectionUpdate` /
  `Connection`; share a write shape only when accepted fields are truly identical, or
  output-only state leaks into writes as the resource evolves.
- **provider-specific-config-uses-oneof** -- mutually exclusive provider config is a typed
  `oneof`, not parallel optional fields with hidden invariants. On oneof switch, clear
  the previous variant's dependent state.
- **public-resource-references-use-aip-names** -- public references carry canonical
  resource names; database IDs stay internal; one typed parser owns name parsing.
- **public-identifier-fields-name-the-concrete-resource** -- `cluster_id`, `pipeline_ids`;
  never a bare `id` whose referent depends on the service name.
- **reserve-removed-proto-number-and-name** -- enforced by the `go-proto-reserved` hook:
  removal adds `reserved N;` and `reserved "name";`; renumbering is never safe.

## RPC surface

- **collection-rpcs-use-list-and-pagination** -- retrieval of many is `List*` with
  pagination and filtering even when today's upstream returns everything; `Get` is one
  resource. Renaming later is a breaking change; designing bounded now is free.
- **asynchronous-resource-mutations-return-operations** -- async public mutations return
  the repo's standard long-running operation shape, never fake-synchronous responses.
- **protovalidate-runs-once-at-rpc-boundary** -- shared middleware validates; handlers do
  not repeat guaranteed nil/format checks.
- **reject-invalid-explicit-input** -- a caller-supplied invalid value is an error, never
  silently skipped or replaced with a default that changes what the caller asked for.
- **etag-preconditions-protect-resource-mutations** -- carry etags through update/delete
  and enforce the precondition atomically with the storage mutation, not read-check-write.

## Errors on the public surface

- **translate-and-sanitize-errors-at-api-boundary** -- lower layers return rich domain
  errors; the service boundary logs the cause and emits the public shape. Never leak
  provider payloads, internal type names, or tenant existence.
- **public-errors-use-structured-actionable-details** -- stable `Reason_*` enums and
  `BadRequest` field violations tied to public request fields; reasons at the
  granularity callers can act on -- not one per message variant, and never collapsing
  different remediation paths.
- **preserve-upstream-protocol-error-granularity** -- Kafka and friends fail per
  transport, broker, topic, partition, and item; inspect at the native level and map
  through domain helpers. Flattening to one error returns false success.
