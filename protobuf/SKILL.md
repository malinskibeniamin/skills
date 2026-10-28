---
name: protobuf
description: "Design and review Protobuf schemas and their consumers. Use for .proto changes, Buf/codegen configuration, schema evolution, Protovalidate/CEL, descriptors, or protobuf runtime contracts. Google resource API conventions belong to aip."
paths:
  - "**/*.proto"
  - "**/buf.yaml"
  - "**/buf.gen*.yaml"
  - "**/buf.work.yaml"
  - "**/buf.lock"
---

# Protobuf

Treat the schema as a contract for serialization, generated code, validation and any
descriptor-driven consumers—not just a transport DTO. Apply only the layers the
repository uses. Skill loading grants neither delegation nor migration permission.

## Inspect the contract

1. Pin the review base/head, including working changes when requested. Include deleted
   and renamed schemas, imports, custom options, generation config and affected output.
2. Identify syntax/edition, compiler/plugins, runtime versions, Buf modules/locks,
   generation commands, compatibility policy, persisted messages and deployed consumers.
   Check binary, ProtoJSON, generated-source and behavioral compatibility separately.
3. Read [compatibility](references/compatibility.md) for schema or generation changes.
   Follow affected descriptors/messages through producers, adapters, storage and clients;
   generated code is evidence, never a hand-edit target.
4. Load only relevant depth:
   - Validation, requiredness or CEL changes: [validation](references/validation.md).
   - TS/Python runtime or RPC consumers: [runtimes](references/runtimes.md).
   - Reflection, custom options, forms or duplicated schema facts:
     [schema-driven capabilities](references/schema-driven.md).
   - APIs adopting Google resource conventions: load [aip](../aip/SKILL.md) completely.
     A `.proto` extension alone does not make every General AIP applicable.
   - React Connect Query flows: load [connect-query](../connect-query/SKILL.md).

## Verify behavior

Use repository-owned commands and the pinned toolchain. Where configured, exercise Buf
format/build/lint, breaking detection against the actual review/deployed baseline, code
generation and affected consumer checks. Honor module roots and existing rule categories;
report weakened checks and policy gaps rather than silently changing policy.

A review stays read-only: generate into a disposable output/snapshot when necessary.
Name unavailable tools, missing baselines and untested languages; passing lint or wire
checks alone cannot prove semantic compatibility or runtime validation.

For a changed contract, seek a counterexample at its public seam: an old payload/new
reader, new payload/old reader, unset versus explicit default, invalid request reaching
the server, or an edit adapter losing information. During implementation, first make
that counterexample fail a test; then fix and replay it through the real consumer.

## Report two distinct results

- **Defects:** diff-introduced failures with an affected consumer/scenario, evidence,
  consequence, smallest compatible fix and verification. These affect the review verdict.
- **Opportunities:** optional schema-driven improvements grounded in actual duplication
  or an existing descriptor consumer. State the benefit, adoption cost and smallest
  experiment. Keep them out of inline defect comments and blocking findings. Missing
  Protovalidate, custom options, AIP conventions or a newer runtime is not itself a bug.

Use the parent review's findings schema; gate reviews put advisory capabilities in
`simplification_opportunities`, not `findings` or `testing_gaps`. Report verification
limits and rollout risks; do not invent independent review, cross-language parity or
conformance results.
