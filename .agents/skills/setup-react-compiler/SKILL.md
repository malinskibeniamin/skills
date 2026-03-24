---
name: setup-react-compiler
description: Install React Compiler (babel-plugin-react-compiler) with rsbuild config and Claude Code hook to flag unnecessary manual memoization. Use when setting up React Compiler, removing useMemo/useCallback, or optimizing React performance automatically.
---

# Setup React Compiler

## What This Sets Up

- **babel-plugin-react-compiler** with rsbuild integration
- **PostToolUse hook** flagging unnecessary `useMemo`, `useCallback`, `React.memo`
- `'use no memo'` directive for escape hatch and redpanda-ui directory

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

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/react-compiler-check.sh" }
        ]
      }
    ]
  }
}
```

### 6. Verify & Commit

- [ ] rsbuild config includes babel plugin
- [ ] Hook script is executable
- [ ] redpanda-ui `.tsx` files have `'use no memo'`

Commit: `Add React Compiler with rsbuild and memoization check hook`
