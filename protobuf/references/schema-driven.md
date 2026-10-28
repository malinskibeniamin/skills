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
