# Project Rules

## Quick Reference (read on every turn)

Rules: bun tsgo biome vitest | no-memo(compiler) no-as-any no-ts-ignore no-style={{}} | UI:@/components/ui/ | no-raw-HTML(<button>-><Button>) | zustand:create<T>()() useShallow | env:@/env(no process.env) | TanStack-Router(no react-router-dom) | connect-query(no raw useQuery) | TDD: failing test first, always

## Toolchain

- Use `bun` as package manager (not npm/npx)
- Use `tsgo` for type checking (not tsc)
- Do not install eslint or prettier (this project uses Biome)
- Do not use `rm -rf` except for: node_modules, dist, .next, build, .cache, .turbo, coverage
- Do not use `git push --force` (use `--force-with-lease`)
- Do not use `git reset --hard`
- Do not use `--no-verify` on git commands

## Commit Format

All commits must follow: `type(scope): description`
- **Types**: feat, fix, refactor, style, test, docs, chore, perf, ci, build, revert
- **Scope** required: e.g. `feat(webui):`, `fix(backend):`
- Description: lowercase first letter, no trailing period, 5-72 chars

## Code Quality

- Run `bun run lint:fix` before finishing
- Run `bun run type:check` before finishing
- Do not add heavy dependencies to production: moment (use date-fns), lodash (use lodash-es), jquery, core-js, classnames (use clsx)

## React Rules

- Do not use class components — use functional components only (React Compiler requires this)
- Do not use raw HTML elements (`<button>`, `<input>`, `<select>`, etc.) — use components from `@/components/ui/`
- Do not use `dangerouslySetInnerHTML` without DOMPurify
- Do not use `eval()` or `new Function()`
- Do not assign `.innerHTML` directly
- Do not use `as any`, `as Record<string, any>`, `as Record<string, unknown>`, `@ts-ignore`, or `@ts-expect-error`
- Do not remove focus outlines (`outline: none`) without `focus-visible:ring-*` replacement
- Do not use manual `useMemo` / `useCallback` / `React.memo` (React Compiler handles this)
- Icon-only buttons must have `aria-label`
- Buttons must have onClick, asChild, type="submit", or disabled
- Prefer `<Link>` over `onClick + navigate()`
- Do not use barrel imports (re-exports from index files) — import directly from source files
- Use `{ passive: true }` on `addEventListener('scroll'|'touchstart'|'wheel')`
- Use dynamic `import()` or `React.lazy()` for heavy deps (`chart.js`, `d3`, `three.js`, `pdf-lib`)
- Use `structuredClone()` instead of `JSON.parse(JSON.stringify())`
- Use `.requestSubmit()` instead of `.submit()` (triggers validation)
- Do not use `delete` on arrays (creates sparse holes) — use `.filter()` or `Array.with()`
- Use `Number()` or `parseInt(str, 10)` — not `parseInt(str)` without radix
- Use `<Button>` not `<div role="button">` — native keyboard/focus/a11y
- Do not pass strings to `setTimeout` — use arrow functions
- Do not compare with `=== NaN` — use `Number.isNaN()`
- When writing `useEffect`, use named function expressions: `useEffect(function syncDocumentTitle() { ... }, [title])`

## Tailwind CSS

- Do not use inline `style={{}}` — use Tailwind utility classes
- Do not use raw hex/rgb colors in className or CSS — use design tokens
- Do not use `!important` — fix specificity instead
- Do not override visual styles (bg-*, text-*, border-*) on registry components — use variant prop
- Use `100dvh` not `100vh` (mobile viewport bug)
- Use `width: 100%` not `100vw` (scrollbar overflow)
- Do not use `user-scalable=no` (WCAG 1.4.4 violation)

## Environment Variables

- Do not access `process.env.X` directly — import from `@/env` (validated with t3-env + zod)
- All env vars must be declared in `src/env.ts`
- Exception: `process.env` is correct in build/test config files (rsbuild.config, vitest.config, etc.)

## Accessibility

- All `<img>` must have `alt` attribute
- Clickable `<div>` / `<span>` must have `role`, `tabIndex`, and keyboard handler
- `role="combobox"` requires `aria-expanded` and `aria-controls`
- `role="dialog"` requires `aria-label` or `aria-labelledby`
- `role="tablist"` requires child `role="tab"` elements

## Zustand

- Use `create<T>()()` double-parens (not `create<T>()`)
- Use `useShallow` for multi-value selectors
- Use `persist` middleware instead of direct localStorage

## State & Data

- Use zustand for client state, TanStack Query for server state
- Do not use raw `useQuery` / `useMutation` when ConnectRPC is available (exception: `useTransport`/`callUnaryMethod` pattern with `@connectrpc/connect` imports)
- Protobuf v2: use `create(Schema, { ... })` — do not spread without `create()` wrapper
- Protobuf v2: use `timestampFromDate()` for Timestamp fields
- Protobuf v2: use `anyPack()` for Any fields with `typeRegistry`
- `handleSubmit(onSubmit)` must have error callback: `handleSubmit(onSubmit, onError)`

## Development Lifecycle

Follow this order for every task. Do not skip phases.

1. **Understand** — explore context, ask clarifying questions one at a time, propose approaches
2. **Plan** — write exact file paths, exact code, expected output. No TBD or placeholders
3. **Implement (TDD)** — write failing test FIRST, then minimal code to pass, then refactor
4. **Verify** — confirm the fix works yourself. Do NOT ask the user to test manually. Use `agent-browser` for UI verification or test runner for logic
5. **Review** — check spec compliance, then code quality. Create PR with conventional commit format

## Test Quality

- Write failing test FIRST — no production code without a failing test
- Use `userEvent.setup()` (not `fireEvent`)
- Prefer `getByRole` for accessibility assertions
- Never use `setTimeout` or `waitForTimeout` in tests — use `await waitFor(() => expect(...))`
- Classify: `.test.ts` (unit, no DOM), `.test.tsx` (integration, renders), `e2e/*.spec.ts` (Playwright)
- Every new source file must have a co-located test file

## Error Handling & Resilience

- Route files with data fetching (`loader`, `useQuery`) should have `errorComponent`
- `React.lazy()` must be wrapped in `<Suspense fallback={...}>`
- Query hooks: always handle loading, error, AND empty states
- Async event handlers should have error handling

## Auto-Generated Files (skip — do not modify)

- `*.gen.ts` / `*.gen.tsx` (TanStack Router routeTree)
- `*_pb.ts` / `*_pb.js` (protobuf generated)
- `*_connectquery.ts` (Connect Query generated)
- Files with `@generated` or `DO NOT EDIT` in first 5 lines
