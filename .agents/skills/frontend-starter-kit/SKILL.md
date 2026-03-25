---
name: frontend-starter-kit
description: Meta-skill that runs all generic frontend setup skills in order — toolchain enforcement, Biome + Ultracite, quality gate, LLM optimization, React Compiler, zustand — and installs community workflow skills (TDD, triage, architecture, refactoring, design). Use when starting a new frontend project or bootstrapping frontend best practices from scratch.
---

# Frontend Starter Kit

## What This Sets Up

### Setup skills (configures hooks + packages)

1. **setup-toolchain** — Ban npm/npx/tsc/eslint/prettier, enforce bun + tsgo + --yarn flag
2. **setup-biome** — Biome + Ultracite linting/formatting with auto-fix hook
3. **setup-quality-gate** — quality:gate script, CI workflow, Stop hook for tsgo
4. **setup-llm-optimization** — AI_AGENT=1, CLAUDECODE=1, output truncation
5. **setup-react-compiler** — React Compiler with rsbuild, memoization check
6. **setup-zustand** — Zustand best practices: double-parens create, useShallow, persist middleware

### Community workflow skills (installed from mattpocock/skills)

6. **tdd** — Test-driven development with red-green-refactor loop
7. **triage-issue** — Bug investigation and root cause analysis
8. **improve-codebase-architecture** — Architectural improvements and deep module analysis
9. **request-refactor-plan** — Create detailed refactor plans with tiny commits, filed as GitHub issues
10. **design-an-interface** — Generate multiple radically different interface designs using parallel sub-agents

## Steps

### 1. Run each setup skill in order

Execute skills 1–6 sequentially. Each skill is idempotent — if already configured, it will verify and skip.

### 2. Install community workflow skills

```bash
bunx skills@latest add mattpocock/skills/tdd -y
bunx skills@latest add mattpocock/skills/triage-issue -y
bunx skills@latest add mattpocock/skills/improve-codebase-architecture -y
bunx skills@latest add mattpocock/skills/request-refactor-plan -y
bunx skills@latest add mattpocock/skills/design-an-interface -y
```

### 3. Final verification

After all skills complete:

- [ ] `.claude/settings.json` has all hooks configured
- [ ] `biome.jsonc` exists
- [ ] `rsbuild.config.ts` has React Compiler plugin
- [ ] Package.json has all scripts: `lint`, `lint:fix`, `type:check`, `test`, `quality:gate`
- [ ] `.github/workflows/quality-gate.yml` exists
- [ ] All hook scripts in `.claude/hooks/` are executable
- [ ] zustand-check.sh catches single-parens create and inline object selectors
- [ ] All community skills installed: `tdd`, `triage-issue`, `improve-codebase-architecture`, `request-refactor-plan`, `design-an-interface`

### 4. Commit

Stage everything and commit: `Bootstrap frontend starter kit`
