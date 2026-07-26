# Project Rules

Lean by design: only rules that are neither machine-enforced nor inferable. Hooks, Biome (ultracite), and React Doctor teach at violation time; path-scoped skills (accessibility, connect-query, tanstack-router, e2e-testing, ux-copy, registry-workflow) auto-load the deep guidance. Do not re-add enforced rules here.

## Toolchain

`bun` pkg | TypeScript 7 `tsc` typecheck | Biome lint/fmt | React Doctor (Stop hook) React patterns | `--force-with-lease` | safe rm: node_modules dist .next build .cache .turbo coverage
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
3. **Implement** -- `/tdd` every file, `/deslop` write mode ON for the whole session (both runtimes): ladder before every line. Fail first -> pass -> refactor. Match the shape of the matching `exemplars/` file
4-6. **`/go`** -- verify -> self-review + cross-model review -> `/simplify` -> `/deslop` -> `/commit-push-pr` -> monitor CI -> fix -> done

Alias: `/work` = full lifecycle. `/go` = phase 4-6 (ship tail).

### Effort + model routing

Default `high`. Fable-5: `high` or lower ONLY (`xhigh`/`max` furnaces, worse output). Never inject `ultrathink`.

Rank cost/intel/taste (1-10 higher better; cost = pay): Fable-5 1/10/9 | Opus-5 5/8/9 | Sonnet-5 6/5/5 | GPT-5.6 Sol (codex) 8/9/6 | GPT-5.6 Terra 9/6/5 | GPT-5.6 Luna 10/3/2. Taste = UI/UX, code quality, API, copy. GPT-5.5 retired (5.6 GA).

Model character: Sol = ultimate robot/tool/AI assistant, efficient exhaustive instruction-following, turn every stone | Fable = smartest, broadest, best frontend and gorgeous visible code; extremely complex work plus initial sketches/wireframes/prototypes before cheaper execution | Opus = low-harness default with Fable-like taste, less intelligence, lower cost.

GPT-5.6 variants (effort floors are hard): **Sol** = the workhorse -- actual implementation at `xhigh`, Opus-work adversarial review at `high`, plan and Sol-only review at `xhigh`. **Terra** = budget non-code work -- posting PR comments and test-runner/CI chores at `medium`|`high`; never product code or review. **Luna** = last resort for cheap tool loops far from code at `high`; never development or review.

Claude taste quota ladder (higher of 5h/7d): 0-20% Fable high | 21-35% Fable medium | 36-50% Fable low | 51-75% Opus xhigh | 76-90% Opus medium | 91-95% Opus low | 96-100% or missing/stale no Claude. Re-check `/stay-within-limits` before every wave and every Claude review dispatch; never reuse a review profile.

Ships -> intelligence > taste > cost (tiebreaker) | below bar -> rerun smarter, don't ask | user-facing -> taste >= 7 | token furnaces -> codex | **implementation pair**: when Claude enabled, Opus 5 xhigh + Sol xhigh in isolated/non-overlapping lanes; without Claude, Sol xhigh only | **Cross-model review, automatic on every non-trivial change**: author model never solely reviews its own work; use a DIFFERENT family; fresh Sol high adversarial review checks Opus work, and Opus 5 xhigh feedback checks Sol implementation; without Claude, clean-context Sol xhigh owns all hats; P0-P3 fix per routing, cross re-check | **NEVER Haiku** | GPT via `/codex` CLI only | Claude via per-invocation `model` + `effort`.

### Monitor (not sleep)

`Bash(run_in_background)` + `Monitor` stream output:
CI: `gh pr checks <n> --watch` | dev server | vitest watcher | container log | build output

## Auto-Generated (never edit)

`*.gen.ts`/`*.gen.tsx` | `*_pb.ts`/`*_pb.js` | `*_connectquery.ts` | `@generated`/`DO NOT EDIT` first 5 line
