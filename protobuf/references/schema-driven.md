# Schema-driven capabilities

Read when a project consumes descriptors/options or repeats schema facts in validators,
forms, SDKs or documentation. These are opportunity lenses, not universal requirements.

## Look for leverage in existing consumers

- **Shared validation:** derive client feedback and server checks from the same standard
  constraints/CEL where runtime support exists. Keep server enforcement authoritative.
- **Descriptor-driven forms:** derive types, presence, oneof selectors, field errors and
  well-known-type conversions. Keep layout and UI component ownership with the host.
- **Behavior-aware edits:** connect required/output-only/immutable/resource annotations
  to actual create/update behavior, request composition and update-mask generation.
- **Custom options:** drive useful UI hints, documentation or redaction only when a
  generator/runtime consumer reads them. A `sensitive` marker alone does not redact logs;
  hidden/disabled controls do not authorize or reject a request.
- **Plugins and SDKs:** generate repeated adapters from descriptors when it removes a
  demonstrated source of drift. Preserve types, provenance and reproducible generation.

For an annotation change, name its reader, generated artifact and observed behavior.
Check all consumers before changing its meaning. Prefer standard annotations over a
duplicate vocabulary; add a custom option only for a real unmet consumer requirement.

Source: [Protobuf-ES reflection and plugins](https://protobufes.com/reference/).

## Schema projections and plugin consumers

For JSON Schema/OpenAPI generation, treat output as a projection with a coverage boundary,
not equivalent executable validation. Inspect field-name mode, strict/permissive variants,
64-bit/alternate numeric representations, enums, oneofs, presence, well-known types,
unknown-property policy and references. Test accepted/rejected payloads in the generated
validator AND actual runtime; custom CEL and stateful policy need not survive projection.

Buf's JSON Schema plugin and the community Connect-OpenAPI plugin have different owners,
options and release status. Pin the chosen version. For an HTTP client/spec, verify actual
paths, methods, error shapes, streaming support and auth metadata; documentation generation
does not create server routes or enforce security. A local `base`/override file option
may not work with remote plugins. Keep one schema source where useful, without forcing
OpenAPI/JSON Schema into projects with no consumer.

Sources: [Buf JSON Schema variants](https://github.com/bufbuild/protoschema-plugins#json-schema),
[Connect-OpenAPI options and limitations](https://github.com/sudorandom/protoc-gen-connect-openapi),
[projection workflow](https://buf.build/blog/protobuf-json-schema-and-openapi).

For a custom protoc plugin, read binary `CodeGeneratorRequest` from stdin, emit binary
`CodeGeneratorResponse` on stdout and send diagnostics to stderr. Generate only
`file_to_generate`, not all imported descriptors; advertise supported optional/edition
features accurately. Test imported options, retention, deterministic output and failures
through the real compiler invocation. A descriptor option does nothing until its reader
acts; extension-number ownership matters for shared custom vocabularies.

Sources: [compiler plugin contract](https://github.com/protocolbuffers/protobuf/blob/main/src/google/protobuf/compiler/plugin.proto),
[descriptor/plugin model](https://protobuf.com/extending/).

Choose a typed oneof for a closed set of alternatives. Use `Any` with an intentional
type allowlist/registry when extensibility is needed; a type URL is not permission for
arbitrary network fetches. `Struct`/`Value` trade schema guarantees for flexibility and
use double-precision numbers: bound and validate them instead of hiding precise integers
or a stable domain model inside an untyped bag.

Sources: [Any](https://protobuf.com/advanced/any/),
[Struct and Value](https://protobuf.com/advanced/value/).

Descriptors can also drive workflow, data or AI-tool adapters when a concrete consumer
benefits. Prototype one adapter and its failure/typing contract first. The Jev example
is experimental, not a default runtime recommendation or authority to send data to an
external AI service.

Source: [experimental descriptor-driven AI example](https://buf.build/blog/asking-jev-questions-with-protobuf).

## Protoform inspiration, not a required dependency

Examined [Protoform at dbe6237](https://github.com/malinskibeniamin/protoform/tree/dbe6237aa268f05274da7ce704416f593a56c045),
2026-10-28:

- [Provider](https://github.com/malinskibeniamin/protoform/blob/dbe6237aa268f05274da7ce704416f593a56c045/registry/base-nova/protoform/lib/protobuf-provider/provider.ts)
  joins descriptors, validation rules, field behaviors and UI options.
- [Field masks](https://github.com/malinskibeniamin/protoform/blob/dbe6237aa268f05274da7ce704416f593a56c045/registry/base-nova/protoform/lib/protobuf-provider/field-mask.ts)
  connect edited fields to schema paths and exclude non-updatable behaviors.
- [UI options](https://github.com/malinskibeniamin/protoform/blob/dbe6237aa268f05274da7ce704416f593a56c045/registry/base-nova/protoform/lib/protobuf-provider/proto/protoform/v1/auto_form_ui.proto)
  encode form hints and conditional presentation as custom options.
- [Domain glossary](https://github.com/malinskibeniamin/protoform/blob/dbe6237aa268f05274da7ce704416f593a56c045/CONTEXT.md)
  separates form values, native messages, update intent and unknown-wire-field retention.

These establish possible consumers, not proof of every implementation's correctness.
Review round trips, oneof branch changes, absent/default values, 64-bit values, unknown
data, root/field validation errors and intentional clears. Suggest only capabilities
that solve a concrete problem in the reviewed repository, with a bounded experiment.
