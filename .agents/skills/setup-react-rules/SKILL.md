---
name: setup-react-rules
description: Configure Claude Code hooks enforcing React best practices — ban useEffect, ban raw HTML elements (use redpanda-ui), ban Chakra UI imports, ban TypeScript escape hatches (as any, ts-ignore, ts-expect-error). Use when enforcing React patterns, banning useEffect, or setting up component library enforcement.
---

# Setup React Rules

## What This Sets Up

PostToolUse hooks on Edit/Write (all exclude `redpanda-ui/` directory):

- **Ban useEffect** (and useLayoutEffect, useInsertionEffect) — escape hatch: `// allow-useEffect: [reason]`
- **Ban raw HTML elements** — suggest redpanda-ui components
- **Ban Chakra UI / legacy imports** — block `@chakra-ui/react` and `@redpanda-data/ui`
- **Ban TypeScript escape hatches** — block `as any`, `@ts-ignore`, `@ts-expect-error`

## Steps

### 1. Create hook scripts

Write scripts from [REFERENCE.md](REFERENCE.md) into `.claude/hooks/`:

- `react-rules-check.sh` — single script handling all rules

Make executable.

### 2. Configure hook in `.claude/settings.json`

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/react-rules-check.sh" }
        ]
      }
    ]
  }
}
```

### 3. Verify

- [ ] Hook blocks new `useEffect` in diff
- [ ] Hook allows `useEffect` with `// allow-useEffect:` comment
- [ ] Hook blocks `<button>`, `<input>`, etc. in TSX files
- [ ] Hook blocks `@chakra-ui/react` imports
- [ ] Hook blocks `as any`, `@ts-ignore`, `@ts-expect-error`
- [ ] Hook skips `redpanda-ui/` directory

### 4. Commit

Stage and commit: `Add React rules enforcement hooks`
