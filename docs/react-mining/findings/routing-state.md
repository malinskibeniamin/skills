# Routing + Client State — Mined Patterns

Theme: TanStack Router (loaders, search params, route organization, navigation),
zustand stores, URL-as-state, client/server state boundaries.

Source: 4,050 Engineer A frontend commits (2022-08 → 2026-07) across
apps/cloud-ui, apps/adp-ui, apps/admin-ui, apps/adp-console. Diffs read from
`~/Documents/git/cloudv2` (read-only).

## Timeline anchor: the react-router → TanStack Router migration

The whole theme pivots on a single 2026-Q1 migration, so evolution reads
"before = react-router-dom, after = TanStack Router":

- 2022-08..09 — react-router v6 adopted (`113b0b59` Sentry+RR v6; `9430e2d9`
  admin-ui RR-dom setup). Immediate cleanup of v5 idioms: `8c640d7` replace
  `<Redirect/>` with `<Navigate/>`, `c38801d` remove `<Redirect>` in `<Switch>`,
  `f558833` replace `history.push` with `navigate()`.
- 2024-2025 — react-router matured; imperative `useNavigate` replaces leftover
  `history.push` (`7bbc057` 2024-07).
- 2026-01 — **the migration**: `3bd9c7b` (2026-01-21) admin-ui
  react-router-dom → @tanstack/react-router, `363a3f1` (2026-01-22) finish admin
  migration, `68587a9` (2026-01-26) cloud-ui migration (635 files,
  +11k/-6.5k), `ca41b36` (2026-01-28) add loaders. adp-ui is TanStack-native
  from birth.
- 2026-06 — dead react-router-dom deps removed (`cd32956`).

Everything below is the post-migration steady state (2026), with anti-patterns
drawn from the pre-migration code and from fix/refactor commits that corrected
early TanStack mistakes.

---

## Pattern 1 — Loader/hook query-key parity (the prefetch must warm the key the page reads)

**Practice.** A route `loader` prefetches with `queryClient.ensureQueryData`
using a connect-query key built with the SAME ingredients the component's hook
uses: `createConnectQueryKey({ schema, input, transport, cardinality })`. The
transport and the (possibly empty) input are part of the key hash, so the
loader must stamp them in or it warms a *different* cache entry than the page
reads. Components under a warmed route then read via `useGet…SuspenseQuery`
(synchronous cache hit) instead of a duplicate `useQuery` with an
`isLoading/error/!data` triple-branch. Cold path is owned by the route's
`defaultPendingComponent` + `errorComponent`.

**Why.** Without parity the prefetch is a silent no-op: intent/hover preload
never delivers "data already there", detail pages double-fetch and flash a
spinner the loader already paid for.

**Anti-pattern.** (a) Loader builds a transport-less / input-less key while the
hook's key includes them → two cache entries, wasted fetch. (b) Component
re-fetches with its own `useQuery` and hand-rolls `if (isLoading) <Spinner/>`
under an already-warm loader.

**Evidence.**
- `ea63d95` (2026-06-19) fix: "make detail-route loaders actually prefetch
  (query-key parity)" — root-causes that loaders hashed keys differently from
  hooks; stamps the same transport + explicit empty input into every
  detail/finite loader; adds regression tests asserting `loader key === hook
  key`. Fixes a P0 false "model not found" on cold deep-link.
- `88d8a70` (2026-04-21) refactor: "pair tanstack-router loaders with
  useSuspenseQuery" — adds `useGet…Suspense` hooks, drops the triple-branch from
  six components, sets router `defaultPendingComponent/ErrorComponent`,
  `defaultPendingMs: 300`.
- `77790751` (2026-06-19) perf: "warm route loaders for first-paint data" —
  chains secondary prefetches (budgets, providers, spending) into detail
  loaders.
- `7b33fe5` (2026-06-17) prime guardrails detail via loader; `0b66443`
  (2026-06-26) OAuth clients loader-key parity tests.

**Evolution.** Engineer C 2026 loaders existed but were decorative → Apr 2026 paired
with suspense reads → Jun 2026 proven correct with key-equality regression
tests. Latest wins: loader + `useSuspenseQuery`, key parity asserted in tests.

**Enforcement.** `hook` (grep-level, near-zero false positives): in a file under
`src/routes/**`, if a `loader:` body calls `createConnectQueryKey(` without a
`transport` property in the same object literal, warn "loader key omits
transport — will not match the hook's key (query-key parity)". Plus `exemplar`:
`apps/adp-ui/src/routes/_authenticated/llm-providers/$name.tsx` (10-line
canonical loader).

---

## Pattern 2 — Route/component/constants file split under `routes/`

**Practice.** Each route is three co-located files: `foo.tsx` holds ONLY the
`createFileRoute(...)` config (`loader`, `beforeLoad`, `validateSearch`,
`errorComponent`, `component:`); `foo.page.tsx` holds the rendered component;
`foo.constants.ts` single-sources tab ids / zod search schema. The `.page.tsx`
and `.constants.ts` suffixes are deliberately named so the TanStack Router
generator's `routeFileIgnorePattern` skips them (files under `routes/` are
otherwise treated as route modules).

**Why.** Keeps the route module small and generator-safe; lets the search schema
be imported by both the route's `validateSearch` and the component's controlled
`<Tabs value>` so the two cannot drift; matches the ">300 LOC route →
refactor" rule structurally.

**Anti-pattern.** One fat route file mixing loader + 300-line component; a tab
enum duplicated between `validateSearch` and the JSX.

**Evidence.**
- `ab5502ec` (2026-06-18) creates `access.constants.ts` (tab ids + zod schema),
  `access.tsx` (route), `access.page.tsx` (component) as three files.
- adp-ui current tree: 155 route files, consistently `X.tsx` + `X.page.tsx`
  pairs (`llm-providers.tsx`/`llm-providers.page.tsx`,
  `_authenticated.tsx`/`_authenticated.page.tsx`, `mcp-servers.tsx`/`.page.tsx`).
- `88d8a70` adds shared `route-pending.tsx` / `route-error.tsx` referenced by
  route configs.

**Evolution.** cloud-ui migration (`68587a9`) put components inline in route
files; adp-ui converged on the `.page.tsx` split by mid-2026 as routes grew.

**Enforcement.** `exemplar`: the `access.tsx` / `access.page.tsx` /
`access.constants.ts` trio. Optional `hook`: a `.tsx` file under `routes/` that
both `export const Route = createFileRoute` AND declares a component >200 LOC →
suggest splitting to `.page.tsx`.

---

## Pattern 3 — Component tab/filter state belongs in the URL (validateSearch + Zod, not useState)

**Practice.** Any state that should survive reload or be shareable (active tab,
list filter facets, pagination) is modeled as a route search param:
`validateSearch: mySchema` (a Zod v4 schema passed DIRECTLY, not
`(s) => schema.parse(s)`), read via `Route.useSearch({ select })`, written via a
same-route `navigate({ search: (prev) => ({ ...prev, tab }), replace: true })`.
`replace: true` avoids history spam. A `search.middlewares:
[stripSearchParams({ tab: DEFAULT })]` keeps the default value out of the URL so
`/access` stays clean while `/access?tab=roles` is shareable. The Zod schema
uses `.catch(DEFAULT).default(DEFAULT)` so bad/absent params collapse to the
landing value.

**Why.** Shared links and reloads open the correct view; the schema is a single
source of truth the controlled component and the route cannot drift from.

**Anti-pattern.** `const [activeTab, setActiveTab] = useState('overview')` for
tab state (lost on reload, not shareable); filter state held only in component
state.

**Evidence.**
- `3d09be5` (2026-04-09) FIRST version: replaces `useState('overview')` with a
  hand-rolled `validateSearch` + a `VALID_TABS` array literal + manual
  `includes` guard; `navigate({ replace: true })`.
- `ab5502ec` (2026-06-18) MATURE version: Zod v4 schema in `*.constants.ts`,
  schema passed directly to `validateSearch`, `stripSearchParams` middleware,
  `useSearch({ select })`.
- `a23154bb` (2026-06-05) rolls the pattern across agents, mcp-servers,
  oauth-clients/providers, secret-store, guardrails (all filter facets
  round-trip in the URL).
- Supporting nav fixes: `46bc1fa`, `a5ceb80` (2026-06-03) pass the `tab` search
  param through cross-page navigation so create/edit → detail keeps the tab.

**Evolution.** useState (pre-Apr) → hand-rolled `VALID_TABS` array
`validateSearch` (Apr) → Zod schema single-sourced in `*.constants.ts` +
`stripSearchParams` + `useSearch({ select })` (Jun). **Latest wins: Zod v4
schema passed directly, default stripped from URL.**

**Enforcement.** `skill` (tanstack-router): "Tab/filter/pagination state that
should survive reload or be shareable is URL state, not `useState`. Define a Zod
schema in a `*.constants.ts` sibling, pass it directly to `validateSearch`, read
with `Route.useSearch({ select })`, write with `navigate({ search: (prev) =>
({...prev, x}), replace: true })`, and strip the default via `search.middlewares:
[stripSearchParams({ x: DEFAULT })]`." Optional `hook`: a `useState` whose
initial value is a tab-id string literal inside a route `.page.tsx` → nudge.

---

## Pattern 4 — Native TanStack search params, not a URL-state wrapper library

**Practice.** Use TanStack Router's own `validateSearch`/`useSearch`/`navigate`
for URL state. Do NOT pull in a third-party URL-state lib or a home-grown
wrapper on top of the router.

**Why.** The router already owns typed, validated search params; a wrapper is
duplicated surface area that drifts and adds a dependency.

**Anti-pattern.** `nuqs` dependency; a `table-url-state.ts` abstraction layer.

**Evidence.**
- `a23154bb` (2026-06-05) deletes the `nuqs` dependency AND the
  `table-url-state.ts` wrapper "in favour of the inline native pattern already
  used by governance and llm-providers." This is a deliberate de-abstraction.

**Evolution.** A wrapper/lib was tried, then removed once the native pattern
proved sufficient — matches the repo's "delete/inline before abstract" rule.

**Enforcement.** `hook`: flag any `import ... from 'nuqs'` in adp-ui, and any new
`*url-state*` wrapper module under a UI app, with message "use native
TanStack `validateSearch`/`useSearch` (see a23154bb)". Reinforce via `deslop`.

---

## Pattern 5 — Loader-readable client persistence via `useSyncExternalStore` + plain localStorage (NOT zustand persist)

**Practice.** Client-side persisted values that a route loader must read (page
size, selected ADP environment, theme, last-seen release) live in a plain
localStorage module exposing `getX()` (synchronous, `localStorage`-guarded),
`setX()` (writes + dispatches a same-tab event), and `subscribeToX()`. React
reads them through `useSyncExternalStore(subscribe, getSnapshot, () =>
serverDefault)`. The loader and the component both call the same synchronous
`getStoredPageSize(surface) ?? DEFAULT`, so their connect-query infinite-keys
match and the warm cache is read with no second fetch.

**Why.** Loaders run OUTSIDE React and must read the value synchronously before
render. zustand `persist` hydrates inside React and isn't reachable from a
loader, and the value (page size) is part of the query key — a size known only
after layout would make the loader warm a key the page never reads. This is the
explicit reason the team chose useSyncExternalStore over a zustand store here.

**Anti-pattern.** Holding loader-relevant persisted state in a zustand `persist`
store (loader can't read it); `useState` page size (loader/page key mismatch →
flash + double fetch); measuring the viewport for page size.

**Evidence.**
- `6c2af3e5` (2026-06-22) feat: "add persisted rows-per-page selector" —
  introduces `page-size-storage.ts` + `useStoredPageSize`; commit body spells
  out the loader/key-parity rationale.
- `9e4d757`, `aaeefef` (2026-06-29) seed agents/users page size via
  `useStoredPageSize` for parity; `fab2b10` (2026-06-22) read stored page size
  in the llm-providers loader.
- `949b43d` (2026-07-03) consolidate list pagination on the persisted footer.
- Current: `apps/adp-ui/src/hooks/use-client-storage.ts`,
  `apps/adp-ui/src/lib/page-size-storage.ts`,
  `apps/adp-ui/src/lib/adp-environment-storage.ts`.

**Evolution.** cloud-ui (2025) used zustand for UI/nav state; adp-ui (2026)
introduced the loader-readable localStorage-module pattern specifically because
of loader/query-key parity — a deliberate divergence, latest and most
considered.

**Enforcement.** `exemplar`: `apps/adp-ui/src/lib/page-size-storage.ts` +
`apps/adp-ui/src/hooks/use-client-storage.ts`. `skill` (tanstack-router):
"Persisted client state that a loader reads must be a synchronous localStorage
module read via `useSyncExternalStore`, not zustand `persist` (loaders run
outside React). Loader and page must resolve the same `getX(surface) ?? DEFAULT`
so their query keys match."

---

## Pattern 6 — Zustand slice composition with typed StateCreator + named devtools actions

**Practice.** A single store composes domain slices:
`create<Store>()(devtools((...args) => ({ ...createConsoleSlice(...args),
...createBreadcrumbSlice(...args), ...createNavSlice(...args) })))`. Each slice
is a `StateCreator<Store, [['zustand/devtools', never]], [], Slice>` and every
`set(...)` passes a named action string `set({...}, undefined,
'domain/action')` for devtools traceability.

**Why.** Slices keep client-UI state (nav, breadcrumbs, console status)
modular and typed; named actions make the devtools timeline readable; one store
avoids provider sprawl.

**Anti-pattern.** Redux / `@reduxjs/toolkit` + `react-redux` (removed);
untyped `create()` without the double-call `create<T>()()`; anonymous
`set(...)` with no action label.

**Evidence.**
- `30a50b35`, `babd483`, `1906125` (all 2025-06-13) introduce zustand slices
  for nav / breadcrumb / console status in cloud-ui, replacing Redux slices.
- `5307425a` (2025-07-01) admin-ui: "Replace redux with zustand" — drops
  `@reduxjs/toolkit` + `react-redux` from the lockfile.
- Historical anti-pattern: `ba63060` (2022-10-24) "Reconfigure Redux store and
  rtk-query", `065f88b` breadcrumbSlice (Redux) tests.

**Evolution.** 2022-2024 Redux/RTK-Query → 2025 zustand slices (client) +
TanStack Query (server). Redux fully removed by mid-2025. Latest wins: zustand.

**Enforcement.** `exemplar`: `apps/cloud-ui/src/core/store/layout/cloud-store.tsx`.
`hook`: flag `set({...})` calls in a zustand slice missing the third
action-label argument (devtools traceability); flag any new `@reduxjs/toolkit`
import.

---

## Pattern 7 — Typed router context as loader dependency injection (queryClient + transport, not imports)

**Practice.** The router is created with a typed `context: RouterContext`
carrying `queryClient`, `transport`, `getToken`, `hostBridge`, `isEmbedded`, and
env metadata. Loaders receive these via `({ context: { queryClient, transport },
params })` rather than importing a module-level singleton. The same factory
(`getRouter`) builds both standalone and embedded (Module Federation) modes by
swapping the context (`createMemoryHistory` + host-bridged transports when
embedded).

**Why.** Loaders stay pure and testable (context is injectable in tests);
dual-mode standalone/embedded is a context swap, not a code fork; transport
selection (gateway vs dataplane vs adp-api) is resolved once at router
construction.

**Anti-pattern.** Loaders importing `queryClient`/`transport` directly (couples
to a singleton, breaks embedded mode and tests).

**Evidence.**
- Current `apps/adp-ui/src/router.tsx`: `RouterContext` interface with
  `queryClient`/`transport`; `getRouter(options)` returns different history +
  transports for embedded vs standalone; `defaultPreload: embedded ? false :
  'intent'`.
- `07bb7fa` (2026-04-02) "pass navigateTo prop through Console loader for
  sidebar navigation"; `626db66` (2026-04-02) tests for loader config + v2Url;
  `6689d7a` (2026-04-02) adds the ADP UI architecture reference documenting the
  loader/context split.

**Evolution.** cloud-ui migration wired a queryClient into context (`ca41b36`);
adp-ui generalized it into a full dual-mode `RouterContext`.

**Enforcement.** `exemplar`: `apps/adp-ui/src/router.tsx`. `hook`: a
`createConnectQueryKey`/`callUnaryMethod` inside a `loader:` that references an
imported `transport`/`queryClient` symbol (rather than the destructured
`context`) → warn.

---

## Pattern 8 — Router-level default pending/error/notFound + fail-fast bounded loaders

**Practice.** Configure router-wide `defaultPendingComponent`,
`defaultErrorComponent`, `defaultNotFoundComponent`, `defaultOnCatch`
(Sentry report), `defaultPendingMs`/`defaultPendingMinMs`, `scrollRestoration`,
`trailingSlash: 'never'`. Route `errorComponent` owns the cold/failure path so
components skip `isLoading/error` branching. Blocking loaders that call a
possibly-unreachable environment wrap the query's abort signal with a
deadline-derived signal so an unreachable env fails fast into `errorComponent`
instead of hanging behind the pending spinner forever, and switching
environments cancels in-flight requests.

**Why.** One consistent fallback surface across every route; instant cache hits
skip the spinner; unreachable private environments become a fast recoverable
route error, not an infinite spinner; the environment switcher (rendered outside
the route Outlet) stays usable during failure.

**Anti-pattern.** Per-component `if (isLoading) <Spinner/> / if (error) ...`
triple-branch; unbounded loader `ensureQueryData` with no deadline that hangs on
a private-IP environment.

**Evidence.**
- `88d8a70` (2026-04-21) sets the router defaults + `RoutePendingComponent`.
- `745ee8e1` (2026-06-18) fix: "bound env-scoped route loaders so unreachable
  envs fail fast" — adds `envDataplaneRequestSignal`/`envRequestSignal` deadline
  wrapper in `lib/query-policy.ts` (Refs AI-1392).
- `7ae194d` (2026-06-19) drop dead loading guards covered by loaders;
  `c3258992` (2026-04-20) replace fullscreen LoadingScreen with inline section
  in federated loaders.
- `39e6649` (2026-04-15) add retry button in error component.

**Evolution.** Early loaders had no deadline and components self-branched → Apr
2026 router defaults centralize pending/error → Jun 2026 loaders bounded with
abort/deadline signals. Latest wins: bounded loaders + route-owned cold path.

**Enforcement.** `hook`: a route `errorComponent`/`pendingComponent` present but
its `.page.tsx` still contains `if (isLoading)` / `if (error)` from a
non-suspense hook → suggest suspense read. `exemplar`:
`apps/adp-ui/src/router.tsx` defaults block + `apps/adp-ui/src/lib/query-policy.ts`
signal helpers.

---

## Pattern 9 — Redirect in `beforeLoad`/`loader` via `throw redirect()`, not `<Navigate>` in render

**Practice.** Route-guard and conditional redirects live in `beforeLoad`
(or loader) as `throw redirect({ to, search })`, evaluated before the component
renders. `<Navigate>`/imperative `navigate` is reserved for in-component,
event-driven navigation.

**Why.** Redirect decisions that depend on flags/permissions/data should short
-circuit before render, avoiding a mount-then-redirect flash and `useEffect`
navigation races.

**Anti-pattern.** Conditional `<Navigate to=.../>` in the component body or a
`useEffect(() => navigate(...))` guard; the v5-era `<Redirect>` inside
`<Switch>`.

**Evidence.**
- Current `apps/adp-ui/src/routes/_authenticated/access.tsx`: `beforeLoad`
  awaits feature flags then `throw redirect({ to: '/agents', search: {} })`.
- Historical cleanup chain toward this: `8c640d7` (2022-08) `<Redirect/>` →
  `<Navigate/>`, `c38801d` (2022-08) remove `<Redirect>` in `<Switch>`,
  `7bbc057` (2024-07) `useNavigate` instead of `history.push` after delete.
- `68587a9` migration body: "`<Navigate>` → TanStack's `<Navigate>` or
  `redirect()`".

**Evolution.** v5 `<Redirect>` → v6 `<Navigate>` (2022) → imperative
`useNavigate` for events (2024) → `throw redirect()` in `beforeLoad` for guards
(2026). Latest wins: guard redirects in `beforeLoad`.

**Enforcement.** `skill` (tanstack-router): "Guard/conditional redirects go in
`beforeLoad`/`loader` as `throw redirect({ to, search })`, not `<Navigate>` in
render or a `useEffect` navigate. Reserve `useNavigate`/`<Link>` for
user-triggered navigation." `hook`: `<Navigate` JSX inside a route `.page.tsx`
component body → nudge toward `beforeLoad`.

---

## Pattern 10 — Navigation escape hatches: plain `<a>` outside the provider, `unsafeNavigateToExternalUrl` for computed URLs

**Practice / refinement of "always `<Link>` / no window.location".** Two
sanctioned exceptions:
1. Components rendered ABOVE the RouterProvider (e.g. a global error modal) use a
   plain `<a href>` — TanStack `<Link>` throws with no router context.
2. Navigation to a computed/external URL not in the route tree goes through a
   single `unsafeNavigateToExternalUrl(router, url, reason, options)` helper that
   centralizes the `to: url as any` type escape with a documented
   `'auth-redirect' | 'external-link'` reason — instead of scattering
   `window.location =` or raw casts.

**Why.** Keeps the "typed `<Link>`, no `window.location`" rule intact while
naming the two legitimate exits so they're greppable and reviewed.

**Anti-pattern.** `<TanStackRouterLink>` in a pre-router error boundary (crashes);
`window.location.href = ...`; ad-hoc `router.navigate({ to: x as any })`
sprinkled around.

**Evidence.**
- `9c1add9` (2026-03-19) "use regular link outside tanstack provider" — swaps
  `<TanStackRouterLink to="/users">` for `<a href="/users">` inside the global
  error modal (renders above the router).
- Current `apps/cloud-ui/src/utils/routes/unsafe-navigate.ts` — the documented
  `unsafeNavigateToExternalUrl` helper with reason enum.
- `39e6649` (2026-04-15) use TanStack Router `Link` (the positive default).

**Evolution.** cloud-ui migration introduced `unsafe-navigate.ts` as the single
escape hatch (`68587a9`); the outside-provider `<a>` exception landed
2026-03.

**Enforcement.** `skill` (tanstack-router) note listing the two exceptions +
`hook` refinement: allow plain `<a>` only in files that are NOT under `routes/`
AND render outside RouterProvider; flag `router.navigate({ to: ... as any })`
anywhere except `unsafe-navigate.ts`. `exemplar`:
`apps/cloud-ui/src/utils/routes/unsafe-navigate.ts`.

---

## Pattern 11 — Layout routes for shared detail/create/edit chrome

**Practice.** A parent layout route (`$name.tsx`) owns the loader + shared chrome
(header, tabs, breadcrumb) and renders `<Outlet>`; child index/edit/model routes
(`$name.index.tsx`, `$name.edit.tsx`, `$name.models.$model.tsx`) render into it.
Create/edit flows that were sibling routes are converted to layout routes so
navigation between them keeps the shared frame mounted.

**Why.** The layout loader warms shared data once for all children; navigating
create → edit → detail doesn't unmount/remount the frame or refetch.

**Anti-pattern.** Flat sibling routes each re-declaring the header/loader; a
create route that hard-swaps away from the edit route.

**Evidence.**
- `af32c41` (2026-03-26) aigw: "fix create/edit route navigation by converting
  to layout routes".
- Current adp-ui tree: `llm-providers/$name.tsx` (layout, loader) +
  `$name.index.tsx` / `$name.edit.tsx` / `$name.models.$model.page.tsx` children.
- `88d8a70` extends edit-route loaders with secondary prefetch chained off the
  layout loader.

**Evolution.** Migration produced some flat routes → converted to layout routes
through 2026 as detail pages grew tabs/children.

**Enforcement.** `exemplar`: `apps/adp-ui/src/routes/_authenticated/llm-providers/`
directory (`$name.tsx` layout + children). `skill` (tanstack-router): "Detail
pages with tabs/create/edit children use a `$name.tsx` layout route owning the
shared loader + chrome + `<Outlet>`; children render into it."

---

## Cross-cutting: named stale-time constants (refines "no inline staleTime")

`apps/adp-ui/src/lib/query-policy.ts` centralizes `QUERY_STALE_TIME`
(`default/resourceList/resourceDetail/metrics/catalog` = 60s/60s/60s/2m/∞) with a
documented rationale, and loaders/hooks reference the named keys.
`88d8a70` added `staleTime: 30_000` to lists and `staleTime: Infinity` to the
immutable model catalog. Router `defaultStaleTime`/`defaultPreloadStaleTime`
also pull from this constant. Already-encoded rule "no inline staleTime/gcTime —
named const" is confirmed in current code; exemplar is `query-policy.ts`.

---

## Summary table

| # | Pattern | Enforcement | Strongest SHA |
|---|---------|-------------|---------------|
| 1 | Loader/hook query-key parity | hook + exemplar | `ea63d95` (2026-06-19) |
| 2 | Route/component/constants file split | exemplar | `ab5502ec` (2026-06-18) |
| 3 | URL-as-tab/filter state (validateSearch+Zod) | skill (+hook) | `ab5502ec` (2026-06-18) |
| 4 | Native search params, delete URL wrapper libs | hook | `a23154bb` (2026-06-05) |
| 5 | Loader-readable localStorage via useSyncExternalStore | exemplar + skill | `6c2af3e5` (2026-06-22) |
| 6 | Zustand slice composition + named devtools actions | exemplar + hook | `5307425a` (2025-07-01) |
| 7 | Typed router context as loader DI | exemplar + hook | `router.tsx` (current) |
| 8 | Router-level default pending/error + fail-fast loaders | hook + exemplar | `745ee8e1` (2026-06-18) |
| 9 | Redirect in beforeLoad via `throw redirect()` | skill + hook | `access.tsx` (current) |
| 10 | Nav escape hatches (`<a>` outside provider, unsafeNavigate) | skill + exemplar | `9c1add9` (2026-03-19) |
| 11 | Layout routes for detail/create/edit chrome | exemplar + skill | `af32c41` (2026-03-26) |
