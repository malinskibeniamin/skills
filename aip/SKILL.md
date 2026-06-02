---
name: aip
description: "Designs resource-oriented protobuf APIs using Google AIP rules. Use when adding or changing a resource message, standard-method RPC, name versus {resource}_id choice, parent wiring, nested or top-level collections, or singleton resources."
paths:
  - "**/*.proto"
---

# Protobuf AIP Design

Use for AIP-121/122/133/134/135/154/156/158/203 resource APIs.

## Core Rule
`name` = full resource path, resource identity. Never bare id.
`{resource}_id` = client-chosen final segment. Create request only.
`parent` = full parent resource name. Create/List for nested collections.
Example: `publishers/123` + `book_id=456` -> `publishers/123/books/456`.

## Resource
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

Rules: `name` field 1; full path only; `IDENTIFIER` alone; no `OUTPUT_ONLY`/`IMMUTABLE`; never in `update_mask`; id regex `^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$`.

## Create
```proto
message CreateBookRequest {
  string parent = 1 [
    (google.api.field_behavior) = REQUIRED,
    (google.api.resource_reference).child_type = "library.example.com/Book"
  ];
  string book_id = 2 [(google.api.field_behavior) = OPTIONAL];
  Book book = 3 [(google.api.field_behavior) = REQUIRED];
}
rpc CreateBook(CreateBookRequest) returns (Book) {
  option (google.api.method_signature) = "parent,book,book_id";
}
```

Rules: ignore `book.name`; server composes `name = parent + "/books/" + book_id`; empty id -> server generates valid id; management-plane id must exist; data-plane id should exist, may be optional; nested -> required `parent` + `child_type`; top-level -> omit `parent`; add method signature.

## Parent
`parent` = full parent resource name, not bare id.
Get/Update/Delete use full `name`; Create/List use `parent`.

## Singleton

AIP-156 singleton: one per parent. Fixed `name`; no `{resource}_id`; no Create/Delete; Get/Update only.

## Standard Methods
```proto
message GetBookRequest {
  string name = 1 [(google.api.field_behavior) = REQUIRED, (google.api.resource_reference).type = "library.example.com/Book"];
}
message DeleteBookRequest {
  string name = 1 [(google.api.field_behavior) = REQUIRED, (google.api.resource_reference).type = "library.example.com/Book"];
  string etag = 2 [(google.api.field_behavior) = OPTIONAL];
}
message UpdateBookRequest {
  Book book = 1 [(google.api.field_behavior) = REQUIRED];
  google.protobuf.FieldMask update_mask = 2;
}
message ListBooksRequest {
  string parent = 1 [(google.api.field_behavior) = REQUIRED, (google.api.resource_reference).child_type = "library.example.com/Book"];
  int32 page_size = 2;
  string page_token = 3;
}
message ListBooksResponse { repeated Book books = 1; string next_page_token = 2; }
```

## Backend Rules
- Create: ignore body `name`; parse `parent`; verify parent exists; compose full `name`; persist full `name`.
- Generated id must match regex; prefix UUID/hex with letter.
- Store parent id/FK separately; List scoped by parent column.
- `name` = key, immutable. Reject `update_mask` with `name`.
- Update: load by `book.name`; field-mask merge; validate; persist; never write output-only client input.
- Delete: key by full `name`; use `etag` when concurrency needed.

## Checklist
1. `(google.api.resource)` type/pattern/singular/plural.
2. `name` field 1, full path, `IDENTIFIER` only.
3. Nested: `parent` required + `child_type`. Top-level: no `parent`. Singleton: no id/Create/Delete.
4. Create has `{resource}_id` request field; body `name` ignored; method signature present.
5. Get/Delete use full `name` + `resource_reference.type`.
6. Update uses resource + `FieldMask`; rejects `name` mask.
7. List uses `parent`, `page_size`, `page_token`; response has `next_page_token`.

Refs: AIP-121/122/133/134/135/154/156/158/203 at https://google.aip.dev/.
