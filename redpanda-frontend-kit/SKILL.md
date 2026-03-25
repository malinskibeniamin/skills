---
name: redpanda-frontend-kit
description: Meta-skill that runs the generic frontend-starter-kit plus all Redpanda-specific skills (React rules, react-doctor, TanStack Router, Connect Query). Use when bootstrapping a new Redpanda frontend project or setting up the full Redpanda frontend stack.
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
6. **setup-zustand** — Zustand best practices enforcement

### Redpanda-specific
7. **setup-react-rules** — Ban useEffect, raw HTML, Chakra, TS escape hatches
8. **setup-react-doctor** — Health scoring with Stop hook
9. **setup-tanstack-router** — Route tree auto-generation + anti-pattern enforcement
10. **setup-connect-query** — ConnectRPC + Connect Query + Protobuf enforcement

## Steps

### 1. Run frontend-starter-kit

This executes all 5 generic skills.

### 2. Run Redpanda-specific skills

Execute setup-react-rules, setup-react-doctor, setup-tanstack-router, setup-connect-query in order.

For setup-connect-query, detect the protobuf version from `package.json` and install the appropriate variant (v1 or v2).

### 3. Final verification

- [ ] All `.claude/hooks/` scripts are executable
- [ ] `.claude/settings.json` has all hooks (including zustand-check, tanstack-router-check, connect-query-check)
- [ ] `biome.jsonc` exists
- [ ] `react-doctor.config.json` exists
- [ ] All package.json scripts present: `lint`, `lint:fix`, `type:check`, `test`, `quality:gate`, `doctor`, `generate:routes`
- [ ] connect-query-check.sh matches the detected protobuf version (v1 or v2)

### 4. Commit

Stage everything and commit: `Bootstrap Redpanda frontend kit`
