---
name: frontend-starter-kit
description: Complete frontend stack — 14 setup skills + 10 owned workflow skills + 5 optional community skills in one command. Use when starting a new frontend project or bootstrapping frontend best practices from scratch.
---

# Frontend Starter Kit

## Setup Skills (1-14, sequential, idempotent)

1. **setup-toolchain** — bun + tsgo enforcement, destructive command guards
2. **setup-biome** — Biome + Ultracite, auto-fix hook
3. **setup-quality-gate** — quality:gate script, CI workflow, Stop hook, bundle guard
4. **setup-agent-config** — AI_AGENT=1, output truncation
5. **setup-react-compiler** — React Compiler + memoization check
6. **setup-zustand** — double-parens create, useShallow, persist
7. **setup-accessibility** — ARIA enforcement, Playwright AXE, WCAG 2.1 AA
8. **setup-react-rules** — ban raw HTML, TS escapes, XSS, barrel imports
9. **setup-env-validation** — t3-env + zod, ban process.env
10. **setup-conventional-commits** — type(scope): description
11. **setup-react-doctor** — health scoring + Stop hook
12. **setup-tanstack-router** — route tree auto-gen + enforcement
13. **setup-connect-query** — ConnectRPC + Protobuf enforcement
14. **setup-e2e-testing** — Playwright + Testcontainers + axe-core

## Workflow Skills (15-24)

development-lifecycle, tdd, brainstorming, setup-ci-pipeline, improve-codebase-architecture, request-refactor-plan, design-an-interface, grill-me, triage-issue, write-a-skill

## Steps

### 1. Run setup skills 1-14 sequentially
Each skill's `SETUP.md` has install steps. Set `REACT_RULES_BAN_USEEFFECT=1` in session-env.sh.

### 2. Install workflow skills
```bash
bunx skills@latest add malinskibeniamin/skills/development-lifecycle --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/tdd --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/brainstorming --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/setup-ci-pipeline --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/improve-codebase-architecture --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/request-refactor-plan --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/design-an-interface --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/grill-me --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/triage-issue --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/write-a-skill --agent claude-code -y
```

### 3. Community skills (optional)
```bash
bunx skills@latest add mattpocock/skills/write-a-prd --agent claude-code -y
bunx skills@latest add mattpocock/skills/prd-to-issues --agent claude-code -y
bunx skills@latest add mattpocock/skills/qa --agent claude-code -y
bunx skills@latest add mattpocock/skills/ubiquitous-language --agent claude-code -y
bunx skills@latest add mattpocock/skills/git-guardrails-claude-code --agent claude-code -y
```

### 4. Verify
- [ ] `.claude/settings.json` has all hooks, `biome.jsonc` + `src/env.ts` exist
- [ ] Scripts: lint, lint:fix, type:check, test, quality:gate
- [ ] `.github/workflows/quality-gate.yml` exists, all hooks executable
