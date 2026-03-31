---
name: setup-quality-gate
description: Add quality:gate package.json script for fast local/CI quality checks (biome + tsgo + related tests), GitHub Actions workflow, and Stop hook for type checking. Use when setting up quality gates, CI pipelines, or pre-push validation.
---

# Setup Quality Gate

## What This Sets Up

- `quality:gate` package.json script — runs lint, type check, and related tests in <5 seconds
- Additional package.json scripts: `lint`, `lint:fix`, `type:check`, `test`
- **GitHub Actions workflow** with formatting integrity check (`git diff --exit-code`)
- **Stop hook** running `tsgo` + related tests before Claude finishes (auto-detects Vitest/Jest/Bun test runner)
- **Bundle guard hook** (PostToolUse) that warns when known-heavy dependencies (moment, lodash, jquery, core-js, classnames) are added to package.json
- **CI status check** — verify `gh run list` passes before declaring work complete
- **`@claude` review trigger** — after creating a PR, comment `@claude review` to trigger automated Claude review

## Steps

### 1. Add package.json scripts

Merge into existing `scripts` (don't overwrite):

```json
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check --write .",
    "type:check": "tsgo",
    "test": "vitest --run",
    "test:related": "vitest --run --related",
    "quality:gate": "biome check . && tsgo && vitest --run --related $(git diff --name-only HEAD)"
  }
}
```

**Note**: `quality:gate` uses `--related` with `git diff` to only run tests affected by changed files. Target: <5 seconds.

### 2. Create GitHub Actions workflow

Write `.github/workflows/quality-gate.yml` from [REFERENCE.md](REFERENCE.md). Key features:
- Runs on PR and push to main
- Formatting integrity: `bun run lint:fix && git diff --exit-code` (fails if code wasn't formatted)
- Type checking: `bun run type:check`
- Tests: `bun test --run`

### 3. Create Stop hook script

Copy [`scripts/typecheck-stop.sh`](scripts/typecheck-stop.sh) into `.claude/hooks/`. Make executable.

### 4. Create Bundle guard hook script

Copy [`scripts/bundle-guard.sh`](scripts/bundle-guard.sh) into `.claude/hooks/`. Make executable.

### 5. Configure hooks in `.claude/settings.json`

Add to hooks config:
- **Stop**: `.claude/hooks/typecheck-stop.sh`
- **PostToolUse**: `.claude/hooks/bundle-guard.sh`

### 6. Verify

- [ ] `bun run lint` works
- [ ] `bun run type:check` works
- [ ] `bun run quality:gate` works
- [ ] `.github/workflows/quality-gate.yml` exists
- [ ] Stop hook script is executable
- [ ] Bundle guard hook script is executable

### 7. Commit

Stage all files and commit: `Add quality gate scripts and CI workflow`
