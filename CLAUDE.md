# Project Rules

## Quick Ref (every turn)

bun tsgo biome vitest | Compiler memoizes | fix types (guards, generics) | `@/components/ui/` | `<Button>` always | zustand `create<T>()()` `useShallow` | `@/env` | TanStack Router | connect-query | TDD: fail first | browser: `agent-browser` / `bunx playwright` (CLI) -- never "no browser tools"

## Toolchain

`bun` pkg mgr | `tsgo` typecheck | Biome lint/fmt | `--force-with-lease` | safe rm: node_modules dist .next build .cache .turbo coverage

## Bash Discipline

`find` -> `-maxdepth N` or `| head` | `git log` -> `-n 30` or `--oneline` | `grep -r` -> Grep tool | `cat` >200 lines -> Read | `llm-truncate` caps 4KB | `bash-verbose-guard` nudges pre-exec | `rtk-rewrite` auto-prefixes git/cargo/test/gh/tsc with `rtk` (60-90% output cut) -- install: `brew install rtk` -- filters: `.rtk/filters.toml`

## External Services (MCP banned -> CLI)

Jira `acli` | Gmail `gws` (not format:full) | Browser `agent-browser` | CI `gh` (Blacksmith runs surface in GH Actions) | Calendar/Drive `gws` | Buildkite `bk` | Box `box` | M365 `m365`. `mcp-ban.sh` denies + shows syntax. MCP 10-25k chars, CLI 100-500.

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
- Proto forms: `useProtoForm` owns state -- no parallel `useState<*Config>` / `useState<*Auth>` (hook)
- `form.setValue(name, v, { shouldDirty: true, shouldValidate: true })` -- options required unless silence intentional (hook)
- Multi-field forms: render `<FormErrorSummary>` / `role="alert"` / `aria-live` (hook) -- submit errors must be screen-reader visible
- Proto labels/descriptions: hydrate from `getFieldDescription(schema, field)` via `ProtoAnnotations` registry -- don't hardcode strings in JSX when a proto annotation exists

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

### Effort per phase (Opus 4.7)

Default `high`. Implement (TDD) + Plan + Review (security/arch) = `xhigh`. No `max` -- diminishing returns + overthinking on 4.7. Never inject `ultrathink` into prompts/hooks/skills -- on 4.7 it silently downgrades xhigh->high.

### Subagent model choice (cost)

Explore -> Sonnet (codebase greps don't need Opus). Plan/Review -> Opus xhigh. general-purpose -> Sonnet if plan is atomic, Opus otherwise. Haiku 4.5 for lookups/boilerplate.

### Monitor (not sleep)

`Bash(run_in_background)` + `Monitor` stream output:
CI: `gh pr checks <n> --watch` | dev server | vitest watcher | container logs | build output

## UX Copy

Sentence case | no Latin abbrev (for example, that is, and so on, through) | no ableist lang | they/them

## Tests

Fail first -> pass | `userEvent.setup()` + `getByRole` | `await waitFor(()=>expect(...))` async | `.test.ts` unit `.test.tsx` integration `.browser.test.tsx` visual `e2e/*.spec.ts` Playwright | co-locate | `test()` not `it()` | `vi.fn()`/`vi.mock()`/`vi.spyOn()` | `.toBeVisible()` > `.toBeInTheDocument()` | no `waitForTimeout` | no `test.skip` E2E (`test.fixme()` known bugs) | `createRouterTransport` ConnectRPC mocks | `data-testid` interactives | `test.step()` Playwright
Green != done. Zero warnings in local output AND CI. `DeprecationWarning`, React `act()`, unhandled rejections, `@ts-ignore`, `npm WARN deprecated` = fix at source. Hooks: `test-warning-check` (local, Bash PostToolUse) + `ci-warning-audit` (Stop, scans `gh run view --log` on green). Escape: `// allow: test-warning` in test file with reason, or `TEST_WARNINGS_ALLOW=1` / `CI_WARNING_AUDIT=0` env.

## Logging

Structured JSON | requestId/traceId all entries | log at decision points | named levels per module | never log secrets/PII

## Error Handling

Boundaries: route+loader -> `errorComponent` (hook) | `React.lazy()` in `<Suspense>` | handle loading+error+empty
Catch: set error state / re-throw / handler -- no silent fallbacks, no log-only UI | parse errors: early return `<ErrorState />`
ConnectError fields: `findDetails(BadRequestSchema)` in `onError` -> iterate `fieldViolations` -> `form.setError` per violation -- toast only non-field (hook)
Validation: format not presence | UPPER_SNAKE pattern | exhaustive: `default: never`/`satisfies never`
Async: `onChange` async needs `AbortController` | `mutate()` needs `onError` (hook) | `Promise.allSettled` for partial-fail
Form UX: show ALL errors | `aria-invalid`+`aria-describedby` (hook) | disabled submit: `<Tooltip>` why (hook) | URL: `type="url"` | secrets: `type="text"` when verifying
State: oneof clear prev on switch | auth/config separate from form | FieldMask `paths`: `Object.keys(dirtyFields)` (hook)

## Auto Mode

Deny rules mirror `enforce-toolchain.sh` | test `bunx skills:*` allow rule | admin: `autoMode.environment` whitelist | `claude auto-mode defaults` schema | plan->approve->auto natural fit

## Auto-Generated (skip)

`*.gen.ts`/`*.gen.tsx` | `*_pb.ts`/`*_pb.js` | `*_connectquery.ts` | `@generated`/`DO NOT EDIT` first 5 lines
