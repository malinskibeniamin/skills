# General AIP Applicability Reference

This is a compact index to the 72 published General AIPs numbered 1 through 236. It is derived from the official corpus at `google.aip.dev`; the linked official page remains authoritative and must be read for exact requirements, exceptions, and examples before making a decision.

**State policy:** Approved guidance is normative according to its own requirement keywords. AIP-162 is draft and AIP-182 is reviewing; both are advisory only. `Apply` below identifies the main design pressure, not every rule.

**Fast lookup:** `rg -n '^## AIP-(122|133|161) ' aip/REFERENCE.md`. Search `Use when` terms first, then open every selected source. Categories: meta/process/concepts; resources; protocol/methods; fields; design patterns; compatibility/polish/protobuf; batch/specialized.

---

**Meta, process, and API concepts**

## AIP-1 - AIP Purpose and Guidelines

**State:** approved

**Use when:** Authoring, changing, interpreting, or deciding whether to rely on an AIP.

**Apply:** Treat approved AIPs as best current practice and rely primarily on them. Distinguish guidance from process documents and all lifecycle states. Ground proposals in concrete examples or prior art and follow the editor review/approval workflow.

**Source:** https://google.aip.dev/1

## AIP-2 - AIP Numbering

**State:** approved

**Use when:** Proposing an AIP or choosing its scope and number.

**Apply:** Let editors assign numbers. Use 1-999 for generally applicable AIPs and the allocated block for a domain-specific scope; do not infer that every integer is assigned.

**Source:** https://google.aip.dev/2

## AIP-3 - AIP Versioning

**State:** approved

**Use when:** Releasing or citing a version of the AIP corpus.

**Apply:** Version the corpus by ISO date, tag releases as `vYYYY-MM-DD`, cut a new version for significant changes, and maintain a dated changelog in each AIP.

**Source:** https://google.aip.dev/3

## AIP-8 - AIP Style and Guidance

**State:** approved

**Use when:** Writing or reviewing an AIP document.

**Apply:** Cover one discrete topic with actionable, client-benefiting guidance. Avoid duplication or contradiction, state conditional applicability, use the required document structure and normative keywords, keep rationale separate, and provide valid examples and references.

**Source:** https://google.aip.dev/8

## AIP-9 - Glossary

**State:** approved

**Use when:** Naming actors, surfaces, and artifacts in API design or AIP prose.

**Apply:** Use the corpus vocabulary consistently, especially API, service, interface, method, request, producer, consumer, client, user, and declarative client, rather than treating near-synonyms as interchangeable.

**Source:** https://google.aip.dev/9

## AIP-100 - API Design Review FAQ

**State:** approved

**Use when:** Planning an API design review, launch stage, exception, or escalation.

**Apply:** Seek review early for externally consumed APIs and do not use launch pressure as a substitute for review. A restricted alpha may precede approval where allowed. Document guideline violations with `aip.dev/not-precedent`, rationale, and the exception reasoning from AIP-200.

**Source:** https://google.aip.dev/100

## AIP-111 - Planes

**State:** approved

**Use when:** Deciding whether management-plane conventions fit a high-throughput or established-protocol surface.

**Apply:** Apply the resource-oriented AIPs to management-plane APIs. Data-plane APIs may diverge for latency, throughput, or external-protocol needs; any resource-oriented management facade over data-plane functionality still follows management-plane guidance.

**Source:** https://google.aip.dev/111

---

**Resource design**

## AIP-121 - Resource-oriented design

**State:** approved

**Use when:** Defining an API's nouns, hierarchy, schemas, methods, or mutation completion semantics.

**Apply:** Model named resources and collections in an acyclic hierarchy, keep one resource schema across methods, provide Get and normally List, prefer standard methods, keep requests stateless, and make management-plane mutation completion mean the resource reached a readable steady state.

**Source:** https://google.aip.dev/121

## AIP-122 - Resource names

**State:** approved

**Use when:** Defining resource patterns, IDs, aliases, parent fields, references, or display names.

**Apply:** Use unique relative resource names with alternating plural collection and ID segments separated by `/`. Put the complete relative name in the resource's first field, `name`; use `parent` for a collection owner and typed string names for associations. Return canonical names even when accepting aliases, use `//{service}/{relative_name}` only for genuinely ambiguous cross-API references, document user ID syntax, and reserve `name` from display text.

**Source:** https://google.aip.dev/122

## AIP-123 - Resource types

**State:** approved

**Use when:** Adding `(google.api.resource)`, resource-reference annotations, or multiple name patterns.

**Apply:** Declare a globally unique `{service}/{Type}` aligned with the message name plus valid `pattern`, `singular`, and `plural`. Keep collection/variable names and patterns coherent and unique. Append new patterns without removing or reordering existing ones.

**Source:** https://google.aip.dev/123

## AIP-124 - Resource association

**State:** approved

**Use when:** Modeling multiple ownership candidates, many-to-one, or many-to-many relationships.

**Apply:** Give each resource instance at most one canonical parent. Represent other associations as typed resource-name fields and filter List by them; use repeated resource names or an association subresource for many-to-many relationships. Do not require multiple parents in List.

**Source:** https://google.aip.dev/124

## AIP-126 - Enumerations

**State:** approved

**Use when:** Choosing enum, string, or boolean representations for a bounded value set.

**Apply:** Use enums for infrequently changing closed sets, `UPPER_SNAKE_CASE` values, and normally `{ENUM}_UNSPECIFIED = 0`; nest single-message enums. Prefer documented kebab-case strings for frequently changing sets and established standardized codes where one exists. Use booleans only when future expansion is implausible.

**Source:** https://google.aip.dev/126

## AIP-128 - Declarative-friendly interfaces

**State:** approved

**Use when:** A resource will be managed by Terraform, configuration tools, controllers, or other declarative clients.

**Apply:** Use strongly consistent standard lifecycle methods and declarative annotations. Expose output-only `reconciling` when convergence is delayed, return current rather than intended state, require etags and change validation, avoid imperative custom methods, and follow the stricter update/delete rules linked by the AIP.

**Source:** https://google.aip.dev/128

## AIP-129 - Server-Modified Values and Defaults

**State:** approved

**Use when:** The server supplies defaults, normalizes input, computes effective values, or otherwise changes fields.

**Apply:** Give every field one owner. Mark server-owned values `OUTPUT_ONLY` and preserve client-owned input. Represent a configurable value and its computed result as separate input and `effective_...` fields; annotate permitted normalization with `google.api.field_info` and return other user values unchanged.

**Source:** https://google.aip.dev/129

## AIP-156 - Singleton resources

**State:** approved

**Use when:** Exactly one resource inherently exists per parent.

**Apply:** Use a static final name segment with no resource ID and still declare `singular` and `plural`. Omit Create and Delete; normally provide Get and Update unless every field is output-only. The singleton begins and ends with its parent.

**Source:** https://google.aip.dev/156

---

**Protocol and methods**

## AIP-127 - HTTP and gRPC Transcoding

**State:** approved

**Use when:** Mapping protobuf RPCs to HTTP paths, verbs, bodies, query parameters, or additional bindings.

**Apply:** Annotate every public RPC with `google.api.http`; follow the method-specific verb/path/body rules, bind resource-name fields in paths, and let unbound non-body fields become query parameters. Use additional bindings only for genuine alternate URIs and keep path variables consistent with request fields.

**Source:** https://google.aip.dev/127

## AIP-130 - Methods

**State:** approved

**Use when:** Choosing between standard, batch, aggregate, custom, or streaming operations.

**Apply:** Choose the first category that honestly fits: standard resource/collection method, then batch or aggregate, then resource/collection/stateless custom method, then streaming. Favor the most uniform category clients can automate; do not distort standard semantics to avoid a custom method.

**Source:** https://google.aip.dev/130

## AIP-131 - Standard methods: Get

**State:** approved

**Use when:** Retrieving one resource.

**Apply:** Define `Get{Resource}` with HTTP `GET`, a required typed `name` as the sole path variable, signature `name`, no body, and the resource itself as response. Do not add unrelated required fields; normally return the full resource and use standard permission/not-found errors.

**Source:** https://google.aip.dev/131

## AIP-132 - Standard methods: List

**State:** approved

**Use when:** Listing a finite resource collection.

**Apply:** Define `List{Resources}` with HTTP `GET`, literal collection path, required typed `parent` except for top-level resources, and pagination on every List. Return one repeated resource field plus `next_page_token`; use the standardized `filter`, `order_by`, `show_deleted`, and `total_size` shapes only when applicable and document non-natural ordering.

**Source:** https://google.aip.dev/132

## AIP-133 - Standard methods: Create

**State:** approved

**Use when:** Creating a resource in an existing collection.

**Apply:** Define `Create{Resource}` with HTTP `POST`, typed `parent` unless top-level, an explicit resource body, and the resource or correctly typed LRO as response. Include `{resource}_id` for management-plane resources, allow callers to choose it, ignore body `name`, document ID format, and return `ALREADY_EXISTS` or permission-safe errors for collisions.

**Source:** https://google.aip.dev/133

## AIP-134 - Standard methods: Update

**State:** approved

**Use when:** Mutating fields on an existing resource.

**Apply:** Define `Update{Resource}` using `PATCH`, body `{resource}`, URI `{resource}.name`, and resource/LRO response. Include an optional `google.protobuf.FieldMask update_mask`; omitted means populated fields, and `*` means full replacement. Keep state transitions and other side effects in custom methods; use `allow_missing` and etag semantics only as specified.

**Source:** https://google.aip.dev/134

## AIP-135 - Standard methods: Delete

**State:** approved

**Use when:** Deleting one resource, cascading children, or supporting idempotent deletion.

**Apply:** Define `Delete{Resource}` with HTTP `DELETE`, required typed `name`, no body, and Empty/resource/LRO response according to hard/soft/long-running behavior. Default missing resources to `NOT_FOUND`; require explicit `force` for cascading children, validate etags when accepted, and use `allow_missing` only for the documented no-op behavior.

**Source:** https://google.aip.dev/135

## AIP-136 - Custom methods

**State:** approved

**Use when:** Required behavior does not fit a standard method without distorting its semantics.

**Apply:** Prefer resource- or collection-bound custom methods. Name the RPC verb+noun without prepositions or standard-method verbs; map the same lower-camel verb after `:`, use `GET` for read-only operations and `POST` for mutations/billed stateless work, and follow canonical `name`/`parent`, body, request, response, and LRO patterns.

**Source:** https://google.aip.dev/136

## AIP-151 - Long-running operations

**State:** approved

**Use when:** Work cannot reasonably finish within a normal request or needs durable progress/error tracking.

**Apply:** Return a non-streaming `google.longrunning.Operation`, declare both `response_type` and `metadata_type`, and implement the standard Operations service rather than a local substitute. Return start failures immediately, execution failures in `Operation.error`, and progress/partial non-terminal errors in typed metadata. Keep standard-method response types canonical; type changes are breaking, and disallowed parallel work returns `ABORTED`.

**Source:** https://google.aip.dev/151

---

**Fields**

## AIP-140 - Field names

**State:** approved

**Use when:** Naming any request, response, resource, scalar, repeated, boolean, binary, URI, or display field.

**Apply:** Use precise American-English `lower_snake_case`, the same name for the same concept, singular/plural matching cardinality, familiar abbreviations, adjective-before-noun, and noun/state rather than action wording. Omit `is_` on booleans, use `bytes` for binary, distinguish `uri` from `url`, avoid language keywords, and use `display_name` for non-unique human labels.

**Source:** https://google.aip.dev/140

## AIP-141 - Quantities

**State:** approved

**Use when:** Representing counts, measurements, rates, compound units, or inverse units.

**Apply:** Put the accepted unit suffix on numeric fields, use `_count` for item counts, standard singular abbreviations, and `per` for inverse units. Avoid unsigned integer types. Use a specialized quantity message only when the richer representation is justified.

**Source:** https://google.aip.dev/141

## AIP-142 - Time and duration

**State:** approved

**Use when:** Representing instants, elapsed time, dates, time of day, intervals, or recurring civil time.

**Apply:** Reuse `google.protobuf.Timestamp`, `Duration`, and appropriate `google.type` civil-time messages. Name instants `*_time` and durations `*_duration`, document precision/range/time-zone semantics, and do not encode time as ad hoc integers or strings when a common component fits.

**Source:** https://google.aip.dev/142

## AIP-143 - Standardized codes

**State:** approved

**Use when:** Representing media types, countries/regions, currencies, languages, or time zones.

**Apply:** Use standard strings rather than API-specific enums: IANA media type in `mime_type`, CLDR territory in `region_code`, ISO 4217 in `currency_code`, BCP 47 in `language_code`, IANA zone in `time_zone`, or ISO 8601 offset in `utc_offset`. Link the standard, accept case-insensitively when unambiguous, and return canonical case.

**Source:** https://google.aip.dev/143

## AIP-144 - Repeated fields

**State:** approved

**Use when:** Adding a list or deciding its update semantics.

**Apply:** Use a plural repeated field with an enforced practical upper bound; use a subresource if the data may grow too large, and store other resources by name rather than inline. Choose scalars only when elements will not need metadata. Whole-list Update is normal; use canonical atomic Add/Remove methods when races require them, but declarative resources must use Update.

**Source:** https://google.aip.dev/144

## AIP-145 - Ranges

**State:** approved

**Use when:** Modeling numeric, lexical, or temporal ranges and intervals.

**Apply:** Prefer same-typed `start_...` and `end_...` fields with an inclusive start and exclusive end. Use `google.type.Interval` for matching timestamp intervals. Where strong colloquial convention requires both ends inclusive, use `first_...` and `last_...` and document the exception clearly.

**Source:** https://google.aip.dev/145

## AIP-146 - Generic fields

**State:** approved

**Use when:** Considering `oneof`, maps, `Struct`, `Value`, or `Any` instead of a concrete schema.

**Apply:** Prefer explicit typed fields. Use `oneof` for a closed set of alternatives, maps for homogeneous keyed values, `Struct`/`Value` only for intentionally schemaless JSON, and `Any` only with a controlled type registry and a real need for extensible protobuf payloads. Document validation and compatibility.

**Source:** https://google.aip.dev/146

## AIP-147 - Sensitive fields

**State:** approved

**Use when:** Handling passwords, private keys, tokens, credentials, secrets, or other values unsafe to return or log.

**Apply:** Accept sensitive values as `INPUT_ONLY` and never return them after receipt. For optional secrets, expose an output-only `{field}_set` boolean or, when identification is useful, an `obfuscated_{field}` value. Prevent accidental exposure through logs, errors, exports, or read methods.

**Source:** https://google.aip.dev/147

## AIP-148 - Standard fields

**State:** approved

**Use when:** Adding common identity, display, timestamp, annotation, description, request, or freshness fields.

**Apply:** Reuse the defined name, type, behavior, and semantics for `name`, `parent`, `display_name`, `title`, `given_name`, `family_name`, `create_time`, `update_time`, `delete_time`, `expire_time`, `purge_time`, `annotations`, `ip_address`, and `uid`. Do not coin synonyms; follow the linked AIPs for other common fields such as etag, request ID, filter, and validation-only.

**Source:** https://google.aip.dev/148

## AIP-149 - Unset field values

**State:** approved

**Use when:** Zero/default and absent carry different meaning, especially on create or update.

**Apply:** Define what an unset value means and preserve proto presence only when the distinction is part of the contract. Use `optional` deliberately, not as a substitute for `REQUIRED`/`OPTIONAL` field behavior, and evaluate compatibility before changing presence or default semantics.

**Source:** https://google.aip.dev/149

## AIP-202 - Fields

**State:** approved

**Use when:** A field has a machine-readable format beyond its protobuf scalar type.

**Apply:** Add `google.api.field_info` only when this or another AIP calls for it. Apply its format only to the permitted primitive type, currently UUID4 and IPv4/IPv6 string formats, and compare parsed values rather than raw normalized text. Adding or changing a format is breaking unless the field already always conformed; new formats need an RFC or approved AIP.

**Source:** https://google.aip.dev/202

## AIP-203 - Field behavior documentation

**State:** approved

**Use when:** Annotating requiredness, ownership, mutability, identity, ordering, or oneof/nested behavior.

**Apply:** Annotate every field reachable from a request with all applicable behaviors and at least one of `REQUIRED`, `OPTIONAL`, or `OUTPUT_ONLY`, except the resource etag and documented oneof case. Use `IDENTIFIER`, `IMMUTABLE`, `INPUT_ONLY`, and `UNORDERED_LIST` only with their defined semantics; `IDENTIFIER` belongs only on resource `name` and should not be stacked with redundant behaviors. Treat nested annotations independently and behavior changes as compatibility changes.

**Source:** https://google.aip.dev/203

## AIP-216 - States

**State:** approved

**Use when:** Exposing lifecycle or operational state on a resource.

**Apply:** Use an output-only `state` enum only when users need to reason about meaningful transitions. Provide a safe zero value, stable non-overlapping values, and canonical transition methods; do not let Update write state directly. Prefer common state names where semantics align and document state-dependent behavior and errors.

**Source:** https://google.aip.dev/216

---

**Design patterns**

## AIP-152 - Jobs

**State:** approved

**Use when:** Users define reusable work and run it repeatedly with executions or results.

**Apply:** Model persistent configuration as a resource whose type ends in `Job` and normally provide all five standard methods. Define `Run{Job}` as HTTP `POST ...:run` returning an LRO that resolves to `Run{Job}Response`. If scheduled/history use cases need durable results, add execution subresources with Get/List/Delete and have the operation refer to the execution.

**Source:** https://google.aip.dev/152

## AIP-153 - Import and export

**State:** approved

**Use when:** Moving one or many resources or their data into or out of a service.

**Apply:** Use HTTP `POST` Import/Export custom methods, returning LROs unless they can never exceed a few seconds. Separate collection transfer from data transfer on one resource. Put source/destination configuration in a `oneof source`/`oneof destination` even when only one variant exists, keep data-wide options top-level, use a shared format for inline import/export, and report partial failures as `google.rpc.Status` in metadata.

**Source:** https://google.aip.dev/153

## AIP-154 - Resource freshness validation

**State:** approved

**Use when:** Concurrent writers or delete/update races can overwrite newer state.

**Apply:** Add `string etag` to the resource without a field-behavior annotation and accept it on mutating requests where freshness matters. If supplied, succeed only on a match and otherwise return `ABORTED`; a request-level etag is annotated `REQUIRED` or `OPTIONAL`. Declarative-friendly resources require etags. Document strong versus weak validation semantics.

**Source:** https://google.aip.dev/154

## AIP-155 - Request identification

**State:** approved

**Use when:** A mutation may be retried and duplicate execution would be unsafe.

**Apply:** Add optional `string request_id` to the request, document its format, honor it for a reasonable deduplication window, and guarantee idempotency whenever it is supplied. Support UUIDs; when the field uses UUIDs, annotate `UUID4`. A duplicate returns the earlier response or, when history is unavailable, an equivalent current-state success without repeating side effects.

**Source:** https://google.aip.dev/155

## AIP-157 - Partial responses

**State:** approved

**Use when:** Full resources are expensive and clients need selectable response detail.

**Apply:** Prefer the standard `fields` system parameter for arbitrary response projection or a `view` enum for a small stable set of named views. Do not add new request `read_mask` fields; if retaining a legacy read mask, follow field-mask consistency and document omitted fields.

**Source:** https://google.aip.dev/157

## AIP-158 - Pagination

**State:** approved

**Use when:** A List or collection-reading method can return more than a bounded response.

**Apply:** Add working pagination from the first release using optional `page_size`, opaque URL-safe `page_token`, and `next_page_token`; define default/maximum sizes and invalid-value handling. Subsequent requests may change page size but otherwise keep arguments consistent. Never expose token structure or use it for authorization, return an empty next token only at end, and use `skip` only with the AIP's degraded-response behavior.

**Source:** https://google.aip.dev/158

## AIP-159 - Reading across collections

**State:** approved

**Use when:** Listing one resource type across multiple parents or looking up a globally unique name.

**Apply:** Extend the standard List parent with the `-` wildcard in the documented parent position for aggregate reads, preserving the normal response and pagination contract. Keep ordinary Get by full unique resource name; do not create a second lookup RPC when canonical names already identify instances.

**Source:** https://google.aip.dev/159

## AIP-160 - Filtering

**State:** approved

**Use when:** A collection read accepts a filter expression.

**Apply:** Use `string filter`, document supported fields, operators, functions, traversal, limitations, and precedence, and keep syntax compatible with the standard expression language. Validate field existence, types, enum/code values, and syntax; reject invalid filters with `INVALID_ARGUMENT` unless a documented relaxation applies.

**Source:** https://google.aip.dev/160

## AIP-161 - Field masks

**State:** approved

**Use when:** Selecting fields for reads or updates.

**Apply:** Use `google.protobuf.FieldMask` relative to the resource and support consistent dotted traversal. Make reading then writing the same mask a no-op apart from output-only fields; define map/wildcard behavior, never address repeated elements by index, ignore output-only input as required, and reject invalid write paths with `INVALID_ARGUMENT` unless the documented deletion case applies.

**Source:** https://google.aip.dev/161

## AIP-162 - Resource Revisions

**State:** draft (advisory)

**Use when:** Users need immutable historical snapshots, aliases, diffs, or rollback.

**Apply:** Advisory only. Consider a `{Resource}Revision` collection, normally nested at `revisions/{revision}`, containing a resource `snapshot` and `create_time`; document how revisions are created. Keep aliases and rollback explicit, avoid revision hierarchies that become recursive, and apply all relevant standard-method AIPs.

**Source:** https://google.aip.dev/162

## AIP-163 - Change validation

**State:** approved

**Use when:** Clients need to validate a mutation without committing it.

**Apply:** Add `bool validate_only` to the existing mutating request rather than a parallel validation RPC. Perform the same permissions and feasible validation as the live call, return the same response shape without side effects, and omit values that cannot exist without execution. Declarative-friendly mutations require it.

**Source:** https://google.aip.dev/163

## AIP-164 - Soft delete

**State:** approved

**Use when:** Deleted resources remain recoverable before permanent purge.

**Apply:** Make Delete mark and return the resource, add `delete_time` and `purge_time` and normally `DELETED` state, provide canonical Undelete, and optionally provide separately authorized Expunge. Exclude deleted resources from List unless `show_deleted`; let Get return them; document purge timing and exact state/error behavior.

**Source:** https://google.aip.dev/164

## AIP-165 - Criteria-based delete

**State:** approved

**Use when:** Batch Delete by explicit names cannot handle a justified large criteria-based deletion.

**Apply:** Avoid this pattern by default. If necessary, define long-running `Purge{Resources}` over a collection with required standard `filter` and `force`. Without force, perform a dry run returning count/sample; with force, delete. Document scope, estimate/sample semantics, permissions, and partial behavior.

**Source:** https://google.aip.dev/165

## AIP-210 - Unicode

**State:** approved

**Use when:** Accepting non-ASCII text in identifiers, uniqueness keys, length limits, or billing units.

**Apply:** State whether limits count bytes, code points, or grapheme clusters; choose units matching user expectations. Prefer ASCII identifiers. Normalize Unicode consistently (normally NFC), define case/normalization behavior before uniqueness checks, and avoid truncating inside an encoded or user-perceived character.

**Source:** https://google.aip.dev/210

## AIP-211 - Authorization checks

**State:** approved

**Use when:** A method reads, mutates, or reveals existence of one or more protected resources.

**Apply:** Check authorization before any request validation. On failure return `PERMISSION_DENIED` with non-leaking wording; when a missing child prevents its own check, use authorized parent-child access to decide `NOT_FOUND`. Check only permissions relevant to the operation being called rather than probing related operations to reveal existence.

**Source:** https://google.aip.dev/211

## AIP-214 - Resource expiration

**State:** approved

**Use when:** A resource may automatically expire or be retained for a configurable period.

**Apply:** Represent expiration with `google.protobuf.Timestamp expire_time`. If callers may specify relative lifetime, use a oneof `expiration` containing `expire_time` and input-only `google.protobuf.Duration ttl`; always return `expire_time` and leave `ttl` empty. Integer TTL is only for protocols whose semantics require it and needs `aip.dev/not-precedent`.

**Source:** https://google.aip.dev/214

## AIP-217 - Unreachable resources

**State:** approved

**Use when:** A List spanning locations or child collections can partially succeed because some scopes are unavailable.

**Apply:** Return reachable resources plus repeated `unreachable` service-relative resource names only where partial success is appropriate. Keep contents unordered, page-scoped, and compatible with pagination; define opt-in/adoption behavior and never hide ordinary per-resource authorization or validation failures as unreachable infrastructure.

**Source:** https://google.aip.dev/217

---

**Compatibility, versioning, polish, and protobuf**

## AIP-180 - Backwards compatibility

**State:** approved

**Use when:** Adding, removing, renaming, moving, retyping, or changing semantics of any public API element.

**Apply:** Evaluate wire, source, generated-client, HTTP, resource-name, behavioral, and data-format compatibility. Preserve field numbers/names and reserve removed ones; do not move symbols or fields into oneofs casually, narrow accepted values, change resource patterns, or reinterpret existing data. Additive syntax can still be behaviorally breaking.

**Source:** https://google.aip.dev/180

## AIP-181 - Stability levels

**State:** approved

**Use when:** Deciding which breaking or isolated changes are allowed at alpha, beta, stable, or a new major version.

**Apply:** Match change freedom to the declared stability: alpha permits iteration, beta sharply limits breaking changes, and stable preserves compatibility except the documented isolated/emergency cases. Put intentional broad breaks in a new major version and communicate migration.

**Source:** https://google.aip.dev/181

## AIP-182 - External software dependencies

**State:** reviewing (advisory)

**Use when:** Resources expose versions of databases, runtimes, operating systems, or other externally released software.

**Apply:** Advisory only. Support current LTS versions, stop offering new resources on end-of-life versions after a documented transition, publish lifecycle/migration expectations, and define continued support for existing resources rather than assuming an external version remains viable forever.

**Source:** https://google.aip.dev/182

## AIP-185 - API Versioning

**State:** approved

**Use when:** Creating packages/endpoints or promoting alpha, beta, and stable API releases.

**Apply:** Choose the documented channel-based or release-based strategy and apply it consistently to proto package, URI, and generated surface. Use stability suffixes/channels as defined, reserve new major versions for incompatible contracts, and use visibility controls rather than cloning versions for audience differences where appropriate.

**Source:** https://google.aip.dev/185

## AIP-190 - Naming conventions

**State:** approved

**Use when:** Naming interfaces/services, RPCs, request/response messages, resources, or supporting messages.

**Apply:** Use consistent `PascalCase` protobuf symbols and the standard `{Verb}{Noun}`, `{Method}Request`, and `{Method}Response` relationships. Name interfaces for the domain rather than implementation details, avoid redundant or misleading suffixes, and keep names stable across the API surface.

**Source:** https://google.aip.dev/190

## AIP-191 - File and directory structure

**State:** approved

**Use when:** Organizing protobuf packages, versions, files, imports, and language package options.

**Apply:** Use proto3, one versioned API package for a coherent surface, predictable lowercase underscore filenames and directories, and the prescribed service/resource/common file layout. Set package annotations/options for generated languages consistently and avoid package fragmentation that breaks discovery or clients.

**Source:** https://google.aip.dev/191

## AIP-192 - Documentation

**State:** approved

**Use when:** Writing comments for services, methods, messages, fields, enums, errors, deprecations, or external references.

**Apply:** Document every public element in clear complete sentences focused on user-visible semantics. State formats, defaults, limits, ordering, behavior, side effects, and errors; use supported Markdown and stable cross-references; mark deprecations canonically; keep internal implementation notes separate.

**Source:** https://google.aip.dev/192

## AIP-193 - Errors

**State:** approved

**Use when:** Selecting status codes, messages, details, permission/not-found ordering, or partial-error behavior.

**Apply:** Return canonical `google.rpc.Status` codes with stable machine-readable details, including `ErrorInfo` where required, and concise English developer messages; add `LocalizedMessage` for end-user text. Check authorization before existence, map conditions consistently, and do not smuggle partial errors into successful responses except through an approved pattern.

**Source:** https://google.aip.dev/193

## AIP-194 - Automatic retry configuration

**State:** approved

**Use when:** Publishing generated-client retry policies for an RPC.

**Apply:** Automatically retry only unary, non-transactional requests whose repetition cannot cause unintended changes; `UNAVAILABLE` is the standard retryable code. Do not auto-retry cancellation, deadline, invalid-input, or data-loss failures, and generally surface the other listed codes; retry an `ABORTED` transaction only at the whole-transaction level.

**Source:** https://google.aip.dev/194

## AIP-200 - Precedent

**State:** approved

**Use when:** Existing local APIs conflict with current guidance or an exception is proposed.

**Apply:** Prefer current guidance for new surfaces, but consider local consistency, pre-existing behavior, external specifications/systems, deadlines, and technical constraints through the AIP's exception framework. Mark every intentional violation `aip.dev/not-precedent` with rationale so it cannot become accidental precedent.

**Source:** https://google.aip.dev/200

## AIP-205 - Beta-blocking changes

**State:** approved

**Use when:** An alpha design may launch but must change before beta.

**Apply:** Add an internal `aip.dev/beta-blocker` comment at the problematic API element and state the required beta change. Treat it as tracked release-blocking design debt, not approval to carry the issue into beta.

**Source:** https://google.aip.dev/205

## AIP-213 - Common components

**State:** approved

**Use when:** Choosing or proposing a shared protobuf message, enum, annotation, or type.

**Apply:** Import only the approved global component families (including `google.api`, `google.longrunning`, `google.protobuf`, `google.rpc`, and `google.type`) when semantics match. Organization-wide packages end in `.type`, require design review, and cannot export generic components. Treat shared messages/enums as effectively unversioned: do not remove members or casually add fields/values; add new types only after broad coordination and propagation time.

**Source:** https://google.aip.dev/213

## AIP-215 - API-specific protos

**State:** approved

**Use when:** Locating protos used by one API or deciding whether to place them in a common package.

**Apply:** Keep every API-specific proto in that API's major-version package. Refer to another API's resources by resource-name strings, never by importing its resource messages. Duplicate an API-specific proto across API versions instead of inventing an unversioned shared package; use only the governed organization/global common components allowed by AIP-213.

**Source:** https://google.aip.dev/215

---

**Batch and specialized operations**

## AIP-231 - Batch methods: Get

**State:** approved

**Use when:** Retrieving multiple explicitly named resources of one type more efficiently than repeated Get calls.

**Apply:** Define atomic HTTP `GET` `BatchGet{Resources}` at `:batchGet`, with typed `parent` where applicable and bounded required repeated `names` (or nested Get requests only when per-item options differ). Do not paginate or partially succeed; return resources in request-name order and fail the whole call when any item/location fails.

**Source:** https://google.aip.dev/231

## AIP-233 - Batch methods: Create

**State:** approved

**Use when:** Creating multiple resources of the same type in one request.

**Apply:** Define `BatchCreate{Resources}` from standard Create request semantics with a documented maximum batch size. Synchronous batches are atomic; use an LRO for long-running or partial-success behavior, declare response/metadata types, preserve input ordering where required, and report partial failures with the prescribed per-item status shape.

**Source:** https://google.aip.dev/233

## AIP-234 - Batch methods: Update

**State:** approved

**Use when:** Updating multiple explicitly supplied resources of one type in one request.

**Apply:** Define `BatchUpdate{Resources}` from standard Update request semantics, including each resource's mask and freshness behavior, with a documented maximum size. Synchronous batches are atomic; LRO/partial-success variants use the prescribed result and status metadata and keep item correlation/order clear.

**Source:** https://google.aip.dev/234

## AIP-235 - Batch methods: Delete

**State:** approved

**Use when:** Deleting multiple explicitly named resources of one type in one request.

**Apply:** Define `BatchDelete{Resources}` from standard Delete semantics with bounded names or nested delete requests as permitted. Keep synchronous hard-delete batches atomic; use the specified resource response for soft delete and LRO metadata for long-running/partial success. Preserve force, etag, allow-missing, permission, and item-correlation semantics.

**Source:** https://google.aip.dev/235

## AIP-236 - Policy preview

**State:** approved

**Use when:** Users must evaluate a proposed access-policy configuration against live traffic before promotion.

**Apply:** Model `{Policy}Experiment` as a nested resource containing the full proposed policy, etag, annotations, and output-only `{Policy}PreviewMetadata`. Use long-running standard lifecycle methods plus required `StartPreview{Policy}Experiment`/`StopPreview{Policy}Experiment` and optional atomic `Commit{Policy}Experiment`; preserve live-policy names, cascade policy deletion, require etags for commit, and emit correlated logs containing live/experiment etags and the stable log prefix.

**Source:** https://google.aip.dev/236

---

# Canonical protobuf skeleton

Use this only after selecting and reading the applicable AIPs; conditional rules and service-specific constraints can change the shape.

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
  string etag = 3;
  google.protobuf.Timestamp create_time = 4
      [(google.api.field_behavior) = OUTPUT_ONLY];
  google.protobuf.Timestamp update_time = 5
      [(google.api.field_behavior) = OUTPUT_ONLY];
}

service LibraryService {
  rpc GetBook(GetBookRequest) returns (Book) {
    option (google.api.http) = {
      get: "/v1/{name=publishers/*/books/*}"
    };
    option (google.api.method_signature) = "name";
  }

  rpc ListBooks(ListBooksRequest) returns (ListBooksResponse) {
    option (google.api.http) = {
      get: "/v1/{parent=publishers/*}/books"
    };
    option (google.api.method_signature) = "parent";
  }

  rpc CreateBook(CreateBookRequest) returns (Book) {
    option (google.api.http) = {
      post: "/v1/{parent=publishers/*}/books"
      body: "book"
    };
    option (google.api.method_signature) = "parent,book,book_id";
  }

  rpc UpdateBook(UpdateBookRequest) returns (Book) {
    option (google.api.http) = {
      patch: "/v1/{book.name=publishers/*/books/*}"
      body: "book"
    };
    option (google.api.method_signature) = "book,update_mask";
  }

  rpc DeleteBook(DeleteBookRequest) returns (google.protobuf.Empty) {
    option (google.api.http) = {
      delete: "/v1/{name=publishers/*/books/*}"
    };
    option (google.api.method_signature) = "name";
  }
}
```

For `UpdateBookRequest`, AIP-134 requires an `update_mask` field but specifies it as optional: omission means all populated fields; `*` means full replacement. Do not preserve the former local rule that made the mask required.

# Review output template

```text
AIP | state | applicability | result | evidence/exception
122 | approved | resource name changed | fail | name is a bare ID
162 | draft | revision history proposed | advisory | use nested revisions collection
182 | reviewing | no external runtime exposed | not applicable | -
```

Attribution: summaries are adapted from the Google API Improvement Proposals, licensed under CC BY 4.0. Official pages are linked per entry.
