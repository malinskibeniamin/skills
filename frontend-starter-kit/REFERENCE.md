# Frontend Starter Kit Reference

## Canonical Stack (owner-provided, 2026-07-09)

The `full` profile targets this stack. Every enforcement hook and reference assumes these choices unless the repo proves otherwise.

| Layer | Choice | Enforced / guided by |
|---|---|---|
| UI runtime | React 19 (Compiler on) | react-compiler, react-rules |
| Bundler | Rsbuild | quality-gate (bundle guard), toolchain |
| Styling | Tailwind (design tokens) | tailwind-check hook, CLAUDE.md |
| Type checking | TypeScript 7 + `tsc` | toolchain |
| Lint/format | Biome + Ultracite | biome (owns single-element a11y rules) |
| Unit/integration tests | Vitest + happy-dom + React Testing Library | quality-gate, test conventions |
| Browser/E2E tests | Vitest browser mode + Playwright | e2e-testing |
| Navigation | TanStack Router | tanstack-router |
| REST data | TanStack Query | connect-query reference (query patterns) |
| gRPC data | @bufbuild/protobuf + Connect Query | connect-query |
| Forms | react-hook-form + @bufbuild/protovalidate + @bufbuild/cel + @standard-schema/spec | form-mode + error-boundary hooks, connect-query |
| Schema validation (non-proto) | Zod | env-validation (t3-env + zod) |
| Client state | Zustand (when context is not enough) | zustand |
| Component layer | shadcn + Base UI | registry-workflow |
| Charts | Recharts v3+ | registry-workflow taxonomy |
| Syntax highlighting | ShikiJS v4+ | -- (React.lazy heavy dep rule) |
| Flow canvas | XYFlow React | -- (React.lazy heavy dep rule) |
| Dates | date-fns + react-day-picker | CLAUDE.md light-dep list |
| Toasts | sonner | error-handling rules (formatToastErrorMessageGRPC) |

Not in the stack (do not introduce): Next.js, react-router-dom, Radix as new dependency (Base UI is the headless layer), moment/dayjs, Jest, ESLint/Prettier, npm/yarn/pnpm as package runner.

## Full Skill Inventory

### Setup Skills (14) -- configure hooks + packages

| # | Skill | Hook type | What enforce |
|---|---|---|---|
| 1 | toolchain | PreToolUse, SessionStart | bun, TypeScript 7 `tsc`, no npm/npx/tsgo |
| 2 | biome | Stop | Biome + Ultracite lint/format |
| 3 | quality-gate | Stop, PostToolUse | `tsc`, related tests, bundle guard |
| 4 | agent-config | SessionStart, PreToolUse, PostToolUse, UserPromptSubmit | AI_AGENT, output truncation, context injection |
| 5 | react-compiler | PostToolUse | Ban manual memoization (if compiler installed) |
| 6 | zustand | PostToolUse | Double-parens, useShallow, persist |
| 7 | accessibility | PostToolUse | ARIA, keyboard nav, alt text |
| 8 | react-rules | PostToolUse | 22+ React/TS/security checks |
| 9 | env-validation | Biome noProcessEnv | Ban raw process.env (lint rule, no hook) |
| 10 | conventional-commits | PreToolUse | Commit message format |
| 11 | react-doctor | Stop | Introduced blocking diagnostics |
| 12 | tanstack-router | PostToolUse | Route tree, anti-patterns |
| 13 | connect-query | PostToolUse | ConnectRPC, protobuf v2 |
| 14 | e2e-testing | -- | Playwright, Testcontainers, axe-core |

### Owned Workflow Skills -- hook-integrated, auto-load via paths:

| Skill | Replaces | Key feature |
|---|---|---|
| tdd | mattpocock/tdd (incorporated) | TDD iron law + async leak detection + deep modules |
| triage | mattpocock/triage (incorporated, multi-tracker GH+Jira) | State-machine triage + bug root cause -> TDD fix plan |
| diagnosing-bugs | mattpocock/diagnosing-bugs (vendored) | Feedback-loop-first 6-phase debugging |

### Community Workflow Skills -- from mattpocock/skills

prototype, to-questionnaire, to-spec, to-tickets, writing-for-agents

## Install Order

1. Setup skills 1-14 (sequential, idempotent)
2. Owned workflow skills (5 installs)
3. Community skills
4. Set `REACT_RULES_BAN_USEEFFECT=1` in session env
5. Run `bun run quality:gate` verify

## Hook Architecture

```
SessionStart (2)     -> env vars, /tmp cleanup
UserPromptSubmit (2) -> project state + intent detection
PreToolUse (3)       -> toolchain, test flags, commits
PostToolUse (11)     -> 10 Edit|Write checks + 1 Bash truncation
Stop (6)             -> biome, typecheck, react-doctor, registry, orchestration, violations
```

Total: 24 hooks. PostToolUse parallel (~80ms wall clock).
