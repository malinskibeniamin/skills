# Project Rules

Lean by design: only rules that are neither machine-enforced nor inferable. Hooks, Biome (ultracite), and React Doctor teach at violation time; path-scoped skills (accessibility, connect-query, tanstack-router, e2e-testing, ux-copy, registry-workflow) auto-load the deep guidance. Do not re-add enforced rules here.

## Toolchain

`bun` pkg | `tsgo` typecheck | Biome lint/fmt | React Doctor (Stop hook) React patterns | `--force-with-lease` | safe rm: node_modules dist .next build .cache .turbo coverage
External services via CLI, not MCP: Jira `acli` | Google `gog` | browser `agent-browser` | CI `gh` | Buildkite `bk` | Box `box` | M365 `m365`

## Code Quality

Code is liability: keep additions only for product value, defensive correctness, or test confidence | delete/inline before abstract | `bun run lint:fix` + `bun run type:check` pre-done

## Stack conventions (chosen, not inferable)

- UI: `@/components/ui/` registry first, `<Button>` for every button, variant props + design tokens (`bg-primary`, `var(--destructive)`) -- fix specificity at source, never restyle registry components inline
- State: zustand = client, TanStack Query = server, connect-query for ConnectRPC | env via `@/env` (t3-env+zod, declare in `src/env.ts`)
- Proto: enums by name, never magic numbers | Functional components only (Compiler)
- Validate format, not presence: URL regex, enum membership, UPPER_SNAKE patterns
- Tests: `.test.ts` unit | `.test.tsx` integration | `.browser.test.tsx` visual | `e2e/*.spec.ts` Playwright | co-locate with source

## Lifecycle (MANDATORY -- hooks enforce)

Order every task. Hooks block skipped steps.

1. **Understand** -- explore, one question at time, propose
2. **Plan** -- exact path, code, expect output
3. **Implement** -- `/tdd` every file. Fail first -> pass -> refactor
4-6. **`/go`** -- verify -> self-review + cross-model review -> `/simplify` -> `/deslop` -> `/commit-push-pr` -> monitor CI -> fix -> done

Alias: `/work` = full lifecycle. `/go` = phase 4-6 (ship tail).

### Effort + model routing

Default `high`. Fable-5: `high` or lower ONLY (`xhigh`/`max` furnaces, worse output). Never inject `ultrathink`.

Rank cost/intel/taste (1-10 higher better; cost = pay): Fable-5 1/10/9 | Opus-4.8 4/7/8 | Sonnet-5 6/5/7 | GPT-5.6 (codex) 8/9/6. Taste = UI/UX, code quality, API, copy. GPT-5.5 retired (5.6 GA).

Ships -> intelligence > taste > cost (tiebreaker) | below bar -> rerun smarter, don't ask | bulk mechanical -> codex GPT-5.6, free | user-facing -> taste >= 7 | review/plan -> Fable-5/Opus-4.8 | token furnaces -> codex | **thinker/executor split**: Fable/frontier thinks, tastes, plans; GPT-5.6 executes; smart model reviews diff | **Cross-model review, automatic on every change**: author model never solely reviews its own work -- Claude wrote -> GPT-5.6 reviews; GPT wrote -> Fable/Opus (clean GPT-5.6 OK); P0-P3 fix per routing, cross re-check | **NEVER Haiku** | GPT via `/codex` CLI only | Claude via `model` param.

### Monitor (not sleep)

`Bash(run_in_background)` + `Monitor` stream output:
CI: `gh pr checks <n> --watch` | dev server | vitest watcher | container log | build output

## Auto-Generated (never edit)

`*.gen.ts`/`*.gen.tsx` | `*_pb.ts`/`*_pb.js` | `*_connectquery.ts` | `@generated`/`DO NOT EDIT` first 5 line
