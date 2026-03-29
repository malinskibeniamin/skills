---
name: redpanda-frontend-kit
description: Meta-skill that runs the generic frontend-starter-kit plus additional React skills and Redpanda-specific registry workflow. Use when bootstrapping a new Redpanda frontend project or setting up the full Redpanda frontend stack.
---

# Redpanda Frontend Kit

## What This Sets Up

Runs the generic **frontend-starter-kit** first, then adds additional React enforcement and Redpanda-specific tooling:

### Generic (via frontend-starter-kit)
1. **setup-toolchain** — Ban npm/npx/tsc, enforce bun + tsgo, block destructive commands
2. **setup-biome** — Biome + Ultracite with auto-fix hook
3. **setup-quality-gate** — quality:gate script, CI workflow, tsgo Stop hook, bundle guard
4. **setup-llm-optimization** — AI_AGENT=1, output truncation
5. **setup-react-compiler** — React Compiler + memoization check
6. **setup-zustand** — Zustand best practices enforcement
7. **setup-accessibility** — ARIA enforcement, Playwright AXE, WCAG 2.1 AA

### Additional React skills (generic — usable in any project)
8. **setup-react-rules** — Ban useEffect, raw HTML, Chakra, TS escape hatches, XSS vectors
9. **setup-react-doctor** — Health scoring with Stop hook
10. **setup-tanstack-router** — Route tree auto-generation + anti-pattern enforcement
11. **setup-connect-query** — ConnectRPC + Connect Query + Protobuf enforcement

### Redpanda-specific
12. **setup-registry-workflow** — Redpanda UI registry component workflow

## Steps

### 1. Run frontend-starter-kit

This executes all 5 generic skills.

### 2. Run additional React skills

Execute setup-react-rules, setup-react-doctor, setup-tanstack-router, setup-connect-query in order.

For setup-connect-query, detect the protobuf version from `package.json` and install the appropriate variant (v1 or v2).

### 3. Run Redpanda-specific skills

Execute setup-registry-workflow for Redpanda UI registry component workflow.

### 4. Final verification

- [ ] All `.claude/hooks/` scripts are executable
- [ ] `.claude/settings.json` has all hooks (including zustand-check, tanstack-router-check, connect-query-check)
- [ ] `biome.jsonc` exists
- [ ] `react-doctor.config.json` exists
- [ ] All package.json scripts present: `lint`, `lint:fix`, `type:check`, `test`, `quality:gate`, `doctor`, `generate:routes`
- [ ] connect-query-check.sh matches the detected protobuf version (v1 or v2)

### 5. Commit

Stage everything and commit: `Bootstrap Redpanda frontend kit`
