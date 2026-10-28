# Protobuf source review — 2026-10-28

Decision record and coverage ledger for maintainers, not a required reading pass on every
review. Window: **2025-04-28 through 2026-10-28**, inclusive. Read the full available
article/static content, not only search snippets; no article copies are vendored.

## Coverage and limits

- Buf: intersected publication dates from [RSS](https://buf.build/blog/rss.xml) with the
  [blog sitemap](https://buf.build/sitemap.xml) and checked the archive. **23 posts**;
  no additional in-window article URLs found in the sitemap.
- Connect: the [official site](https://connectrpc.com/) links its project content through
  Buf; its sitemap exposes no separate blog archive and `/blog/` returned 404. The
  [Buf Connect category](https://buf.build/blog/category/connect) has **five in-window
  posts**, all included below. This establishes the discoverable archive, not proof that
  no unlinked announcement exists elsewhere.
- Protobuf.com: union of [sitemap](https://protobuf.com/sitemap-0.xml) and internal page
  links yielded **58 routes**: 54 content routes (including a duplicate ecosystem listing),
  two quiz shells and two legacy redirect shells. Read static text and sample schemas;
  did not execute all interactive quizzes, editors or practice checks. A practice
  conclusion's rendered success text is not evidence of completing exercises.
- Cross-checked adopted contracts against official specs/docs and implementation sources.
  This is an inline source review, not an independent behavioral evaluation of reviewers
  or a conformance run of the advertised runtimes. Archive counts are a dated snapshot.

## Decision path

```text
Schema-to-consumer review objective
  <- Buf/Connect articles + Protobuf.com identify concrete failure modes
  -> official contracts and pinned implementation qualify those claims
  -> conditional compatibility / validation / runtime / schema-driven references
  -> real contract probes + existing routing tests verify limited observable behavior
```

Keep AIP conditional, opportunities advisory and the existing `.proto` review routing.
No new subagent, default migration, hosted service, publication or AI-data permission.
New depth is reached through the existing references, leaving skill discovery and rendered
skill pages unchanged. Reviewer defect-detection improvement remains unmeasured.

## Blog ledger

Connect-category entries are marked **Connect**; all others are Buf archive entries.

| Published | Article | Adopted lens / disposition |
| --- | --- | --- |
| 2026-10-26 | [Protobuf in Python and TypeScript is actually good now](https://buf.build/blog/protobuf-in-python-and-typescript-is-actually-good-now) | Runtime ergonomics; no forced TS/Python migration. |
| 2026-10-15 | [Asking Jev questions with Protobuf](https://buf.build/blog/asking-jev-questions-with-protobuf) | Experimental descriptor-driven adapters; permission boundary. |
| 2026-10-07 | **Connect**: [connect-go v2 is here](https://buf.build/blog/connect-go-v2) | Library/API major versus wire protocol; optional Go migration. |
| 2026-09-30 | **Connect**: [gRPC vs REST Is the Wrong Question](https://buf.build/blog/grpc-vs-rest-is-the-wrong-question) | One schema, multiple transports; GET only without side effects. |
| 2026-09-22 | **Connect**: [Protobuf, JSON Schema, and OpenAPI](https://buf.build/blog/protobuf-json-schema-and-openapi) | JSON Schema/OpenAPI projections and validation coverage. |
| 2026-09-17 | [A faster Protovalidate](https://buf.build/blog/faster-protovalidate) | Native validation fast paths; Python package/runtime changes. |
| 2026-09-11 | [Delta Encoding in Protobuf](https://buf.build/blog/delta-encoding-in-protobuf) | Optional measured deltas, signed values and recovery costs. |
| 2026-09-02 | **Connect**: [gRPC-Web Failed the Web](https://buf.build/blog/grpc-web-failed-the-web) | RPC failures versus HTTP success; browser and streaming limits. |
| 2026-08-26 | **Connect**: [connect-rust joins the Connect project](https://buf.build/blog/connect-rust-joins-the-connect-project) | Rust borrowed views, ownership and release maturity. |
| 2026-08-24 | [The modern Protobuf workflow](https://buf.build/blog/the-modern-protobuf-workflow) | Reproducible toolchain, registry boundaries, modular adoption. |
| 2026-08-14 | [Protobuf-ES just got a lot faster](https://buf.build/blog/protobuf-es-performance) | Codec performance/CSP; measure actual bundles and workloads. |
| 2026-08-10 | [Protobuf Tip #10: Choosing the right integer type](https://buf.build/blog/choosing-the-right-protobuf-integer-type) | Integer domain/distribution tradeoffs; no deployed type churn. |
| 2026-07-07 | [protobuf-py: Protobuf for Python, without compromises](https://buf.build/blog/protobuf-py) | Python runtime APIs, native acceleration/fallback evidence. |
| 2026-05-08 | [CoreWeave Acquires Bufstream](https://buf.build/blog/coreweave-acquires-bufstream) | Corporate announcement; no schema-review requirement derived. |
| 2026-01-14 | [Protobuf now has full LSP support](https://buf.build/blog/protobuf-lsp) | Editor/compiler/import parity; roadmap is not shipped capability. |
| 2025-09-12 | [Protovalidate is now v1.0](https://buf.build/blog/protovalidate-v1) | Validation semantics and migrations; annotations need enforcement. |
| 2025-07-16 | [Introducing hyperpb: 10x faster dynamic Protobuf parsing that’s even 3x faster than generated code](https://buf.build/blog/hyperpb) | Descriptor parser reuse; parse-only versus access/validation costs. |
| 2025-06-17 | [Protobuf Tip #9: Some numbers are more equal than others](https://buf.build/blog/totw-9-some-numbers-are-more-equal-than-others) | Low new-field tags; never renumber deployed contracts. |
| 2025-06-03 | [Protobuf Tip #8: Never use required](https://buf.build/blog/totw-8-never-use-required) | Legacy requiredness versus semantic validation requiredness. |
| 2025-06-02 | [Protobuf Tip #7: Scoping it out](https://buf.build/blog/totw-7-scoping-it-out) | Schema-aware byte diagnosis and heuristic limitations. |
| 2025-05-19 | [Protobuf Tip #6: The subtle dangers of enum aliases](https://buf.build/blog/totw-6-dangers-of-enum-aliases) | Alias order affects JSON/reflection; preserve deployed contracts. |
| 2025-05-13 | [Protobuf Tip #5: Avoid import public/weak](https://buf.build/blog/totw-5-avoid-import-public-weak) | Import portability; no automatic legacy import removal. |
| 2025-04-29 | [Protobuf Tip #4: Accepting mistakes we can’t fix](https://buf.build/blog/totw-4-accepting-mistakes) | Rolling compatibility outranks cosmetic schema cleanup. |

## Protobuf.com route ledger

Related lessons live in the linked skill references, not a duplicated tutorial. Indexes,
community lists and playground shells supply orientation, not runtime requirements.

| Route | Read / disposition |
| --- | --- |
| [/](https://protobuf.com/) | Static guide/index/sample content; no mandatory tool adoption. |
| [/advanced/](https://protobuf.com/advanced/) | Compatibility/presence/descriptor concepts; qualified by official contracts. |
| [/basics/](https://protobuf.com/basics/) | Schema/codegen concepts; qualified by deployed-consumer compatibility. |
| [/binary/](https://protobuf.com/binary/) | Wire framing/diagnosis; interactive controls not exhaustively executed. |
| [/community/](https://protobuf.com/community/) | Static guide/index/sample content; no mandatory tool adoption. |
| [/descriptors/](https://protobuf.com/descriptors/) | Static guide/index/sample content; no mandatory tool adoption. |
| [/ecosystem/](https://protobuf.com/ecosystem/) | Static guide/index/sample content; no mandatory tool adoption. |
| [/efficiency/](https://protobuf.com/efficiency/) | Static guide/index/sample content; no mandatory tool adoption. |
| [/extending/](https://protobuf.com/extending/) | Static guide/index/sample content; no mandatory tool adoption. |
| [/playground/](https://protobuf.com/playground/) | Static guide/index/sample content; no mandatory tool adoption. |
| [/practice/](https://protobuf.com/practice/) | Practice instructions/sample schema only; not deployed migration advice. |
| [/quiz/](https://protobuf.com/quiz/) | Static guide/index/sample content; no mandatory tool adoption. |
| [/types/](https://protobuf.com/types/) | Static guide/index/sample content; no mandatory tool adoption. |
| [/validation/](https://protobuf.com/validation/) | Static guide/index/sample content; no mandatory tool adoption. |
| [/advanced/any/](https://protobuf.com/advanced/any/) | Compatibility/presence/descriptor concepts; qualified by official contracts. |
| [/advanced/editions/](https://protobuf.com/advanced/editions/) | Compatibility/presence/descriptor concepts; qualified by official contracts. |
| [/advanced/field-presence/](https://protobuf.com/advanced/field-presence/) | Compatibility/presence/descriptor concepts; qualified by official contracts. |
| [/advanced/imports/](https://protobuf.com/advanced/imports/) | Compatibility/presence/descriptor concepts; qualified by official contracts. |
| [/advanced/limits/](https://protobuf.com/advanced/limits/) | Compatibility/presence/descriptor concepts; qualified by official contracts. |
| [/advanced/options/](https://protobuf.com/advanced/options/) | Compatibility/presence/descriptor concepts; qualified by official contracts. |
| [/advanced/required-fields/](https://protobuf.com/advanced/required-fields/) | Compatibility/presence/descriptor concepts; qualified by official contracts. |
| [/advanced/schema-evolution/](https://protobuf.com/advanced/schema-evolution/) | Compatibility/presence/descriptor concepts; qualified by official contracts. |
| [/advanced/unknown-fields/](https://protobuf.com/advanced/unknown-fields/) | Compatibility/presence/descriptor concepts; qualified by official contracts. |
| [/advanced/value/](https://protobuf.com/advanced/value/) | Compatibility/presence/descriptor concepts; qualified by official contracts. |
| [/basics/enums/](https://protobuf.com/basics/enums/) | Schema/codegen concepts; qualified by deployed-consumer compatibility. |
| [/basics/fields/](https://protobuf.com/basics/fields/) | Schema/codegen concepts; qualified by deployed-consumer compatibility. |
| [/basics/generating-code/](https://protobuf.com/basics/generating-code/) | Schema/codegen concepts; qualified by deployed-consumer compatibility. |
| [/basics/maps/](https://protobuf.com/basics/maps/) | Schema/codegen concepts; qualified by deployed-consumer compatibility. |
| [/basics/messages/](https://protobuf.com/basics/messages/) | Schema/codegen concepts; qualified by deployed-consumer compatibility. |
| [/basics/nested-messages/](https://protobuf.com/basics/nested-messages/) | Schema/codegen concepts; qualified by deployed-consumer compatibility. |
| [/basics/oneof/](https://protobuf.com/basics/oneof/) | Schema/codegen concepts; qualified by deployed-consumer compatibility. |
| [/basics/packages/](https://protobuf.com/basics/packages/) | Schema/codegen concepts; qualified by deployed-consumer compatibility. |
| [/basics/repeated-fields/](https://protobuf.com/basics/repeated-fields/) | Schema/codegen concepts; qualified by deployed-consumer compatibility. |
| [/basics/services/](https://protobuf.com/basics/services/) | Schema/codegen concepts; qualified by deployed-consumer compatibility. |
| [/binary/binary-basics/](https://protobuf.com/binary/binary-basics/) | Wire framing/diagnosis; interactive controls not exhaustively executed. |
| [/binary/explorer/](https://protobuf.com/binary/explorer/) | Wire framing/diagnosis; interactive controls not exhaustively executed. |
| [/binary/field-parsing/](https://protobuf.com/binary/field-parsing/) | Wire framing/diagnosis; interactive controls not exhaustively executed. |
| [/binary/field-tags/](https://protobuf.com/binary/field-tags/) | Wire framing/diagnosis; interactive controls not exhaustively executed. |
| [/binary/map-encoding/](https://protobuf.com/binary/map-encoding/) | Wire framing/diagnosis; interactive controls not exhaustively executed. |
| [/binary/presence/](https://protobuf.com/binary/presence/) | Wire framing/diagnosis; interactive controls not exhaustively executed. |
| [/binary/varints/](https://protobuf.com/binary/varints/) | Wire framing/diagnosis; interactive controls not exhaustively executed. |
| [/binary/wire-types/](https://protobuf.com/binary/wire-types/) | Wire framing/diagnosis; interactive controls not exhaustively executed. |
| [/binary/zigzag/](https://protobuf.com/binary/zigzag/) | Wire framing/diagnosis; interactive controls not exhaustively executed. |
| [/conclusion/](https://protobuf.com/conclusion/) | Static guide/index/sample content; no mandatory tool adoption. |
| [/practice/1/](https://protobuf.com/practice/1/) | Practice instructions/sample schema only; not deployed migration advice. |
| [/quiz/hard/](https://protobuf.com/quiz/hard/) | Client-rendered quiz shell; no static question text; not executed. |
| [/quiz/normal/](https://protobuf.com/quiz/normal/) | Client-rendered quiz shell; no static question text; not executed. |
| [/build/](https://protobuf.com/build/) | Legacy redirect shell; target basics/advanced covered. |
| [/ecosystem/page/2/](https://protobuf.com/ecosystem/page/2/) | Duplicate ecosystem list; not 87 endorsed dependencies. |
| [/practice/2/](https://protobuf.com/practice/2/) | Practice instructions/sample schema only; not deployed migration advice. |
| [/practice/3/](https://protobuf.com/practice/3/) | Practice instructions/sample schema only; not deployed migration advice. |
| [/practice/4/](https://protobuf.com/practice/4/) | Practice instructions/sample schema only; not deployed migration advice. |
| [/practice/5/](https://protobuf.com/practice/5/) | Practice instructions/sample schema only; not deployed migration advice. |
| [/practice/6/](https://protobuf.com/practice/6/) | Practice instructions/sample schema only; not deployed migration advice. |
| [/practice/7/](https://protobuf.com/practice/7/) | Practice instructions/sample schema only; not deployed migration advice. |
| [/practice/8/](https://protobuf.com/practice/8/) | Practice instructions/sample schema only; not deployed migration advice. |
| [/practice/conclusion/](https://protobuf.com/practice/conclusion/) | Practice instructions/sample schema only; not deployed migration advice. |
| [/schema-design/](https://protobuf.com/schema-design/) | Legacy redirect shell; target basics/advanced covered. |

## Qualifications that changed the guidance

- **Stable serialization:** explanatory “canonical JSON” language is not a byte-canonical
  hashing contract. [Official binary guidance](https://protobuf.dev/programming-guides/serialization-not-canonical/)
  rejects general canonical serialization; [ProtoJSON options](https://protobuf.dev/programming-guides/json/#json-options)
  vary representation. Keep signatures/cache identities domain-defined.
- **Presence and copies:** editions' singular scalar presence does not imply collection
  presence. Preserve unknowns with runtime-aware copy/clone APIs, not only the original
  object instance. [Presence rules](https://protobuf.dev/programming-guides/field_presence/)
  and [unknown-field retention](https://protobuf.dev/programming-guides/proto3/#unknowns)
  qualify the simplified explanations.
- **Wire safety:** widening a field can still truncate values in old readers; map/repeated
  conversions can lose duplicates/order. [Conditional compatibility](https://protobuf.dev/programming-guides/proto3/#updating)
  outranks blanket claims that compatible wire types are safe.
- **Examples are not syntax authority:** reserve names and numbers in separate statements;
  16–2047 is the two-byte tag range. Compile examples and use the [language grammar](https://protobuf.dev/reference/protobuf/proto3-spec/#reserved)
  and [encoding reference](https://protobuf.dev/programming-guides/encoding/) instead of
  reproducing mixed `reserved` syntax or blog range/bit-unit typos.
- **Versions drift:** the September article's `protovalidate2` launch name/backend is not
  a standing installation recipe. Inspected Python
  [package metadata](https://github.com/bufbuild/protovalidate-py/blob/422b498c2b837d51b9b45a2acc7ae6016def0964/pyproject.toml)
  and [public API](https://github.com/bufbuild/protovalidate-py/blob/422b498c2b837d51b9b45a2acc7ae6016def0964/protovalidate/__init__.py)
  identify the native-backed `protovalidate` v2 package, protobuf-py dependency and
  Google-input compatibility. Inspect the consumer's lockfile and error objects.
- **Projection is lossy:** JSON Schema variants differ in accepted names, numeric forms
  and emitted defaults; CEL does not automatically become JSON Schema. Inspected
  [Buf plugin source/README](https://github.com/bufbuild/protoschema-plugins/tree/19b879ca6b6016f020afaa38adb7f07aec7abd35)
  and [community OpenAPI plugin](https://github.com/sudorandom/protoc-gen-connect-openapi/tree/cb55c4ae4bf6ee067cc04c45a419294c8a225174).
  Confirm local-only options and the actual generated-validator/runtime boundary.
- **Transport is separate:** HTTP 200 can end in an RPC streaming error; browser support
  is narrower than the [Connect protocol](https://connectrpc.com/docs/protocol/).
  [Go migration details](https://github.com/connectrpc/connect-go/blob/104961aa92d27bcd5499e62c16fafdac26f6b749/docs/v2-migration.md)
  also expose read-limit and replacement-option changes beyond simple signature edits.
- **Marketing/benchmarks:** conformance, ownership announcements, popularity counts and
  fixture speedups do not prove application validation, deployment support or a worthwhile
  migration. Retain optional experiments, not universal rules or performance promises.

Current behavior belongs to the target repository's installed versions and explicit
contracts. Revisit this record when a rule's source/API changes, not on every review.

## Contract probes

Inline disposable consumer, 2026-10-28: Buf 1.70.0, protoc 36.2, Protobuf-ES 2.16.0,
Connect/Connect-Web 2.3.0, Bun 1.4.4 on macOS arm64. Observed:

- New `int64` 4294967297 decodes as 1 through the old `int32` reader; in-range 41 survives.
- Explicit scalar zero survives its own codec, but an implicit-presence intermediary
  omits it. Reordering enum aliases changes the JSON name in the pinned runtime.
- Message-aware clone retains an unknown future field in a new object. Differently
  ordered wire fields decode to equal known values. Tags 16/2047/2048 use 2/2/3 bytes.
- Buf rejects mixed name/number `reserved`; separate statements compile.
- A loopback HTTP server sends one item then a terminal Connect `permission_denied`
  error with HTTP 200. An HTTP-only success assertion fails; the real generated-descriptor
  Connect client yields the item and throws `PermissionDenied` on iteration.

These reproduce the rule distinctions, not a before/after reviewer-accuracy improvement.
No production deployment, browser/CORS/proxy, Go v2, Python/Rust runtime, custom plugin
or projected-schema validator was executed in this reading pass.
