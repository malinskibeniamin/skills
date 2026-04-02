# Frontend Starter Kit Reference

## Full Skill Inventory

### Setup Skills (14) — configures hooks + packages

| # | Skill | Hook type | What it enforces |
|---|---|---|---|
| 1 | setup-toolchain | PreToolUse, SessionStart | bun, tsgo, no npm/npx/tsc |
| 2 | setup-biome | Stop | Biome + Ultracite lint/format |
| 3 | setup-quality-gate | Stop, PostToolUse | tsgo, related tests, bundle guard |
| 4 | setup-llm-optimization | SessionStart, PreToolUse, PostToolUse, UserPromptSubmit | AI_AGENT, output truncation, context injection |
| 5 | setup-react-compiler | PostToolUse | Ban manual memoization (if compiler installed) |
| 6 | setup-zustand | PostToolUse | Double-parens, useShallow, persist |
| 7 | setup-accessibility | PostToolUse | ARIA, keyboard nav, alt text |
| 8 | setup-react-rules | PostToolUse | 22+ React/TS/security checks |
| 9 | setup-env-validation | PostToolUse | Ban raw process.env |
| 10 | setup-conventional-commits | PreToolUse | Commit message format |
| 11 | setup-react-doctor | Stop | Health score regression |
| 12 | setup-tanstack-router | PostToolUse | Route tree, anti-patterns |
| 13 | setup-connect-query | PostToolUse | ConnectRPC, protobuf v2 |
| 14 | setup-e2e-testing | — | Playwright, Testcontainers, axe-core |

### Owned Workflow Skills (5) — hook-integrated, auto-load via paths:

| Skill | Replaces | Key feature |
|---|---|---|
| test-driven-development | mattpocock/tdd + test-guardian | TDD iron law + async leak detection |
| systematic-debugging | mattpocock/triage-issue | 4-phase root cause analysis |
| writing-plans | mattpocock/prd-to-plan | "Junior engineer" detail level |
| requesting-code-review | — (new) | Two-stage review + codex adversarial |
| brainstorming | — (new) | Design + challenge modes |

### Community Workflow Skills (10) — from mattpocock/skills

improve-codebase-architecture, request-refactor-plan, design-an-interface, write-a-prd, prd-to-issues, write-a-skill, grill-me, qa, ubiquitous-language, git-guardrails-claude-code

## Install Order

1. Setup skills 1–14 (sequential, idempotent)
2. Owned workflow skills (5 installs)
3. Community skills (10 installs)
4. Set `REACT_RULES_BAN_USEEFFECT=1` in session env
5. Run `bun run quality:gate` to verify

## Hook Architecture

```
SessionStart (2)     → env vars, /tmp cleanup
UserPromptSubmit (2) → project state + intent detection
PreToolUse (3)       → toolchain, test flags, commits
PostToolUse (11)     → 10 Edit|Write checks + 1 Bash truncation
Stop (6)             → biome, typecheck, react-doctor, registry, orchestration, violations
```

Total: 24 hooks. PostToolUse runs in parallel (~80ms wall clock).
