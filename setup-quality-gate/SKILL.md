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
- **Test performance audit hook** (Stop) that compares per-test durations against session-start baseline and surfaces improvements/regressions as an audit table
- **CI status check** — verify `gh run list` passes before declaring work complete
- **`@claude` review trigger** — after creating a PR, comment `@claude review` to trigger automated Claude review
- **Codex second opinion** (optional) — `/codex:review` for cross-model review via [codex-plugin-cc](https://github.com/openai/codex-plugin-cc)

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

### 2. Create asset type declarations

Create `src/types/assets.d.ts` from [REFERENCE.md](REFERENCE.md) — tsgo can't resolve `.svg`, `.css`, `.png` imports without it. These are bundler-handled at build time.

### 3. Create GitHub Actions workflow

Write `.github/workflows/quality-gate.yml` from [REFERENCE.md](REFERENCE.md). Key features:
- Runs on PR and push to main
- Formatting integrity: `bun run lint:fix && git diff --exit-code` (fails if code wasn't formatted)
- Type checking: `bun run type:check`
- Tests: `bun test --run`

### 4. Create Stop hook script

Copy [`scripts/typecheck-stop.sh`](scripts/typecheck-stop.sh) into `.claude/hooks/`. Make executable.

### 5. Create Bundle guard hook script

Copy [`scripts/bundle-guard.sh`](scripts/bundle-guard.sh) into `.claude/hooks/`. Make executable.

### 6. Create Test performance audit hook script

Copy [`scripts/test-perf-stop.sh`](scripts/test-perf-stop.sh) into `.claude/hooks/`. Make executable.

### 7. Configure hooks in `.claude/settings.json`

Add to hooks config:
- **Stop**: `.claude/hooks/typecheck-stop.sh`, `.claude/hooks/test-perf-stop.sh`
- **PostToolUse**: `.claude/hooks/bundle-guard.sh`

### 8. Verify

- [ ] `bun run lint` works
- [ ] `bun run type:check` works (no errors on .svg/.css imports)
- [ ] `bun run quality:gate` works
- [ ] `.github/workflows/quality-gate.yml` exists
- [ ] `src/types/assets.d.ts` exists
- [ ] Stop hook scripts are executable (typecheck + test-perf)
- [ ] Bundle guard hook script is executable

### 9. Commit

Stage all files and commit: `Add quality gate scripts and CI workflow`
