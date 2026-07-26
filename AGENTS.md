<!-- GENERATED from CLAUDE.md + .agents/codex-appendix.md by scripts/generate-agents-md.sh -- do not edit by hand -->
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

GPT-5.6 variants (effort floors are hard): **Sol** = the workhorse -- smartest model rivaled only by Fable-5; ALL code writing and implementation at `medium`|`high`, every review/plan check at `xhigh`. **Terra** = budget non-code work -- posting PR comments and test-runner/CI chores at `medium`|`high`; never product code or review. **Luna** = last resort for cheap tool loops far from code at `high`; never development or review.

Claude review/plan quota ladder (higher of 5h/7d): <20% Fable low | 20-<50% Opus high | 50-<75% Opus low | 75-<90% Sonnet low | >=90% or missing/stale usage no Claude. Re-check `/stay-within-limits` before every wave. Always add Sol xhigh; if Claude is disabled, Sol owns all required hats.

Ships -> intelligence > taste > cost (tiebreaker) | below bar -> rerun smarter, don't ask | bulk mechanical -> codex Sol (plan allowance) | user-facing -> taste >= 7 | token furnaces -> codex | **thinker/executor split**: frontier thinks, tastes, plans; Sol executes | **Cross-model review, automatic on every non-trivial change**: author model never solely reviews its own work; use a DIFFERENT family when available; Claude profile + Sol xhigh, or Sol-only complete coverage; P0-P3 fix per routing, cross re-check | **NEVER Haiku** | GPT via `/codex` CLI only | Claude via per-invocation `model` + `effort`.

### Monitor (not sleep)

`Bash(run_in_background)` + `Monitor` stream output:
CI: `gh pr checks <n> --watch` | dev server | vitest watcher | container log | build output

## Auto-Generated (never edit)

`*.gen.ts`/`*.gen.tsx` | `*_pb.ts`/`*_pb.js` | `*_connectquery.ts` | `@generated`/`DO NOT EDIT` first 5 line

## Codex-specific

### Commits

`type(scope): description` -- feat|fix|refactor|style|test|docs|chore|perf|ci|build|revert. Scope required. Lowercase, 5-72 chars. (Codex has no conventional-commits deny hook on every event; state the format here.)

### Runtime notes

- Hooks arrive per-call (no PostToolBatch); behavior is generated to parity from skill-manifest.json.
- `process.env` allowed only in build/test configs; app code goes through `@/env`.
- Subagent output enforcement is best effort; follow `agents/references/findings-schema.md` for review findings.

### Native delegation

- In native Codex, do not spawn subagents or start a recursive `codex exec` unless the user explicitly requests subagents, delegation, parallel agent work, or invokes `/swarm`. Skill activation alone is not consent. `/work`, `/go`, `/review`, `/grilling`, `/resilience-review`, and `/plow-ahead` do not grant it.
- Without consent, run required review and planning axes inline in the root context. Report them as inline, never independent or cross-family. Parallel shell and tool calls remain allowed.
- Spawned agents may not create descendants without separate authorization for nested delegation.
- Preserve the user's selected model and reasoning effort. Do not rewrite Codex config or enable experimental multi-agent flags as part of this policy.

### Native stop boundaries

- Honor any user-supplied earlier stop point. Otherwise, stop after plan and grilling before edits; after implementation approval, stop after opening the PR, handling the first automated review/fix pass, and taking one CI status snapshot.
- `/plow-ahead` may waive milestone stops, but it is not delegation consent. Do not poll for later human feedback unless the user asks.
- `ccusage` token/cost reports are not Codex subscription-quota evidence. Use a host meter or user-reported value; otherwise usage is unknown and report `Codex usage unavailable to the harness`. Never infer quota from session tokens. Do not guess reset time. Sol xhigh review/plan checks remain ungated; other unknown-usage agent waves checkpoint after one explicitly requested wave.
