# Setup Quality Gate
## What This Sets Up

- `quality:gate` script -- lint + type check + related tests in <5s
- GitHub Actions workflow w/ formatting integrity (`git diff --exit-code`)
- Stop hook: TypeScript 7 `tsc` + related tests before finish
- Bundle guard hook: warn on heavy deps (moment, lodash, jquery, core-js, classnames)
- Test perf audit hook: surface duration regressions >30%
- CI status check + `@claude review` trigger
- Optional: `/codex:review` cross-model review

## Steps

### 1. Package.json scripts
```json
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check --write .",
    "type:check": "tsc",
    "test": "vitest --run",
    "test:related": "vitest --run --related",
    "quality:gate": "biome check . && tsc && vitest --run --related $(git diff --name-only HEAD)"
  }
}
```

### 2. Asset type declarations
Create `src/types/assets.d.ts` from [REFERENCE.md](REFERENCE.md) -- `tsc` needs declarations for .svg/.css/.png imports.

### 3. GitHub Actions
Write `.github/workflows/quality-gate.yml` from [REFERENCE.md](REFERENCE.md). Run on PR + push to main.

### 4. Hook scripts
Copy into `.claude/hooks/`, `chmod +x`:
- `scripts/typecheck-stop.sh` -> Stop
- `scripts/test-perf-stop.sh` -> Stop

### 5. Verify
- [ ] `bun run quality:gate` work
- [ ] `.github/workflows/quality-gate.yml` exist
- [ ] `src/types/assets.d.ts` exist
- [ ] All hook scripts executable + configured
