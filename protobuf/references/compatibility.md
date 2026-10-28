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

Sources: [Buf generation](https://buf.build/docs/generate/usage/),
[cross-version runtime guarantees](https://protobuf.dev/support/cross-version-runtime-guarantee/).
