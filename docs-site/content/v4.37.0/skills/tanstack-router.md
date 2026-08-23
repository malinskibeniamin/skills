---
title: "/tanstack-router"
description: "Apply TanStack Router patterns for Query ownership and typed search. Use when changing routes, loaders, navigation, route trees, or search parameters."
type: skill
sidebar:
  label: "/tanstack-router"
---
![Diagram of the /tanstack-router skill](/diagrams/skills/tanstack-router.svg)

[Open the editable Excalidraw source](/diagrams/skills/tanstack-router.excalidraw)

Run `/read-the-damn-docs` before changing current APIs. Read
[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/tanstack-router/REFERENCE.md) for code shapes and [SETUP.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/tanstack-router/SETUP.md) for installation.

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
