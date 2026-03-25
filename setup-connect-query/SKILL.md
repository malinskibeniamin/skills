---
name: setup-connect-query
description: Configure Claude Code PostToolUse hook enforcing ConnectRPC + Connect Query + Protobuf best practices — ban raw useQuery/useMutation when Connect Query is available, ban empty invalidateQueries(), warn on axios/fetch, enforce protobuf v2 patterns. Use when setting up data fetching enforcement, ConnectRPC patterns, or protobuf type safety.
---

# Setup Connect Query

## What This Sets Up

PostToolUse hook on Edit/Write catching data-fetching anti-patterns across the ConnectRPC + TanStack Query + Protobuf stack:

- **Ban raw `useQuery`/`useMutation`** from `@tanstack/react-query` when file uses ConnectRPC — must use Connect Query
- **Ban `invalidateQueries()`** with no args — must specify query key
- **Warn on `axios` imports** — prefer ConnectRPC transport
- **Warn on `fetch()` calls** — prefer ConnectRPC transport
- **Protobuf v2 only**: Ban `new Message()` construction — use `create(Schema)`
- **Protobuf v2 only**: Ban `PlainMessage`/`PartialMessage` — use `MessageShape`/`MessageInitShape`

Escape hatch: `// allow-direct-query: [reason]` for legitimate REST endpoints.

## Steps

### 1. Detect protobuf version

Check `package.json` for `@bufbuild/protobuf` version:
- `^1.x` → install **v1 variant** (skips protobuf v2 checks)
- `^2.x` → install **v2 variant** (includes protobuf v2 checks)

### 2. Create hook script

Write the appropriate `connect-query-check.sh` variant from [REFERENCE.md](REFERENCE.md) into `.claude/hooks/`. Make executable.

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

### 5. Commit

Stage and commit: `Add Connect Query and protobuf enforcement hook`
