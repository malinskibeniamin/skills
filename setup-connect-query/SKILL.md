---
name: setup-connect-query
description: Enforce ConnectRPC + Connect Query + Protobuf v2 patterns via PostToolUse hooks. Bans raw useQuery, empty invalidateQueries, $typeName literals. Use when setting up ConnectRPC, protobuf type safety, or data fetching enforcement.
paths:
  - "**/*_connectquery*"
  - "**/*_pb*"
  - "**/gen/**"
---

# Setup Connect Query

## What This Sets Up

PostToolUse hook on Edit/Write catching data-fetching anti-patterns across the ConnectRPC + TanStack Query + Protobuf stack:

- **Ban raw `useQuery`/`useMutation`** from `@tanstack/react-query` when file uses ConnectRPC — must use Connect Query (exception: files importing from `@connectrpc/connect` directly for `useTransport`/`callUnaryMethod` pattern)
- **Ban `invalidateQueries()`** with no args — must specify query key
- **Warn on `axios` imports** — prefer ConnectRPC transport
- **Warn on `fetch()` calls** — prefer ConnectRPC transport
- **Protobuf v2 only**: Ban `new Message()` construction — use `create(Schema)`
- **Protobuf v2 only**: Ban `PlainMessage`/`PartialMessage` — use `MessageShape`/`MessageInitShape`
- **Protobuf v2 only**: Ban manual object literals with `$typeName` — use `create(Schema)` for type-safe construction

Escape hatch: `// allow-direct-query: [reason]` for legitimate REST endpoints.

## Steps

### 1. Detect protobuf version

Check `package.json` for `@bufbuild/protobuf` version:
- `^1.x` → install **v1 variant** (skips protobuf v2 checks)
- `^2.x` → install **v2 variant** (includes protobuf v2 checks)

### 2. Create hook script

Copy [`scripts/connect-query-check.sh`](scripts/connect-query-check.sh) and [`scripts/_hook-lib.sh`](scripts/_hook-lib.sh) into `.claude/hooks/`. Make executable.

### 3. Configure hook in `.claude/settings.json`

Add to hooks config: **PostToolUse** (matcher: `Edit|Write`): `.claude/hooks/connect-query-check.sh`

### 4. Verify

- [ ] Hook blocks `useQuery` from `@tanstack/react-query` in files with ConnectRPC imports
- [ ] Hook allows `useQuery` from `@tanstack/react-query` in files without ConnectRPC imports
- [ ] Hook blocks `invalidateQueries()` with no args
- [ ] Hook warns on `axios` imports
- [ ] Hook respects `// allow-direct-query:` escape hatch
- [ ] (v2 only) Hook blocks `new MessageRequest()` protobuf construction
- [ ] (v2 only) Hook blocks `PlainMessage<T>` usage
- [ ] (v2 only) Hook blocks manual object literals with `$typeName`
- [ ] Hook allows raw `useQuery`/`useMutation` when file imports from `@connectrpc/connect`

### 5. Commit

Stage and commit: `Add Connect Query and protobuf enforcement hook`
