# RPC boundaries

Read for changed transports, streaming, middleware, errors or caching. Identify library
version, wire protocol and caller platform independently. A service descriptor lists RPC
shapes; it does not guarantee every generated client/deployment supports them.

## Observe the whole call

- For Connect unary calls, inspect HTTP status and the structured RPC error. For Connect
  streaming, HTTP 200 can carry a terminal `EndStreamResponse` error. For gRPC/gRPC-Web,
  inspect their RPC status/trailers, not HTTP success alone. Include a failure after the
  first streamed message in client, metrics and tracing checks.
- Retain typed error details and the required type registry without leaking internal
  messages or secrets. Check an unexpected server exception as well as a caller violation.
- Verify cancellation/deadlines reach handlers and upstream work. On early iteration exit,
  release streams/resources using the runtime's contract; exercise backpressure, disconnect
  and bounded buffering when changed. Retry only with the method's actual safety contract;
  a timeout does not prove that a mutation never ran.

Sources: [Connect response/error framing](https://connectrpc.com/docs/protocol/),
[gRPC status](https://grpc.io/docs/guides/status-codes/),
[cancellation](https://grpc.io/docs/guides/cancellation/),
[retry semantics](https://grpc.io/docs/guides/retry/).

## Browser, middleware and deployment

Web Connect transports use fetch with Connect or gRPC-Web, not native gRPC. Current
browser clients support server streaming, not general client/duplex streaming. Test the
selected shape through the real browser, CORS, credentials and proxy; an in-process test
does not exercise HTTP versions, TLS, compression, trailers or buffering behavior.

Sources: [browser limits](https://connectrpc.com/docs/web/getting-started/),
[in-process versus HTTP](https://connectrpc.com/docs/go/in-process-transport/),
[CORS requirements](https://connectrpc.com/docs/cors/).

Trace auth, validation, logging and recovery in their actual order for unary AND streaming
paths. Connect-Go v2 server interceptors can reject before message decoding; v1 unary
interceptors ran after decoding. Enforce compressed/decompressed message limits at the
transport/decoder seam; post-decode validation cannot undo parser allocations. A stream
needs appropriate total-work limits as well as per-message limits.

Source: [Go interceptor lifecycle and authentication](https://connectrpc.com/docs/go/interceptors/).

## GET and caching are contract changes

Enable Connect GET only for unary methods truthfully marked `NO_SIDE_EFFECTS`; mere
idempotence does not suffice. Verify client/server opt-in and proxy URL-size behavior.
Request data enters the URL: consider logs, history and other URL exposure, not just
body redaction. Review cache-control, authorization and cache-key isolation before shared
caching; an annotation neither supplies safe cache policy nor makes secrets public-safe.

Source: [GET opt-in](https://connectrpc.com/docs/web/get-requests-and-caching/).
