---
name: frontend-starter-kit
description: Meta-skill that runs all generic frontend setup skills in order — toolchain enforcement, Biome + Ultracite, quality gate, LLM optimization, React Compiler, zustand — and installs community workflow skills (TDD, triage, architecture, refactoring, design). Use when starting a new frontend project or bootstrapping frontend best practices from scratch.
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
8. **setup-react-rules** — Ban raw HTML, TS escape hatches, XSS vectors, Tailwind enforcement
9. **setup-env-validation** — t3-env + zod, ban raw process.env access
10. **setup-logging** — Structured Pino logger, ban console.error/warn/debug
11. **setup-conventional-commits** — Enforce type(scope): description commit format

### Community workflow skills (installed from mattpocock/skills)

6. **tdd** — Test-driven development with red-green-refactor loop
7. **triage-issue** — Bug investigation and root cause analysis
8. **improve-codebase-architecture** — Architectural improvements and deep module analysis
9. **request-refactor-plan** — Create detailed refactor plans with tiny commits, filed as GitHub issues
10. **design-an-interface** — Generate multiple radically different interface designs using parallel sub-agents

## Steps

### 1. Run each setup skill in order

Execute skills 1–11 sequentially. Each skill is idempotent — if already configured, it will verify and skip.

Set `REACT_RULES_BAN_USEEFFECT=1` in the SessionStart hook (`.claude/hooks/session-env.sh`):

```bash
echo "export REACT_RULES_BAN_USEEFFECT=1" >> "$CLAUDE_ENV_FILE"
```

### 2. Install community workflow skills

```bash
bunx skills@latest add mattpocock/skills/tdd --agent claude-code -y
bunx skills@latest add mattpocock/skills/triage-issue --agent claude-code -y
bunx skills@latest add mattpocock/skills/improve-codebase-architecture --agent claude-code -y
bunx skills@latest add mattpocock/skills/request-refactor-plan --agent claude-code -y
bunx skills@latest add mattpocock/skills/design-an-interface --agent claude-code -y
```

### 3. Final verification

After all skills complete:

- [ ] `.claude/settings.json` has all hooks configured
- [ ] `biome.jsonc` exists
- [ ] `rsbuild.config.ts` has React Compiler plugin
- [ ] Package.json has all scripts: `lint`, `lint:fix`, `lint:file`, `lint:fix:file`, `type:check`, `test`, `quality:gate`
- [ ] `.github/workflows/quality-gate.yml` exists
- [ ] All hook scripts in `.claude/hooks/` are executable
- [ ] zustand-check.sh catches single-parens create and inline object selectors
- [ ] accessibility-check.sh catches missing alt, clickable divs without keyboard support
- [ ] react-rules-check.sh catches raw HTML, `as any`, inline style, raw hex colors
- [ ] env-validation-check.sh blocks raw `process.env.` access
- [ ] logging-check.sh blocks `console.error` in non-test files
- [ ] conventional-commits-check.sh blocks commits without `type(scope):` format
- [ ] `src/env.ts` exists with t3-env zod schema
- [ ] `src/lib/logger.ts` exists with Pino config
- [ ] All community skills installed: `tdd`, `triage-issue`, `improve-codebase-architecture`, `request-refactor-plan`, `design-an-interface`

### 4. Commit

Stage everything and commit: `Bootstrap frontend starter kit`
