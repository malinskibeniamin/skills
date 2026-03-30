---
name: setup-react-compiler
description: Install React Compiler with rsbuild and enforce compiler-friendly patterns via PostToolUse hooks. Flags manual memoization, derived state, useRef cache. Use when setting up React Compiler or post-compiler patterns.
---

# Setup React Compiler

## What This Sets Up

- **babel-plugin-react-compiler** with rsbuild integration
- **PostToolUse hook** enforcing compiler-friendly React patterns:
  - Flags `useMemo`, `useCallback`, `React.memo` (compiler handles memoization)
  - Flags derived-state-via-useEffect (`useState` + `useEffect` to compute derived values)
  - Flags `useRef` used as memoization cache
- `'use no memo'` directive for escape hatch and component library directories

See [REFERENCE.md](REFERENCE.md) for post-compiler coding rules and pattern reference.

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

### 3. Add `'use no memo'` to component library files

Add `'use no memo'` directive at the top of all `.tsx` files in the component library directory (auto-detected, or set `UI_LIB_DIRS`). The compiler should not auto-memoize distribution/registry components.

### 4. Create hook script

Copy [`scripts/react-compiler-check.sh`](scripts/react-compiler-check.sh) and [`scripts/_hook-lib.sh`](scripts/_hook-lib.sh) into `.claude/hooks/`. Make executable.

### 5. Configure hook in `.claude/settings.json`

Add to hooks config: **PostToolUse** (matcher: `Edit|Write`): `.claude/hooks/react-compiler-check.sh`

### 6. Verify & Commit

- [ ] rsbuild config includes babel plugin
- [ ] Hook script is executable
- [ ] Component library `.tsx` files have `'use no memo'`

Commit: `Add React Compiler with rsbuild and compiler-friendly pattern enforcement`
