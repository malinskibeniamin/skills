# TanStack Router Reference

## Query-backed loader

```tsx
export const Route = createFileRoute('/dashboards/$dashboardId')({
  loader: ({ context, params }) =>
    context.queryClient.prefetchQuery(dashboardQueryOptions(params.dashboardId)),
  component: Dashboard,
})

function Dashboard() {
  const { dashboardId } = Route.useParams()
  const dashboard = useSuspenseQuery(dashboardQueryOptions(dashboardId))
  return <DashboardView dashboard={dashboard.data} />
}
```

Root setup uses `createRootRouteWithContext<{ queryClient: QueryClient }>()` and
`defaultPreloadStaleTime: 0`.

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
Query-backed `useLoaderData`, untyped Query context, and stale router preload caching.
