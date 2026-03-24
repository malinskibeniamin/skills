---
name: frontend-starter-kit
description: Meta-skill that runs all generic frontend setup skills in order — toolchain enforcement, Biome + Ultracite, quality gate, LLM optimization, and React Compiler. Use when starting a new frontend project or bootstrapping frontend best practices from scratch.
---

# Frontend Starter Kit

## What This Sets Up

Runs these skills in order:

1. **setup-toolchain** — Ban npm/npx/tsc, enforce bun + tsgo + --yarn flag
2. **setup-biome** — Biome + Ultracite linting/formatting with auto-fix hook
3. **setup-quality-gate** — quality:gate script, CI workflow, Stop hook for tsgo
4. **setup-llm-optimization** — AI_AGENT=1, CLAUDECODE=1, output truncation
5. **setup-react-compiler** — React Compiler with rsbuild, memoization check

## Steps

### 1. Run each skill in order

Execute each skill above sequentially. Each skill is idempotent — if already configured, it will verify and skip.

### 2. Final verification

After all skills complete:

- [ ] `.claude/settings.json` has all hooks configured
- [ ] `biome.jsonc` exists
- [ ] `rsbuild.config.ts` has React Compiler plugin
- [ ] Package.json has all scripts: `lint`, `lint:fix`, `typecheck`, `test`, `quality:gate`
- [ ] `.github/workflows/quality-gate.yml` exists
- [ ] All hook scripts in `.claude/hooks/` are executable

### 3. Commit

Stage everything and commit: `Bootstrap frontend starter kit`
