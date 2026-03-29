---
name: setup-react-rules
description: Configure Claude Code hooks enforcing React best practices — ban raw HTML elements (use shadcn/ui components), ban TypeScript escape hatches (as any, ts-ignore, ts-expect-error), ban dangerouslySetInnerHTML, ban eval/new Function, ban .innerHTML assignment. Optional useEffect ban (opt-in). Auto-detects component library directory. Use when enforcing React patterns or setting up component library enforcement. Works with Claude Code and Codex.
---

# Setup React Rules

## What This Sets Up

PostToolUse hooks on Edit/Write (auto-detects and excludes component library directories):

- **Ban raw HTML elements** — suggest shadcn/ui components from `@/components/ui/`
- **Ban TypeScript escape hatches** — block `as any`, `@ts-ignore`, `@ts-expect-error`
- **Ban dangerouslySetInnerHTML** — XSS risk, escape hatch: `// allow-dangerouslySetInnerHTML: [reason]`
- **Ban eval() and new Function()** — code injection risk (OWASP A03)
- **Ban .innerHTML assignment** — XSS risk, use textContent or React rendering
- **Ban inline `style={{}}`** — use Tailwind utility classes
- **Ban raw hex/rgb in className** — use design tokens (`text-destructive`, not `text-[#ff0000]`)
- **Ban `!important`** — breaks Tailwind cascade, fix specificity instead

### Opt-in rules

- **Ban useEffect** (and useLayoutEffect, useInsertionEffect) — enable with `REACT_RULES_BAN_USEEFFECT=1`. Best for greenfield projects using TanStack Query + zustand. Escape hatch: `// allow-useEffect: [reason]`
- **Ban type assertions** (`as X`) — enable with `REACT_RULES_BAN_TYPE_ASSERTIONS=1`. Allows `as const` and `as const satisfies`. Forces type guards, generics, or schema validation instead. Escape hatch: `// allow-type-assertion: [reason]`

## Steps

### 1. Create hook scripts

Copy [`scripts/react-rules-check.sh`](scripts/react-rules-check.sh) and [`scripts/_hook-lib.sh`](scripts/_hook-lib.sh) into `.claude/hooks/`. Make executable.

### 2. Configure hook in `.claude/settings.json`

Add to hooks config: **PostToolUse** (matcher: `Edit|Write`): `.claude/hooks/react-rules-check.sh`

### 3. Verify

- [ ] Hook blocks `<button>`, `<input>`, etc. in TSX files
- [ ] Hook blocks `as any`, `@ts-ignore`, `@ts-expect-error`
- [ ] Hook auto-detects and skips component library directories
- [ ] (If `REACT_RULES_BAN_USEEFFECT=1`) Hook blocks new `useEffect` in diff
- [ ] (If `REACT_RULES_BAN_USEEFFECT=1`) Hook allows `useEffect` with `// allow-useEffect:` comment

### 4. Codex compatibility (optional)

If the project also uses OpenAI Codex, run `codex-compat` to generate `.codex/hooks.json` from the Claude Code config.

### 5. Commit

Stage and commit: `Add React rules enforcement hooks`
