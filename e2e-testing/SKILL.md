---
name: e2e-testing
description: Use when writing or fixing Playwright E2E specs, fixtures, browser tests, or flakes.
paths:
  - "e2e/**/*.spec.ts"
  - "playwright.config.ts"
---

# E2E Testing

Run `/read-the-damn-docs` before choosing current Playwright, Testcontainers, axe-core, or
browser APIs. Setup belongs in [SETUP.md](SETUP.md).

## Conventions

- Put E2E tests in `e2e/*.spec.ts`; name files by feature.
- Select with `getByRole` > `getByLabel` > `getByText` > `getByTestId` > CSS.
- Test IDs use `{feature}-{element}`, optional index, or state.
- The route sibling hook runs nearby browser/integration tests after route edits.
- The structural refactor hook requires a test for new pages or extracted components.

## Accessibility and browsers

Run axe on every page, but automated accessibility covers only a subset. An axe-only pass
does not prove keyboard order, focus, names, zoom, or assistive-technology behavior.

On PRs, run the full suite in Chromium. Tag critical journeys and credible engine risks
`@cross-browser`; run those in Firefox and WebKit. Reserve the full browser matrix for a
nightly lane or release gate. Emulation cannot prove every branded browser or physical device.

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
- Use one CI retry only as a stopgap and zero as the goal. Prefer compact local reporters.
- Delete render-only specs; each journey exercises a user-caused side effect.

## Generated and long-lived exploration

For combinatorial customer contracts that cannot be proved cheaper, use narrow generated
action sequences or a stateful property. Follow
[PROPERTY-BASED-TESTING.md](../tdd/PROPERTY-BASED-TESTING.md): keep an independent oracle and
replay seed, then convert real findings to deterministic regressions. This complements fixed
journeys, cross-browser checks, accessibility, visual review, and dogfood.

For listener, DOM, timer, subscription, or heap growth within one browser context, use
[SOAK-TESTING.md](SOAK-TESTING.md). Isolated E2E tests cannot prove resource lifetime.

## Evidence and tools

Monitor `bun run test:e2e`; react to failures before completion.

| Need | Tool |
|---|---|
| CI/test suite | Playwright |
| Selector or AI inspection | `agent-browser snapshot` |
| Visual smoke evidence | `agent-browser screenshot --annotate` |
| Interactive debugging | Playwright UI mode |
