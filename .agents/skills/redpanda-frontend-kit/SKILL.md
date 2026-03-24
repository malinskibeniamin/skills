---
name: redpanda-frontend-kit
description: Meta-skill that runs the generic frontend-starter-kit plus all Redpanda-specific skills (React rules, react-doctor, TanStack Router). Use when bootstrapping a new Redpanda frontend project or setting up the full Redpanda frontend stack.
---

# Redpanda Frontend Kit

## What This Sets Up

Runs the generic **frontend-starter-kit** first, then adds Redpanda-specific enforcement:

### Generic (via frontend-starter-kit)
1. **setup-toolchain** — Ban npm/npx/tsc, enforce bun + tsgo
2. **setup-biome** — Biome + Ultracite with auto-fix hook
3. **setup-quality-gate** — quality:gate script, CI workflow, tsgo Stop hook
4. **setup-llm-optimization** — AI_AGENT=1, output truncation
5. **setup-react-compiler** — React Compiler + memoization check

### Redpanda-specific
6. **setup-react-rules** — Ban useEffect, raw HTML, Chakra, TS escape hatches
7. **setup-react-doctor** — Health scoring with Stop hook
8. **setup-tanstack-router** — Route tree auto-generation

## Steps

### 1. Run frontend-starter-kit

This executes all 5 generic skills.

### 2. Run Redpanda-specific skills

Execute setup-react-rules, setup-react-doctor, setup-tanstack-router in order.

### 3. Final verification

- [ ] All `.claude/hooks/` scripts are executable
- [ ] `.claude/settings.json` has all hooks
- [ ] `biome.jsonc` exists
- [ ] `react-doctor.config.json` exists
- [ ] All package.json scripts present: `lint`, `lint:fix`, `typecheck`, `test`, `quality:gate`, `doctor`, `generate:routes`

### 4. Commit

Stage everything and commit: `Bootstrap Redpanda frontend kit`
