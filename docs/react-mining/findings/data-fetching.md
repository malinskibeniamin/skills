# Data Fetching — connect-query, ConnectRPC, TanStack Query, Protobuf

Pattern-mining of Engineer A's 4-year frontend history (`apps/cloud-ui`, `apps/admin-ui`, `apps/adp-ui`, `apps/adp-console`). Focus: query/mutation hooks, cache invalidation, transports, prefetch, retry policy.

The current canonical exemplar for this whole theme is **`apps/adp-ui/src/hooks/use-llm-providers.ts`** paired with **`apps/adp-ui/src/lib/api/resource-query-contract.ts`** and **`apps/adp-ui/src/lib/query-policy.ts`**. Almost every pattern below points back at these three files.

> Scope note: the following are ALREADY ENCODED and only refinements/contradictions are reported — connect-query for ConnectRPC (except `useTransport`/`callUnaryMethod`); Protobuf v2 schema-first `create(Schema,{...})`; `timestampFromDate()`; `anyPack()`+`typeRegistry`; `invalidateQueries` > `refetchQueries` awaited; no inline `staleTime`/`gcTime`; proto enums by name; `ConnectError.from()`; `formatToastErrorMessageGRPC`; `*Mutation` suffix; `mutate()` needs `onError`; FieldMask paths from `Object.keys(dirtyFields)`.

---

## Semantic staleTime tier registry (not just "a named const")

**Practice.** Cache freshness is not a scattered magic number and not even a single shared const — it is a **named semantic-tier registry**, `QUERY_STALE_TIME`, whose keys describe the *kind* of data (`resourceList`, `resourceDetail`, `metrics`, `search`, `discovery`, `catalog`, `immediate`, `default`) and whose values carry a paragraph of rationale for each tier. Interactive resource data sits at 60s (cache serves instantly, staleTime only gates the background refetch on mount); expensive metrics charts at 2m; server-static catalogs at `Number.POSITIVE_INFINITY`; search tighter at 30s. This refines the already-encoded "named const" rule: the requirement is a *taxonomy of freshness intent*, and every call site picks a tier by meaning rather than inventing a duration. `gcTime` likewise draws from the registry (`cache: 30m`).

**Anti-pattern.** (a) Raw magic numbers inline (`staleTime: 3 * aSecond`). (b) The intermediate generation of two vague buckets `SHORT_LIVED_CACHE_STALE_TIME` / `LONG_LIVED_CACHE_STALE_TIME` — better than magic numbers but still forces a binary short/long choice with no room for "discovery" vs "metrics" vs "catalog". (c) One-off `staleTime: Infinity` scattered per hook.

**Evidence.**
- `f84f8a494194` (2023-12-12) `cloud-ui: Set react-query staleTime to a reasonable amount` — first move off default 0.
- `6cc3cd19e276` (2025-06-19) `admin-ui: Don't refetch on window focus, fix stale time` — replaced `3 * aSecond` with `SHORT_LIVED_CACHE_STALE_TIME` (the two-bucket generation).
- `8696c2199d37` (2026-02-04) `cloud-ui: set useGetADPConfigQuery to infinite stale time` — admin-controlled config → `Infinity`, the seed of the `catalog: POSITIVE_INFINITY` tier idea.
- `d989f3c42dea` (2026-05-25) migrated bespoke `ADP_ENVIRONMENT_ROUTING_STALE_TIME` → `QUERY_STALE_TIME.discovery`, folding a one-off const into the registry.

**Evolution.** magic number → two vague buckets (2025) → **full semantic-tier registry with per-tier rationale** (adp-ui, 2026). Latest wins.

**Enforcement — `skill`.** Extend the connect-query skill: "Never pass a numeric literal or a private per-hook const to `staleTime`/`gcTime`. Import a tier from `query-policy.ts` (`QUERY_STALE_TIME.resourceDetail` etc.). If no tier fits, add one to the registry with a rationale comment — do not inline the number." (The existing hook already bans some inline usage; the taxonomy choice is judgment, so it belongs in the skill.)

---

## App-owned transport hook as a single seam

**Practice.** Components never call connect-query's `useTransport()` directly. Every resource hook resolves its transport through one **app-owned indirection hook** (`useGatewayRpcTransport` in adp-ui, delegating to `useTransport`), which layers the resolution order: routed gateway transport (published by `_authenticated.beforeLoad` into router context) → root router context → connect-query fallback. The payoff is stated in the code: environment-routed / standalone-decoupled transports can be taught to the app *without touching every resource hook again*. One seam, N consumers.

**Anti-pattern.** (a) Each hook importing `useTransport` from `@connectrpc/connect-query` and reading the ambient `TransportProvider` — a migration to environment-scoped transports then has to edit every hook. (b) Deep `TransportProvider` nesting to swap transports per subtree. (c) Multiple duplicate `useTransport` definitions drifting apart.

**Evidence.**
- `c42d9e64cadb` (2026-03-30) `adp-console: migrate to explicit transport, remove TransportProvider` — began moving off provider-implicit transport.
- `2a104a4aac4b` (2026-03-30) `adp-console: consolidate useTransport to single source of truth`.
- `ad94941f6ba2` (2026-05-19) `feat(adp-ui): add runtime transport foundation` — introduced the transport hooks (`use-gateway-transport`, `use-controlplane-transport`, `use-gatekeeper-transport`) + `bearer-interceptor`.
- `179bb0058168` (2026-05-28) `refactor(adp-ui): centralize gateway rpc transport hook` — **strongest**: one new `useGatewayRpcTransport` swapped into 9 resource hooks in a single mechanical pass, proving the "change once" payoff.

**Evolution.** implicit `TransportProvider` (cloud-ui, 2024) → explicit per-call transport → **single app-owned resolver hook** (adp-ui, 2026).

**Enforcement — `skill` file (with a `hook` assist).** Skill wording: "Resource hooks must resolve transport through the app's transport hook (e.g. `useGatewayRpcTransport`), never import `useTransport` from `@connectrpc/connect-query` at a call site." Hook assist (near-zero FP): in `apps/*/src/hooks/use-*.ts` flag an added line matching `import\s+\{[^}]*\buseTransport\b[^}]*\}\s+from\s+['"]@connectrpc/connect-query['"]` — the app-owned hook is the only sanctioned importer.

---

## Cardinality-agnostic invalidation through a query-key contract

**Practice.** Query-key construction and invalidation live in ONE module (`resource-query-contract.ts`) exposing `finiteResourceQueryKey`, `invalidateResource`, `invalidateFiniteResource`, `removeFiniteResource`. The load-bearing rule: mutations invalidate lists with **`createConnectQueryKey({ schema, input, cardinality: undefined })`**, which matches *both* finite (`useQuery`) and infinite (`useInfiniteQuery`) queries — so a write refreshes the list no matter which read shape the surface happens to use, and omitting `input` matches every page/filter variant. Detail reads are invalidated by exact finite key (or `removeQueries` on delete).

**Anti-pattern.** Invalidating with `cardinality: 'finite'` only. When a list surface later migrates from a plain `useQuery` to a cursor `useInfiniteQuery`, the finite key silently stops matching and the visible list shows stale rows until `staleTime` expires — a real bug fixed in the field.

**Evidence.**
- `5ba649808562` (2026-06-26) `fix(adp-ui): refetch the OAuth providers cursor list after writes` — **strongest**: create/update/delete were invalidating only the finite key; switched to `invalidateResource` (cardinality: undefined) so the infinite cursor list refetches too. Ships a regression test seeding both finite+infinite keys and asserting both get invalidated.
- `81ba3650da4c` (2026-06-26) same fix for OAuth clients.
- `d989f3c42dea` (2026-05-25) `fix(adp-ui): invalidate resource detail caches` — after delete invalidate exact detail keys; after rename invalidate route/request/response names so renamed/deleted resources don't render stale.

**Evolution.** per-mutation hand-rolled keys → shared contract helpers → **cardinality-agnostic list invalidation** (2026). Latest wins.

**Enforcement — `exemplar`.** Point at `apps/adp-ui/src/lib/api/resource-query-contract.ts` (the helpers) + `use-llm-providers.ts` mutation `onSuccess` blocks (the call pattern). Canonical shape: list → `invalidateResource`; detail → `invalidateFiniteResource`; delete → `removeFiniteResource`.

---

## Invalidate broadly by service/method, never build over-specific keys

**Practice.** Invalidation targets the widest correct scope — the whole method/service — rather than reconstructing the exact request variant. The connect-query key from `{ schema, cardinality: undefined }` (no input) prefix-matches every filter/page/variant of a list method, so one call covers them all. The intermediate admin-ui form of this was `queryKey: [method.service.typeName], exact: false`.

**Anti-pattern.** Rebuilding each specific request object (`new Listthe companyProductsRequest({filter:{ids}})`, `{public:true}`, per-org, per-id …) and invalidating each key individually. It is verbose, and it silently misses any variant you forgot to enumerate. Also banned: `invalidateQueries()` with no args (nukes the entire cache).

**Evidence.**
- `1a3d43f17c72` (2024-11-18) `admin-ui: simplify invalidating cache` — **strongest**: deleted ~40 lines that hand-built `Listthe companyProductsRequest` / `GetOrganizationRequest` keys per id/org, replaced with two `[typeName], exact:false` invalidations; also dropped the now-pointless `companyProductIds`/`organizationId` params from the helper signature.
- `66f49cae7325` (2024-08-24) `cloud-ui: Simplify invalidating public API cluster cache`.
- `44e0b7f570ea` / `962700518b75` (2024-09-20) `Ensure cache is invalidated on user/invite mutations` — establishing the "mutation must invalidate" reflex.

**Evolution.** per-input keys (2024) → `[service.typeName], exact:false` (late 2024) → `createConnectQueryKey({schema, cardinality:undefined})` (2026). Latest wins.

**Enforcement — `hook` (already partly live).** The existing `connect-query-check.sh` blocks `invalidateQueries\(\s*\)` (no-arg). Keep it. Add a skill note (judgment) discouraging per-variant key enumeration in mutation `onSuccess` — prefer the method-wide `invalidateResource` helper.

---

## Loader ↔ hook query-key parity (prefetch must warm the exact key the read uses)

**Practice.** A route loader's `ensureQueryData`/`prefetchQuery` only helps if it seeds the *byte-for-byte identical* key the component's connect-query hook will read. Because a connect-query hook key includes the transport (and input), the loader must stamp the SAME transport + explicit input into `createConnectQueryKey`. When they match, the detail page renders synchronously from the warmed cache with no second request and no spinner flash. This is verified with regression tests that assert `loaderKey === hookKey`.

**Anti-pattern.** Loader builds its key WITHOUT the transport (and, for empty-input lists, without the input). The hashes differ, TanStack stores two separate cache entries, the loader warms a cache the page never reads → intent/hover preload delivers nothing, and every detail navigation double-fetches and flashes. Also produced a P0: a model-detail page rendered a false "not found" on cold deep-link because the catalog query was undefined mid-load.

**Evidence.**
- `ea63d95bbd94` (2026-06-19) `fix(adp-ui): make detail-route loaders actually prefetch (query-key parity)` — **strongest and definitive**: fixed silent no-op loaders across every ADP section, added loader-cache-key regression tests, moved warmed reads onto `useGet…SuspenseQuery` and let route-level pending/`errorComponent` own the cold path.
- `a13340e8211d` (2026-06-19) `fix(adp-ui): fixed, prefetch-safe page-size defaults for cursor lists` — same-day companion.

**Evolution.** New discipline crystallized in 2026 once route loaders + hover-prefetch were introduced. No prior generation.

**Enforcement — `skill` + `exemplar`.** Skill: "A route loader that prefetches a connect-query read MUST construct its key with `createConnectQueryKey` using the same transport (and explicit input) the hook uses, and ship a test asserting loader key === hook key. Under a warmed loader, read via `useGet…SuspenseQuery` and let the route's pending/errorComponent handle loading/error — do not hand-roll `if (isLoading) <Spinner/>`." Exemplar: the `llmProvidersListInfiniteQueryOptions` / `useGetLLMProviderSuspenseQuery` pair in `use-llm-providers.ts`.

---

## Exhaustive page-walk for "must-reach-everything" surfaces; single-page read stays single-page

**Practice.** Two distinct read shapes with an explicit contract. A single-page finite `useQuery` (`useListLLMProvidersQuery`) is fine for cheap reads that genuinely want one page (counts, lookups by names already in hand). Any surface that must reach the *complete* set — a picker/select — uses an exhaustive `next_page_token` walk (`fetchAllLLMProviders`) requesting the server's max page size (`FETCH_ALL_PAGE_SIZE = 1000`) with a hard `MAX_LIST_PAGES = 100` ceiling that throws (never hot-loops) if the server returns a non-terminating token. The doc comment on the single-page hook explicitly warns it must NOT back a picker.

**Anti-pattern.** A single unpaginated list call backing a select/picker — a tenant past the server's first page (default 50, created_at desc) silently loses every older resource, and the user can never pick them.

**Evidence.**
- `use-llm-providers.ts` (current) — `fetchAllLLMProviders`, `useAllLLMProvidersQuery`, `MAX_LIST_PAGES` guard, and the warning comment on `useListLLMProvidersQuery`.
- `resource-query-contract.ts` (current) — `FETCH_ALL_PAGE_SIZE`/`MAX_LIST_PAGES` with AIP-158 rationale.
- `a13340e8211d` (2026-06-19) — prefetch-safe fixed page-size defaults for cursor lists (the paginated table variant, `useCursorPager`).

**Evolution.** Emerged with the AIP-paginated ADP APIs (2026); codified the "which read shape" decision into named helpers and a doc-comment contract.

**Enforcement — `exemplar`.** `apps/adp-ui/src/hooks/use-llm-providers.ts` is canonical: the three coexisting reads (single-page finite, exhaustive walk, cursor list) with doc comments stating which surface each serves. This is a taste/judgment call, not regex-checkable.

---

## Guarded, deduped hover/intent prefetch policy

**Practice.** Prefetching tab/detail data on hover or focus so the surface is warm before the click, but routed through a single policy object (`PREFETCH_POLICY` = 75ms debounce, 1000ms throttle) and a `guardedPrefetchQuery` helper that returns a structured `PrefetchResult` and short-circuits with a typed `PrefetchBlockReason` (`disabled | destructive | duplicate | expensive | fresh | missing-context | missing-params | private | throttled`). It reserves the throttle window before network work so failed prefetches still back off noisy endpoints, and refuses to prefetch destructive/private/expensive queries or ones already fresh in cache. The code explicitly says nav links should prefer TanStack Router's native `preload="intent"`; this helper is only for component-adjacent prefetches that can't use the router path.

**Anti-pattern.** Firing a raw `queryClient.prefetchQuery` on every `onMouseEnter` — hover-spam duplicate requests, refetching already-fresh data, and prefetching destructive/private endpoints.

**Evidence.**
- `6855b26ac823` (2026-06-25) `prefetch Access tab data on hover so the tab is warm before the click`.
- `5e94379e9077` (2026-06-25) `prefetch MCP server tool discovery on hover` — **strongest**: shared `mcpServerInfoQueryKey` + `prefetchMCPServerInfo` under the exact key the Inspector hook reads, with an integration test asserting no second discovery call after prefetch.
- `8ea5dab18bd1` (2026-06-25) `prefetch agent detail tab data on hover`.

**Evolution.** New capability in mid-2026; immediately abstracted into a guarded policy rather than left as ad-hoc `onMouseEnter` handlers.

**Enforcement — `exemplar`.** `apps/adp-ui/src/lib/query-policy.ts` (`guardedPrefetchQuery`, `PREFETCH_POLICY`, `PrefetchBlockReason`). Note in skill: "prefer router `preload=\"intent\"`; use `guardedPrefetchQuery` only for prefetches the router can't express, never a raw `prefetchQuery` on hover."

---

## Structural retry classification (network-failure vs server error) + global refetch discipline

**Practice.** Retry behavior is centralized in `query-policy.ts` and classifies failures **structurally, never by message text** (locale-independent). A transport-level fetch failure — `ConnectError` with `Code.Unknown` whose `.cause instanceof TypeError` (CORS/offline/DNS/refused, all opaque `Failed to fetch`) — is retried exactly ONCE then surfaced fast, because a permanent misconfig will never recover and the full 3× backoff (~14s) just freezes the UI. Server-reported `Internal`/`Unknown`/`Unavailable` keep the full retry budget; `PermissionDenied` gets a short 500ms retry to ride out post-sign-in role-propagation races. Global query defaults: `refetchOnWindowFocus: false`, `refetchOnReconnect: false`, mutations `retry: false`.

**Anti-pattern.** (a) One-size-fits-all `retry: failureCount > 3 ? false : true` that burns ~14s of backoff on an unrecoverable CORS/offline error. (b) Matching on error message strings. (c) Aggressive `refetchOnWindowFocus`/`refetchOnMount` causing refetch churn on every tab switch and route re-entry.

**Evidence.**
- `6cc3cd19e276` (2025-06-19) `admin-ui: Don't refetch on window focus, fix stale time` — set `refetchOnWindowFocus:false`, `refetchOnMount:false`, `refetchOnReconnect:true`, alongside retry tuning. Establishes the discipline.
- `9f44b55e2cc3` (2026-02-03) `fix(admin-ui): prevent background refetch errors and improve route error handling`.
- `query-policy.ts` + `core/grpc/query-client.ts` (current) — `isNetworkFailure`, `shouldRetryQuery`, `queryRetryDelay`, `NETWORK_FAILURE_MAX_RETRIES = 1`, PermissionDenied short-retry, global refetch flags.

**Evolution.** simple count-cap retry + refetch-on-focus (2024) → focus/mount off (2025) → **structural network-failure discrimination + role-propagation retry** (2026). Latest wins.

**Enforcement — `hook` + `exemplar`.** Hook (near-zero FP): flag added `new QueryClient(` whose options object contains a `retry:` that is a boolean/number literal or references neither `shouldRetryQuery`/`query-policy` — steer to the shared policy. Also flag `refetchOnWindowFocus: true` added in a `QueryClient` default. Exemplar: `apps/adp-ui/src/lib/query-policy.ts` + `core/grpc/query-client.ts`.

---

## Authenticated vs unauthenticated transports + token-caching interceptor

**Practice.** Auth is a property of the transport, not the call site. There are two transports: an **authenticated** one whose bearer interceptor throws `ConnectError('...', Code.Unauthenticated)` when no token is present (fail loud, don't silently send anon), and an **unauthenticated** one (empty interceptor list) mounted only around genuinely-public surfaces like signup. The modern factory (`transport-factory.ts`) caches the token in the interceptor closure and pairs it with a refresh interceptor that clears the cache and fires `onAuthError` on refresh failure; transports are module-cached by base URL so the same instance is reused (which is what makes loader↔hook key parity work).

**Anti-pattern.** A single transport with a "send with token if we have one, otherwise send anyway — worst case a 401" interceptor. It masks auth bugs behind opaque 401s and couples public and private surfaces to one transport. Fetching a fresh access token on *every* request instead of caching it.

**Evidence.**
- `bc7b9c3e5577` (2024-06-06) `cloud-ui: Use auth/non-auth transports` — **strongest**: split the permissive single transport into an authenticated one that throws `Unauthenticated` when no token, plus a dedicated unauthenticated `TransportProvider` around the signup page.
- `f78b1482778b` (2024-05-16) `cloud-ui: Support multiple grpc connect transport providers`.
- `2708b40d41ba` (2024-05-22) `cloud-ui: Remove gatekeeper transport` — consolidated to a single proxied endpoint.
- `transport-factory.ts` (current) — `createAuthenticatedTransport` / `createDevTransport`, cached-token bearer interceptor + `createTokenRefreshInterceptor`.

**Evolution.** permissive single transport (early 2024) → explicit auth/non-auth split (mid 2024) → **factory with token caching + refresh + gateway error recovery** (adp-ui, 2026). Latest wins.

**Enforcement — `exemplar`.** `apps/adp-ui/src/core/grpc/transport-factory.ts`. This is architectural setup, not per-diff checkable — best as a canonical file plus a skill sentence: "public surfaces mount an unauthenticated transport; the authenticated transport throws `Unauthenticated` rather than sending anonymous requests."

---

## Test-mock discipline for connect-query hooks

**Practice.** Hook/loader tests mock the transport with `createRouterTransport` from `@connectrpc/connect` (routing by RPC schema), seed the cache with `queryClient.setQueryData` under keys built from the *same* `createConnectQueryKey`, and assert cache state (`getQueryState(key)?.isInvalidated`) rather than spying on fetch. Mocks must export the *full* connect-query surface or `isolate:false` CI runs fail.

**Anti-pattern.** Mocking `fetch`/axios or partial connect-query surfaces; asserting on network calls instead of cache state.

**Evidence.**
- `5ba649808562` (2026-06-26) — the invalidation regression test seeds finite+infinite keys and asserts both invalidated (shown above).
- `02372fb58395` (2026-04-16) `fix(adp-ui): add all connect-query exports to test mocks`.
- `a207ad0d7f61` (2026-04-13) `fix(adp-ui): global mock for useDataplaneTransport to fix isolate:false CI failures`.
- `fed759436ceb` (2026-04-16) `add TransportProvider to route-test-utils mock for consistency`.

**Evolution.** Grew with the adp-ui hook layer through 2026; converged on `createRouterTransport` + cache-state assertions.

**Enforcement — `exemplar`.** `apps/adp-ui/src/hooks/use-oauth-providers.mutation-invalidation.integration.test.tsx` is the canonical shape for a mutation-invalidation test.
</content>
</invoke>
