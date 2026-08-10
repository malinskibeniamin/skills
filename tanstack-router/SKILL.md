---
name: tanstack-router
description: Apply TanStack Router patterns for Query ownership and typed search. Use when changing routes, loaders, navigation, route trees, or search parameters.
paths:
  - "**/routes/**/*.tsx"
  - "**/routes/**/*.ts"
---

# TanStack Router

Follow `/tanstack-intent` first and load the matching guidance shipped by the installed
Router package. Intent owns current API syntax and version behavior. This skill adds local
ownership and URL-state policy. Read [REFERENCE.md](REFERENCE.md) for local code shapes and
[SETUP.md](SETUP.md) for installation.

## Ownership

- Router loaders start server fetches after navigation intent.
- TanStack Query owns cache, refetch, invalidation, and garbage collection.
- Components observe Query through `useQuery` or `useSuspenseQuery`.

Use suspense for page-critical blocking data; use regular queries for deferred data with
inline loading, empty, and error states. Query-backed loaders set
`defaultPreloadStaleTime: 0` and use `createRootRouteWithContext`.

## Route rules

- Scope `useParams`, `useSearch`, `useLoaderData`, and `useRouteContext` with `{ from }` or
  a route API; reject `strict: false`.
- Query-backed components read Query, not `Route.useLoaderData`.
- Route files export route configuration only; reusable components live elsewhere.
- Navigation uses router APIs, not `window.location`.
- `react-router-dom`, `URLSearchParams`, and nuqs are migration debt.
- Route-tree changes trigger generation.

## Search parameters

The router owns search typing through `validateSearch`.

- URL: shareable tabs, filters, sort, and page.
- Storage: personal density, page size, and collapsed state.
- Validate enums, dates, and bounded numbers; clamp stale page indexes.
- Merge updates from prior search state.
- Use `replace: true` inside a section so Back exits the section.

## Completion

- Types prove route and search scope.
- Query data has an active observer and complete visible states.
- Navigation preserves browser history semantics.
- Search URLs survive malformed, stale, and shared values.
- Route tree, focused tests, typecheck, and lint pass.
