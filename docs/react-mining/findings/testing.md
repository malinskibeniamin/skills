# Testing patterns — mined from 4 years of Engineer A's frontend commits

Scope: vitest unit/integration, vitest-browser visual regression, Playwright e2e, flake fixes, test infra, mocking strategy, CI reliability. Corpus: `engineer-a-frontend-commits.txt` (4,050 commits). ~359 e2e-keyword, ~871 test-keyword, 26 explicit "flak" commits.

## Context: two testing eras + a four-layer pyramid

The repo contains **two distinct e2e worlds**, and the shift between them is itself the biggest finding:

- **Legacy (`tests/e2e-ui`, cloud-ui/admin-ui)** — Playwright against a **real Auth0 + real backend**, `__checks__/` feature dirs, `.utils.ts` page-object helpers, `waitForElementStrict/Soft`, `@critical`/`@non-critical` tags, long-running seeded clusters/networks. Flaky by nature (auth webhooks, network, cold caches).
- **Modern (`apps/adp-ui/e2e`)** — Playwright with **all network mocked at the `page.route` layer**, journey `*.spec.ts` files, a shared `tests/base.ts` fixture, no real auth (localStorage bypass compiled into the build). CPU-bound, deterministic, fast.

The full pyramid Engineer A converged on (adp-ui):
1. `*.test.ts` — pure unit (happy-dom).
2. `*.integration.test.tsx` — component + RTL + module-mocked hooks (happy-dom, sharded in CI).
3. `*.browser.test.tsx` — vitest-browser visual regression, real Chromium, **Linux/Chromium baselines committed to git**, run in both light and dark.
4. `e2e/*.spec.ts` — Playwright journeys, network fully mocked, **functional correctness only — screenshots are informational, never `toHaveScreenshot`** (visual regression is layer 3's job).

This division of labor is explicitly documented in `apps/adp-ui/e2e/tests/base.ts`:
> "Do NOT use `toHaveScreenshot()` in e2e tests… Visual regression detection belongs in Vitest browser tests (*.browser.test.tsx), which commit Linux/Chromium baselines. E2e tests focus on functional correctness only."

---

## Pattern 1 — Role + accessible-name lookups over loose text queries

**Description.** For any element that carries a decorative icon, opens in a portal, or shares text with other nodes — menu items, buttons, options, Stripe inputs — query by `getByRole/findByRole(role, { name })`, never `findByText`/`getByText(/loose/)`. Role+name matching ignores decorative icons, waits on the real interactive node entering the a11y tree, and can't accidentally match incidental labels or timestamps. This is the single most common flake root-cause in the corpus.

**Anti-pattern it replaces.** `findByText('Copy callback URLs')` races the DropdownMenu open transition and matches decorative-icon text nodes; `getByText(/10/)` matches a wall-clock timestamp during the 10 o'clock hour; `getByText('Card number')` matches an incidental label instead of the Stripe input.

**Evidence.**
- `5986cbf5` (2026-06-05) — de-flake oauth-clients row-action menu: switched two lookups from exact-text `findByText` to `findByRole('menuitem', { name })`, "the same robust pattern the passing sibling tests already use." Role+name "ignores the decorative icon and waits on the actual menu item."
- `6042c5d7` (2026-04-24) — Stripe form readiness wait tightened from `getByText('Card number')` to `getByRole('textbox', { name: 'Card number' })` "so we only match the interactive input, not incidental labels."
- `ac3f0f9c` (2026-06-11) — dropped a `getByText(/10/)` loose query that matched the rendered wall-clock timestamp during any 10 o'clock hour (TZ=GMT); the exact `'3 / 10'` assertion already locks the rendering.

**Enforcement.** `hook` — flag `getByText(/…/ )` / `findByText(/…/)` **regex** arguments in `*.test.tsx`/`*.spec.ts` as high-flake (loose text match); nudge toward `getByRole(role, { name })`. Also flag `getByText('literal')` used as a click/interaction target (vs a plain assertion). Detection: `(get|find|query)ByText\(\s*/` regex literal, or `getByText(...).click()`.

---

## Pattern 2 — Wrap visibility/negative assertions in waitFor/expect.poll for animated & async-swap UI

**Description.** A one-shot synchronous `expect(...).toBeVisible()` or `expect(queryBy...).toBeNull()` catches base-ui/Radix components mid-transition (fade-in `opacity:0`) or mid-async-swap. `findByRole` resolves the moment an element enters the a11y tree, but jest-dom `toBeVisible` fails on `opacity:0`. Wrap the visibility/absence check in `waitFor`/`vi.waitFor`/`expect.poll` so it retries until the transition settles. Group co-dependent assertions in **one** `waitFor` so they settle together.

**Anti-pattern it replaces.** `expect(await findByRole('menuitem')).toBeVisible()` firing during a fade-in; `expect(queryByRole('option')).toBeNull()` checked before the combobox filter runs; a bare absence assertion (`not.toContain('"type"')`) placed outside the `waitFor` that guards the async snippet swap.

**Evidence.**
- `933940283` (2026-06-17) — wrapped `expect(await findByRole('menuitem')).toBeVisible()` in `waitFor`: base-ui DropdownMenu "opens with a fade-in animation — so the one-shot synchronous visibility check could catch the menu mid-transition."
- `2003cf5f` (2026-06-10) — moved a bare `expect(container.textContent).not.toContain('"type"')` **into** the same `waitFor` as the url assertion: "under parallel CI load the previous client's highlighted snippet (which does carry `"type"`) can still be mid-swap."
- `50c4550d` (2026-06-11) — region-select negative assertions `queryByRole('option').toBeNull()` wrapped in `waitFor` so they wait for combobox filtering.

**Enforcement.** `skill` — "A synchronous visibility or negative (`toBeNull`/`not.toContain`) assertion that follows an async `find*`/user event on animated base-ui/Radix UI is a flake. Wrap it in `waitFor`/`expect.poll`; put co-dependent assertions in the same `waitFor` block so they settle atomically." Partially checkable as a `hook`: flag `expect(queryBy…).toBeNull()`/`.not.toBeInTheDocument()` **not** inside a `waitFor` in the same statement group.

---

## Pattern 3 — Replace fixed sleeps and no-op waits with condition polling

**Description.** Never `setTimeout`/`page.waitForTimeout` before an assertion — poll the actual condition with `vi.waitFor`/`waitFor`/`expect.poll`. It is both deterministic and faster (polling settles in ~80ms vs a fixed 400ms). Also: audit "wait" helpers that don't actually wait.

**Anti-pattern it replaces.** `await new Promise(r => setTimeout(r, 400))`; a `waitForElementSoft` that wrapped `expect.soft()` inside `toPass()` — `expect.soft` never throws, so `toPass` resolved instantly and the "wait" was a silent no-op (root cause of flake across 5 test suites); a `setTimeout(0)` scheduler-flush band-aid in `afterEach`.

**Evidence.**
- `e408afc9` (2026-06-13) — "replace 400ms sleep with waitFor": `vi.waitFor` is "deterministic and faster (about 80ms versus 400ms-plus)."
- `02aaa58b` (2026-04-14) — "make waitForElementSoft actually wait": `expect.soft()` inside `toPass()` "never throws — making the retry a no-op that resolves instantly without waiting. This was the root cause of flakiness across resource-group, service-account, SSO, user, and billing tests." Aliased to `waitForElementStrict`.
- `7a22c539` (2026-04-16) — removed a `setTimeout(0)` flush from `afterEach`: "The setTimeout(0) flush was a band-aid. The proper fix is clearing router store listeners and QueryClient caches synchronously."

**Enforcement.** `hook` — already have "no `waitForTimeout`". Extend detection to: `setTimeout(` / `new Promise(resolve => setTimeout` inside `*.test.*`/`*.spec.*`; and `expect.soft(` used **inside** `.toPass(` / `waitFor(` (the no-op-wait trap). Both are mechanically greppable.

---

## Pattern 4 — Unmocked-request safety-net fixture (network isolation as a test invariant)

**Description.** The adp-ui e2e suite mocks **all** network at `page.route`. A shared `base.ts` fixture registers a catch-all route **first** (Playwright dispatches LIFO, so it runs last), lets through only static app assets + an allowlist of external URLs, and **fails the test if any unmocked call leaked**. It also seeds default empty-list RPC mocks for every sidebar/prefetch RPC (TanStack Router preloads sibling route data on hover), so tests don't randomly fail on incidental prefetches. Per-test mocks registered later win via LIFO.

**Why.** Real-backend e2e (legacy `tests/e2e-ui`) was the dominant flake source (auth webhooks, cold caches, network). Full mocking makes runs CPU-bound and deterministic, and the safety net turns "forgot to mock an endpoint" from a silent flake into a loud, actionable failure listing every leaked call.

**Anti-pattern it replaces.** e2e hitting real Auth0/backends; silent fall-through to a live service; forgetting a prefetch mock and getting sporadic failures near the sidebar.

**Evidence.**
- `apps/adp-ui/e2e/tests/base.ts` (current) — catch-all LIFO guard, static-asset/allowlist gate, `_unmockedGuard` auto-fixture that throws `"Unexpected network calls detected — add a page.route() mock…"` listing each call; seeds `ListAgents`/`ListMCPServers`/`ListLLMProviders`/… empty defaults.
- `3e253c18` (2026-06-05) / `54bf4d67` (2026-06-05) — "mock ListGuardrails in the api-error-handling e2e" / "in LLM-provider e2e" — the safety net surfacing missing prefetch mocks.
- `b3ec6556` (2026-07-09) — "mock GetADPConfig in embedded bridge e2e" — same net catching a new dependency.

**Enforcement.** `exemplar` — `apps/adp-ui/e2e/tests/base.ts` is the canonical fixture; new e2e specs must `import { test, expect } from './base'` (never `@playwright/test` directly). Add a `hook`: in `apps/adp-ui/e2e/tests/*.spec.ts`, flag `from '@playwright/test'` imports of `test`/`expect` — must come from `./base`.

---

## Pattern 5 — Module-mock the data/router layer for integration & browser tests; typed mock factories

**Description.** Integration and browser tests don't hit `page.route`; they `vi.mock` the connect-query and TanStack Router modules with a **shared typed factory** (`mockConnectQuery()`, `mockRouterForBrowserTest()` in `src/__tests__/browser-test-utils.tsx`). The connect-query mock returns a no-op surface for **every** hook variant (`useQuery`, `useSuspenseQuery`, `useMutation`, `useInfiniteQuery`, `useSuspenseInfiniteQuery`, …) so a route file that pulls a hook in transitively doesn't crash at import time; per-test mocks override the specific hook. This is the layer-2/3 analogue of the layer-4 `page.route` net.

**Anti-pattern it replaces.** Ad-hoc per-file `vi.mock` bodies that miss a transitively-imported hook and crash at import; hand-rolled router stubs that drift.

**Evidence.**
- `browser-test-utils.tsx` (current) — `mockConnectQuery()` documents each no-op fallback and *why* (e.g. `useSuspenseQuery` "so route files that hit a service via the suspense variant don't crash at import-time").
- `9098b461` (2026-06-08) — "add missing update mutation mocks in browser tests"; `29983059` (2026-07-07) — "mock useCreateGuardrailMutation in guardrails list browser test"; `f65c14de` (2026-06-09) — "stub router in connection-tab browser test"; `035f611f` (2026-06-18) — "fix browser-mock routeApi.useNavigate so search updates apply". A steady stream of "mock the hook that was added" fixes.
- `a5aaef45` (2026-05-25) — "mock recharts responsive container": `vi.mock('recharts', importOriginal)` forcing fixed `ResponsiveContainer` dimensions so charts render deterministically (ResponsiveContainer measures 0×0 in a headless render).

**Enforcement.** `exemplar` — `src/__tests__/browser-test-utils.tsx` (`mockConnectQuery`, `mockRouterForBrowserTest`, `getRouteComponent`). `skill`: "Integration/browser tests mock the connect-query + router modules via the shared factory in browser-test-utils, not per-file. `recharts` `ResponsiveContainer` must be mocked to fixed dimensions or charts render 0×0."

---

## Pattern 6 — Deterministic visual-regression capture: fixed frame, small viewport, tolerance tiers, dark mode

**Description.** vitest-browser `*.browser.test.tsx` files commit Linux/Chromium PNG baselines. Determinism is engineered: wrap subjects in a fixed-dimension `ScreenshotFrame`/`ScaledScreenshotFrame` (default narrow width to keep baselines small); disable animation (`isAnimationActive={false}`, `reducedMotion`); poll for async render completion (syntax highlighting) before capture; and use **named tolerance-tier constants** (`DENSE_FORM_SCREENSHOT_OPTIONS`, `CHART_SCREENSHOT_OPTIONS` at 0.10) rather than inline magic numbers, because dense forms and pattern-filled charts rasterize a few percent differently between the Linux CI writer and a macOS reviewer. Every browser test also runs in dark mode via a setup file that adds `.dark` to `<html>` and infixes `-dark` into the baseline filename.

**Anti-pattern it replaces.** Full-page screenshots whose async-settled height varies run-to-run (hard DIMENSION mismatch, no tolerance can absorb it); capturing a portaled tooltip overlay that's mid-paint; per-spec copy-pasted tolerance numbers; light-mode-only coverage missing dark-mode contrast regressions.

**Evidence.**
- `f2b56510` (2026-06-24) — "pin dcr-settings capture height": tall page's below-fold height varied 1444px vs 1542px run-to-run → clamp to a fixed 700px `ScaledScreenshotFrame` so the baseline dimension is deterministic.
- `6cdacc61` (2026-06-19) — "wait for highlighted json screenshots": `expect.poll(() => hasHighlightedJson(...))` before `toMatchScreenshot`, so syntax-highlight token `<span>`s exist before capture.
- `213574bd` (2026-06-24) — "mock tooltips in action-picker visual test": hiding via `display:none` was insufficient — an already-painted overlay landed in the graded capture (paint-vs-capture race); `vi.mock` the tooltip so no portal overlay can exist, "removing the flake structurally rather than racing the compositor."
- `77c8e356` (2026-06-14) — "capture every browser test in dark mode too" — reuses light config, layers a `.dark` setup file, infixes `-dark` into baseline filenames.

**Enforcement.** `exemplar` — `browser-test-utils.tsx` (`ScreenshotFrame`, `ScaledScreenshotFrame`, `DENSE_FORM_SCREENSHOT_OPTIONS`, `CHART_SCREENSHOT_OPTIONS`, `captureScreenshot`). `hook`: in `*.browser.test.tsx`, flag inline `allowedMismatchedPixelRatio:` / `maxDiffPixels:` numeric literals — must use a named tolerance-tier constant. `skill`: "browser screenshots wrap the subject in a fixed-dimension frame, poll async render before capture, and never rely on `display:none` to hide portaled overlays (mock the overlay component instead)."

---

## Pattern 7 — Retry auth at the setup layer, never inside the login helper

**Description.** For real-auth flows (Auth0 post-login webhook flakes intermittently), the recovery path is a **setup-level retry with a fresh browser context** (`auth.setup.ts` retry loop), not an in-function "navigate back and hope" retry inside the login helper. The helper's job is to throw cleanly on failure; the setup retry catches it and re-runs from scratch. Also: fail fast on the webhook error (don't wait out a 60s timeout).

**Anti-pattern it replaces.** In-function retry that navigates to app root after a webhook error — the app doesn't auto-login from error state, so the retry threw an error that *competed with* the setup-level retry; loose URL matching (`error=` as well as `code=`) that masked the failure instead of throwing.

**Evidence.**
- `931b649b` (2026-04-14) — "remove broken in-function auth retry, rely on setup retry": restored strict `code=`-only URL matching so the helper throws cleanly and `auth.setup.ts`'s retry loop recovers with a fresh context.
- `4c666b66` (2026-04-14) — "add in-step retry for billing auth setup"; `95a69efe` (2026-04-14) — "add retry to default auth"; `6d41a99c` (2026-04-14) — "add auth retry for webhook flakiness."
- `614a924e` (2026-04-14) — "fail fast on Auth0 webhook error instead of 60s timeout."

**Enforcement.** `skill` — "Auth/setup flake recovery belongs in the setup project's retry loop with a fresh context, not in the login helper. The helper throws cleanly; strict URL matching (`code=` only) so a webhook failure surfaces instead of hanging. Fail fast on known error states rather than timing out." (Legacy-suite specific; low mechanical checkability → skill.)

---

## Pattern 8 — Wait for the RPC response before asserting the UI state it drives

**Description.** When an action fires a mutation and the UI updates only after the refetch settles, assert on the **network response first** (`waitForResponse`/`waitForRequest`), then assert UI state with a longer timeout. On a cold React Query cache the refetch can exceed the default 15s. Ordering the wait on the actual causal event (response → UI) removes the guesswork.

**Anti-pattern it replaces.** Asserting a button becomes disabled "within DEFAULT_TIMEOUT" immediately after the mutation, before the cold-cache refetch completes; redundant/duplicate `waitForRequest` calls that don't match the causal ordering.

**Evidence.**
- `6042c5d7` (2026-04-24) — payment: `setDefaultPaymentMethod` asserted delete-button-disabled within 15s, but "on cold cache React Query takes longer to refetch. Wait for the SetDefaultPaymentMethod response first, then assert UI state with DEFAULT_TIMEOUT_LONG (30s)."
- `6751507f` (2024-06-08) — "Refactor waitForResponse/toast soft assertations."
- `409a6bd3` (2024-06-07) — "remove redundant waitForRequest calls"; `f690608f` (2024-06-25) — "make marketplace test wait for redirect rather than API call" (wait on the *observable outcome*, not the intermediate call).

**Enforcement.** `skill` — "After a mutation, wait on the RPC response (`page.waitForResponse`) before asserting the UI it drives; cold-cache refetches can exceed the default timeout. Prefer waiting on the observable outcome (redirect, rendered value) over intermediate API calls."

---

## Pattern 9 — Tune the runner to the workload; keep flake-prone tiers non-blocking with sticky reporting

**Description.** Because adp-ui e2e mocks all network, workers are **CPU-bound**, so throughput scales with cores (`workers: '100%'` on a 16-vcpu runner) — but WebKit is heavier and saturates the box, so it runs at `50%` and is sharded. Pixel-diff and cross-browser e2e are the most flake-prone tiers, so they are `continue-on-error: true` (non-blocking) with a single CI `retries: 1`, a **failure-only sticky PR comment** (update-or-create by marker, self-deletes when green), and full Playwright report/trace/video artifacts on failure. lint/type-check/unit/integration/build stay as the hard merge gates. Build once, share the artifact across matrix legs (`ADP_UI_E2E_SKIP_BUILD=1`).

**Anti-pattern it replaces.** Uniform worker count that saturates on WebKit and batch-fails unrelated specs faster than the retry can absorb; a single cross-browser flake turning the merge gate red; re-building the app in every matrix leg; `rsbuild dev` in CI (its error overlay intercepts pointer events under parallel load, and on-demand compilation causes Module Federation "factory is undefined" first-load races) — CI serves the static build via `rsbuild preview`.

**Evidence.**
- `2761479f` (2026-06-18) — "run webkit e2e at 50% workers to fix CPU-contention flake": WebKit at 100% "saturate[s] the box and a sustained burst of click/expect timeouts can outlast the single retry (a recent run batch-failed ~8 unrelated webkit specs together, all generic actionability timeouts)."
- `800fd6a7` (2026-04-27) — "speed up CI, non-block flaky tiers, sticky failure comment": build artifact shared across legs, integration sharded 1/2+2/2, browser+e2e `continue-on-error`, `report-failures` sticky comment that self-deletes when green.
- `917d31d3` (2026-06-14) — "keep the renamed e2e/visual checks non-blocking + add a CI retry": `retries=1` because "these specs mock all network, so a failure is almost always CPU-contention flake"; kept `wait-for-checks` ignore list in sync when check names changed.

**Enforcement.** `skill` — "Mocked-network e2e is CPU-bound: size workers to cores, throttle the heavy engine (WebKit 50%). Serve the static build via `rsbuild preview` in CI, never `rsbuild dev` (error-overlay pointer interception + Module Federation cold-compile races). Flake-prone tiers (pixel diff, cross-browser) stay non-blocking with `retries:1` + sticky failure comment; lint/type/unit/integration/build are the hard gates." `exemplar`: `apps/adp-ui/e2e/playwright.config.ts` (heavily commented rationale).

---

## Pattern 10 — Reset mock state between tests so assertions can't leak

**Description.** Add `afterEach(() => vi.clearAllMocks())` when consecutive tests assert on the same mock's call history — otherwise `mockFn.toHaveBeenCalledWith(...)` in test 2 passes on test 1's leftover calls even if test 2's code path never fired. Mirrors the isolation the Playwright fixture gives e2e.

**Anti-pattern it replaces.** Accumulated `mockShowToast` call history across BYOC and Dedicated tests, making the second test's `toHaveBeenCalledWith` a false pass.

**Evidence.**
- `9482bcbc` (2026-04-28) — "clear mocks between settings delete tests": "without afterEach(vi.clearAllMocks), mockShowToast call history accumulates between the BYOC and Dedicated tests, so the second test's toHaveBeenCalledWith assertion would pass even if the Dedicated path never fired the toast."
- `727ead66` (2026-04-28) — "mock showToast in cluster settings delete tests" (same suite hardening).
- `861a5943` (2026-04-27) — "silence stub-data-provider warnings in test runs" (companion isolation/noise cleanup).

**Enforcement.** `hook` — in a `*.test.tsx` file where a `vi.fn()`/`vi.mock` result is asserted with `toHaveBeenCalled*` in **more than one** `test()`, require an `afterEach(vi.clearAllMocks|vi.resetAllMocks)` or per-test re-creation. Heuristic but greppable: multiple `toHaveBeenCalled` on the same identifier + no `clearAllMocks/resetAllMocks` in the file.

---

## Cross-cutting notes / refinements to ALREADY-ENCODED rules

- **Refinement to "userEvent.setup()"**: for **combobox/typeahead filtering**, `user.keyboard('tokyo')` was replaced with `fireEvent.change(combobox, { target: { value: 'tokyo' } })` (`defff748`, 2026-06-11). userEvent's per-keystroke dispatch raced the debounced filter under parallel load; a single `fireEvent.change` sets the value atomically. This is a **deliberate exception** to the general "prefer userEvent" rule — worth capturing so the skill doesn't flag it as a regression.
- **Refinement to "createRouterTransport for ConnectRPC mocks"**: adp-ui does **not** use `createRouterTransport` — it introduced **runtime transport seams** (`ad94941f` foundation 2026-05-19, `bc96eb18` 2026-06-03, `179bb005` centralized gateway-rpc hook 2026-05-28) and mocks at that seam or via `page.route` RPC regex. No MSW anywhere in the corpus. The mocking layer is transport-seam + `vi.mock('@connectrpc/connect-query')` (browser/integration) and `page.route(rpcRoute(method))` (e2e).
- **`test.step` / tags**: journey specs tag with `{ tag: ['@smoke', '@feat:llm', '@flow:crud'] }` for selective CI runs — richer than the encoded `@critical`/`@non-critical`.
- **RPC route matching by regex, not glob** (`base.ts`): `new RegExp('/${method}(?:[/?#]|$)')` used over `**/Method` glob "so cross-origin URLs match deterministically."

## Strongest single SHA per pattern (for the compact summary)
1. `5986cbf5` · 2. `933940283` · 3. `02aaa58b` · 4. `base.ts` (infra) · 5. `a5aaef45` · 6. `f2b56510` · 7. `931b649b` · 8. `6042c5d7` · 9. `2761479f` · 10. `9482bcbc`
