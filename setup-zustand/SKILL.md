---
name: setup-zustand
description: Enforce zustand best practices via PostToolUse hooks — double-parens create, useShallow selectors, persist middleware. Use when setting up zustand enforcement or preventing re-render issues.
---

# Setup Zustand

## What This Sets Up

PostToolUse hook on Edit/Write catching zustand anti-patterns:

- **Ban single-parens `create<T>()`** — must be `create<T>()()` for middleware type inference
- **Ban inline object selectors** — `(s) => ({ a: s.a })` causes infinite re-renders, suggest `useShallow`
- **Ban localStorage/sessionStorage in store files** — use zustand `persist` middleware instead

## Steps

### 1. Create hook script

Copy [`scripts/zustand-check.sh`](scripts/zustand-check.sh) and [`scripts/_hook-lib.sh`](scripts/_hook-lib.sh) into `.claude/hooks/`. Make executable.

### 2. Configure hook in `.claude/settings.json`

Add to hooks config: **PostToolUse** (matcher: `Edit|Write`): `.claude/hooks/zustand-check.sh`

### 3. Verify

- [ ] Hook blocks `create<State>()` single-parens in files importing zustand
- [ ] Hook blocks `(s) => ({ ... })` inline object selectors
- [ ] Hook blocks `localStorage` in zustand store files
- [ ] Hook skips non-TS/TSX files
- [ ] Hook skips files that don't import zustand (for checks 1 and 3)

### 4. Commit

Stage and commit: `Add zustand best practices enforcement hook`
