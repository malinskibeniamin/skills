---
name: setup-logging
description: Enforce structured logging patterns via PostToolUse hook — ban console.error/warn/debug in production code, require structured logger with object arguments. Use when setting up logging, enforcing structured logs, or banning console.error/warn.
---

# Setup Logging

## What This Sets Up

- **PostToolUse hook** (Edit|Write) that catches logging anti-patterns in TS/TSX/JS/JSX files
- **Bans `console.error()`**, `console.warn()`, `console.debug()` — enforces structured logger instead
- **Flags string concatenation** in log calls — enforces structured objects
- Skips test files (`*.test.*`, `*.spec.*`, `__tests__/`)
- Complements Biome's `noConsole` rule (which bans `console.log`) by extending to error/warn/debug and enforcing structured format
- **Library-agnostic** — works with any structured logger (Pino, Winston, Bunyan, etc.)

## Steps

### 1. Install a structured logger

Pick one — the hook doesn't care which, only that you use `logger.X({...})` instead of `console.X(...)`:

| Logger | Install | Notes |
|--------|---------|-------|
| **Pino** | `bun add pino` | Fastest, JSON-native, recommended |
| **Winston** | `bun add winston` | Most popular, flexible transports |
| **Bunyan** | `bun add bunyan` | JSON-native, mature |

### 2. Create logger

Create `src/lib/logger.ts` — see [REFERENCE.md](REFERENCE.md) for a Pino example. Adapt for your chosen library. Key requirements:
- Structured JSON output (not string messages)
- Pretty-print in development, JSON in production
- Context-aware child loggers (e.g. `logger.child({ module: "auth" })`)

### 3. Create hook script

Copy [`scripts/logging-check.sh`](scripts/logging-check.sh) and [`scripts/_hook-lib.sh`](scripts/_hook-lib.sh) into `.claude/hooks/`. Make executable.

### 4. Configure hook

Add to `.claude/settings.json` hooks config: **PostToolUse** (matcher: `Edit|Write`): `.claude/hooks/logging-check.sh`

### 5. Codex compatibility (optional)

If the project also uses OpenAI Codex, run `codex-compat` to generate `.codex/hooks.json` from the Claude Code config.

### 6. Verify & Commit

- [ ] `logging-check.sh` is executable
- [ ] Hook blocks `console.error(` in non-test `.ts` files
- [ ] Hook blocks `console.warn(` in non-test `.tsx` files
- [ ] Hook blocks `console.debug(` in non-test `.js` files
- [ ] Hook blocks `logger.error("msg: " + err)` (string concatenation)
- [ ] Hook allows `console.error(` in `*.test.ts` files
- [ ] Hook allows `logger.error({ message: "failed", error: err })`
- [ ] Hook configured in `.claude/settings.json`

Stage all files and commit: `Add structured logging enforcement hook`
