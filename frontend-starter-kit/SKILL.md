---
name: frontend-starter-kit
description: Complete frontend stack — 14 setup skills + 10 owned workflow skills + 5 optional community skills in one command. Use when starting a new frontend project or bootstrapping frontend best practices from scratch.
---

# Frontend Starter Kit

## What This Sets Up

### Setup skills (configures hooks + packages)

1. **setup-toolchain** — Ban npm/npx/tsc/eslint/prettier, enforce bun + tsgo, block destructive commands
2. **setup-biome** — Biome + Ultracite linting/formatting with auto-fix hook, kebab-case filenames
3. **setup-quality-gate** — quality:gate script, CI workflow, Stop hook for tsgo + related tests, bundle guard
4. **setup-agent-config** — AI_AGENT=1, CLAUDECODE=1, output truncation
5. **setup-react-compiler** — React Compiler with rsbuild, memoization check
6. **setup-zustand** — Zustand best practices: double-parens create, useShallow, persist middleware
7. **setup-accessibility** — ARIA enforcement, Playwright AXE setup, WCAG 2.1 AA compliance
8. **setup-react-rules** — Ban raw HTML, TS escape hatches, XSS vectors, Tailwind enforcement, class components
9. **setup-env-validation** — t3-env + zod, ban raw process.env access
10. **setup-conventional-commits** — Enforce type(scope): description commit format
11. **setup-react-doctor** — Health scoring with Stop hook, warnings surfaced
12. **setup-tanstack-router** — Route tree auto-generation + anti-pattern enforcement
13. **setup-connect-query** — ConnectRPC + Connect Query + Protobuf enforcement
14. **setup-e2e-testing** — Playwright + Testcontainers + axe-core accessibility testing

### Owned workflow skills (hook-integrated)

15. **development-lifecycle** — One skill for the full loop: understand → plan → TDD → verify → review → compound
16. **tdd** — TDD iron law + async leak detection (auto-loads on test files via paths:)
17. **brainstorming** — Design exploration + challenge mode
18. **setup-ci-pipeline** — GitHub Actions CI: coverage, visual regression, dependabot, bundle budgets
19. **improve-codebase-architecture** — Architectural improvements and deep module analysis
20. **request-refactor-plan** — Create detailed refactor plans with tiny commits, filed as GitHub issues
21. **design-an-interface** — Generate multiple radically different interface designs using parallel sub-agents
22. **grill-me** — Stress-test your design decisions
23. **triage-issue** — Triage bugs: explore codebase, find root cause, file TDD fix plan as GitHub issue
24. **write-a-skill** — Create new agent skills

## Steps

### 1. Run each setup skill in order

Execute skills 1–14 sequentially. Each skill is idempotent — if already configured, it will verify and skip.

Set `REACT_RULES_BAN_USEEFFECT=1` in the SessionStart hook (`.claude/hooks/session-env.sh`):

```bash
echo "export REACT_RULES_BAN_USEEFFECT=1" >> "$CLAUDE_ENV_FILE"
```

For setup-connect-query, detect the protobuf version from `package.json` and install the appropriate variant (v1 or v2).

### 2. Install owned workflow skills

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

### 3. Install community workflow skills (optional)

```bash
bunx skills@latest add mattpocock/skills/write-a-prd --agent claude-code -y
bunx skills@latest add mattpocock/skills/prd-to-issues --agent claude-code -y
bunx skills@latest add mattpocock/skills/qa --agent claude-code -y
bunx skills@latest add mattpocock/skills/ubiquitous-language --agent claude-code -y
bunx skills@latest add mattpocock/skills/git-guardrails-claude-code --agent claude-code -y
```

### 3. Final verification

- [ ] `.claude/settings.json` has all hooks, `biome.jsonc` exists, `src/env.ts` exists
- [ ] Package.json scripts: `lint`, `lint:fix`, `type:check`, `test`, `quality:gate`
- [ ] `.github/workflows/quality-gate.yml` exists, all hooks executable
- Commit: `Bootstrap frontend starter kit`
