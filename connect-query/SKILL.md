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

Protobuf gotchas (Timestamp, Duration, Any, cache patterns): [REFERENCE.md](REFERENCE.md). Setup: [SETUP.md](SETUP.md).