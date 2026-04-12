# Project Rules

## Quick Reference (read on every turn)

Rules: bun tsgo biome vitest | React Compiler handles memoization | fix types properly (type guards, generics) | UI from @/components/ui/ | <Button> for all buttons | zustand:create<T>()() useShallow | env from @/env | TanStack Router for routing | connect-query for data fetching | TDD: failing test first, always

## Toolchain

- Use `bun` as package manager
- Use `tsgo` for type checking
- Use Biome for linting and formatting
- Use `--force-with-lease` for force pushes
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

- Use functional components (React Compiler requires them)
- Use components from `@/components/ui/` for all form elements and interactive UI
- Use DOMPurify when rendering user-provided HTML
- Use JSON.parse() for data parsing, textContent for text insertion, Sanitizer API (setHTML) for safe HTML
- Fix types properly — use type guards, generics, or schema validation
- Replace focus outlines with `focus-visible:ring-*` styles
- React Compiler handles memoization — remove manual useMemo/useCallback/React.memo
- Add `aria-label` to icon-only buttons
- Every `<Button>` needs a purpose: onClick, asChild, type="submit", or disabled
- Use `<Link>` for navigation (accessible, supports basePath)
- Import directly from source files (tree-shaking friendly)
- Use `{ passive: true }` on scroll/touch/wheel listeners
- Use `React.lazy()` or dynamic `import()` for heavy deps (chart.js, d3, three.js, pdf-lib)
- Use `structuredClone()` for deep cloning
- Use `.requestSubmit()` for form submission (triggers validation)
- Use `.filter()` or `Array.with()` for array element removal
- Use `Number()` or `parseInt(str, 10)` with explicit radix
- Use `<Button>` for clickable elements (native keyboard/focus/a11y)
- Pass functions to `setTimeout`, use `Number.isNaN()` for NaN checks
- Name useEffect callbacks: `useEffect(function syncDocumentTitle() { ... }, [title])`

## Tailwind CSS

- Use Tailwind utility classes for styling
- Use design tokens for colors: `var(--destructive)`, `bg-primary`
- Fix specificity issues at the source (cascade layers, selector ordering)
- Use variant prop on registry components for visual changes
- Use `100dvh` for full viewport height (mobile-safe)
- Use `width: 100%` for full-width containers
- Respect zoom: keep user-scalable enabled (WCAG 1.4.4)

## Environment Variables

- Import from `@/env` (validated with t3-env + zod)
- Declare all env vars in `src/env.ts`
- Exception: `process.env` is correct in build/test config files (rsbuild.config, vitest.config, etc.)

## Accessibility

- Every `<img>` needs an `alt` attribute
- Clickable `<div>` / `<span>` need `role`, `tabIndex`, and keyboard handler
- `role="combobox"` needs `aria-expanded` and `aria-controls`
- `role="dialog"` needs `aria-label` or `aria-labelledby`
- `role="tablist"` needs child `role="tab"` elements

## Zustand

- Use `create<T>()()` double-parens pattern
- Use `useShallow` for multi-value selectors
- Use `persist` middleware for local storage

## State & Data

- zustand for client state, TanStack Query for server state
- Use connect-query hooks for ConnectRPC services (exception: `useTransport`/`callUnaryMethod` with `@connectrpc/connect`)
- Protobuf v2: use `create(Schema, { ... })` with schema-first functions
- Protobuf v2: use `timestampFromDate()` for Timestamp, `anyPack()` for Any with `typeRegistry`
- Include error callback: `handleSubmit(onSubmit, onError)`

## Development Lifecycle

Follow this order for every task:

1. **Understand** — explore context, ask clarifying questions one at a time, propose approaches
2. **Plan** — write exact file paths, exact code, expected output
3. **Implement (TDD)** — write failing test FIRST, then minimal code to pass, then refactor
4. **Verify** — confirm it works yourself using agent-browser or test runner
5. **Review** — check spec compliance, then code quality. Create PR with conventional commit format
6. **Complete the lifecycle** — push changes, create PR, monitor CI (`Monitor` tool on `gh pr checks <number> --watch`), fix failures, request review. Do not stop until the lifecycle is complete.

## UX Copy

- Use sentence case for headings and labels (not Title Case)
- Replace Latin abbreviations: e.g. → for example, i.e. → that is, etc. → and so on, via → through
- Avoid ableist language: use "check" not "sanity check", "placeholder" not "dummy"
- Use gender-neutral language: they/them, not he/she

## Test Quality

- Write failing test FIRST — then make it pass
- Use `userEvent.setup()` and `getByRole` for accessibility assertions
- Use `await waitFor(() => expect(...))` for async assertions
- Classify: `.test.ts` (unit), `.test.tsx` (integration), `e2e/*.spec.ts` (Playwright)
- Co-locate test files with source files

## Logging

- Use structured logging (JSON format) with consistent field names
- Include requestId or traceId in all log entries for distributed tracing
- Log at decision points (if/else branches), not just errors
- Use named log levels (debug/info/warn/error) controllable per module
- Never log secrets, tokens, or PII

## Error Handling & Resilience

- Route files with data fetching need `errorComponent`
- Wrap `React.lazy()` in `<Suspense fallback={...}>`
- Handle loading, error, AND empty states for query hooks
- Add error handling to async event handlers

## Auto-Generated Files (skip these)

- `*.gen.ts` / `*.gen.tsx` (TanStack Router routeTree)
- `*_pb.ts` / `*_pb.js` (protobuf generated)
- `*_connectquery.ts` (Connect Query generated)
- Files with `@generated` or `DO NOT EDIT` in first 5 lines
