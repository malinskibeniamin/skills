# React Compiler Reference

## Post-Compiler Mental Model

> "Write React as if every render is free and memoization is automatic."

**Pre-compiler era:** manual control over re-renders, defensive memoization, referential equality as priority.
**Post-compiler era:** compiler auto-inserts memoization, renders cheap, code organized around clarity + correctness.

## Post-React Compiler Coding Rules

Follow when React Compiler enabled:

1. **Write components as pure functions** — derive UI from props, state, context. No hidden mutable state, no side effects during render.
2. **Prefer plain JavaScript** — `const total = items.reduce(...)` not `useMemo(() => items.reduce(...), [items])`. Compiler memoizes automatically.
3. **Inline callbacks fine** — `<Dialog onClose={() => setOpen(false)} />` correct. Don't extract to `useCallback`.
4. **Derive, don't store** — never `useState` + `useEffect` for derived values. Compute inline during render.
5. **Hooks for semantics, not performance** — `useState` for true UI state, `useEffect` only for syncing with external systems, `useRef` for imperative handles.
6. **Don't use `useRef` as memoization cache** — compiler owns caching.
7. **Treat `useMemo`/`useCallback`/`React.memo` as escape hatches** — only when integrating with non-React systems, or referential stability needed for correctness (not performance). Document why.
8. **Respect `'use no memo'`** — never remove. Last-resort opt-out, not default.
9. **Follow naming conventions** — PascalCase for components (aids compiler inference), `use*` prefix for hooks.

## react-compiler-check.sh

> Script: [`scripts/react-compiler-check.sh`](scripts/react-compiler-check.sh)

## Escape Hatch: 'use no memo'

When React Compiler causes issues with specific component, add directive at file top:

```tsx
'use no memo'

export function ProblematicComponent() {
  // Compiler will skip this file
  const value = useMemo(() => expensiveCalc(), [dep])
  return <div>{value}</div>
}
```

Rules for directives:
- Never introduce directives automatically
- Respect existing — never remove `'use no memo'`
- `'use no memo'` only as last-resort escape hatch
- Document why opt-out exists

## Compiler Modes

React Compiler supports four compilation modes:

| Mode | Behavior | When to use |
|------|----------|-------------|
| `infer` (default) | Heuristically detects components (PascalCase + JSX) and hooks (`use*` prefix) | Most projects — works out of box |
| `annotation` | Only compiles functions annotated with `"use memo"` | Incremental adoption, safety-critical code |
| `syntax` | Relies on Flow-specific component syntax | Rare — Flow codebases only |
| `all` | Attempts to compile all top-level functions | Generally discouraged — unpredictable |

Rules:
- Assume `infer` mode unless explicitly configured otherwise
- Never rely on compilation for correctness — code must work without compiler
- Follow naming conventions (PascalCase components, `use*` hooks) to aid inference
- Never introduce `"use memo"` or `"use no memo"` directives automatically
- Respect existing directives — define compiler trust boundaries, not performance hints

### Annotation Mode for Legacy Codebases

For large legacy codebases, `annotation` mode = opt in file-by-file instead of compiling everything at once.

**Setup:**

```ts
// rsbuild.config.ts (or babel config)
plugins: [
  pluginBabel({
    babelLoaderOptions: {
      plugins: [['babel-plugin-react-compiler', { compilationMode: 'annotation' }]],
    },
  }),
],
```

**Environment variable:**

Set `REACT_COMPILER_MODE=annotation` in SessionStart hook so memoization checks adapt:

```bash
echo "export REACT_COMPILER_MODE=annotation" >> "$CLAUDE_ENV_FILE"
```

**Migration workflow:**

1. Install compiler with `annotation` mode — nothing changes, no files compiled
2. Add `"use memo"` to files as you migrate — compiler activates per-file
3. In annotated files, remove manual `useMemo`/`useCallback`/`React.memo`
4. In non-annotated files, manual memoization stays correct, hooks won't flag it
5. Once all files annotated, switch to `infer` mode, remove `"use memo"` directives

**Hook behavior by mode:**

| Mode | File has `"use memo"` | File has `"use no memo"` | No directive | Manual memo flagged? |
|------|----------------------|-------------------------|--------------|---------------------|
| `infer` | N/A (not needed) | Skip — compiler opted out | Compiled | Yes |
| `annotation` | Compiled | Skip — compiler opted out | Not compiled | No |

## Component Library Directory

All files in component library dir (`components/ui/` or `redpanda-ui/`) need `'use no memo'` because:
- Registry/distribution components need explicit memoization control
- Compiler may interfere with component API contracts
- Consumers may have different compiler settings

## Post-Compiler Pattern Reference

| Pre-compiler (avoid) | Post-compiler (prefer) |
|---|---|
| `useMemo(() => items.reduce(...), [items])` | `const total = items.reduce(...)` |
| `useCallback(() => setOpen(false), [])` | `() => setOpen(false)` inline |
| `React.memo(Component)` | Plain `function Component()` |
| `useState` + `useEffect` for derived values | Compute inline: `const filtered = items.filter(...)` |
| `useRef` as memoization cache | Plain computation |
| Extract callbacks to variables | Inline in JSX props |
| `useState({a, b, c})` single large object | Multiple `useState` calls |

## When Manual Optimization IS Allowed

Only when:
1. Profiling reveals real bottleneck **after** compilation
2. Interfacing with non-React or legacy systems
3. Referential stability needed for **correctness** (not performance)
4. Precise effect re-execution control beyond compiler inference

In these cases: add `'use no memo'` and document why.