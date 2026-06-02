# Protobuf AIP Reference

## Repo-derived patterns to keep

Observed common patterns in a large Go/protobuf control-plane + public API monorepo:

- Public surface often has CRUD services, `google.api.http`, OpenAPI annotations, authz options, `google.api.field_behavior`, `buf.validate`, nested `Filter`, pagination, `FieldMask`, operation wrappers for async mutations.
- Newer resource-oriented areas use `(google.api.resource)`, `name` as full resource name, `IDENTIFIER`, storage/table annotations, tenant scoping, default ordering, and generated persistence.
- Older public endpoints often use `id` path params and response wrappers (`GetXResponse { X x = 1; }`). Treat as legacy compatibility. For new resources, choose AIP canonical `name`; map `id` at REST/UI boundary if required.
- Validation is split: `field_behavior` documents API contract; `buf.validate`/CEL enforces runtime shape; storage annotations enforce DB constraints.
- Lists commonly use nested `Filter`, `page_size`, `page_token`, `next_page_token`. Tokens must be bound to the filter to avoid mixing pages from different queries.
- Mutations frequently return an operation. That does not change Create/Update/Delete request semantics.

## Canonical resource example

```proto
message Book {
  option (google.api.resource) = {
    type: "library.example.com/Book"
    pattern: "publishers/{publisher}/books/{book}"
    singular: "book"
    plural: "books"
  };

  string name = 1 [
    (google.api.field_behavior) = IDENTIFIER,
    (buf.validate.field).string.pattern = "^publishers/[a-z][a-z0-9-]{0,62}/books/[a-z][a-z0-9-]{0,62}$"
  ];
  string display_name = 2 [(google.api.field_behavior) = REQUIRED];
  google.protobuf.Timestamp create_time = 3 [(google.api.field_behavior) = OUTPUT_ONLY];
  google.protobuf.Timestamp update_time = 4 [(google.api.field_behavior) = OUTPUT_ONLY];
  string etag = 5 [(google.api.field_behavior) = OUTPUT_ONLY];
}
```

Notes:
- AIP-121: resources are nouns; prefer standard methods.
- AIP-122: `name` is resource identity and full path.
- AIP-203: `IDENTIFIER` alone; not `OUTPUT_ONLY`, not `IMMUTABLE`.
- Use `display_name` for human text. Do not overload `name`.

## Canonical service example

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
  message Filter {
    string display_name_contains = 1;
    State state = 2;
  }
  Filter filter = 4;
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

## LRO variant

For async control-plane mutations, keep AIP request shape but return operation:

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

If using a local `Operation` type/wrapper, mirror same idea: operation id/state/error/result/metadata. Operation completion must mean steady resource state for management-plane calls.

## Legacy compatibility guidance

If existing public API has:

```proto
message Network { string id = 1; string name = 2; }
message GetNetworkRequest { string id = 1; }
```

Do not copy this into new AIP resources. Prefer:

```proto
message Network {
  option (google.api.resource) = { type: "example.com/Network" pattern: "networks/{network}" };
  string name = 1 [(google.api.field_behavior) = IDENTIFIER];
  string display_name = 2;
}
message GetNetworkRequest { string name = 1 [(google.api.resource_reference).type = "example.com/Network"]; }
```

If REST must remain `/v1/networks/{id}`, adapt at gateway/handler: `id` -> `name = "networks/" + id`. Keep internal/resource contract full-path.

## Update rules

- `update_mask` required unless API explicitly supports full replacement.
- Reject `name`, output-only, immutable, and unknown mask paths.
- Apply mask to stored resource, not to an empty resource.
- Validate after merge.
- Optional nested message mask means replace that submessage unless supporting deeper paths.
- For oneof changes, clear previous branch values and validate exactly one branch if required.

## Pagination/filter rules

- `page_size == 0` means server default; enforce max.
- `page_token` comes from prior `next_page_token`; empty means first page.
- Token should include cursor, order key, page size, and serialized filter hash/version.
- If request filter/order differs from token, return `INVALID_ARGUMENT`.
- Use stable ordering with tie-breaker, for example `created_at desc, name asc`.
- Filter fields should be explicit, typed, and indexed when needed; avoid unstructured query strings unless adopting AIP-160 deliberately.

## Validation and docs

- `REQUIRED`: client must provide; enforce with `buf.validate.field.required` for messages and string/enum rules for scalars.
- `OPTIONAL`: meaningful optional input; use explicit `optional` when presence matters.
- `OUTPUT_ONLY`: server writes; ignore or reject input consistently.
- `IMMUTABLE`: may be set on Create, never changed on Update.
- `IDENTIFIER`: resource `name`; immutable and not client-input on Create.
- Enums: first value `*_UNSPECIFIED = 0`; add `defined_only` and `not_in: [0]` when caller must choose.
- Times: prefer `create_time`/`update_time` per AIP names; if existing surface uses `created_at`/`updated_at`, do not mix within same API version.

## AIP map

- AIP-121 resource-oriented design: nouns + standard verbs; Get/List usually required; custom methods only when CRUD does not fit.
- AIP-122 resource names: full path, collection/id alternating segments, one canonical parent.
- AIP-133 Create: collection parent + resource body + `{resource}_id`; response resource or LRO.
- AIP-134 Update: resource body + field mask; target from resource `name`.
- AIP-135 Delete: request `name`; response empty or LRO; optional `etag`.
- AIP-154 freshness: `etag` for optimistic concurrency.
- AIP-156 singleton: no Create/Delete/id; fixed child under parent.
- AIP-158 pagination: `page_size`, `page_token`, `next_page_token`.
- AIP-203 field behavior: document every request/resource field where behavior matters.

Refs: https://google.aip.dev/121 https://google.aip.dev/122 https://google.aip.dev/133 https://google.aip.dev/134 https://google.aip.dev/135 https://google.aip.dev/154 https://google.aip.dev/156 https://google.aip.dev/158 https://google.aip.dev/203
