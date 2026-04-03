---
name: setup-ci-pipeline
description: "Configure GitHub Actions CI for React/TypeScript frontend projects. Coverage gates, visual regression, caching, Blacksmith workers, bundle budgets. Use when setting up CI, optimizing pipelines, or adding quality gates to PRs."
---

# Setup CI Pipeline

## What This Sets Up

GitHub Actions workflow optimized for React/TypeScript frontend projects:

- **Quality gate** — lint, type-check, tests in <5 min
- **Coverage gates** — enforce thresholds, post diff on PRs
- **Visual regression** — Playwright screenshot comparison
- **Dependency automation** — dependabot for minor/patch
- **Bundle budget** — alert on size regressions
- **Caching** — smart bun dependency caching (only when it helps)

See [REFERENCE.md](REFERENCE.md) for workflow templates, Blacksmith optimization, and visual regression patterns.

## Steps

### 1. Create quality-gate workflow

Write `.github/workflows/quality-gate.yml` from [REFERENCE.md](REFERENCE.md).

### 2. Configure dependabot

Write `.github/dependabot.yml` — auto-update minor/patch, manually review major.

### 3. Add visual regression tests

Add `toHaveScreenshot()` assertions to Playwright e2e tests.

### 4. Configure coverage

Add `--coverage --coverage.thresholds.lines=80` to test scripts.

### 5. Verify & Commit

- [ ] `gh workflow run quality-gate.yml` runs successfully
- [ ] Coverage report appears on PRs
- [ ] Dependabot creates its first PR
- Commit: `Add CI pipeline with quality gates`
