---
name: setup-react-rules
description: Enforce React/TS/security rules via PostToolUse hooks — bans raw HTML, TS escape hatches, XSS vectors, barrel imports, missing passive listeners. Use when enforcing React patterns or component library standards.
---

# Setup React Rules

## What This Sets Up

PostToolUse hooks on Edit/Write (auto-detects and excludes component library directories):

- **Ban raw HTML elements** — suggest shadcn/ui components from `@/components/ui/`
- **Ban TypeScript escape hatches** — block `as any`, `as Record<string, any>`, `as Record<string, unknown>`, `@ts-ignore`, `@ts-expect-error`
- **Ban barrel imports** — flag re-exports from index files, suggest direct path imports
- **Ban missing passive event listeners** — flag `addEventListener('scroll'|'touchstart'|'wheel')` without `{ passive: true }`
- **Ban static imports of heavy deps** — flag top-level imports of `chart.js`, `d3`, `three.js`, `pdf-lib` (suggest dynamic `import()` or `React.lazy()`)
- **Ban dangerouslySetInnerHTML** — XSS risk, escape hatch: `// allow: dangerouslySetInnerHTML [reason]`
- **Ban eval() and new Function()** — code injection risk (OWASP A03)
- **Ban .innerHTML assignment** — XSS risk, use textContent or React rendering
- **Ban inline `style={{}}`** — use Tailwind utility classes
- **Ban raw hex/rgb in className and CSS** — use design tokens (`text-destructive`, not `text-[#ff0000]`)
- **Ban `!important`** in TSX/JSX/CSS/SCSS/SASS/LESS — breaks Tailwind cascade
- **Ban visual style overrides** on registry components (use variant prop, layout classes are fine)
- **Ban `onClick + navigate()`** — use `<Button asChild><Link>` instead
- **Require handler on buttons** — onClick, asChild, type="submit", or disabled
- **Ban icon inside AlertTitle** — use the icon prop on `<Alert>`
- **Enforce `create()` wrapper** for protobuf message spreads (v2 only)
- **Require `aria-label`** on icon-only buttons
- **Ban `outline: none`** — breaks keyboard navigation, use focus-visible
- **React Compiler** — ban manual `useMemo`/`useCallback`/`React.memo` (respects annotation mode)
- **Ban class components** — use functional components (required for React Compiler)

### Opt-in rules

- **Ban useEffect** (and useLayoutEffect, useInsertionEffect) — enable with `REACT_RULES_BAN_USEEFFECT=1`. Best for greenfield projects using TanStack Query + zustand. Escape hatch: `// allow: useEffect [reason]`
- **Ban type assertions** (`as X`) — enable with `REACT_RULES_BAN_TYPE_ASSERTIONS=1`. Allows `as const` and `as const satisfies`. Forces type guards, generics, or schema validation instead. Escape hatch: `// allow: type-assertion [reason]`

### Soft guidance (enforced by Claude, not hooks)

- **Named useEffect functions** — when writing `useEffect`, always use a named function expression that describes the effect's purpose. Name cleanup functions symmetrically. If you can't name the effect without "and" or "also", split it. If the name starts with "sync" or "update" followed by state, it's probably derived state — compute inline instead.
- **`useSyncExternalStore` for subscriptions** — when subscribing to browser APIs (`navigator.onLine`, `matchMedia`, scroll position) or external stores without React bindings, prefer `useSyncExternalStore` over manual `useEffect` + `addEventListener`. Concurrent-mode safe and eliminates boilerplate.
- **Form-level `validate`** — for cross-field validation with react-hook-form (v7.72+), use `useForm({ validate })` instead of custom logic in `onSubmit`. Errors integrate with `formState.errors` automatically.

## Steps

### 1. Create hook scripts

Copy [`scripts/react-rules-check.sh`](scripts/react-rules-check.sh), [`scripts/tailwind-check.sh`](scripts/tailwind-check.sh), and [`scripts/_hook-lib.sh`](scripts/_hook-lib.sh) into `.claude/hooks/`. Make executable.

### 2. Configure hook in `.claude/settings.json`

Add to hooks config: **PostToolUse** (matcher: `Edit|Write`): `.claude/hooks/react-rules-check.sh`

### 3. Verify

- [ ] Hook blocks `<button>`, `<input>`, etc. in TSX files
- [ ] Hook blocks `as any`, `@ts-ignore`, `@ts-expect-error`
- [ ] Hook auto-detects and skips component library directories
- [ ] (If `REACT_RULES_BAN_USEEFFECT=1`) Hook blocks new `useEffect` in diff
- [ ] (If `REACT_RULES_BAN_USEEFFECT=1`) Hook allows `useEffect` with `// allow: useEffect` comment

### 4. Codex compatibility (optional)

If the project also uses OpenAI Codex, run `codex-compat` to generate `.codex/hooks.json` from the Claude Code config.

### 5. Commit

Stage and commit: `Add React rules enforcement hooks`
