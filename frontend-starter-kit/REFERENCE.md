# Frontend Starter Kit Reference

## Full Skill Inventory

### Setup Skills (14) -- configure hooks + packages

| # | Skill | Hook type | What enforce |
|---|---|---|---|
| 1 | toolchain | PreToolUse, SessionStart | bun, tsgo, no npm/npx/tsc |
| 2 | biome | Stop | Biome + Ultracite lint/format |
| 3 | quality-gate | Stop, PostToolUse | tsgo, related tests, bundle guard |
| 4 | agent-config | SessionStart, PreToolUse, PostToolUse, UserPromptSubmit | AI_AGENT, output truncation, context injection |
| 5 | react-compiler | PostToolUse | Ban manual memoization (if compiler installed) |
| 6 | zustand | PostToolUse | Double-parens, useShallow, persist |
| 7 | accessibility | PostToolUse | ARIA, keyboard nav, alt text |
| 8 | react-rules | PostToolUse | 22+ React/TS/security checks |
| 9 | env-validation | PostToolUse | Ban raw process.env |
| 10 | conventional-commits | PreToolUse | Commit message format |
| 11 | react-doctor | Stop | Health score regression |
| 12 | tanstack-router | PostToolUse | Route tree, anti-patterns |
| 13 | connect-query | PostToolUse | ConnectRPC, protobuf v2 |
| 14 | e2e-testing | -- | Playwright, Testcontainers, axe-core |

### Owned Workflow Skills -- hook-integrated, auto-load via paths:

| Skill | Replaces | Key feature |
|---|---|---|
| tdd | mattpocock/tdd (incorporated) | TDD iron law + async leak detection + deep modules |
| triage | mattpocock/triage (incorporated, multi-tracker GH+Jira) | State-machine triage + bug root cause -> TDD fix plan |
| diagnosing-bugs | mattpocock/diagnosing-bugs (vendored) | Feedback-loop-first 6-phase debugging |
| brainstorming | -- (owned) | Design + challenge modes |

### Community Workflow Skills -- from mattpocock/skills

improve-codebase-architecture, prototype, to-spec, to-tickets, writing-great-skills

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