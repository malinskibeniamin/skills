---
name: setup-tanstack-router
description: Configure TanStack Router route tree auto-generation and anti-pattern enforcement via Claude Code PostToolUse hooks. Regenerates routeTree when route files change. Bans react-router-dom, window.location navigation, strict:false, untyped hooks, URLSearchParams. Use when setting up TanStack Router, file-based routing, route generation hooks, or enforcing router type safety.
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

Write scripts from [REFERENCE.md](REFERENCE.md) into `.claude/hooks/`:

- `tanstack-router-gen.sh` — route tree regeneration
- `tanstack-router-check.sh` — anti-pattern enforcement

Make both executable. During setup, ask the user for their routes directory path (default: `src/routes/`).

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
- [ ] Hook blocks `useSearch` without `validateSearch` in route files

### 5. Commit

Stage and commit: `Add TanStack Router auto-generation and anti-pattern hooks`
