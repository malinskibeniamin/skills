---
name: aip
description: "Designs/reviews APIs against applicable Google AIPs 1-236. Use for API proposals, protobuf/REST schemas, resources, methods, HTTP, fields, pagination/filtering, LROs, compatibility/versioning, errors/retries, docs, or declarative/batch patterns."
paths:
  - "**/*.proto"
  - "**/*openapi*.{yaml,yml,json}"
---

# Google AIP Design and Review

Use the General AIPs as the source of truth. Approved AIPs are normative. AIP-162 (draft) and AIP-182 (reviewing) are advisory: consider and label them, but never present them as requirements.

## Workflow

1. Read the whole proposed surface and nearby established APIs. Classify management plane vs data plane.
2. Search [REFERENCE.md](REFERENCE.md) by concept or `AIP-N`. List every plausibly applicable AIP; record why each selected or excluded. Do not apply every AIP blindly.
3. Open each applicable official `https://google.aip.dev/{number}` page before deciding. The local reference is an applicability map and offline fallback, not a replacement for current official guidance.
4. Resolve conflicts in this order: current approved AIP, documented local compatibility requirement, precedent exception. Never copy a violation as precedent. Mark necessary exceptions `aip.dev/not-precedent` with rationale.
5. Derive a change-specific checklist from the exact official guidance. Cover proto/HTTP shape, behavior, errors, lifecycle, compatibility, documentation, and client ergonomics, not syntax alone.
6. Design or review the smallest conformant surface. Preserve wire compatibility unless the version/stability policy permits a break.
7. Run `api-linter` using the repository's existing command/config when available. Treat it as a floor: manually review applicable rules it cannot encode.
8. Report evidence as `AIP | state | applicability | result | evidence/exception`. Separate normative failures from advisory suggestions.

## Baseline

- Model management APIs as named resources in an acyclic hierarchy with standard methods first.
- Give resources a canonical relative resource `name` containing the complete service-relative path and a `(google.api.resource)` annotation; reserve display text for `display_name`.
- Make HTTP paths, request fields, method signatures, resource references, field behaviors, pagination, filtering, masks, errors, and LRO metadata agree.
- Validate behavior after mutations reaches the steady state promised by the method or operation.
- Review every change for compatibility, not only field-number reuse: names, types, formats, semantics, HTTP bindings, resource patterns, requiredness, and client behavior matter.
- Document user-visible semantics, validation, defaults, ordering, limits, side effects, errors, retention, and exceptions.

## Guardrails

- Do not invent guidance for unassigned numbers; the range contains 72 published General AIPs, not 236 documents.
- Do not treat examples as universal requirements. Apply conditional AIPs only when their trigger holds.
- Do not downgrade **must**/**must not** from an approved AIP. Distinguish **should** recommendations and documented exceptions.
- Do not claim conformance from `api-linter` alone or from this checklist alone.
- For legacy surfaces, prefer an explicit compatibility adapter over extending a non-conformant pattern.
