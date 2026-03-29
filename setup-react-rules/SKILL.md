---
name: setup-react-rules
description: Configure Claude Code hooks enforcing React best practices — ban useEffect, ban raw HTML elements (use shadcn/ui components), ban Chakra UI imports, ban TypeScript escape hatches (as any, ts-ignore, ts-expect-error), ban dangerouslySetInnerHTML, ban eval/new Function, ban .innerHTML assignment. Use when enforcing React patterns, banning useEffect, or setting up component library enforcement. Works with Claude Code and Codex.
---

# Setup React Rules

## What This Sets Up

PostToolUse hooks on Edit/Write (all exclude `components/ui/` and `redpanda-ui/` directories):

- **Ban useEffect** (and useLayoutEffect, useInsertionEffect) — escape hatch: `// allow-useEffect: [reason]`
- **Ban raw HTML elements** — suggest shadcn/ui components from `@/components/ui/`
- **Ban Chakra UI imports** — block `@chakra-ui/react`
- **Ban TypeScript escape hatches** — block `as any`, `@ts-ignore`, `@ts-expect-error`
- **Ban dangerouslySetInnerHTML** — XSS risk, escape hatch: `// allow-dangerouslySetInnerHTML: [reason]`
- **Ban eval() and new Function()** — code injection risk (OWASP A03)
- **Ban .innerHTML assignment** — XSS risk, use textContent or React rendering

## Steps

### 1. Create hook scripts

Write scripts from [REFERENCE.md](REFERENCE.md) into `.claude/hooks/`:

- `react-rules-check.sh` — single script handling all rules

Make executable.

### 2. Configure hook in `.claude/settings.json`

Add to hooks config: **PostToolUse** (matcher: `Edit|Write`): `.claude/hooks/react-rules-check.sh`

### 3. Verify

- [ ] Hook blocks new `useEffect` in diff
- [ ] Hook allows `useEffect` with `// allow-useEffect:` comment
- [ ] Hook blocks `<button>`, `<input>`, etc. in TSX files
- [ ] Hook blocks `@chakra-ui/react` imports
- [ ] Hook blocks `as any`, `@ts-ignore`, `@ts-expect-error`
- [ ] Hook skips `components/ui/` and `redpanda-ui/` directories

### 4. Codex compatibility (optional)

If the project also uses OpenAI Codex, run `codex-compat` to generate `.codex/hooks.json` from the Claude Code config.

### 5. Commit

Stage and commit: `Add React rules enforcement hooks`
