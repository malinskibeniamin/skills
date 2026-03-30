---
name: setup-tanstack-router
description: Auto-generate TanStack Router route tree and enforce router patterns via PostToolUse hooks. Bans react-router-dom, window.location, untyped hooks. Use when setting up TanStack Router or file-based routing.
---

# Setup TanStack Router

## What This Sets Up

- `generate:routes` package.json script
- **PostToolUse hook** (Write/Edit) that regenerates route tree when route files change
- **PostToolUse hook** (Write/Edit) that catches routing anti-patterns:
  - Ban `react-router-dom` imports
  - Ban `window.location` for navigation (block) and reads (warn)
  - Warn on `window.location.reload()` — suggest `router.invalidate()`
  - Ban `strict: false` in router hooks
  - Ban untyped `useParams()`, `useSearch()`, `useLoaderData()`, `useRouteContext()` without `{ from }`
  - Ban `URLSearchParams` — suggest nuqs
  - Warn on exported components from route files (breaks code splitting)
  - Require `validateSearch` when `useSearch` is used in route files

## Steps

### 1. Add package.json script

```json
{
  "scripts": {
    "generate:routes": "tsr generate"
  }
}
```

### 2. Create hook scripts

Copy [`scripts/tanstack-router-gen.sh`](scripts/tanstack-router-gen.sh), [`scripts/tanstack-router-check.sh`](scripts/tanstack-router-check.sh), and [`scripts/_hook-lib.sh`](scripts/_hook-lib.sh) into `.claude/hooks/`. Make all executable.

During setup, ask the user for their routes directory path (default: `src/routes/`).

### 3. Configure hooks in `.claude/settings.json`

Add to hooks config: **PostToolUse** (matcher: `Edit|Write`):
- `.claude/hooks/tanstack-router-gen.sh`
- `.claude/hooks/tanstack-router-check.sh`

### 4. Verify

- [ ] `bun run generate:routes` works
- [ ] Creating a new route file triggers regeneration
- [ ] Hook blocks `react-router-dom` imports
- [ ] Hook blocks `window.location.href = ...`
- [ ] Hook warns on `window.location.reload()`
- [ ] Hook blocks `strict: false`
- [ ] Hook blocks `useParams()` without `{ from }`
- [ ] Hook allows `Route.useParams()`
- [ ] Hook blocks `new URLSearchParams`
- [ ] Hook warns on exported components from route files
- [ ] Hook blocks `useSearch` without `validateSearch` in route files

### 5. TanStack official skills (optional)

For additional soft guidance (search params, data loading, auth guards, error handling, type safety), install the official TanStack Router skills:

```bash
npx @tanstack/intent@latest install
```

This adds 28 reference skills from the TanStack Router docs. They complement the hooks above with patterns and examples that are too context-dependent to enforce deterministically.

### 6. Commit

Stage and commit: `Add TanStack Router auto-generation and anti-pattern hooks`
