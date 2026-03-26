---
name: setup-react-compiler
description: Install React Compiler (babel-plugin-react-compiler) with rsbuild config and Claude Code hook to enforce compiler-friendly patterns. Flags manual memoization, derived-state-via-useEffect, and useRef-as-cache. Use when setting up React Compiler or adopting post-compiler coding patterns.
---

# Setup React Compiler

## What This Sets Up

- **babel-plugin-react-compiler** with rsbuild integration
- **PostToolUse hook** enforcing compiler-friendly React patterns:
  - Flags `useMemo`, `useCallback`, `React.memo` (compiler handles memoization)
  - Flags derived-state-via-useEffect (`useState` + `useEffect` to compute derived values)
  - Flags `useRef` used as memoization cache
- `'use no memo'` directive for escape hatch and redpanda-ui directory

## Post-React Compiler Coding Rules

These rules should be followed whenever React Compiler is enabled:

1. **Write components as pure functions** — derive UI from props, state, and context. No hidden mutable state, no side effects during render.
2. **Prefer plain JavaScript** — `const total = items.reduce(...)` not `useMemo(() => items.reduce(...), [items])`. The compiler memoizes automatically.
3. **Inline callbacks are fine** — `<Dialog onClose={() => setOpen(false)} />` is correct. Do not extract to `useCallback`.
4. **Derive, don't store** — never `useState` + `useEffect` to compute derived values. Compute inline during render.
5. **Hooks are for semantics, not performance** — `useState` for true UI state, `useEffect` only for syncing with external systems, `useRef` for imperative handles.
6. **Do not use `useRef` as a memoization cache** — the compiler owns caching.
7. **Treat `useMemo`/`useCallback`/`React.memo` as escape hatches** — only use when integrating with non-React systems, or when referential stability is required for correctness (not performance). Document why.
8. **Respect `'use no memo'`** — never remove it. Use it as a last-resort opt-out, not a default.
9. **Follow naming conventions** — PascalCase for components (aids compiler inference), `use*` prefix for hooks.

## Steps

### 1. Install dependencies

```bash
bun add -D babel-plugin-react-compiler @rsbuild/plugin-babel --yarn
```

### 2. Configure rsbuild

Add to `rsbuild.config.ts` (merge with existing config):

```ts
import { pluginBabel } from '@rsbuild/plugin-babel';

export default {
  plugins: [
    pluginBabel({
      babelLoaderOptions: {
        plugins: ['babel-plugin-react-compiler'],
      },
    }),
  ],
};
```

### 3. Add `'use no memo'` to redpanda-ui files

Add `'use no memo'` directive at the top of all `.tsx` files in the `redpanda-ui/` directory. The compiler should not auto-memoize distribution/registry components.

### 4. Create hook script

Write `react-compiler-check.sh` from [REFERENCE.md](REFERENCE.md) into `.claude/hooks/`. Make executable.

### 5. Configure hook in `.claude/settings.json`

Add to hooks config: **PostToolUse** (matcher: `Edit|Write`): `.claude/hooks/react-compiler-check.sh`

### 6. Verify & Commit

- [ ] rsbuild config includes babel plugin
- [ ] Hook script is executable
- [ ] redpanda-ui `.tsx` files have `'use no memo'`

Commit: `Add React Compiler with rsbuild and compiler-friendly pattern enforcement`
