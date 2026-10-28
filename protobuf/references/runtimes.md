# Runtime and RPC consumers

Read installed versions, generated imports and current primary docs before prescribing
APIs. The [Buf article](https://buf.build/blog/protobuf-in-python-and-typescript-is-actually-good-now)
motivates modern TS/Python ergonomics; it is not a mandate to replace a working runtime.
Protobuf conformance does not establish application validation, transport support or
compatibility between arbitrary generator/runtime versions.

For transport, interceptor, streaming, caching or RPC error changes, also read
[RPC boundaries](rpc.md); message-runtime conformance does not cover those contracts.

## TypeScript

For Protobuf-ES v2, use schema-based APIs such as `create(Schema, init)`, binary/JSON
helpers and generated discriminated oneofs. Use the runtime's well-known-type helpers;
register concrete types when decoding/encoding `Any` JSON. Check integer precision,
presence, unknown data and conversions at adapters rather than casting DTOs into messages.
Use `clone(Schema, message)` when retaining runtime message state; JSON copies lose unknown
fields and generic object copies can lose presence/default semantics.

Inspect generator options, direct imports and actual bundler output before claiming
tree-shaking. Schema descriptors are useful runtime data; avoid removing ones that
validation, reflection or plugins require.

For codec/bundle optimizations, verify the installed release under the deployment's CSP
and bundler. A faster codec is not evidence that `unsafe-eval` is needed or that every
application gets the published benchmark's speedup; use [performance evidence](wire-and-performance.md).

Sources: [working with messages](https://protobufes.com/guides/messages/),
[runtime reference](https://protobufes.com/reference/),
[custom options](https://protobufes.com/reference/reflection/custom-options/).

Source: [Protobuf-ES codec design](https://buf.build/blog/protobuf-es-performance).

React query integration belongs to the existing Connect Query skill, not a second rubric.

## Python

Identify the message runtime and generator separately from the RPC layer. `protobuf-py`
and Google's `google.protobuf` have different generated APIs; do not mix their objects
or apply one runtime's map/presence semantics to the other. Use the project's type checker
and actual generated API to verify integration.

On validator upgrades, inspect the error-object runtime too. Native-backed Protovalidate
Python v2 uses `protobuf-py` violation messages even when accepting Google inputs; old
`HasField`/JSON conversions or assumptions that it installs Google's `protobuf` transitively
can break. Check explicit dependencies, supported wheels/build requirements and release
notes. The September article called this `protovalidate2`; resolve the installed
package/version rather than copying its launch-time install name.

Sources: [native validator changes](https://buf.build/blog/faster-protovalidate),
[current Python package and dependencies](https://github.com/bufbuild/protovalidate-py/blob/main/pyproject.toml).

Connect-Python can target Google's message runtime with the `protobuf=google` plugin
option; adopting its RPC layer need not also replace messages. Check async/sync client
choice, WSGI/ASGI deployment, protocol and streaming limitations for the pinned version.

Source: [Connect-Python setup and Google compatibility](https://connectrpc.com/docs/python/getting-started/),
[streaming](https://connectrpc.com/docs/python/streaming/).

## Go and Rust, when affected

Keep Go's supported message runtime. Distinguish Connect-Go's library major from the
Connect wire protocol: v1/v2 peers interoperate; migrating is optional. For a v2 change,
check generated `/v2` imports, plain-message signatures, context metadata, pluggable HTTP
transport and unified interceptors together. Verify intentional error messages explicitly:
bare Go errors are no longer exposed on the wire. Migration-tool output still needs
manual interceptor/instrumentation review and a real transport test.
Review read limits explicitly: the migration tool can preserve v1's unbounded behavior
instead of adopting v2's bounded default. Check option semantics too: codec/compressor
configuration can replace defaults rather than append to them.

Sources: [Go v2 migration](https://connectrpc.com/docs/go/migrating-to-v2/),
[pinned migration details](https://github.com/connectrpc/connect-go/blob/104961aa92d27bcd5499e62c16fafdac26f6b749/docs/v2-migration.md),
[API versus protocol](https://buf.build/blog/connect-go-v2).

For Rust zero-copy/borrowed views, prove backing-buffer lifetime across async boundaries,
ownership conversions and validation; check crate features, MSRV and actual API stability.
Use the repository's runtime, not a mandatory Buffa/Connect replacement. For all other
languages, load their generator/runtime docs only when affected.

Source: [Connect-Rust and Buffa](https://buf.build/blog/connect-rust-joins-the-connect-project).
