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

## Router + Query

- Router loaders start server fetches after navigation intent.
- TanStack Query owns cache, refetch, invalidation, and garbage collection.
- Components observe Query through `useQuery` or `useSuspenseQuery`.

Route-known Query inputs have one pipeline: `validateSearch` -> `loaderDeps` -> one
`queryOptions` builder -> loader and component observer. Return only search fields used by
the query. Components consume `useLoaderDeps`, not a parallel reading of query-driving
search. If the installed Router guidance supports building options in route `context`,
share that exact options value; never adopt undocumented syntax from an example.

- Page-critical data: await `ensureQueryData`; observe with `useSuspenseQuery`.
- Route-known deferred data: start it in the loader; observe with `useQuery` and visible
  loading, empty, and error states.
- Interaction-only data may start from the component.

Query-backed loaders set `defaultPreloadStaleTime: 0` and use
`createRootRouteWithContext`.

## Navigation lifetimes

Keep resource, navigation, outcome, and render ownership separate:

- A superseded navigation loses permission to publish; shared loader or Query work can
  remain useful.
- `beforeLoad` is replay-safe authentication, redirect, or context construction. Preloads
  and navigations can each run it; keep observable side effects and ordinary data fetches
  out so loaders retain parallelism.
- Direct loader requests forward `abortController.signal`. Query functions forward the
  signal owned by Query. Do not cancel shared work globally on every navigation.
- Redirects from `beforeLoad` or loaders use `throw redirect(...)`, not imperative
  navigation.
- Use `onResolved` for analytics and non-DOM cleanup. Use `onRendered` for focus,
  scrolling, measurement, or other work that requires committed route content.
- Use Router pending UI and its timing options rather than hand-built navigation timers.

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
- Loader and observer use the same Query options builder and loader-owned inputs.
- Query data has an active observer and complete visible states.
- Rapid or preloaded navigation cannot publish stale route UI or duplicate app-owned work.
- Navigation tests assert the rendered route landmark after the URL changes.
- Navigation preserves browser history semantics.
- Search URLs survive malformed, stale, and shared values.
- Route tree, focused tests, typecheck, and lint pass.
