# Runtime and RPC consumers

Read installed versions, generated imports and current primary docs before prescribing
APIs. The [Buf article](https://buf.build/blog/protobuf-in-python-and-typescript-is-actually-good-now)
motivates modern TS/Python ergonomics; it is not a mandate to replace a working runtime.
Protobuf conformance does not establish application validation, transport support or
compatibility between arbitrary generator/runtime versions.

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

Sources: [working with messages](https://protobufes.com/guides/messages/),
[runtime reference](https://protobufes.com/reference/),
[custom options](https://protobufes.com/reference/reflection/custom-options/).

For Connect, distinguish server/runtime support from browser capabilities. Web transports
speak Connect or gRPC-Web via fetch, not native gRPC directly to any server. Verify the
chosen protocol, CORS/auth, cancellation/deadlines and supported streaming shape through
the real deployment. A successful unary request does not prove duplex streaming works.
React query integration belongs to the existing Connect Query skill, not a second rubric.

Sources: [browser protocols](https://connectrpc.com/docs/web/choosing-a-protocol/),
[streaming support](https://connectrpc.com/docs/web/using-clients/).

## Python

Identify the message runtime and generator separately from the RPC layer. `protobuf-py`
and Google's `google.protobuf` have different generated APIs; do not mix their objects
or apply one runtime's map/presence semantics to the other. Use the project's type checker
and actual generated API to verify integration.

Connect-Python can target Google's message runtime with the `protobuf=google` plugin
option; adopting its RPC layer need not also replace messages. Check async/sync client
choice, WSGI/ASGI deployment, protocol and streaming limitations for the pinned version.

Source: [Connect-Python setup and Google compatibility](https://connectrpc.com/docs/python/getting-started/),
[streaming](https://connectrpc.com/docs/python/streaming/).

For Go or other languages, preserve their supported runtime and repository conventions;
inspect that language's generator/runtime documentation only when affected. A TS/Python
ergonomics article supplies no evidence that another runtime needs replacement.
