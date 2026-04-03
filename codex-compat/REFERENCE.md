# Codex Compatibility Reference

## codex-batch-check.sh

Stop hook wrapper that runs all PostToolUse Edit|Write checks on changed files.
Reuses the existing `.claude/hooks/` scripts — no duplication.
Handles JS/TS, CSS/SCSS (for tailwind-check), and package.json (for bundle-guard).

> Script: [`scripts/codex-batch-check.sh`](scripts/codex-batch-check.sh)

## .codex/hooks.json template

Generate this from the existing `.claude/settings.json`. Copy PreToolUse Bash, SessionStart, and Stop hooks directly. Add the batch checker as a Stop hook.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/enforce-toolchain.sh",
            "statusMessage": "Checking toolchain..."
          },
          {
            "type": "command",
            "command": ".claude/hooks/conventional-commits-check.sh",
            "statusMessage": "Validating commit format..."
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/session-env.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": ".codex/hooks/codex-batch-check.sh",
            "statusMessage": "Running code quality checks on changed files..."
          }
        ]
      }
    ]
  }
}
```

**Notes:**
- PreToolUse Bash hooks work identically on Codex (same JSON format, same `permissionDecision` output)
- SessionStart hooks work identically on Codex
- Stop hooks work identically on Codex (`decision: "block"` continues the turn)
- PostToolUse Edit|Write hooks are NOT in `.codex/hooks.json` — the batch checker handles them
- `_hook-lib.sh` must be in `.claude/hooks/` alongside the check scripts

## AGENTS.md template

Generate this at the repo root. It provides soft guidance for rules that Codex can't enforce via hooks. Customize based on which skills are actually installed.

```markdown
# Project Rules

## Quick Reference (read on every turn)

Rules: bun(--yarn) tsgo biome vitest | no-memo(compiler) no-as-any no-ts-ignore no-style={{}} | UI:@/components/ui/ | no-raw-HTML(<button>→<Button>) | zustand:create<T>()() useShallow | env:@/env(no process.env) | TanStack-Router(no react-router-dom) | connect-query(no raw useQuery) | TDD: failing test first, always

## Toolchain

- Use `bun` as package manager (not npm/npx)
- Use `tsgo` for type checking (not tsc)
- Always use `--yarn` flag with `bun install` / `bun add`
- Do not install eslint or prettier (this project uses Biome)
- Do not use `rm -rf` except for: node_modules, dist, .next, build, .cache, .turbo, coverage
- Do not use `git push --force` (use `--force-with-lease`)
- Do not use `git reset --hard`

## Commit Format

All commits must follow: `type(scope): description`
- **Types**: feat, fix, refactor, style, test, docs, chore, perf, ci, build, revert
- **Scope** required: e.g. `feat(webui):`, `fix(backend):`
- Description: lowercase first letter, no trailing period, 5-72 chars

## Code Quality

- Run `bun run lint:fix` before finishing
- Run `bun run type:check` before finishing
- Do not add heavy dependencies to production: moment (use date-fns), lodash (use lodash-es), jquery, core-js, classnames (use clsx)
- Use kebab-case for all filenames (`my-component.tsx`, not `MyComponent.tsx`)

## React Rules

- Do not use class components — use functional components only (React Compiler requires this)
- Do not use raw HTML elements (`<button>`, `<input>`, `<select>`, etc.) — use components from `@/components/ui/`
- Do not use `dangerouslySetInnerHTML` without DOMPurify
- Do not use `eval()` or `new Function()`
- Do not assign `.innerHTML` directly
- Do not use `as any`, `as Record<string, any>`, `as Record<string, unknown>`, `@ts-ignore`, or `@ts-expect-error`
- Do not remove focus outlines (`outline: none`)
- Do not use manual `useMemo` / `useCallback` / `React.memo` (React Compiler handles this)
- Icon-only buttons must have `aria-label`
- Buttons must have onClick, asChild, type="submit", or disabled
- Prefer `<Link>` over `onClick + navigate()`
- Do not use barrel imports (re-exports from index files) — import directly from source files
- Use `{ passive: true }` on `addEventListener('scroll'|'touchstart'|'wheel')`
- Use dynamic `import()` or `React.lazy()` for heavy deps (`chart.js`, `d3`, `three.js`, `pdf-lib`)
- When writing `useEffect`, use named function expressions: `useEffect(function syncDocumentTitle() { ... }, [title])`

## Tailwind CSS

- Do not use inline `style={{}}` — use Tailwind utility classes
- Do not use raw hex/rgb colors in className or CSS — use design tokens
- Do not use `!important` — fix specificity instead
- Do not override visual styles (bg-*, text-*, border-*) on registry components — use variant prop

## Environment Variables

- Do not access `process.env.X` directly — import from `@/env` (validated with t3-env + zod)
- All env vars must be declared in `src/env.ts`

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
- Protobuf v2: use `create(Schema, { ... })` — do not construct messages as object literals with `$typeName`
- Protobuf v2: use Standard Schema + protovalidate as react-hook-form resolver instead of duplicating validation in Zod
- Protobuf v2: use `timestampFromDate()` for Timestamp fields — never `{ seconds, nanos }` objects
- Protobuf v2: use `anyPack()` for Any fields — never construct without `typeUrl`/@type
- `handleSubmit(onSubmit)` must have error callback: `handleSubmit(onSubmit, onError)`

## Development Lifecycle

Follow this order for every task. Do not skip phases.

1. **Understand** — explore context, ask clarifying questions one at a time, propose approaches
2. **Plan** — write exact file paths, exact code, expected output. No TBD or placeholders
3. **Implement (TDD)** — write failing test FIRST, then minimal code to pass, then refactor
4. **Verify** — confirm the fix works yourself. Do NOT ask the user to test manually. Use `agent-browser` for UI verification (headless, fast, low tokens) or test runner for logic. Playwright MCP and chrome extensions are NOT available in Codex — use agent-browser instead: `agent-browser open <url> && agent-browser snapshot && agent-browser screenshot`
5. **Review** — check spec compliance, then code quality. Create PR with conventional commit format

## Test Quality

- Write failing test FIRST — no production code without a failing test
- Use `userEvent.setup()` (not `fireEvent`)
- Prefer `getByRole` for accessibility assertions
- Never use `setTimeout` or `waitForTimeout` in tests — use `await waitFor(() => expect(...))`
- Run `--detectAsyncLeaks` to check for async leaks
- Classify: `.test.ts` (unit, no DOM), `.test.tsx` (integration, renders), `e2e/*.spec.ts` (Playwright)
- Every new source file must have a co-located test file

## Error Handling & Resilience

- Route files with data fetching (`loader`, `useQuery`) should have `errorComponent`
- `React.lazy()` must be wrapped in `<Suspense fallback={...}>`
- Query hooks: always handle loading, error, AND empty states — never assume data exists
- Async event handlers (`onClick={async ...}`) should have error handling

## Auto-Generated Files

Skip these files — do not modify or flag patterns in them:
- `*.gen.ts` / `*.gen.tsx` (TanStack Router routeTree)
- `*_pb.ts` / `*_pb.js` (protobuf generated)
- `*_connectquery.ts` (Connect Query generated)
- Files with `@generated` or `DO NOT EDIT` in first 5 lines

## Config Files

`process.env` is correct in these files (do not flag):
- `rsbuild.config.*`, `vite.config.*`, `webpack.config.*`
- `vitest.config.*`, `jest.config.*`, `playwright.config.*`
- `tailwind.config.*`, `next.config.*`

## Two-Stage Code Review

Before creating a PR:
1. **Spec compliance** — does it match requirements? No scope creep?
2. **Code quality** — clean, tested, accessible, type-safe, DRY?
Then: create PR with conventional commit, suggest review
```
