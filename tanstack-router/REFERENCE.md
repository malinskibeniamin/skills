# TanStack Router Reference

## Query identity

Use one options builder and one owned input pipeline. The stable pattern works with
version-matched Router packages that expose `useLoaderDeps`:

```tsx
export const Route = createFileRoute('/dashboards/$dashboardId')({
  validateSearch: z.object({
    asOf: z.iso.date().optional(),
    debug: z.boolean().catch(false),
  }),
  loaderDeps: ({ search: { asOf } }) => ({ asOf }),
  loader: ({ context, deps, params }) =>
    context.queryClient.ensureQueryData(
      dashboardQueryOptions(params.dashboardId, deps),
    ),
  component: DashboardPage,
})
```

```tsx
const routeApi = getRouteApi('/dashboards/$dashboardId')

function DashboardPage() {
  const { dashboardId } = routeApi.useParams()
  const deps = routeApi.useLoaderDeps()
  const dashboard = useSuspenseQuery(dashboardQueryOptions(dashboardId, deps))
  return <DashboardView dashboard={dashboard.data} />
}
```

The `debug` search value cannot reload or re-key the query because the query does not use
it. A component must not rebuild these options from `useSearch`; that creates a second
dependency list which can drift.

When TanStack Intent for the installed Router explicitly exposes a route `context` option
that is recomputed from `params` and `loaderDeps`, prefer creating the options there and
passing the same context value to both `ensureQueryData` and `useSuspenseQuery`. Otherwise
use the supported `useLoaderDeps` pattern above. Do not infer API availability from blog
examples.

Root setup uses `createRootRouteWithContext<{ queryClient: QueryClient }>()` and
`defaultPreloadStaleTime: 0`.

## Blocking and deferred work

Await `ensureQueryData` only when the route needs the result before rendering. For
route-known deferred data, start the version-matched non-blocking Query preload API from
the loader, then render `useQuery` loading, empty, and error states. Component-only starts
are reserved for interaction-gated data whose input does not exist at navigation intent.

## Navigation ownership

| Need | Public owner |
|---|---|
| Keep or cancel loading work | Router loader flight or Query cache |
| Decide which navigation may publish | Router navigation transaction |
| Choose success, redirect, or failure | Route attempt |
| Prove route content committed | Framework render / `onRendered` |

Direct loader fetches consume the Router signal:

```tsx
loader: ({ abortController }) =>
  fetchAccount({ signal: abortController.signal })
```

Query functions consume Query's signal instead:

```tsx
queryFn: ({ signal }) => fetchAccount({ signal })
```

Keep `beforeLoad` replay-safe and use redirects as control flow:

```tsx
beforeLoad: ({ context }) => {
  if (!context.user) throw redirect({ to: '/login' })
}
```

Use the event matching the effect:

```tsx
router.subscribe('onResolved', trackPageView)
router.subscribe('onRendered', focusPageHeading)
```

`onResolved` is not proof that route DOM committed. A URL assertion has the same limit.

## Behavior tests

- Open a shared URL whose query key includes validated search and assert one accurate
  request before the first route render.
- Change the query-driving search value and assert exactly the new key; unrelated search
  must not reload it.
- Hover-preload then click and assert app-owned loader work is not duplicated.
- Delay route A, navigate to B, and assert only B's landmark and effects appear.
- Combine an ordinary loader error with a sibling redirect and assert stale error UI never
  renders.
- After `waitForURL`, assert a destination landmark; URL publication alone is incomplete.

## Typed search

```tsx
const searchSchema = z.object({
  page: z.coerce.number().int().min(1).catch(1),
  tab: z.enum(['overview', 'settings']).catch('overview'),
})

export const Route = createFileRoute('/users/')({
  validateSearch: searchSchema,
})
```

Read through `Route.useSearch()`. Write with
`navigate({ search: (previous) => ({ ...previous, page: 2 }) })`.

## Hook coverage

The router checks ban `react-router-dom`, `window.location`, `URLSearchParams`, nuqs,
unscoped hooks, `strict: false`, missing `validateSearch`, route-file component exports,
Query-backed `useLoaderData`, untyped Query context, stale router preload caching, and
imperative loader navigation. They warn on broad `loaderDeps`, parallel search-derived
Query inputs, `beforeLoad` side effects, unowned loader cancellation, and DOM work before
`onRendered`.
