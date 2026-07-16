# Error handling & resilience — mined patterns

Source: 4,050 Engineer A frontend commits (2022-08 → 2026-07) across
`apps/cloud-ui`, `apps/adp-ui`, `apps/admin-ui`, `apps/adp-console`, `tests/e2e-ui`.
Method: grepped theme keywords (402 candidate commits), reconstructed bug classes
from ~25 fix diffs, cross-checked against the current live utilities in
`apps/adp-ui/src/lib` and `apps/adp-ui/src/components`.

The corpus shows a clear arc: 2022–2024 cloud-ui built the *toast + error-format*
foundation (redux-epic era), 2025 admin-ui added the *TanStack Router loader +
retry-contract* layer, and 2026 adp-ui matured the hard stuff — *scope-keyed cache
isolation, AbortController discipline, stale-chunk recovery, Sentry noise/PII
governance*. The 2026 fixes are the richest ore: nearly every one ships a named
pure helper + unit test + integration test that reproduces the exact race.

NOTE on ALREADY-ENCODED rules: route `errorComponent` boundaries, `React.lazy`
in `<Suspense>`, loading+error+empty, no silent/log-only catch, parse-error →
early-return `<ErrorState/>`, `findDetails(BadRequestSchema)` → `form.setError`,
`onChange` async `AbortController`, `mutate()` needs `onError`, `Promise.allSettled`
partial-fail, exhaustive `default: never`. Below refines these where the corpus
adds a sharper detection rule; it does not re-report them.

---

## Pattern 1 — Scope-keyed cache isolation (env / org / user boundary)

**Description.** ADP resource queries (providers, MCP servers, OAuth resources,
connections, metrics, detail pages) are logically scoped by the *selected ADP
environment* and by the *organization*, but their TanStack Query keys do NOT
carry that scope. On an environment switch or org switch the previous scope's
cached data survives and briefly renders under the new scope — the app "looks
like it never switched." The fix is an explicit scope-clear at the switch seam:
wipe resource caches, preserve only the discovery/routing queries that describe
the selector itself.

**Anti-pattern / bug class it prevents.** Cache keyed too broadly leaks data
across a security/tenancy boundary. Because the key omits the scope, `staleTime`
and `persist` make it worse: org-scoped queries rehydrate from `localStorage` on
return from an Auth0 redirect, so a full sign-out/in was the only recovery.

**Evidence.**
- `756f6daac8` (2026-05-28) `fix(adp-ui): isolate environment query cache` — new
  `clearADPEnvironmentScopedQueryCache(queryClient)`: snapshot `ListADPEnvironments`
  / `GetADPEnvironment` discovery queries, `queryClient.clear()`, restore only
  those. Called from the selector's `handleSelect` before `setStoredADPEnvironmentId`.
- `5960f0ea1f` (2026-06-09) `fix(adp-ui): clear query cache on org switch` —
  `switchOrganization` now clears persisted + in-memory cache before the Auth0
  redirect, mirroring `signOut`; also keys the in-progress switch by org `id` not
  `auth0Id` so empty-`auth0Id` orgs stop colliding on `''`.
- `6d2abd5f64` (2026-02-03) `fix(admin-ui): standardize query inputs to prevent
  cache key mismatches` — same class from the write side: divergent request-input
  shapes produced two keys for one resource.
- Live utility: `apps/adp-ui/src/lib/adp-environment-query-cache.ts`,
  `apps/adp-ui/src/lib/query-persister.ts` (`shouldPersistQuery` allow-list).

**Enforcement — exemplar + skill.**
- Exemplar: `apps/adp-ui/src/lib/adp-environment-query-cache.ts` (preserve-then-clear
  with a unit test asserting a stale sibling-env provider is gone and discovery
  survives).
- Skill wording: "When a query's data is scoped by a value that is NOT in its
  query key (selected environment, org, tenant, user), you MUST clear that scope's
  cache at every switch seam. Preserve only routing/discovery queries. If the app
  persists the query cache, clearing must run at sign-out, org switch, and scope
  switch alike."

---

## Pattern 2 — Await teardown before a page unload / redirect (fire-and-forget dies)

**Description.** A `void clearPersistedQueryCache(queryClient)` fired immediately
before a full-page Auth0 redirect can be cut off by the navigation: async
`localStorage` removal never settles, so the previous scope's data survives the
unload and rehydrates. Any cleanup that must complete before the page goes away
has to be `await`ed, and the redirect placed after it.

**Anti-pattern / bug class it prevents.** Fire-and-forget cleanup (`void asyncFn()`
or an un-awaited promise) racing a `location.reload()` / `loginWithAuth0()` /
`logout()` full-page navigation — the teardown silently loses the race.

**Evidence.**
- `8b92cbba56` (2026-06-10) `fix(adp-ui): await cache clear on org switch and
  guard empty auth0Id` — STRONGEST. Converts `switchOrganization`/`signOut` to
  `async`, `await clearPersistedQueryCache(...)` *before* `await loginWithAuth0`;
  a test asserts call order `['clear-started','clear-resolved','login']`. Also
  guards empty `auth0Id` (error toast, no redirect) and resets the switching
  spinner + toasts on redirect rejection.
- `5960f0ea1f` (2026-06-09) is the predecessor that introduced the `void` bug.
- `8b92cbba56` also adds the catch that clears in-progress state on failure —
  the un-awaited version left the spinner stuck.

**Enforcement — hook.**
- Detection rule: flag a statement `void <ident>(...)` OR an un-awaited
  promise-returning call whose next sibling statement (same block) is a
  navigation/unload call — `location.reload(`, `location.assign(`,
  `location.href =`, `loginWithAuth0(`, `logoutFromAuth0(`, `window.open(`. Nudge:
  "`await` this cleanup before the redirect; a full-page navigation cancels
  in-flight promises." Low false-positive: the pairing (async cleanup + immediate
  navigation) is specific.

---

## Pattern 3 — AbortController lifecycle for imperative fetches: unmount + last-write-wins

**Description.** Hooks/components that own an `AbortController` for a manual
`fetch`/SSE stream must (a) abort on unmount via a *named* effect, (b) abort the
previous controller at the start of each new invocation (last-click-wins), and
(c) bail out of every state write once `signal.aborted` (the success path, the
catch, and the `finally`). connect-query handles this for you; raw fetch/stream
consumers do not.

**Anti-pattern / bug class it prevents.** (1) Navigating away mid-stream keeps
reading the SSE body (wasted LLM tokens) and calls `setState` after teardown.
(2) A slow earlier fetch resolves after a newer one and overwrites fresh data /
flips the loading state — the classic out-of-order response race.

**Evidence.**
- `a258a6064b` (2026-07-09) `fix(adp-ui): abort playground stream on unmount` —
  `usePlaygroundChat` owned a controller but never aborted on unmount; adds
  `useEffect(function abortStreamOnUnmount(){ return () => abortRef.current?.abort(); }, [])`.
  Test unmounts mid-stream and asserts `capturedSignal.aborted === true`.
- `ab4f4a421e` (2026-06-10) `fix(adp-ui): abort stale agent card fetches in the
  inspector dialog` — STRONGEST. Per-invocation controller, `signal` passed to
  each candidate-URL fetch, `if (controller.signal.aborted) return` after the
  `Promise.allSettled`, in the catch, and guarding the `finally` `setIsLoadingCard`.
  Also aborts on dialog `onOpenChange(false)` and unmount. Test proves a stale
  invocation resolving later cannot overwrite the "fresh" card.
- `e0aaf2d52c` (2026-06-10) `fix(adp-ui): make a2a resubscribe backoff loop
  abortable` — an exponential-backoff reconnect loop that ignored the abort signal.

**Enforcement — hook + skill.**
- Hook detection: a component/hook that constructs `new AbortController()` or holds
  `useRef<AbortController>` but has NO `useEffect(... return () => ...abort())`
  cleanup → warn "abort this controller on unmount." Also: a `fetch(` inside a
  hook body with no `signal:` in its init.
- Skill wording: "Raw `fetch`/SSE outside connect-query owns its cancellation.
  (1) abort on unmount in a named effect; (2) abort the previous controller at the
  start of each new call (last-write-wins); (3) after `await`, `return` early if
  `signal.aborted` on the success path, the catch, AND before any `finally` state
  write. Name the effect `abort<Thing>OnUnmount`."

---

## Pattern 4 — Stale code-split chunk recovery after atomic deploy

**Description.** With route-level auto-code-splitting, a Netlify atomic deploy
replaces every content-hashed `/static/*` chunk and drops the previous deploy's
files. A tab still running the old `index.html` 404s when it imports an old chunk
URL on the next navigation, surfacing as the bundler's cryptic "Loading chunk N
failed." The fix: detect chunk-load errors in *every* boundary (route, federation,
root), render a dedicated `ChunkReloadRecovery` that hard-reloads once (standalone
only), guarded by a `sessionStorage` cooldown so a genuinely broken build can't
loop — and make the 404's Cache-Control not `immutable` so the reload actually
re-fetches.

**Anti-pattern / bug class it prevents.** Treating a deploy-induced chunk 404 as
a generic app error whose "Try again" re-imports the dead URL (no recovery). And
the subtle cache footgun: a 404 served from a path covered by an `immutable`
Cache-Control rule freezes in the browser for a year, so a *soft* reload keeps
serving the cached 404 — only a hard refresh recovers.

**Evidence.**
- `e862bf5164` (2026-06-22) `fix(adp-ui): recover from stale code-split chunks
  after deploys` — STRONGEST. New `lib/chunk-reload.ts`: `isChunkLoadError`
  (matches `ChunkLoadError` name + 5 cross-engine dynamic-import message regexes),
  `shouldAutoReload` (pure — standalone runtime + working sessionStorage + not
  within cooldown), `markChunkReloadAttempt`. Wired into `route-error.tsx`,
  `federation-error-boundary.tsx`, `root-route-components.tsx`.
- `41215a8ca0` (2026-07-06) `fix(adp-ui): stop freezing stale-chunk 404s in the
  browser cache` — retargets the `/static/*` miss redirect to
  `/chunk-not-found.html` OUTSIDE `/static` so the 404 no longer inherits
  `immutable`; ships a unit test guarding the netlify.toml / `_redirects` shape.
- `40c415fbc1` (2026-02-06) `fix(cloud-ui): graceful error handling when AI
  Gateway remote is not ready` — sibling: HEAD-validate the remote entry before MF
  load, show "not available yet" + keep nav for retry instead of ChunkLoadError.

**Enforcement — exemplar.**
- Exemplar: `apps/adp-ui/src/lib/chunk-reload.ts` (+ `.unit.test.ts`) and
  `apps/adp-ui/src/components/chunk-reload-recovery.tsx`. Canonical for: pure
  reload-decision read from a `useState` initializer, effect does the side effect
  only, sessionStorage loop guard, embedded-vs-standalone runtime gate.
- Skill note: "Every error boundary in a code-split app must special-case
  `isChunkLoadError` before the generic fallback; a stale-chunk 404 is a deploy
  event, not an app error."

---

## Pattern 5 — Bounded, code-classified retry contract (never infinite, never blind)

**Description.** The global `QueryClient` must have an explicit retry predicate
that (a) caps attempts, (b) retries only transient codes, and (c) uses bounded
exponential backoff — with a short-delay fast path for known propagation races
(PermissionDenied right after sign-in/org change) and a longer backoff for rate
limits (ResourceExhausted / 429). Mutations retry `false`.

**Anti-pattern / bug class it prevents.** TanStack Query's default retries a
permanent failure (403) infinitely, which then trips a 429 rate limit — a
self-inflicted storm. Also `refetchOnReconnect: true` causes a thundering herd on
tab wake.

**Evidence.**
- `26831148ca` (2026-03-26) `cloud-ui: fix ADP layout infinite retry loop` —
  STRONGEST as the bug: a layout route ran `useClusterData`, whose 403 React Query
  retried infinitely → 429. Fix removed the needless query.
- `3a9c7d4991` (2026-05-18) `fix(adp-ui): tighten query retry contract` — adds
  `queryRetryDelay`: 500ms for PermissionDenied propagation, else
  `min(1000·2^n, 30_000)`; test asserts PermissionDenied surfaces after 4 tries.
- `9f44b55e2c` (2026-02-03) `fix(admin-ui): prevent background refetch errors...`
  — `refetchOnReconnect:false`, retry adds `ResourceExhausted`, longer backoff for
  429; plus route-loader ID validation (see Pattern 8) and InvalidArgument/
  ResourceExhausted boundary cases.
- `185509e661` (2023-12-11) `cloud-ui: Set default query retry options` — the
  original establishment of the contract.

**Enforcement — hook + exemplar.**
- Hook: a `new QueryClient(` whose `defaultOptions.queries` has no `retry` key
  (relies on the infinite-ish default) → warn. And `refetchOnReconnect: true`
  (or unset) on the global client → nudge toward the thundering-herd rationale.
- Exemplar: `apps/adp-ui/src/core/grpc/query-client.ts` — `isRetryableError` +
  `shouldRetryQuery` + `queryRetryDelay`, mutations `retry: false`.

---

## Pattern 6 — Sentry as signal, not noise: severity classification, suppression, PII redaction

**Description.** Not every thrown error deserves a Sentry issue, and no error may
carry credentials. The mature approach classifies each Connect failure by gRPC
code into `error` (5xx + malformed-request 400 bugs) / `warning` (likely-user 4xx)
/ `suppressed` (Canceled, Unauthenticated, NotFound — normal high-volume
outcomes), suppresses at the ingress-agnostic `beforeSend` (so the global
`onunhandledrejection` path can't leak them), keeps a metric counting suppressed
volume, dedupes per error instance, and redacts sensitive URL query-param VALUES
before they reach the route context.

**Anti-pattern / bug class it prevents.** (1) Reporting expected outcomes
(not-found, user cancellations) at `error` level → alert fatigue and a misleading
issue severity. (2) Leaking the OAuth `?code=&state=` (and tokens/secrets) that
briefly live on the Auth0 callback URL into Sentry — which then also triggers
Sentry's scrubber to replace the *whole* route with `[Filtered]`, hiding the route.

**Evidence.**
- `d40ae418b6` (2026-06-25) `feat(adp-ui): classify Sentry severity by gRPC code
  and filter out not-found` — STRONGEST. `connectErrorSeverity(code)` →
  `error|warning|null`; suppressed codes marked handled so the boundary skips
  them; `adp_ui.rpc_error` metric still counts them as `severity:'suppressed'`.
- `5ef0f0a4ec` (2026-06-25) `fix(adp-ui): redact sensitive query params from the
  Sentry route context` — `redactSearch()` replaces values for
  code/state/token/secret/password keys (set + substring match), keeps param names
  and benign params.
- `af4f2ba2e2` (2026-06-24) `fix(adp-ui): dedupe reports, leak-proof source maps`;
  `d91744a712` (2022-08-25) `cloud-ui: Remove PII from Sentry`; `40c415fbc1`
  downgrades an expected operational failure to `level:'info'`.
- Live: `apps/adp-ui/src/lib/api/telemetry-interceptor.ts`,
  `apps/adp-ui/src/lib/telemetry/state-context.ts` (`redactSearch`), `sentry.ts`.

**Enforcement — skill (+ optional hook).**
- Skill wording: "Telemetry is triaged, not dumped. Classify errors by
  code/severity; suppress expected outcomes (cancellation, unauthenticated,
  not-found) but keep a volume metric. Never send URL search strings, request
  bodies, or headers to Sentry without redacting credential-bearing keys
  (code, state, token, secret, password, api_key). Suppress at `beforeSend` so the
  global unhandled-rejection path is covered too."
- Hook (optional, higher FP risk): `Sentry.captureException` with a hard-coded
  `level:'error'` and no code classification, or passing `location.search` /
  `window.location.href` into a Sentry `extra`/context without a redact call.

---

## Pattern 7 — Toast/error formatting always surfaces the real server reason (and nothing secret)

**Description.** A user-facing failure toast must show the actual server-provided
reason and code, via a single shared formatter — not the JS stack, not a generic
"Something went wrong," and not a raw internal payload. Field-level violations go
inline on the form; only non-field errors toast.

**Anti-pattern / bug class it prevents.** (1) Using `error.stack` (or a generic
string) as the toast body so the user never sees *why* it failed. (2) Divergent
ad-hoc toast strings per call site. (3) Leaking internal error internals.

**Evidence.**
- `b8840ae384` (2022-11-07) `cloud-ui: Fix error reason not always being shown to
  the user in the toast message` — STRONGEST as the bug: `getBaseError` used
  `error.stack || 'Unknown'` instead of `error.reason`; adds a `reason` getter and
  an `isCloudAPIError` reason guard.
- `116bdadd21` (2023-12-08) `cloud-ui: Add formatToastErrorMessageGRPC` — the
  shared `Failed to ${action} ${entity} due to: ${error.message} (code: ${code})`.
- `7760f62fcc` (2022-11-08) `cloud-ui: Obfuscate the toast error message` — the
  other guardrail: don't over-expose raw internals.
- Live consolidation: `apps/adp-ui/src/lib/format-error.ts` —
  `formatConnectError`, `formatToastErrorMessage`, `extractFieldViolations`,
  `humanizeAlreadyExistsError`, `humanizeAwsAccessDeniedError`.

**Enforcement — exemplar (+ skill).**
- Exemplar: `apps/adp-ui/src/lib/format-error.ts`.
- Skill wording: "Route all failure toasts through the shared error formatter;
  the body must be the server reason + code, never `error.stack` or a bare generic
  string. Field violations render inline (see already-encoded `findDetails` rule),
  toast only carries non-field errors."

---

## Pattern 8 — Route-loader input validation + treat cancellation/expected codes as non-errors

**Description.** A dynamic route loader must validate the URL param's *format*
(XID / UUID regex) before the API call and throw `notFound()` on a malformed id,
and map both `NotFound` and `InvalidArgument` to `notFound()`. Boundaries must
early-return for control-flow "errors" — unauthenticated (redirect),
chunk-load (reload), and route cancellation (a newer request already took over) —
before rendering the scary generic UI.

**Anti-pattern / bug class it prevents.** (1) A garbage URL param hits the backend
and returns `InvalidArgument`, surfaced as "Something went wrong" instead of a
clean not-found. (2) A rapid route invalidation / env switch cancels an in-flight
loader promise, and that `CancelledError`/`AbortError`/`Code.Canceled` poisons the
route error boundary as if the page failed.

**Evidence.**
- `9f44b55e2c` (2026-02-03) `fix(admin-ui): prevent background refetch errors and
  improve route error handling` — STRONGEST. New `isValidResourceId(id, 'xid'|'uuid')`
  guard at the top of ~11 route loaders; loaders + boundary now handle
  `InvalidArgument` alongside `NotFound`; adds `isResourceNotFoundError`.
- `route-cancellation.ts` (live) `isRouteCancellationError` — CancelledError /
  ConnectError Canceled / DOMException AbortError / name-based fallback; used in
  `route-error.tsx` and `root-route-components.tsx` early-return.
- `aa5ead39cc` (2026-01-27) `admin-ui: allow retrying not found issues`.

**Enforcement — skill + hook.**
- Hook: a `createFileRoute(...).loader` that reads a `$param` and calls
  `ensureQueryData`/`fetchQuery` without a preceding format guard (`isValidResourceId`
  / regex test) → nudge. Detectable via the `params: { xId }` destructure feeding
  a query input with no validation statement between.
- Skill wording: "Validate route-param FORMAT before the API call; malformed →
  `notFound()`. Map `InvalidArgument` to not-found alongside `NotFound`. In error
  boundaries, early-return for cancellation, unauthenticated, and chunk-load
  BEFORE the generic fallback — these are control flow, not failures."

---

## Pattern 9 — Config/flag defaults must be safe for the async-resolve window

**Description.** A feature flag or remote config read before its provider responds
returns the *default*. The chosen default must be the *safe* value for that
pre-initialization window, and when config is genuinely not ready the state should
be a loading sentinel (`null`), not a stale value from a previous scope. Which
direction is "safe" is contextual — the point is to decide it deliberately.

**Anti-pattern / bug class it prevents.** Reading a flag's default as if it were
resolved state during the pre-init window: either hiding a feature that should
render (fail-open needed) or flashing a feature that must stay gated (fail-closed
needed), plus carrying a previous cluster/org's resolved value into the next.

**Evidence.**
- `c6e562e8a3` (2026-04-15) `fix(cloud-ui): keep LD defaults as true to avoid race
  condition` — OpenFeature returns defaults before LaunchDarkly responds; `false`
  defaults briefly hid MFE flags on first render and could break Console load, so
  defaults set to `true` (real gating stays in LD targeting rules).
- `96b5f03594` (2026-02-20) `cloud-ui: fix sidebar isAdpEnabled fail-closed default
  and reset on loading` — opposite direction, same principle: `?? true` (fail-open)
  → `=== true` (fail-closed) so AI nav items hide until config confirms, and reset
  to `null` when config isn't ready so a prior cluster's value can't leak.
- `78f0711ec8` (2024-01-24) `cloud-ui: Check client status when loading LaunchDarkly`.

**Enforcement — skill.**
- Skill wording: "A flag/config default is the value used *before the provider
  resolves*. Choose it for safety in that window (gate sensitive UI fail-closed;
  keep must-load MFE flags fail-open) and reset scope-derived config to a loading
  sentinel — never `?? true`/`?? false` as if resolved. Comment the direction and
  why."

---

## Pattern 10 — Don't gate render on chained dependent queries (flicker) / single stable loading source

**Description.** A query gated on another query's result (`enabled: !!orgId`)
creates a two-stage load: the screen shows empty/loading, the first query
resolves, then the second starts — a visible flash. Where the backend can derive
the scope itself, drop the dependency and the `enabled` gate; otherwise keep one
stable loading source rather than compounding conditions.

**Anti-pattern / bug class it prevents.** Flash of empty/loading state between
chained query stages; a fullscreen loader flipping in for a dependent sub-fetch.

**Evidence.**
- `a2af13fd97` (2024-05-10) `cloud-ui: Do not flicker screen due to subscription
  calls` — STRONGEST. Removes the `filter:{organizationId: orgData?.id}` +
  `enabled:!!orgData?.id` gate from `getCurrentSubscription` (backend infers the
  org), killing the org→subscription chain flash.
- `c3258992ed` (2026-04-20) `fix(cloud-ui): replace fullscreen LoadingScreen with
  inline LoadingSection in federated loaders`.
- `5daaa2d713` / `07a423cb77` — empty-state consolidation so a resolved-empty
  list never flashes as loading; `07a42` also `fix ... page flash before auth step`.

**Enforcement — skill.**
- Skill wording: "Avoid chaining a query on another's data via `enabled:!!x` when
  the backend can derive the scope — it causes a two-stage loading flash. Keep a
  single stable loading source per view; render an explicit empty state for
  resolved-empty, not a spinner."

---

## Pattern 11 (brief) — proto optional message is `undefined`, never `null`

**Description.** protobuf-es represents an absent optional message as `undefined`.
Sentinel checks written against `null` (`!== null` always true, `=== null` always
false) become dead code and silently take the wrong branch.

**Anti-pattern / bug class it prevents.** `!== null` / `=== null` guards on proto
fields that are constant-true/false, choosing the wrong field mask or the wrong
rendered state.

**Evidence.**
- `3a706a84a0` (2026-06-13) `fix(admin-ui): treat absent companyNodePools as
  undefined not null` — a `!== null` check was always true (dead legacy-resize
  branch, wrong field mask) and a sibling `=== null` always false ("Migrating"
  instead of "-"). Replaced with a real presence check.
- `90305b8a89` (2025-12-22) `admin-ui: enable noUselessUndefined biome linter rule`.

**Enforcement — hook.**
- Detection: a `=== null` / `!== null` comparison against a known proto message
  field (or any protobuf-es getter) → nudge "protobuf-es uses `undefined`; use a
  presence check (`!field` / `field == null`) not a `null` sentinel." Overlaps
  Biome `noUselessUndefined`; the hook catches the proto-specific case Biome misses.

---

## Cross-cutting observations

- **Every 2026 adp-ui fix ships a named pure helper + unit test + an integration
  test that reproduces the exact race.** The helpers are deliberately pure so
  they can be read from a `useState` initializer or asserted in isolation
  (`shouldAutoReload`, `connectErrorSeverity`, `redactSearch`, `isChunkLoadError`,
  `clearADPEnvironmentScopedQueryCache`). This "pure-decision + effect-only" split
  is itself a resilience pattern worth encoding.
- **Boundaries are layered and each special-cases control-flow errors in the same
  order:** unauthenticated → chunk-load → cancellation → generic. Any new boundary
  should follow that order (route-error.tsx, root-route-components.tsx,
  federation-error-boundary.tsx all match).
- **The recurring meta-bug is "state resolved asynchronously, read too early or
  scoped too broadly":** cache scope (P1), pre-unload teardown (P2), out-of-order
  fetch (P3), flag defaults (P9), chained queries (P10) are all the same shape.
</content>
