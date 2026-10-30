# Compatibility and generation

## Evolution

- Keep existing tag meanings. Reserve removed field/enum numbers and names; do not reuse
  them. Inspect history/deployed schemas, not only the candidate file.
- Check type, cardinality, enum, oneof, package/service/method and edition changes against
  each actual consumer. Binary-compatible does not imply source- or JSON-compatible.
- Distinguish absence from zero, false, empty text and an empty message. Preserve the
  intended presence discipline; check merge/patch/reset behavior before adding/removing
  `optional`, moving fields into a oneof or changing edition features.
- Exercise unknown enum values and unknown binary fields through intermediaries. A form
  adapter or object reconstruction can discard information even when the runtime preserves
  it. JSON conversion is not an unknown-wire-field-preserving clone.
- Check ProtoJSON field/enum names, 64-bit integer strings, bytes, well-known types and
  unknown-field policy. A rename retaining its tag can still break JSON clients.
- For partial updates, prove masks and values express intentional clears/defaults and
  nested/repeated/map behavior. Do not infer update intent solely from non-default values.
- Account for independently deployed clients, rollback and stored data. A coordinated
  code release does not prove all old payloads/readers have disappeared.

Sources: [schema evolution best practices](https://protobuf.dev/best-practices/dos-donts/),
[field presence](https://protobuf.dev/programming-guides/field_presence/),
[ProtoJSON](https://protobuf.dev/programming-guides/json/).

## Traps a wire check can miss

- Treat integer widening as conditional: an old `int32` reader can truncate a new
  `int64` value. Constrain new writers until old readers are retired; evaluate JSON
  representation separately. Matching wire types do not make arbitrary swaps safe.
- An old reader cannot distinguish an unset oneof from a newly added, unknown branch.
  Exercise forwarding followed by editing, not just a new-reader round trip.
- For maps, test duplicate-key/last-value behavior and unordered iteration. Converting
  repeated entries into a map can discard duplicates and ordering that callers use.
- Avoid new enum aliases or public/weak imports as portability shortcuts. Changing alias
  order can change emitted JSON names and reflection; removing legacy imports/aliases
  still needs a consumer-aware migration, not automatic cleanup.

Sources: [conditional changes, oneofs and maps](https://protobuf.dev/programming-guides/proto3/),
[enum aliases](https://buf.build/blog/totw-6-dangers-of-enum-aliases),
[import portability](https://buf.build/blog/totw-5-avoid-import-public-weak).

For editions, inspect effective feature settings, including scoped overrides, and every
compiler/plugin/runtime's support. Explicit singular-field presence does not give maps
or repeated fields presence. Preserve legacy proto2 `required`/`LEGACY_REQUIRED` carefully:
they affect initialization/parsing/serialization, unlike a runtime validation rule.
For new schemas, use explicit presence plus application validation instead of legacy
requiredness; an editions migration is optional, not an automatic review fix.

Sources: [edition features](https://protobuf.dev/editions/features/),
[legacy requiredness](https://buf.build/blog/totw-8-never-use-required).

Preserve unknowns through compatible intermediaries using the runtime's message-aware
copy/clone APIs. At a security boundary, decide explicitly whether forwarding unvalidated
unknown fields to a newer downstream consumer is permitted. Neither blanket discard nor
blind preservation is a universal policy. Binary serialization, even deterministic mode,
is not a cross-version canonical hash/signature. ProtoJSON defines a mapping, not a unique
byte representation; use an explicit domain canonicalization contract when required.

Sources: [unknown-field retention](https://protobuf.dev/programming-guides/proto3/#unknowns),
[non-canonical serialization](https://protobuf.dev/programming-guides/serialization-not-canonical/),
[ProtoJSON options](https://protobuf.dev/programming-guides/json/#json-options).

For changed encodings, large numeric payloads or byte-level diagnosis, read
[wire and performance](wire-and-performance.md). For the research coverage and rejected
overgeneralizations behind this guidance, see the [dated source review](source-review-2026-10.md).

## Checks are scoped evidence

Inspect `buf.yaml` and its exclusions before interpreting `buf breaking`. `FILE` checks
generated-source compatibility per file; `PACKAGE` per package; `WIRE_JSON` covers binary
and JSON; `WIRE` only binary. Use the repository's policy and all relevant modules against
the correct baseline. A wire-only pass says nothing about a renamed generated accessor.
Tool checks do not establish application semantics or enforcement of custom annotations.

Source: [Buf categories and limitations](https://buf.build/docs/breaking/rules/).

## Generation is part of the API

Trace plugin options/versions, managed mode, imported annotation dependencies, runtime
support and published SDK exports. Reproduce generation with the repository's scripts;
compare affected output and type-check consumers, including when only generation config
changed. Confirm descriptors/custom options needed at runtime survive the generation
and bundling path. Treat missing generated updates as a defect only when this repository
ships those artifacts or its build does not generate them automatically.

Pin schema dependencies/SDK versions and plugin versions/revisions through the existing
config/locks. Remote generation sends schema input to a service; a blog example is not
permission to publish a module, disclose private schemas or add registry credentials.
Keep editor/LSP import roots aligned with CI; editor success alone is not a build proof.

Sources: [Buf generation](https://buf.build/docs/generate/usage/),
[cross-version runtime guarantees](https://protobuf.dev/support/cross-version-runtime-guarantee/).
