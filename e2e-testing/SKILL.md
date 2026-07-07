---
name: e2e-testing
description: Playwright + Testcontainers + axe-core E2E patterns for forms, tables, and workflows. Use when writing or fixing e2e specs, fixtures, browser tests, or debugging flaky Playwright runs.
paths:
  - "e2e/**/*.spec.ts"
  - "playwright.config.ts"
---

# E2E Testing
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

Setup (install, config, fixtures, Testcontainers): see [SETUP.md](SETUP.md).
