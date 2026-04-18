---
name: setup-tanstack-router
description: Auto-generate TanStack Router route tree and enforce router patterns via PostToolUse hooks. Bans react-router-dom, window.location, untyped hooks. Use when setting up TanStack Router or file-based routing.
paths:
  - "**/routes/**/*.tsx"
  - "**/routes/**/*.ts"
---

# TanStack Router Enforcement

## What This Catches

- Ban `react-router-dom` imports
- Ban `window.location` for navigation (block) and reads (warn)
- Warn on `window.location.reload()` -- suggest `router.invalidate()`
- Ban `strict: false` in router hooks
- Ban untyped `useParams()`/`useSearch()`/`useLoaderData()`/`useRouteContext()` without `{ from }`
- Ban `URLSearchParams` -- suggest nuqs
- Warn on exported components from route files (breaks code splitting)
- Require `validateSearch` when `useSearch` is used in route files

Auto-regenerates route tree when route files change.

## Customization

The routes directory pattern defaults to `/routes/`. Update the grep pattern in hook scripts if your project uses a different convention:

```bash
if ! echo "$file_path" | grep -qE '/routes/'; then    # default
if ! echo "$file_path" | grep -qE '/pages/'; then     # pages-based
if ! echo "$file_path" | grep -qE '/app/routes/'; then # nested
```

## Type-Safe Search Params with nuqs

```tsx
import { useQueryState, parseAsInteger, parseAsString } from 'nuqs'

function UsersPage() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1))
  const [filter, setFilter] = useQueryState('filter', parseAsString)
}
```

For initial setup (install, config, verify): see [SETUP.md](SETUP.md).
