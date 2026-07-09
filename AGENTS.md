# Project Rules

## Quick Reference

Rules: bun tsgo biome vitest | React Compiler handles memoization | fix types properly (type guards, generics) | UI from @/components/ui/ | <Button> for all buttons | zustand:create<T>()() useShallow | env from @/env | TanStack Router for routing | connect-query for data fetching | TDD: failing test first, always

## Toolchain

bun (pkg mgr) | tsgo (type check) | Biome (lint/format) | --force-with-lease for force pushes
Safe rm -rf: node_modules, dist, .next, build, .cache, .turbo, coverage

## Commits

`type(scope): description` -- feat|fix|refactor|style|test|docs|chore|perf|ci|build|revert. Scope required. Lowercase, 5-72 chars.

## Code Quality

Code is liability: keep additions only for product value, defensive correctness, or test confidence. Delete/inline before abstract. Run `bun run lint:fix` + `bun run type:check` before finish.

## React

- Functional components only (React Compiler require)
- `@/components/ui/` for all form/interactive UI
- DOMPurify for user HTML. JSON.parse() for data, textContent for text, setHTML for safe HTML
- Type guards/generics/schema validation -- no `as any`, no `@ts-ignore`
- `focus-visible:ring-*` not outline. React Compiler handle memo -- remove useMemo/useCallback/React.memo
- `aria-label` on icon buttons. `<Button>` need: onClick|asChild|type="submit"|disabled
- `<Link>` for navigation. Direct source imports (tree-shaking). `{ passive: true }` on scroll/touch/wheel
- `React.lazy()` for heavy deps. `structuredClone()` for cloning. `.requestSubmit()` for forms
- `Number()` or `parseInt(s,10)`. `Number.isNaN()`. Named useEffect callbacks.

## Tailwind

Utility classes. Design tokens (`bg-primary`). Fix specificity at source. variant prop on registry components. `100dvh` for viewport. `width:100%` for containers. Keep user-scalable enabled.

## Env

`import { env } from "@/env"` (t3-env+zod). All vars in `src/env.ts`. Exception: `process.env` in build/test configs.

## Accessibility

`<img>` need alt. Clickable div/span need role+tabIndex+keyboard handler. combobox->aria-expanded+aria-controls. dialog->aria-label/labelledby. tablist->child role="tab".

## Zustand

`create<T>()()` double-parens. `useShallow` for multi-value selectors. `persist` for localStorage.

## State & Data

zustand=client, TanStack Query=server. connect-query for ConnectRPC (exception: useTransport/callUnaryMethod). Proto v2: `create(Schema,{})`, `timestampFromDate()`, `anyPack()` with typeRegistry. `handleSubmit(onSubmit, onError)`.

## Lifecycle

1. Understand -> 2. Plan -> 2b. `/grilling` (interview -> 3-hat gate -> CONTEXT.md/ADR capture via `/domain-modeling`) -> 3. TDD (RED->GREEN->REFACTOR) -> 4-6. `/go` (verify -> self-review -> `/simplify` -> `/deslop` -> `/commit-push-pr` -> monitor CI -> fix -> done). Hard bug? `/diagnosing-bugs` (feedback-loop-first 6-phase). Bug to ticket? `/triage` (GH or Jira).

Aliases: `/work` = `/development-lifecycle` (full). `/go` = phases 4-6 (ship tail).

Effort: default high. Fable-5: high or lower only (xhigh token-hungry; max a furnace with worse output).

Subagent model routing (rankings 1-10, higher better; cost = actual pay): Fable-5 cost 1 / intelligence 10 / taste 9; Opus-4.8 4/7/8; Sonnet-5 6/5/7; GPT-5.6 (codex) 8/9/6. GPT-5.5 retired -- 5.6 GA, strictly better. Ships -> intelligence > taste > cost (cost tiebreaker only). Defaults not limits: cheap output below bar -> rerun with a smarter model without asking. Bulk mechanical (clear-spec implementation, data analysis, migrations) -> codex GPT-5.6 (effectively free). User-facing (UI/copy/API design) -> taste >= 7. Review/plan -> Fable-5 or Opus-4.8, plus GPT-5.6 independent pass. Computer use + token furnaces -> codex GPT-5.6, report back. Thinker/executor split: Fable/frontier owns thinking, design taste, and the plan; GPT-5.6 executes implementation from that plan; the smart model reviews the diff. Cross-model review, automatic on every change: author model never solely reviews its own work -- Claude authored -> GPT-5.6 adversarial review; GPT-5.6 authored -> Fable/Opus reviews; clean-context GPT-5.6 is an acceptable third perspective; findings P0-P3 -> fixes delegated per routing, re-checked by the cross reviewer. NEVER Haiku. GPT models only via codex CLI (see codex skill); Claude models via the agent model parameter.

## UX Copy

Sentence case. No Latin abbreviations (for example, that is, and so on, through). No ableist language. Gender-neutral.

## Tests

Failing test FIRST. `userEvent.setup()` + `getByRole`. `waitFor()` for async. .test.ts=unit, .test.tsx=integration, e2e/*.spec.ts=Playwright. Co-locate with source.

## Resilience

Route data fetching->errorComponent. React.lazy()->`<Suspense fallback>`. Query hooks->loading/error/empty states. Async handlers->error handling.

### Unhappy Paths (enforced by hook)

- **Catch blocks**: set error state, re-throw, or call error handler -- never swallow silent
- **Error + form**: early return with error UI when deserialization/parse fail -- don't render form below broken Alert
- **Validation depth**: check format (URL regex, enum values, UPPER_SNAKE pattern), not just presence/truthiness
- **Exhaustive switch**: `default: never` or `satisfies never` -- new union variants must fail loud
- **Async validation**: onChange + async validator need AbortController or debounce -- no stale race conditions
- **All errors visible**: `errors.map()` not `errors[0]` -- user see every validation failure
- **Oneof/union fields**: clear previous branch values on switch -- ghost data cause silent bugs
- **Form inputs**: URL fields use `type="url"`, secret-ref fields use `type="text"` (user verify format)
- **aria-invalid** on error inputs, not just data-invalid -- screen readers need ARIA

## Auto-Generated (skip)

*.gen.ts/tsx, *_pb.ts/js, *_connectquery.ts, files with @generated/DO NOT EDIT in first 5 lines.
