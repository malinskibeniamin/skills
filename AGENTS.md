# Project Rules

Lean by design: only rules that are neither machine-enforced nor inferable. Per-call hooks, Biome (ultracite), and React Doctor teach at violation time; skills carry the deep guidance. Do not re-add enforced rules here.

## Toolchain

bun (pkg mgr) | tsgo (type check) | Biome (lint/format) | React Doctor (Stop hook, React patterns) | --force-with-lease for force pushes
Safe rm -rf: node_modules, dist, .next, build, .cache, .turbo, coverage
External services via CLI, not MCP: Jira acli | Google gog | browser agent-browser | CI gh | Buildkite bk | Box box | M365 m365

## Commits

`type(scope): description` -- feat|fix|refactor|style|test|docs|chore|perf|ci|build|revert. Scope required. Lowercase, 5-72 chars.

## Code Quality

Code is liability: keep additions only for product value, defensive correctness, or test confidence. Delete/inline before abstract. Run `bun run lint:fix` + `bun run type:check` before finish.

## Stack conventions (chosen, not inferable)

- UI: `@/components/ui/` registry first, `<Button>` for every button, variant props + design tokens (`bg-primary`) -- fix specificity at source, never restyle registry components inline
- State: zustand = client, TanStack Query = server, connect-query for ConnectRPC. Env via `@/env` (t3-env+zod, declared in `src/env.ts`; `process.env` only in build/test configs)
- Proto: enums by name, never magic numbers. Functional components only (React Compiler)
- Validate format, not presence: URL regex, enum membership, UPPER_SNAKE patterns
- Tests: .test.ts=unit, .test.tsx=integration, .browser.test.tsx=visual, e2e/*.spec.ts=Playwright. Co-locate with source

## Lifecycle

1. Understand -> 2. Plan -> 2b. `/grilling` (interview -> 3-hat gate -> CONTEXT.md/ADR capture via `/domain-modeling`) -> 3. TDD (RED->GREEN->REFACTOR) -> 4-6. `/go` (verify -> self-review + cross-model review -> `/simplify` -> `/deslop` -> `/commit-push-pr` -> monitor CI -> fix -> done). Hard bug? `/diagnosing-bugs` (feedback-loop-first 6-phase). Bug to ticket? `/triage` (GH or Jira).

Aliases: `/work` = `/development-lifecycle` (full). `/go` = phases 4-6 (ship tail).

Effort: default high. Fable-5: high or lower only (xhigh token-hungry; max a furnace with worse output).

Subagent model routing (rankings 1-10, higher better; cost = actual pay): Fable-5 cost 1 / intelligence 10 / taste 9; Opus-4.8 4/7/8; Sonnet-5 6/5/7; GPT-5.6 (codex) 8/9/6. GPT-5.5 retired -- 5.6 GA, strictly better. Ships -> intelligence > taste > cost (cost tiebreaker only). Defaults not limits: cheap output below bar -> rerun with a smarter model without asking. Bulk mechanical (clear-spec implementation, data analysis, migrations) -> codex GPT-5.6 (plan allowance -- cheap, not free). User-facing (UI/copy/API design) -> taste >= 7. Review/plan -> Fable-5 or Opus-4.8, plus GPT-5.6 independent pass. Computer use + token furnaces -> codex GPT-5.6, report back. Thinker/executor split: Fable/frontier owns thinking, design taste, and the plan; GPT-5.6 executes implementation from that plan; the smart model reviews the diff. Cross-model review, automatic on every change: author model never solely reviews its own work -- Claude authored -> GPT-5.6 adversarial review; GPT-5.6 authored -> Fable/Opus reviews; clean-context GPT-5.6 is an acceptable third perspective; findings P0-P3 -> fixes delegated per routing, re-checked by the cross reviewer. NEVER Haiku. GPT models only via codex CLI (see codex skill); Claude models via the agent model parameter.

## Auto-Generated (never edit)

*.gen.ts/tsx, *_pb.ts/js, *_connectquery.ts, files with @generated/DO NOT EDIT in first 5 lines.
