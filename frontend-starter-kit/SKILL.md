---
name: frontend-starter-kit
description: Meta-skill that sets up a complete frontend stack — 13 setup skills (toolchain, Biome, quality gate, React Compiler, zustand, accessibility, React rules, env validation, conventional commits, react-doctor, TanStack Router, Connect Query) plus 13 community workflow skills. Use when starting a new frontend project or bootstrapping frontend best practices from scratch.
---

# Frontend Starter Kit

## What This Sets Up

### Setup skills (configures hooks + packages)

1. **setup-toolchain** — Ban npm/npx/tsc/eslint/prettier, enforce bun + tsgo, block destructive commands
2. **setup-biome** — Biome + Ultracite linting/formatting with auto-fix hook, kebab-case filenames
3. **setup-quality-gate** — quality:gate script, CI workflow, Stop hook for tsgo + related tests, bundle guard
4. **setup-llm-optimization** — AI_AGENT=1, CLAUDECODE=1, output truncation
5. **setup-react-compiler** — React Compiler with rsbuild, memoization check
6. **setup-zustand** — Zustand best practices: double-parens create, useShallow, persist middleware
7. **setup-accessibility** — ARIA enforcement, Playwright AXE setup, WCAG 2.1 AA compliance
8. **setup-react-rules** — Ban raw HTML, TS escape hatches, XSS vectors, Tailwind enforcement, class components
9. **setup-env-validation** — t3-env + zod, ban raw process.env access
10. **setup-conventional-commits** — Enforce type(scope): description commit format
11. **setup-react-doctor** — Health scoring with Stop hook, warnings surfaced
12. **setup-tanstack-router** — Route tree auto-generation + anti-pattern enforcement
13. **setup-connect-query** — ConnectRPC + Connect Query + Protobuf enforcement

### Diagnostics

14. **test-guardian** — Test health across frameworks (Vitest, Jest, Bun), async leak detection, performance profiling

### Community workflow skills (installed from mattpocock/skills)

16. **tdd** — Test-driven development with red-green-refactor loop
17. **triage-issue** — Bug investigation and root cause analysis
18. **improve-codebase-architecture** — Architectural improvements and deep module analysis
19. **request-refactor-plan** — Create detailed refactor plans with tiny commits, filed as GitHub issues
20. **design-an-interface** — Generate multiple radically different interface designs using parallel sub-agents
21. **write-a-prd** — PRD creation via interactive interview
22. **prd-to-plan** — Turn PRD into implementation plan
23. **prd-to-issues** — Break PRD into GitHub issues
24. **write-a-skill** — Create new agent skills
25. **grill-me** — Stress-test your design decisions
26. **qa** — Interactive QA sessions, auto-file GitHub issues
27. **ubiquitous-language** — Domain glossary with canonical terms (DDD)
28. **git-guardrails-claude-code** — Branch protection guardrails

## Steps

### 1. Run each setup skill in order

Execute skills 1–13 sequentially. Each skill is idempotent — if already configured, it will verify and skip.

Set `REACT_RULES_BAN_USEEFFECT=1` in the SessionStart hook (`.claude/hooks/session-env.sh`):

```bash
echo "export REACT_RULES_BAN_USEEFFECT=1" >> "$CLAUDE_ENV_FILE"
```

For setup-connect-query, detect the protobuf version from `package.json` and install the appropriate variant (v1 or v2).

### 2. Install community workflow skills

```bash
bunx skills@latest add mattpocock/skills/tdd --agent claude-code -y
bunx skills@latest add mattpocock/skills/triage-issue --agent claude-code -y
bunx skills@latest add mattpocock/skills/improve-codebase-architecture --agent claude-code -y
bunx skills@latest add mattpocock/skills/request-refactor-plan --agent claude-code -y
bunx skills@latest add mattpocock/skills/design-an-interface --agent claude-code -y
bunx skills@latest add mattpocock/skills/write-a-prd --agent claude-code -y
bunx skills@latest add mattpocock/skills/prd-to-plan --agent claude-code -y
bunx skills@latest add mattpocock/skills/prd-to-issues --agent claude-code -y
bunx skills@latest add mattpocock/skills/write-a-skill --agent claude-code -y
bunx skills@latest add mattpocock/skills/grill-me --agent claude-code -y
bunx skills@latest add mattpocock/skills/qa --agent claude-code -y
bunx skills@latest add mattpocock/skills/ubiquitous-language --agent claude-code -y
bunx skills@latest add mattpocock/skills/git-guardrails-claude-code --agent claude-code -y
```

### 3. Final verification

- [ ] `.claude/settings.json` has all hooks configured
- [ ] `biome.jsonc` exists
- [ ] `rsbuild.config.ts` has React Compiler plugin
- [ ] `react-doctor.config.json` exists
- [ ] `src/env.ts` exists with t3-env zod schema
- [ ] Package.json scripts: `lint`, `lint:fix`, `type:check`, `test`, `quality:gate`, `doctor`, `generate:routes`
- [ ] `.github/workflows/quality-gate.yml` exists
- [ ] All hook scripts in `.claude/hooks/` are executable
- [ ] All community skills installed

### 4. Commit

Stage everything and commit: `Bootstrap frontend starter kit`
