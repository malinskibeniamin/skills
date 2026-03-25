---
name: setup-zustand
description: Configure Claude Code PostToolUse hook enforcing zustand best practices — ban single-parens create(), ban inline object selectors (suggest useShallow), ban direct localStorage in stores (suggest persist middleware). Use when setting up zustand enforcement, preventing infinite re-renders, or enforcing zustand type safety.
---

# Setup Zustand

## What This Sets Up

PostToolUse hook on Edit/Write catching zustand anti-patterns:

- **Ban single-parens `create<T>()`** — must be `create<T>()()` for middleware type inference
- **Ban inline object selectors** — `(s) => ({ a: s.a })` causes infinite re-renders, suggest `useShallow`
- **Ban localStorage/sessionStorage in store files** — use zustand `persist` middleware instead

## Steps

### 1. Create hook script

Write `zustand-check.sh` from [REFERENCE.md](REFERENCE.md) into `.claude/hooks/`. Make executable.

### 2. Configure hook in `.claude/settings.json`

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/zustand-check.sh" }
        ]
      }
    ]
  }
}
```

### 3. Verify

- [ ] Hook blocks `create<State>()` single-parens in files importing zustand
- [ ] Hook blocks `(s) => ({ ... })` inline object selectors
- [ ] Hook blocks `localStorage` in zustand store files
- [ ] Hook skips non-TS/TSX files
- [ ] Hook skips files that don't import zustand (for checks 1 and 3)

### 4. Commit

Stage and commit: `Add zustand best practices enforcement hook`
