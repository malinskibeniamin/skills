# Protobuf AIP Reference

Dense guidance for resource-oriented protobuf APIs. It combines Google AIP rules with patterns observed in large Go control-plane/public API codebases.

## Decision tree

1. New stable resource? Use AIP canonical `name` full path. Do not start with legacy `id`.
2. Existing `id` API? Preserve wire shape, but map `id` to canonical `name` internally when adding new code.
3. User-facing label? Use `display_name` or domain-specific noun, never `name`.
4. Parent-scoped resource? Resource `pattern` includes parent; Create/List take `parent` full resource name.
5. Async mutation? Keep request shape AIP-canonical; only response becomes LRO/operation.
6. Partial update? Require `update_mask`; reject unsafe paths; merge onto stored resource.
7. List? Use stable ordering + opaque page tokens; bind tokens to filter/order.

## Canonical resource

```proto
message Book {
  option (google.api.resource) = {
    type: "library.example.com/Book"
    pattern: "publishers/{publisher}/books/{book}"
    singular: "book"
    plural: "books"
  };

  // Full resource name: publishers/{publisher}/books/{book}
  string name = 1 [
    (google.api.field_behavior) = IDENTIFIER,
    (buf.validate.field).string.pattern = "^publishers/[a-z][a-z0-9-]{0,62}/books/[a-z][a-z0-9-]{0,62}$"
  ];

  string display_name = 2 [(google.api.field_behavior) = REQUIRED];
  State state = 3 [(google.api.field_behavior) = OUTPUT_ONLY];
  google.protobuf.Timestamp create_time = 4 [(google.api.field_behavior) = OUTPUT_ONLY];
  google.protobuf.Timestamp update_time = 5 [(google.api.field_behavior) = OUTPUT_ONLY];
  string etag = 6 [(google.api.field_behavior) = OUTPUT_ONLY];

  enum State {
    STATE_UNSPECIFIED = 0;
    CREATING = 1;
    READY = 2;
    DELETING = 3;
    FAILED = 4;
  }
}
```

Why:
- AIP-121: resources are nouns; standard methods cover common operations.
- AIP-122: `name` is canonical full path; separate `uid`/`id` may be output-only only.
- AIP-203: `IDENTIFIER` means identity, immutable, and not input on create.
- Use `display_name` for human text. If existing API already used `name` for display text, do not mix semantics in the same version.

## Canonical service

```proto
service LibraryService {
  rpc GetBook(GetBookRequest) returns (Book) {
    option (google.api.http) = { get: "/v1/{name=publishers/*/books/*}" };
    option (google.api.method_signature) = "name";
  }

  rpc ListBooks(ListBooksRequest) returns (ListBooksResponse) {
    option (google.api.http) = { get: "/v1/{parent=publishers/*}/books" };
    option (google.api.method_signature) = "parent";
  }

  rpc CreateBook(CreateBookRequest) returns (Book) {
    option (google.api.http) = { post: "/v1/{parent=publishers/*}/books" body: "book" };
    option (google.api.method_signature) = "parent,book,book_id";
  }

  rpc UpdateBook(UpdateBookRequest) returns (Book) {
    option (google.api.http) = { patch: "/v1/{book.name=publishers/*/books/*}" body: "book" };
    option (google.api.method_signature) = "book,update_mask";
  }

  rpc DeleteBook(DeleteBookRequest) returns (google.protobuf.Empty) {
    option (google.api.http) = { delete: "/v1/{name=publishers/*/books/*}" };
    option (google.api.method_signature) = "name";
  }
}
```

Notes:
- Add `method_signature` for new standard methods.
- HTTP body should be explicit resource field (`book`), not `*`, unless preserving compatibility.
- Response wrapper messages (`GetBookResponse`) are legacy/public compatibility; AIP standard methods return the resource directly.

## Request/response shapes

```proto
message GetBookRequest {
  string name = 1 [
    (google.api.field_behavior) = REQUIRED,
    (google.api.resource_reference).type = "library.example.com/Book"
  ];
}

message ListBooksRequest {
  string parent = 1 [
    (google.api.field_behavior) = REQUIRED,
    (google.api.resource_reference).child_type = "library.example.com/Book"
  ];
  int32 page_size = 2 [(buf.validate.field).int32 = { gte: 0 lte: 1000 }];
  string page_token = 3;
  string filter = 4;   // AIP-160 public default. Typed Filter is compatibility/internal.
  string order_by = 5;
}
message ListBooksResponse {
  repeated Book books = 1;
  string next_page_token = 2;
}

message CreateBookRequest {
  string parent = 1 [(google.api.field_behavior) = REQUIRED, (google.api.resource_reference).child_type = "library.example.com/Book"];
  string book_id = 2 [(google.api.field_behavior) = OPTIONAL];
  Book book = 3 [(google.api.field_behavior) = REQUIRED];
}

message UpdateBookRequest {
  Book book = 1 [(google.api.field_behavior) = REQUIRED];
  google.protobuf.FieldMask update_mask = 2 [(google.api.field_behavior) = REQUIRED];
}

message DeleteBookRequest {
  string name = 1 [(google.api.field_behavior) = REQUIRED, (google.api.resource_reference).type = "library.example.com/Book"];
  string etag = 2 [(google.api.field_behavior) = OPTIONAL];
}
```

## Create rules

- Request has `parent` for nested resources; omit for top-level.
- Request has `{resource}_id` when caller may choose final path segment.
- Body is the resource. Ignore body `name`; server composes from `parent` + collection + id.
- Management-plane resources should support user-provided ids when resource needs stable IaC-friendly names.
- Generated ids must satisfy resource id regex; prefix UUID/hex with a letter.
- Verify parent exists before insert; NotFound if parent missing.
- Persist full `name`; optionally store parent id/tenant FK separately for indexing and authorization.

## Update rules

- Require non-empty `update_mask` unless explicit full-replace API.
- Target is `resource.name`, not separate `id`.
- Reject `*`, unknown paths, `name`, output-only fields, immutable fields, and bare oneof discriminator paths.
- Load current row, lock it when concurrent writes are possible, merge mask into stored resource, validate merged result, persist.
- Preserve server-owned fields (`name`, uid/id, timestamps, state, etag unless recomputed).
- If `etag` supplied and mismatch, return Aborted.
- Validation interceptors should ignore violations for fields outside mask, but handlers still must reject invalid masks.

## Delete rules

- Request key is full `name`.
- Optional `etag` enables optimistic concurrency.
- Missing resource returns NotFound unless API explicitly documents idempotent delete.
- Async delete may return LRO/operation; completion means Get returns NotFound or terminal deleted state.

## List, filter, pagination

- AIP public default: `string filter`, `string order_by`.
- Typed nested `Filter` is okay for internal/legacy/generated-client ergonomics, but document as exception.
- `page_size == 0` means server default; enforce max.
- `page_token` opaque; empty means first page.
- Token should include resource type, endpoint/version, filter hash, order fields, cursor values, expiry/version.
- Reject malformed, expired, wrong-resource, wrong-filter, or wrong-order tokens with InvalidArgument.
- Use keyset pagination and stable default order with tie-breaker, for example `create_time desc, name asc`.
- Generated client wrappers depend on exact `page_token`/`next_page_token` names.

## LRO / operation

Preferred:

```proto
rpc CreateBook(CreateBookRequest) returns (google.longrunning.Operation) {
  option (google.longrunning.operation_info) = {
    response_type: "Book"
    metadata_type: "CreateBookMetadata"
  };
}
message CreateBookMetadata {
  string name = 1 [(google.api.field_behavior) = OUTPUT_ONLY];
}
```

Compatibility option: local `Operation` resource/wrapper. If used, keep semantics: opaque operation id, metadata, done/error/result, create/update/delete metadata, operation Get/List, filter-bound page tokens. Method completion/LRO done must mean resource steady state.

## Singleton

Use singleton when exactly one resource exists per parent.

```proto
message Settings {
  option (google.api.resource) = {
    type: "library.example.com/Settings"
    pattern: "publishers/{publisher}/settings"
    singular: "settings"
    plural: "settings"
  };
  string name = 1 [(google.api.field_behavior) = IDENTIFIER];
}
```

No Create. No Delete. No `{resource}_id`. Use Get/Update only.

## Validation and frontend/generated-client implications

- `field_behavior` documents API contract; `buf.validate`/CEL enforces shape. Use both.
- Prefer standard validate rules (`string.email`, `string.uri`, UUID, numeric bounds) over duplicated UI/server logic.
- Proto field names are validation-path contracts. Renames require server `BadRequest.FieldViolation.field` and UI path migration.
- Request wrapper field name becomes error path prefix; keep it canonical: `book`, `update_mask`, `parent`.
- Use `optional` only when unset differs from default; this affects patch payloads and masks.
- Required oneof: `option (buf.validate.oneof).required = true`; use clear oneof and branch names.
- Enum zero: `*_UNSPECIFIED = 0`; reject zero with validation when caller must choose.
- Service/package boundaries affect generated query keys/cache invalidation; group methods intentionally.

## Storage/backend pattern

- Proto annotations define table, columns, orderable/filterable fields, tenancy, primary keys, indexes.
- Repository owns tenancy, uid/name generation, timestamps, transactions, and error mapping.
- Create: insert server-owned fields and return inserted row.
- Get: parse/validate name before DB; tenant-scope query; NotFound on no row.
- List: tenant/parent-scoped query + keyset page helper.
- Update: `SELECT ... FOR UPDATE`; convert row to proto; mutate via mask; pin immutable fields; `UPDATE ... RETURNING`.
- Delete: tenant/parent-scoped delete; check affected rows; optional etag precheck.
- Secrets: never store plaintext in resource proto; return secret value only once on Create; later reads return metadata.

## Legacy compatibility mapping

Legacy shape:

```proto
message Network { string id = 1; string name = 2; }
message GetNetworkRequest { string id = 1; }
```

New AIP shape:

```proto
message Network {
  option (google.api.resource) = { type: "example.com/Network" pattern: "networks/{network}" singular: "network" plural: "networks" };
  string name = 1 [(google.api.field_behavior) = IDENTIFIER];
  string display_name = 2;
  string uid = 3 [(google.api.field_behavior) = OUTPUT_ONLY];
}
message GetNetworkRequest { string name = 1 [(google.api.resource_reference).type = "example.com/Network"]; }
```

If REST must keep `/v1/networks/{id}`, translate `id` -> `name = "networks/" + id` at boundary. Do not let `id` become new proto identity.

## AIP map

- AIP-121 resource design: resources, hierarchy, standard methods; Get/List expected except singleton.
- AIP-122 names: full path, alternating collection/id segments, resource has `name`.
- AIP-127 HTTP: transcode names in path, explicit body field.
- AIP-133 Create: `parent`, resource body, `{resource}_id`, method signature.
- AIP-134 Update: resource + `FieldMask`; target in resource `name`.
- AIP-135 Delete: request `name`; optional LRO/empty response.
- AIP-151 LRO: operation response for async mutations.
- AIP-154 etag: freshness/optimistic concurrency.
- AIP-156 singleton: no Create/Delete/id.
- AIP-158 pagination: `page_size`, `page_token`, `next_page_token`.
- AIP-160 filtering: public string `filter`.
- AIP-161 field masks: update/read masks.
- AIP-203 field behavior: REQUIRED/OPTIONAL/OUTPUT_ONLY/IMMUTABLE/IDENTIFIER.

Refs: https://google.aip.dev/121 https://google.aip.dev/122 https://google.aip.dev/127 https://google.aip.dev/133 https://google.aip.dev/134 https://google.aip.dev/135 https://google.aip.dev/151 https://google.aip.dev/154 https://google.aip.dev/156 https://google.aip.dev/158 https://google.aip.dev/160 https://google.aip.dev/161 https://google.aip.dev/203
