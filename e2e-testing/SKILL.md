---
name: e2e-testing
description: Use when writing or fixing Playwright E2E specs, fixtures, browser tests, or flakes.
paths:
  - "e2e/**/*.spec.ts"
  - "playwright.config.ts"
---

# E2E Testing

Run `/read-the-damn-docs` before choosing Playwright, Testcontainers, axe-core, or browser APIs.
Setup: [SETUP.md](SETUP.md).

## Conventions

- Put E2E tests in `e2e/*.spec.ts`; name files by feature.
- Select with `getByRole` > `getByLabel` > `getByText` > `getByTestId` > CSS.
- Test IDs use `{feature}-{element}`, optional index, or state.
- Reuse owning browser/integration checks after route edits. A new page or extracted
  component alone needs no test; apply the [authoring gate](../test-audit/SKILL.md#authoring-gate).
- Test boundary risks through the real user path and assert its visible or durable result.
  Keep the changed integration real; route stubs prove UI states, not integration.

## Accessibility and browsers

Run axe on every page. An axe-only pass does not prove keyboard order, focus, names,
zoom, or assistive-technology behavior.

Run the full suite in Chromium by default on PRs; affected-only selection needs
[CI fixes](../ci-fixes/SKILL.md) proof. Run full regression on the combined candidate before
merge, preferably in a merge queue. Run critical journeys and engine risks (`@cross-browser`) in Firefox and WebKit before merge.
Supplement required checks with nightly matrices.
Emulation cannot prove every browser/device combination.

## Determinism

- Wait for causes, never durations. Register response/request/render promises before the
  action. After `waitForURL`, assert a destination landmark. Ban `waitForTimeout` and
  `expect.soft` inside `toPass`.
- Test navigation races by delaying A, starting A, navigating to B, then proving B's state
  and effects while A stays absent.
- Prove debounce deadlines and cancellation with fake timers below E2E; E2E asserts visible
  outcomes without sleeping.
- Never use `force: true`; fix the obstruction a user would hit.
- Match RPC routes by `Service/Method`, never a versioned prefix.
- Wrap logical actions in `test.step()` so CI identifies the failed step.
- Keep ephemeral UI visible in test mode, but assert lasting side effects rather than toast text.
- Run clipboard and permission-specific specs in Chromium; cover equivalent outcomes elsewhere.
- Buffer backend/container logs through teardown and capture startup failures. Redact secrets.
- Use zero test retries; preserve first-attempt failures and fix their cause. Follow
  [CI flake diagnosis](../ci-fixes/references/test-signal.md#12-diagnose-flakes), not retry-to-green.
  Prefer compact local reporters.
- Assert consequential outcomes, including read-only journeys. A render-only smoke needs
  a distinct failure mode; a static landmark alone cannot prove a journey.

## Generated and long-lived exploration

For combinatorial contracts, use narrow generated sequences or a stateful property.
[PROPERTY-BASED-TESTING.md](../tdd/PROPERTY-BASED-TESTING.md): keep an independent oracle
and replay seed; turn real findings into deterministic regressions. Supplement fixed journeys,
cross-browser checks, accessibility, visual review and dogfood.

For listener, DOM, timer, subscription or heap growth, use same-context
[SOAK-TESTING.md](SOAK-TESTING.md); isolated E2E cannot prove resource lifetime.

## Evidence and tools

Monitor `bun run test:e2e`; react to failures before completion.

For interactive tools, use [browser/data guidance](../dogfood/SKILL.md#browser-and-data-tasks).
When permitted, use agent-browser interactively; use Playwright Test in CI.
Saved flows do not replace UI assertions; retain browser, accessibility and cross-browser coverage.

| Need | Tool |
|---|---|
| CI/test suite | Playwright Test |
| Selector or AI inspection | `agent-browser snapshot` |
| Visual smoke evidence | `agent-browser screenshot --annotate` |
| Interactive debugging | Playwright UI mode |

Opt-in Browser Use: [guide](BROWSER-USE.md).
