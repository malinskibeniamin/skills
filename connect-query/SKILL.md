---
name: connect-query
description: ConnectRPC + connect-query + Protobuf v2 patterns -- schema-first create(), typed transports, invalidation discipline. Use when writing API calls, mutations, query hooks, or proto-generated client code.
paths:
  - "**/*_connectquery*"
  - "**/*_pb*"
  - "**/gen/**"
---

# Connect Query Enforcement
Run `/read-the-damn-docs` before pinning current ConnectRPC, Connect Query, or Protobuf API guidance.
## What This Catches

- **Ban raw `useQuery`/`useMutation`** from `@tanstack/react-query` when file use ConnectRPC -- use Connect Query (exception: `useTransport`/`callUnaryMethod` pattern)
- **Ban `invalidateQueries()`** no args -- must specify query key
- **Warn on `axios`/`fetch()`** -- prefer ConnectRPC transport
- **Protobuf v2**: Ban `new Message()` -> use `create(Schema)`. Ban `PlainMessage`/`PartialMessage` -> use `MessageShape`/`MessageInitShape`. Ban manual `$typeName` literals.

Escape hatch: `// allow: direct-query [reason]`

## Query-layer discipline (mined from 4 years of review history)

- **Cache tiers, not magic numbers**: 2-3 semantic constants (`SHORT/MEDIUM/LONG_LIVED_CACHE_STALE_TIME`) in one file; `Infinity` only for data that changes exclusively via your own invalidation. Retry policy lives once on the QueryClient (retry 5xx/network, never 4xx).
- **`transform`/`select` in the hook, never parsing in components** -- the component receives display-ready data; page sizes are enforced by the hook, not parsed at call sites.
- **Invalidate, don't refetch; always await it** -- fire-and-forget invalidation races navigation and the next screen renders stale cache. Keys: broad by service/method (cardinality-aware for infinite queries), never over-specific.
- **Loader <-> hook query-key parity** -- a route loader that prefetches with a slightly different key silently double-fetches. Assert key equality in a test.
- **One hook per RPC; split multi-RPC pages** into one data hook per service call. Mutation hooks end in `Mutation` (`WithToast` when they own toasts).
- **Validation direction**: client-side proto validation (protovalidate) applies to what you SEND. Responses are already server-validated -- don't re-validate reads.
- **Proto optionals are `undefined`, never `null`**; unbounded lists get infinite query + "load more"; polling uses built-in `refetchInterval`, not hand-rolled timers.

Protobuf gotchas (Timestamp, Duration, Any, cache patterns): [REFERENCE.md](REFERENCE.md). Setup: [SETUP.md](SETUP.md).