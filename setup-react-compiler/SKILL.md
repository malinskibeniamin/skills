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
- **Annotation mode support** for legacy codebases: set `REACT_COMPILER_MODE=annotation` to only flag memoization in files with `"use memo"` directive

See [REFERENCE.md](REFERENCE.md) for post-compiler coding rules and pattern reference.

## Steps

### 1. Install dependencies

```bash
bun add -D babel-plugin-react-compiler @rsbuild/plugin-babel --yarn
```

### 2. Configure rsbuild

Add to `rsbuild.config.ts` (merge with existing config). **Use `annotation` mode for existing/brownfield codebases** (opt-in per file), `infer` for greenfield:

```ts
import { pluginBabel } from '@rsbuild/plugin-babel';

export default {
  plugins: [
    pluginBabel({
      babelLoaderOptions: {
        plugins: [
          ['babel-plugin-react-compiler', {
            // 'annotation' for brownfield (default) — only compiles files with "use memo"
            // 'infer' for greenfield — compiles all components/hooks automatically
            compilationMode: 'annotation',
          }],
        ],
      },
    }),
  ],
};
```

For brownfield codebases, set the env var so hooks adapt:

```bash
# In .claude/hooks/session-env.sh
echo "export REACT_COMPILER_MODE=annotation" >> "$CLAUDE_ENV_FILE"
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
