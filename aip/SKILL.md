---
name: aip
description: "Designs Google AIP-style protobuf resource APIs. Use when changing resource messages, standard-method RPCs, {resource}_id, parent wiring, CRUD/LRO shape, pagination, filtering, FieldMask, etag, or singleton resources."
paths:
  - "**/*.proto"
---

# Protobuf AIP Design

Repo/code changes: run `/deslop` before commit, push, PR, or merge.
Use for protobuf API design. Default to Google AIP. Treat legacy `id` paths/custom operation envelopes as compatibility exceptions, not new precedent. Deep examples: [REFERENCE.md](REFERENCE.md).

## Non-negotiables

- Resource identity: `string name = 1 [(google.api.field_behavior) = IDENTIFIER];`
- `name` is full path, not display text, not bare id: `publishers/123/books/456`.
- Client create id lives on Create request as `{resource}_id`; body `resource.name` ignored.
- Nested collections use `parent` = full parent resource name on Create/List.
- `IDENTIFIER` alone; do not add `OUTPUT_ONLY` or `IMMUTABLE` to `name`.
- Reject `name`, immutable, output-only, unknown, wildcard, and bare oneof paths in `update_mask`.

## Canonical resource

```proto
message Book {
  option (google.api.resource) = {
    type: "library.example.com/Book"
    pattern: "publishers/{publisher}/books/{book}"
    singular: "book"
    plural: "books"
  };
  string name = 1 [(google.api.field_behavior) = IDENTIFIER];
  string display_name = 2 [(google.api.field_behavior) = REQUIRED];
}
```

## Standard methods

- Get: `name` + `resource_reference.type`; returns resource.
- List: `parent` for nested + `page_size` + `page_token`; response `repeated resources` + `next_page_token`.
- Create: `parent` if nested + `{resource}_id` + resource body; add `method_signature`.
- Update: resource body + required `FieldMask`; resource `name` identifies target.
- Delete: `name`; optional `etag`; returns empty or LRO.
- Singleton: fixed `name`; no `{resource}_id`; no Create/Delete; Get/Update only.

## Compatibility rules

- Existing public APIs may expose `id`, wrapper responses, typed filters, or custom operations. Do not copy these for new stable resources unless preserving wire compatibility.
- If REST must keep `/v1/resources/{id}`, map at gateway/handler to canonical `resources/{id}` internally.
- For LROs, prefer `google.longrunning.Operation` + `operation_info`; custom operation resource only by compatibility.
- Typed `Filter` messages are acceptable for internal/legacy surfaces; public AIP default is string `filter` + `order_by`.

## Implementation rules

- Handlers stay thin: parse resource names, validate masks, call tenant-scoped repo, map errors.
- Create: verify parent, compose full `name`, generate valid id when empty, persist full name.
- List: stable keyset order, opaque token with resource type + filter hash + cursor; reject token/filter mismatch.
- Update: lock current row, field-mask merge onto stored resource, validate merged result, preserve server-owned fields.
- Delete: NotFound for missing unless contract says idempotent; `etag` mismatch -> Aborted.
- Storage: proto annotations define table/columns/order/filter; repo owns tenancy, timestamps, transactions.

## Checklist

1. `(google.api.resource)` has `type`, `pattern`, `singular`, `plural`.
2. `name` field 1, full path, `IDENTIFIER` only; display text is `display_name`.
3. Create uses `{resource}_id`, not body `name`; nested uses `parent` + `child_type`.
4. Get/Delete use full `name` + `resource_reference.type`; Delete may include `etag`.
5. Update has required `FieldMask`; rejects forbidden paths; validates merged resource.
6. List has pagination; filters/order stable across page tokens.
7. `field_behavior` documents; `buf.validate`/CEL enforces; enum zero is `*_UNSPECIFIED`.
8. LRO completion means resource reached steady state.
