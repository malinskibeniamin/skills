# Project Rules

## Quick Ref (every turn)

bun tsgo biome vitest | Compiler memoizes | fix types (guards, generics) | `@/components/ui/` | `<Button>` always | zustand `create<T>()()` `useShallow` | `@/env` | TanStack Router | connect-query | TDD: fail first

## Toolchain

`bun` pkg mgr | `tsgo` typecheck | Biome lint/fmt | `--force-with-lease` | safe rm: node_modules dist .next build .cache .turbo coverage

## Commits

`type(scope): description` -- feat fix refactor style test docs chore perf ci build revert -- scope required -- lowercase, 5-72 chars

## Code Quality

`bun run lint:fix` + `bun run type:check` before finish | lightweight deps: date-fns lodash-es clsx

## React

- Functional only (Compiler) | `@/components/ui/` | DOMPurify for user HTML
- `JSON.parse()` data, `textContent` text, `setHTML` safe HTML
- Fix types: guards, generics, schema -- no `as any`/`as never`/`biome-ignore noExplicitAny`
- `focus-visible:ring-*` not outline:none | Compiler memoizes -- no `useMemo`/`useCallback`/`React.memo`
- `aria-label` icon-only `<Button>` | every `<Button>`: `onClick`/`asChild`/`type="submit"`/`disabled`
- `<Link>` nav | direct imports (tree-shake) | `{ passive: true }` scroll/touch/wheel
- `React.lazy()` heavy deps | `structuredClone()` deep clone | `.requestSubmit()` forms
- `.filter()`/`Array.with()` remove | `Number()`/`parseInt(s,10)` | `Number.isNaN()`
- `<Button>` clickable elements | functions to `setTimeout` | name useEffect: `useEffect(function syncX(){...},[deps])`
- Form mode: `onChange` only | field validation required | errors inline via FormMessage
- Hooks in `/hooks/`, not route files | routes >300 LOC -> `/request-refactor-plan`
- No `window.location` -- router/env | side-effects: `useMutation` not raw fetch
- No `throw new Error()` ConnectRPC -- `ConnectError.from()` | proto enums not magic numbers
- `useWatch()` not `form.watch()` | spread `...field` RHF | `mutate()` needs `onError`
- `ConnectError.from(error)` + `formatToastErrorMessageGRPC()` | `*Mutation` suffix
- No `@redpanda-data/ui` -- registry | no direct `lucide-react` -- `components/icons`
- No inline `staleTime`/`gcTime` -- named constants

## Tailwind

Utility classes | design tokens `var(--destructive)` `bg-primary` | fix specificity at source | variant prop registry components | `100dvh` | `width:100%` | keep user-scalable (WCAG 1.4.4)

## Env Vars

`@/env` (t3-env+zod) | declare in `src/env.ts` | `process.env` OK in build/test configs only

## A11y

`<img>` needs `alt` | clickable div/span: `role` `tabIndex` kbd handler | combobox: `aria-expanded`+`aria-controls` | dialog: `aria-label`/`aria-labelledby` | tablist needs tab children | disabled `<Button>`: wrap `<Tooltip>` why | `aria-invalid` needs `aria-describedby` | no nested interactives

## Zustand

`create<T>()()` | `useShallow` multi-selectors | `persist` local storage

## State & Data

zustand client, TanStack Query server | connect-query for ConnectRPC (except `useTransport`/`callUnaryMethod`) | Protobuf v2: `create(Schema,{...})` schema-first | `timestampFromDate()` Timestamp | `anyPack()` Any+`typeRegistry` | `handleSubmit(onSubmit, onError)` | FieldMask: `Object.keys(dirtyFields)` never hardcode | `invalidateQueries` > `refetchQueries` -- always `await` | new files need tests -- `/tdd`

## Lifecycle (MANDATORY -- hooks enforce)

Order every task. Hooks block skipped steps.

1. **Understand** -- explore, one question at time, propose
2. **Plan** -- exact paths, code, expected output
3. **Implement** -- `/tdd` every file. Fail first -> pass -> refactor
4-6. **`/go`** -- verify -> self-review -> `/simplify` -> `/commit-push-pr` -> monitor CI -> fix -> done

Aliases: `/work` = `/development-lifecycle` (full). `/go` = phases 4-6 (ship tail).

### Effort per phase (Opus 4.7 `xhigh` tier)

Downsized one level from prior xhigh/max mix. 4.7 hits diminishing returns
at max for most phases -- keep max/xhigh reserved for the final gates.

| Phase | Effort | Reason |
|---|---|---|
| 1 Understand | `high` | Exploration needs real synthesis |
| 2 Plan / Grill | `high` | Trade-off judgment |
| 3 Implement (TDD) | `xhigh` | Type-safety + correctness -- highest stakes |
| 4 Simplify | `high` | Pattern recognition |
| 5 Verify | `high` | Judgment on edge-case coverage |
| 5 Review (security/arch) | `xhigh` | Final gate |

### Monitor (not sleep)

`Bash(run_in_background)` + `Monitor` stream output:
CI: `gh pr checks <n> --watch` | dev server | vitest watcher | container logs | build output

## UX Copy

Sentence case | no Latin abbrev (for example, that is, and so on, through) | no ableist lang | they/them

## Tests

Fail first -> pass | `userEvent.setup()` + `getByRole` | `await waitFor(()=>expect(...))` async | `.test.ts` unit `.test.tsx` integration `.browser.test.tsx` visual `e2e/*.spec.ts` Playwright | co-locate | `test()` not `it()` | `vi.fn()`/`vi.mock()`/`vi.spyOn()` | `.toBeVisible()` > `.toBeInTheDocument()` | no `waitForTimeout` | no `test.skip` E2E (`test.fixme()` known bugs) | `createRouterTransport` ConnectRPC mocks | `data-testid` interactives | `test.step()` Playwright

## Logging

Structured JSON | requestId/traceId all entries | log at decision points | named levels per module | never log secrets/PII

## Error Handling

### Boundaries
Route+loader -> `errorComponent` (hook) | `React.lazy()` in `<Suspense>` | handle loading+error+empty | error handling async handlers

### Catch -- Never Swallow
Every catch: set error state / re-throw / error handler | no silent fallbacks | no log-only UI -- user sees feedback | parse errors: early return error UI | `if (parseError) return <ErrorState />`

### Validation
Format not just presence | UPPER_SNAKE validate pattern | new union variants: handle or fail loud | exhaustive: `default: never`/`satisfies never` | error types match resolver contract

### Async Errors
`onChange` async: `AbortController` cancel stale | `mutate()` needs `onError` (hook) | `Promise.all` independent, `Promise.allSettled` partial-fail OK -- no fire-and-forget

### Form Error UX
Show ALL errors not first | `aria-invalid` + `aria-describedby` (hook) | `data-invalid` != `aria-invalid` | disabled submit: `<Tooltip>` why (hook) | URL: `type="url"` (hook) | secrets: `type="text"` when verifying format

### State Consistency
Oneof fields: clear prev branch on switch | auth/config separate from form state -- single source or sync | FieldMask `paths`: `Object.keys(dirtyFields)` (hook)

## Auto Mode

Deny rules mirror `enforce-toolchain.sh` | test `bunx skills:*` allow rule | admin: `autoMode.environment` whitelist | `claude auto-mode defaults` schema | plan->approve->auto natural fit

## Auto-Generated (skip)

`*.gen.ts`/`*.gen.tsx` | `*_pb.ts`/`*_pb.js` | `*_connectquery.ts` | `@generated`/`DO NOT EDIT` first 5 lines
