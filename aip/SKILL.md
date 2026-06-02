---
name: aip
description: "Designs resource-oriented protobuf APIs using Google AIP rules plus common control-plane/public API proto patterns. Use when adding or changing a resource message, standard-method RPC, name versus {resource}_id choice, parent wiring, CRUD/LRO shape, pagination, filtering, or singleton resources."
paths:
  - "**/*.proto"
---

# Protobuf AIP Design

Use for resource-oriented protobuf APIs. Default to Google AIP canonical shape; treat legacy `id`-based APIs as compatibility only. Details/examples: [REFERENCE.md](REFERENCE.md).

## Core rule

`name` = full resource path, identity. Never bare id. Field 1. `IDENTIFIER` only.
`{resource}_id` = client-chosen final segment. Create request only.
`parent` = full parent resource name. Create/List for nested collections.
Example: `publishers/123` + `book_id=456` -> `publishers/123/books/456`.

## Resource shape

```proto
message Book {
  option (google.api.resource) = {
    type: "library.example.com/Book"
    pattern: "publishers/{publisher}/books/{book}"
    singular: "book"
    plural: "books"
  };
  string name = 1 [(google.api.field_behavior) = IDENTIFIER];
}
```

Do not add `OUTPUT_ONLY` or `IMMUTABLE` to `name`; `IDENTIFIER` already means immutable + not input. Never allow `name` in `update_mask`. Id segment regex: `^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$`.

## Standard methods

- Get/Delete: request has `string name = 1 [REQUIRED, resource_reference.type]`.
- List: request has `parent` for nested collections, `page_size`, `page_token`; response has `repeated resources`, `next_page_token`.
- Create: request has `parent` if nested, `{resource}_id`, body resource. Body `name` ignored.
- Update: request has resource + `google.protobuf.FieldMask update_mask`; resource `name` identifies target.
- Singleton: fixed `name`; no `{resource}_id`; no Create/Delete; Get/Update only.

## Control-plane/public API patterns

- Mutations may return an operation/LRO. Keep request/resource shape AIP-canonical; operation is response envelope only.
- HTTP transcoding: `GET/DELETE /v1/{name=...}`; `POST` collection with `body: "resource"`; `PATCH /v1/{resource.name=...}` with `body: "resource"`.
- Public REST compatibility may expose `id` paths or wrapper responses. New protobuf contract should still prefer `name`; if legacy needs `id`, map at boundary, not in new resource identity.
- Use `google.api.field_behavior` for contract docs and `buf.validate`/CEL for enforcement.
- Required oneof: add `option (buf.validate.oneof).required = true`; clear old branch values on switch in handlers/UI.
- Filters are optional nested `Filter` messages; page tokens must encode/validate filter consistency.
- Use `etag` for freshness on Update/Delete when concurrent writes matter.

## Backend rules

Create ignores body `name`; parses `parent`; verifies parent exists; composes/persists full `name`. Generated ids must match regex; prefix UUID/hex with a letter. Store parent FK/tenant column separately; scope List by parent/tenant. Update loads by resource `name`, rejects `name` mask, field-mask merges, validates, persists. Output-only fields are server-owned.

## Checklist

1. `(google.api.resource)` has `type`, `pattern`, `singular`, `plural`.
2. `name` = field 1, full path, `IDENTIFIER` only.
3. Nested: `parent` required + `resource_reference.child_type`; top-level: no `parent`; singleton: no id/Create/Delete.
4. Create: `{resource}_id` request field; body `name` ignored; `method_signature` present.
5. Get/Delete: full `name` + `resource_reference.type`; Delete may include `etag`.
6. Update: resource + required `FieldMask`; `name` identifies target; reject `name`/output-only/immutable masks.
7. List: `parent` for nested, `page_size`, `page_token`; response has `next_page_token`; filters stable across tokens.
8. Validate: field_behavior + buf.validate/CEL agree; enums reject unspecified unless meaningful.
9. LRO: response operation includes metadata/result types; completion gives steady resource state.
