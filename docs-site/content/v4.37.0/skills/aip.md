---
title: "/aip"
description: "Design Google AIP resource APIs. Use for protobuf or REST resources, standard methods, HTTP bindings, fields, pagination, filtering, LROs, errors, compatibility, or batch APIs."
type: skill
sidebar:
  label: "/aip"
---
![Diagram of the /aip skill](/diagrams/skills/aip.svg)

[Open the editable Excalidraw source](/diagrams/skills/aip.excalidraw)

Use the General AIPs as the source of truth. Approved AIPs are normative. AIP-162 (draft) and AIP-182 (reviewing) are advisory: consider and label them, but never present them as requirements.

## Workflow

1. Read the whole proposed surface and nearby established APIs. Classify management plane vs data plane.
2. Walk all 72 `Use when` entries in [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/aip/REFERENCE.md) once to build an applicability ledger; use concept or `AIP-N` search for detail, not as the only discovery method. Record why each AIP is selected or excluded. Do not apply every AIP blindly.
3. Open the exact official `https://google.aip.dev/{number}` page for every applicable AIP, including conforming and advisory rows. Never add an evidence row from the local index alone. After drafting, mechanically compare the applicable-row URLs with the research trace and fetch every gap before finalizing.
4. Resolve conflicts in this order: current approved AIP, documented local compatibility requirement, precedent exception. Never copy a violation as precedent. Mark necessary exceptions `aip.dev/not-precedent` with rationale.
5. Derive a change-specific checklist from the exact official guidance. Cover proto/HTTP shape, behavior, errors, lifecycle, compatibility, documentation, and client ergonomics, not syntax alone.
6. Design or review the smallest conformant surface without silently deleting intended user capability. Preserve wire compatibility unless the version/stability policy permits a break.
7. Run `api-linter` using the repository's existing command/config when available. Treat it as a floor: manually review applicable rules it cannot encode.
8. Report one row per applicable AIP as `AIP | state | applicability | result | evidence/exception`; never combine AIPs in one row or omit conforming passes. Separately list excluded AIPs as not applicable, then verify the two sets account for all 72 published numbers exactly once. Separate normative failures from advisory suggestions.

## Baseline

- Model management APIs as named resources in an acyclic hierarchy with standard methods first.
- Give resources a canonical relative resource `name` containing the complete service-relative path and a `(google.api.resource)` annotation; reserve display text for `display_name`.
- Annotate existing-resource request `name` fields with `resource_reference.type`. Annotate nested List/Create `parent` with `resource_reference.child_type` when the parent type is not declared or may vary, otherwise with the parent's `type`; never point it at the child as `type`.
- Make HTTP paths, request fields, method signatures, resource references, field behaviors, pagination, filtering, masks, errors, and LRO metadata agree.
- Keep corrected schemas self-contained: add the defining import for every annotation or message introduced.
- Preserve relative expiration capability: replace raw TTL numbers with `oneof expiration` containing input-capable `google.protobuf.Timestamp expire_time` and `google.protobuf.Duration ttl [(google.api.field_behavior) = INPUT_ONLY]`; do not keep only `expire_time`, and `expire_time` must not be `OUTPUT_ONLY` because clients may supply an exact time.
- Validate behavior after mutations reaches the steady state promised by the method or operation.
- Review every change for compatibility, not only field-number reuse: names, types, formats, semantics, HTTP bindings, resource patterns, requiredness, and client behavior matter.
- Document user-visible semantics, validation, defaults, ordering, limits, side effects, errors, retention, and exceptions.

## Guardrails

- Do not invent guidance for unassigned numbers; the range contains 72 published General AIPs, not 236 documents.
- Do not treat examples as universal requirements. Apply conditional AIPs only when their trigger holds.
- Do not downgrade **must**/**must not** from an approved AIP. Distinguish **should** recommendations and documented exceptions.
- Do not claim conformance from `api-linter` alone or from this checklist alone.
- Recheck known traps: AIP-122 relative names and parent reference direction; AIP-127 and AIP-130 for HTTP-transcoded resource methods; AIP-134 optional update masks; AIP-154 unannotated resource etags; AIP-161 ignored output-only input; AIP-192 comments on every public declaration; AIP-203 `IDENTIFIER` names and request-field behaviors; `client.proto` for `method_signature`; and AIP-214's input-capable `expire_time` plus input-only `ttl` oneof.
- For legacy surfaces, prefer an explicit compatibility adapter over extending a non-conformant pattern.
