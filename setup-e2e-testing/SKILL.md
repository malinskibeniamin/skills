---
name: setup-e2e-testing
description: Set up Playwright + Testcontainers + axe-core for e2e and accessibility testing. Includes patterns for forms, tables, workflows. Use when setting up e2e tests or writing Playwright tests.
paths:
  - "e2e/**/*.spec.ts"
  - "playwright.config.ts"
---

# E2E Testing

## Conventions

- `e2e/*.spec.ts` — all e2e tests use `.spec.ts` extension
- Name files by feature/workflow: `login.spec.ts`, `create-topic.spec.ts`
- Selector priority: `getByRole` > `getByLabel` > `getByText` > `getByTestId` > CSS selectors

### Test ID Pattern

| Pattern | Example |
|---------|---------|
| `{feature}-{element}` | `data-testid="login-submit-button"` |
| `{feature}-{element}-{index}` | `data-testid="topic-row-0"` |
| `{feature}-{state}` | `data-testid="login-error-message"` |

## Accessibility — Run axe on every new page

```ts
import { test, expect } from '../fixtures/base'

test('page is accessible', async ({ page, makeAxeBuilder }) => {
  await page.goto('/topics/create')
  const results = await makeAxeBuilder().analyze()
  expect(results.violations).toEqual([])
})
```

## Agent-Browser vs Playwright

| Task | Use |
|------|-----|
| Running test suites | Playwright (`bun run test:e2e`) |
| Generating test selectors | `agent-browser snapshot` (a11y tree → getByRole) |
| Visual smoke test | `agent-browser screenshot --annotate` |
| Interactive debugging | Playwright UI mode (`bun run test:e2e:ui`) |
| CI execution | Playwright |
| AI-driven page inspection | agent-browser |

For initial setup (install, config, fixtures, Testcontainers): see [SETUP.md](SETUP.md).
