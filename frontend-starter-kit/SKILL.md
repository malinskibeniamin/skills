---
name: frontend-starter-kit
description: Bootstrap the frontend toolchain, lint, quality gates, React stack, data stack, and CI.
disable-model-invocation: true
argument-hint: "[profile: full | minimal | redpanda | <tool name>]"
---

One skill owns bootstrap. Lazily read only requested `references/<tool>/README.md` plus linked setup/reference. Steps are idempotent. Plugin hook copies are no-ops. Bare repos need export-harness copies.

## Profiles

- **full** default: ordered canonical stack from [REFERENCE.md](REFERENCE.md): React 19, Rsbuild, Tailwind, TanStack Router/Query, Connect Query, shadcn/Base UI, Vitest/Playwright, Biome/Ultracite, TypeScript 7 `tsc`.
- **minimal:** toolchain, biome, quality gate, env validation, conventional commits.
- **redpanda:** full plus `references/redpanda/README.md`, taxonomy, `REDPANDA_KIT=1`.
- **`<tool>`:** only that reference.

## Full order

| Tool | Purpose |
|---|---|
| `toolchain` | `references/toolchain/`: bun, TypeScript 7 `tsc`, destructive-command guards |
| `tanstack-intent` | version-matched guidance/edit gates |
| `biome` | Biome, Ultracite, auto-fix hook |
| `quality-gate` | script, CI, Stop hook, bundle guard |
| `agent-config` | `AI_AGENT=1`, output truncation |
| `react-compiler` | Compiler, memoization check |
| `zustand` | `create<T>()()`, `useShallow`, persist |
| `react-rules` | raw HTML, TS escape, XSS, barrel bans |
| `env-validation` | t3-env/zod, `noProcessEnv` |
| `conventional-commits` | `type(scope): description` |
| `react-doctor` | changed-diagnostic gate, Stop hook |
| `ci-pipeline` | Actions, coverage, cache |
| `redpanda` | registry workflow/taxonomy |

Runtime skills, not setup: `/accessibility`, `/tanstack-router`, `/connect-query`, `/e2e-testing`, `/registry-workflow`, `/ux-copy`. Optional slash-only infra: `/setup-routines`, `/setup-atlassian-workflow`. Existing Biome or Oxlint repositories can opt into type-evidence rules through `/install-anti-slop`.

## Steps

1. Confirm profile; for full, process the table sequentially and lazily.
2. Set `REACT_RULES_BAN_USEEFFECT=1` only for repos choosing strict effects.
3. Workflow skills already ship in the plugin; install nothing extra.

## Verify

- `.claude/settings.json` has hooks, including TanStack Intent when packages exist; `biome.jsonc` and `src/env.ts` exist.
- Scripts: lint, lint:fix, type:check, test, quality:gate.
- `.github/workflows/quality-gate.yml` exists; hooks executable.
