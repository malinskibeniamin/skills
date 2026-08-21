# Setup Biome + Ultracite
- **Biome** linter/formatter + **Ultracite** opinionated preset
- Stop hook auto-fix lint/format on changed JS/TS files (skip `noUnusedImports`, avoid deletion loops)
- Strict: `noConsole`, cognitive complexity 15, `noDeprecatedImports`, restricted imports (moment/lodash/classnames/mobx/yup)

## Steps

### 1. Install
```bash
bun add -D --exact @biomejs/biome@2.5.9 ultracite@7.10.6
```

Keep React Compiler diagnostics single-owned: React Doctor runs them, so do
not also enable Biome's nursery `useReactCompiler` rule.

### 2. Create `biome.jsonc`
From [REFERENCE.md](REFERENCE.md). Extend `ultracite/biome/core` + `ultracite/biome/react`. VCS git on. Test files re-enable `noExplicitAny`.

### 3. Package.json scripts
```json
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check --write .",
    "lint:file": "biome check",
    "lint:fix:file": "biome check --write"
  }
}
```

### 4. Hook
Copy `scripts/biome-autofix.sh` -> `.claude/hooks/`. `chmod +x`. Add to Stop.

### 5. Verify
- [ ] `bun run lint` + `bun run lint:fix` work
- [ ] Hook executable + configured
