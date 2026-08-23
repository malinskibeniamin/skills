---
title: "/e2e-testing"
description: "Playwright + Testcontainers + axe-core E2E patterns for forms, tables, and workflows. Use when writing or fixing e2e specs, fixtures, browser tests, or debugging flaky Playwright runs."
type: skill
sidebar:
  label: "/e2e-testing"
---
![Diagram of the /e2e-testing skill](/diagrams/skills/e2e-testing.svg)

[Open the editable Excalidraw source](/diagrams/skills/e2e-testing.excalidraw)

Run `/read-the-damn-docs` before pinning current Playwright, Testcontainers, axe-core, or browser-tooling APIs.
## Conventions

- `e2e/*.spec.ts` -- all e2e tests use `.spec.ts`
- Name by feature: `login.spec.ts`, `create-topic.spec.ts`
- Selectors: `getByRole` > `getByLabel` > `getByText` > `getByTestId` > CSS
- Test IDs: `{feature}-{element}`, `{feature}-{element}-{index}`, `{feature}-{state}`

## Edit-time Hooks

- **route sibling test**: when a route or `*.page.tsx` changes, run sibling `*.browser.test.*` or `*.integration.test.*`; block if it fails.
- **structural refactor test nudge**: new `*.page.tsx` or split component file needs accompanying `.test`, `.integration.test`, or `.browser.test`.

## Accessibility -- axe on every page

```ts
import { test, expect } from '../fixtures/base'
test('page is accessible', async ({ page, makeAxeBuilder }) => {
  await page.goto('/topics/create')
  const results = await makeAxeBuilder().analyze()
  expect(results.violations).toEqual([])
})
```

## Determinism rules (mined from years of flake fixes)

- **Wait for a cause, never a duration**: `waitForURL()` after navigation clicks, `waitForResponse()`/`waitForRequest()` before asserting UI the RPC drives, element-state waits otherwise. No `waitForTimeout`; no `expect.soft` inside `toPass` (soft failures never retry the block).
- **Timed behavior belongs below E2E**: prove debounce/delay deadlines and cancellation with fake timers in unit/integration tests; E2E asserts the visible outcome without sleeping.
- **No `force: true` clicks** -- if the element needs forcing, something obstructs it and users hit the same wall; fix the obstruction.
- **Match RPC routes on `Service/Method` only**, never version-pinned (`v1alpha1` in a matcher breaks on the next API bump).
- **`test.step()` around every logical action** -- CI failure output then names the exact step; the smaller the step, the faster the diagnosis.
- **Ephemeral UI**: run the suite with a test-mode flag that keeps toasts from auto-dismissing; assert side effects (request fired, row appeared), not toast text.
- **Clipboard/permission-dependent specs run Chromium-only** (Firefox/WebKit permission models differ).
- **Debuggability is part of the test**: buffer backend/container logs so they survive teardown; on `start()` failure capture logs before bailing. Redact secrets/tokens from failure dumps.
- Retries: 1 in CI as a stopgap, 0 as the goal; a spec that needs retries has a wait bug. Locally prefer the markdown reporter (LLM-token-friendly).
- Quality over quantity: delete render-only specs; every spec must exercise a side effect a user can cause.

## Generated browser exploration

When a credible customer contract spans combinatorial state transitions and cannot be
proved at a cheaper seam, use narrow generated action sequences or a stateful property.
Follow the runner-neutral [property-based testing guide](https://github.com/malinskibeniamin/skills/blob/v4.37.0/tdd/PROPERTY-BASED-TESTING.md):
keep an independent boundary oracle, preserve replay evidence, and turn each real finding
into a deterministic regression. Generated exploration complements fixed journeys,
cross-browser checks, accessibility, visual review, and dogfood; it replaces none of them.

## Long-lived SPA resources

For listeners, detached DOM, timers, subscriptions, or heap growth that accumulates
within one browser context, read [SOAK-TESTING.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/e2e-testing/SOAK-TESTING.md). Treat the repeated
round trip as a resource-lifetime contract; ordinary isolated E2E tests cannot prove it.

## Monitor for E2E
`Monitor: bun run test:e2e` -- stream results, react fail before suite finish.

## Agent-Browser vs Playwright

| Task | Tool |
|------|------|
| Test suites | Playwright via `Monitor: bun run test:e2e` |
| Generate selectors | `agent-browser snapshot` (a11y tree) |
| Visual smoke test | `agent-browser screenshot --annotate` |
| Interactive debug | Playwright UI mode |
| CI | Playwright |
| AI page inspection | agent-browser |

Setup (install, config, fixtures, Testcontainers): see [SETUP.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/e2e-testing/SETUP.md).
