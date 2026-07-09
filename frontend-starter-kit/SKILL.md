---
name: frontend-starter-kit
description: Bootstrap the frontend stack -- toolchain, lint, quality gates, React/router/data enforcement, CI -- from lazy reference docs. Use when starting a frontend project, setting up any single tool, or exporting the harness to a bare repo.
argument-hint: "[profile: full | minimal | redpanda | <tool name>]"
---

# Frontend Starter Kit

One skill owns all bootstrap work. Each tool's install steps live in
`references/<tool>/README.md` (plus `SETUP.md`/`REFERENCE.md` where present) -- read them
lazily, only for the profile requested. All steps are idempotent.

Plugin consumers already have every hook shipped and wired -- for them the hook-copy steps
are no-ops; run the config/tooling steps only. The full copy matters for bare repos without
the plugin ("export harness").

## Profiles

- **full** (default): every tool below, in order, targeting the canonical stack in
  [REFERENCE.md](REFERENCE.md) (React 19 + Rsbuild + Tailwind + TanStack Router/Query +
  Connect Query + shadcn/Base UI + Vitest/Playwright + Biome/Ultracite + tsgo).
- **minimal**: toolchain, biome, quality-gate, env-validation, conventional-commits.
- **redpanda**: full + `references/redpanda/README.md` (registry workflow, Redpanda component
  taxonomy, `REDPANDA_KIT=1`).
- **`<tool>`**: just that tool's reference.

## Tools (sequential for full)

| Tool | Reference | What it sets up |
|---|---|---|
| toolchain | `references/toolchain/` | bun + tsgo enforcement, destructive command guards |
| biome | `references/biome/` | Biome + Ultracite, auto-fix hook |
| quality-gate | `references/quality-gate/` | quality:gate script, CI workflow, Stop hook, bundle guard |
| agent-config | `references/agent-config/` | AI_AGENT=1, output truncation |
| react-compiler | `references/react-compiler/` | React Compiler + memoization check |
| zustand | `references/zustand/` | double-parens create, useShallow, persist |
| react-rules | `references/react-rules/` | ban raw HTML, TS escapes, XSS, barrel imports |
| env-validation | `references/env-validation/` | t3-env + zod, ban process.env |
| conventional-commits | `references/conventional-commits/` | type(scope): description enforcement |
| react-doctor | `references/react-doctor/` | health scoring + Stop hook |
| ci-pipeline | `references/ci-pipeline/` | GitHub Actions CI, coverage gates, caching |
| redpanda | `references/redpanda/` | Redpanda registry workflow + component taxonomy |

Runtime-guidance skills (daily work, not setup): `/accessibility`, `/tanstack-router`,
`/connect-query`, `/e2e-testing`, `/registry-workflow`, `/ux-copy`. Optional infra:
`/setup-routines`, `/setup-atlassian-workflow` (slash-only).

## Steps

1. Confirm the profile (default full). Read each tool's reference lazily as you reach it.
2. Set `REACT_RULES_BAN_USEEFFECT=1` in session-env.sh when the repo wants strict effects.
3. Workflow skills (development-lifecycle, tdd, grilling, triage,
   diagnosing-bugs, prototype, domain-modeling) ship with this plugin -- nothing to install.

## Verify

- [ ] `.claude/settings.json` has all hooks, `biome.jsonc` + `src/env.ts` exist
- [ ] Scripts: lint, lint:fix, type:check, test, quality:gate
- [ ] `.github/workflows/quality-gate.yml` exists, all hooks executable
