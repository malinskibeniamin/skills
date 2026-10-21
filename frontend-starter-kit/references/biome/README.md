# Setup Biome + Ultracite
- **Biome** linter/formatter + **Ultracite** opinionated preset
- Stop hook checks session-owned JS/TS files; safe auto-fix is optional.
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
    "check:files": "biome check --error-on-warnings --no-errors-on-unmatched",
    "lint:file": "biome check",
    "lint:fix:file": "biome check --write"
  }
}
```

The hook prefers read-only `check:files`. Existing projects with only `lint:file`
and session tracking keep their configured `lint:fix:file` repair, skipping
`noUnusedImports`, followed by a mandatory read-only check. Without tracking, only
read-only checks run. Legacy Biome checks receive `--error-on-warnings` to preserve
strict warning policy without parsing diagnostic text. Nonzero checker exits block even without file/line
diagnostics. No file-scoped script means no automatic invocation, not a quality pass.
Full project gates still run before delivery; see [check loops](../../../shared/check-loop.md).

### 4. Hook
Copy `scripts/biome-autofix.sh` -> `.claude/hooks/`. `chmod +x`. Add to Stop.

### 5. Verify
- [ ] `bun run lint` + `bun run lint:fix` work
- [ ] Hook executable + configured
