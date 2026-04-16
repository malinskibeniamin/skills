Problem clear. COMPRESSED file has content duplicated — first uncompressed copy, commentary paragraph, then actual compressed copy. Total = 50 headings instead of 25. Fix: remove first copy + commentary, keep only compressed version.

# Project Rules

## Quick Reference (read on every turn)

Rules: bun tsgo biome vitest | React Compiler handles memoization | fix types properly (type guards, generics) | UI from @/components/ui/ | <Button> for all buttons | zustand:create<T>()() useShallow | env from @/env | TanStack Router for routing | connect-query for data fetching | TDD: failing test first, always

## Toolchain

- `bun` — package manager
- `tsgo` — type checking
- Biome — linting/formatting
- `--force-with-lease` for force pushes
- Safe `rm -rf` targets: node_modules, dist, .next, build, .cache, .turbo, coverage

## Commit Format

All commits: `type(scope): description`
- **Types**: feat, fix, refactor, style, test, docs, chore, perf, ci, build, revert
- **Scope** required: e.g. `feat(webui):`, `fix(backend):`
- Lowercase first letter, 5-72 chars

## Code Quality

- Run `bun run lint:fix` before finishing
- Run `bun run type:check` before finishing
- Prefer lightweight deps: date-fns over moment, lodash-es over lodash, clsx over classnames

## React Rules

- Functional components only (React Compiler requires)
- Components from `@/components/ui/` for form elements + interactive UI
- DOMPurify when rendering user-provided HTML
- `JSON.parse()` for data parsing, `textContent` for text insertion, Sanitizer API (`setHTML`) for safe HTML
- Fix types properly — type guards, generics, schema validation
- Replace focus outlines with `focus-visible:ring-*` styles
- React Compiler handles memoization — remove manual `useMemo`/`useCallback`/`React.memo`
- `aria-label` on icon-only buttons
- Every `<Button>` needs purpose: `onClick`, `asChild`, `type="submit"`, or `disabled`
- `<Link>` for navigation (accessible, supports basePath)
- Import direct from source files (tree-shaking friendly)
- `{ passive: true }` on scroll/touch/wheel listeners
- `React.lazy()` or dynamic `import()` for heavy deps (chart.js, d3, three.js, pdf-lib)
- `structuredClone()` for deep cloning
- `.requestSubmit()` for form submission (triggers validation)
- `.filter()` or `Array.with()` for array element removal
- `Number()` or `parseInt(str, 10)` with explicit radix
- `<Button>` for clickable elements (native keyboard/focus/a11y)
- Pass functions to `setTimeout`, `Number.isNaN()` for NaN checks
- Name useEffect callbacks: `useEffect(function syncDocumentTitle() { ... }, [title])`
- Form validation mode: `onChange` only, never `onBlur`/`onSubmit` (enforced by hook)
- Forms must have field validation: `register('field', { validate, required, pattern })` or resolver (enforced by hook)
- Forms must surface errors inline next to fields via FormMessage/FieldError/Field component (enforced by hook)
- Custom hooks (`function use*`) must live in `/hooks/`, not inline in route files
- Route files over 300 LOC → split — use `/request-refactor-plan`
- No `window.location` reads (including `.origin`) — use router utilities or env config
- Side-effect fetches (DELETE/POST/PUT/PATCH): `useMutation`, not raw fetch in handlers
- No `throw new Error()` in ConnectRPC files — use `ConnectError.from()` for gRPC status codes
- No `biome-ignore lint/suspicious/noExplicitAny` — fix types properly, no suppressing
- No `as any` / `as never` casts — use type guards, generics, discriminated unions
- Use proto enums, not magic numbers, for proto-derived values
- `useWatch()` for form field values, not `form.watch()` (React Compiler compat)
- Spread `...field` into react-hook-form controlled components
- `mutate()`/`mutateAsync()` must include `onError` callback
- Use `ConnectError.from(error)` + `formatToastErrorMessageGRPC()` for mutation errors
- `useMutation` results: name with `*Mutation` suffix (e.g. `deleteMutation`)
- No `@redpanda-data/ui` imports in new features — use redpanda-ui registry
- No direct `lucide-react` imports — use `components/icons` barrel
- No inline `staleTime`/`gcTime` numbers — use named constants from query client config

## Tailwind CSS

- Tailwind utility classes for styling
- Design tokens for colors: `var(--destructive)`, `bg-primary`
- Fix specificity at source (cascade layers, selector ordering)
- Variant prop on registry components for visual changes
- `100dvh` for full viewport height (mobile-safe)
- `width: 100%` for full-width containers
- Respect zoom: keep user-scalable enabled (WCAG 1.4.4)

## Environment Variables

- Import from `@/env` (validated with t3-env + zod)
- Declare all env vars in `src/env.ts`
- Exception: `process.env` correct in build/test config files (rsbuild.config, vitest.config, etc.)

## Accessibility

- Every `<img>` needs `alt`
- Clickable `<div>`/`<span>` need `role`, `tabIndex`, keyboard handler
- `role="combobox"` needs `aria-expanded` + `aria-controls`
- `role="dialog"` needs `aria-label` or `aria-labelledby`
- `role="tablist"` needs child `role="tab"` elements
- Disabled `<Button>` must have wrapping `<Tooltip>` explaining why
- `aria-invalid` requires `aria-describedby` for error description
- No nested interactive elements (button inside tooltip trigger)

## Zustand

- `create<T>()()` double-parens pattern
- `useShallow` for multi-value selectors
- `persist` middleware for local storage

## State & Data

- zustand for client state, TanStack Query for server state
- connect-query hooks for ConnectRPC services (exception: `useTransport`/`callUnaryMethod` with `@connectrpc/connect`)
- Protobuf v2: `create(Schema, { ... })` with schema-first functions
- Protobuf v2: `timestampFromDate()` for Timestamp, `anyPack()` for Any with `typeRegistry`
- Include error callback: `handleSubmit(onSubmit, onError)`
- FieldMask: compute `paths` from dirty fields (`Object.keys(dirtyFields)`), never hardcode
- `invalidateQueries` over `refetchQueries` — always `await` invalidation promises
- New route/component/hook files must have test files — run `/tdd`

## Development Lifecycle (MANDATORY — enforced by hooks)

MUST follow this order every task. Hooks block if steps skipped.

1. **Understand** — explore context, ask one clarifying question at time, propose approaches
2. **Plan** — write exact file paths, code, expected output
3. **Implement (TDD)** — run `/tdd` for every new source file. Failing test FIRST, then minimal code to pass, then refactor. Hook blocks new files without tests.
4. **Simplify** — run `/simplify` on changed code before committing. Review reuse, quality, efficiency.
5. **Verify** — confirm works yourself via agent-browser or test runner. Never delegate to user.
6. **Ship** — run `/commit-push`, create PR, use `Monitor` on `gh pr checks <number> --watch` to stream CI, fix failures, request review. Don't stop until lifecycle complete. All gates enforced by stop hooks.

### Streaming observation with Monitor

Use `Monitor` to stream real-time output from background processes, not sleeping/polling:
- **CI checks**: `gh pr checks <number> --watch`
- **Dev server**: stream logs while verifying UI changes in browser
- **Test watcher**: stream vitest output during TDD red-green-refactor
- **Container logs**: stream docker/container logs during integration debugging
- **Build output**: stream build logs during try-and-error fixes

Pattern: start process with `Bash(run_in_background)`, then `Monitor` to observe output and react to errors as they appear.

## UX Copy

- Sentence case for headings/labels (not Title Case)
- Replace Latin abbreviations: e.g. → for example, i.e. → that is, etc. → and so on, via → through
- Avoid ableist language: "check" not "sanity check", "placeholder" not "dummy"
- Gender-neutral language: they/them, not he/she

## Test Quality

- Failing test FIRST — then make pass
- `userEvent.setup()` + `getByRole` for accessibility assertions
- `await waitFor(() => expect(...))` for async assertions
- Classify: `.test.ts` (unit), `.test.tsx` (integration), `.browser.test.tsx` (visual regression), `e2e/*.spec.ts` (Playwright)
- Co-locate test files with source
- Use `test()` not `it()`
- Use `vi.fn()` / `vi.mock()` / `vi.spyOn()` — not Jest equivalents
- Prefer `.toBeVisible()` over `.toBeInTheDocument()` for visible elements
- No `waitForTimeout` — use `waitFor`, `waitForURL`, proper assertions
- No `test.skip` in E2E — hard fail if env missing, `test.fixme()` for known bugs
- Use `createRouterTransport` for ConnectRPC test mocks
- Add `data-testid` on interactive elements for stable selectors
- Use `test.step()` in Playwright for clear failure reports

## Logging

- Structured logging (JSON) with consistent field names
- Include requestId/traceId in all log entries for distributed tracing
- Log at decision points (if/else branches), not just errors
- Named log levels (debug/info/warn/error) controllable per module
- Never log secrets, tokens, or PII

## Error Handling & Resilience

### Route & Component Boundaries

- Route files with `loader` MUST have `errorComponent` (enforced by hook)
- Wrap `React.lazy()` in `<Suspense fallback={...}>`
- Handle loading, error, AND empty states for query hooks
- Add error handling to async event handlers

### Catch Blocks — Never Swallow Errors

- Every `catch` must: set error state, re-throw, or call error handler
- No silent fallbacks: `catch { onChange(e.target.value) }` hides broken state
- No catch-and-log-only in UI — user must see feedback (toast, inline error, error boundary)
- Parse errors: early return with error UI, don't render form below broken state
- Pattern: `if (parseError) return <ErrorState error={parseError} />`  — not `<Alert>` then `<form>` below

### Validation Depth

- Validate **format**, not just **presence** — URL fields need URL regex, enum fields need allowed-values check
- UPPER_SNAKE_CASE fields: validate pattern, don't just check truthy
- New variants in discriminated unions: handle explicitly or fail loudly — never silently pass through
- Exhaustive switch: `default: never` or `satisfies never` to catch unhandled cases at compile time
- Validation error types must match resolver contract — inconsistent shapes (`'validate'` vs `'validation'`) cause silent failures

### Async Error Patterns

- Async validation in `onChange`: use `AbortController` to cancel stale requests on rapid edits
- `mutate()`/`mutateAsync()` must include `onError` callback (enforced by hook)
- `Promise.all` for independent async ops, `Promise.allSettled` when partial failure OK — never fire-and-forget

### Form Error UX

- Show **all** validation errors, not just first — `errors.map()` not `errors[0]`
- Inputs with errors need `aria-invalid` + `aria-describedby` pointing to error message (enforced by hook)
- `data-invalid` no substitute for `aria-invalid` — screen readers need ARIA
- Disabled submit button must have `<Tooltip>` explaining why (enforced by hook)
- URL inputs: `type="url"` for browser-level validation hints (enforced by hook)
- Secret reference fields: `type="text"` not `type="password"` when user needs to verify format

### State Consistency

- Oneof/discriminated union form fields: clear previous branch values when switching — ghost data causes silent submission bugs
- Auth/config state separate from form state: single source of truth or sync explicitly — drift = data loss
- FieldMask `paths`: compute from `Object.keys(dirtyFields)`, never hardcode — brittle on proto field renames (enforced by hook)

## Auto Mode (team setup)

- Deny rules in `settings.json` mirror `enforce-toolchain.sh` — fast rejection before hooks run
- `bunx skills:*` allow rule may get dropped by classifier — test when adopting auto mode
- Admin: configure `autoMode.environment` in managed settings to whitelist trusted repos/services
- Run `claude auto-mode defaults` for full classifier rule schema
- Plan → auto workflow: plan mode (step 2) → approve → auto mode (steps 3-6) natural fit

## Auto-Generated Files (skip these)

- `*.gen.ts` / `*.gen.tsx` (TanStack Router routeTree)
- `*_pb.ts` / `*_pb.js` (protobuf generated)
- `*_connectquery.ts` (Connect Query generated)
- Files with `@generated` or `DO NOT EDIT` in first 5 lines