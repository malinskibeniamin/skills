---
name: setup-quality-gate
description: Add quality:gate package.json script for fast local/CI quality checks (biome + tsgo + related tests), GitHub Actions workflow, and Stop hook for type checking. Use when setting up quality gates, CI pipelines, or pre-push validation.
---

# Setup Quality Gate

## What This Sets Up

- `quality:gate` package.json script — runs lint, type check, and related tests in <5 seconds
- Additional package.json scripts: `lint`, `lint:fix`, `typecheck`, `test`
- **GitHub Actions workflow** with formatting integrity check (`git diff --exit-code`)
- **Stop hook** running `tsgo` before Claude finishes

## Steps

### 1. Add package.json scripts

Merge into existing `scripts` (don't overwrite):

```json
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check --write .",
    "typecheck": "tsgo",
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
- Type checking: `bun run typecheck`
- Tests: `bun test --run`

### 3. Create Stop hook script

Write `typecheck-stop.sh` from [REFERENCE.md](REFERENCE.md) into `.claude/hooks/`. Make executable.

### 4. Configure Stop hook in `.claude/settings.json`

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/typecheck-stop.sh"
          }
        ]
      }
    ]
  }
}
```

### 5. Verify

- [ ] `bun run lint` works
- [ ] `bun run typecheck` works
- [ ] `bun run quality:gate` works
- [ ] `.github/workflows/quality-gate.yml` exists
- [ ] Stop hook script is executable

### 6. Commit

Stage all files and commit: `Add quality gate scripts and CI workflow`
