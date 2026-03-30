---
name: setup-e2e-testing
description: Configure Playwright for end-to-end testing with Testcontainers for infrastructure, axe-core for accessibility audits, and test patterns for forms, tables, and multi-step workflows. Use when setting up e2e tests, writing Playwright tests, or adding accessibility testing to a frontend project.
---

# Setup E2E Testing

## What This Sets Up

- **Playwright** for browser-based end-to-end testing
- **Testcontainers** for spinning up backend services (databases, APIs) in Docker during tests
- **@axe-core/playwright** for automated WCAG 2.1 AA accessibility audits in every test
- Test patterns and naming conventions

See [REFERENCE.md](REFERENCE.md) for detailed patterns, Testcontainers setup, and accessibility testing.

## Steps

### 1. Install dependencies

```bash
bun add -D @playwright/test @testcontainers/playwright @axe-core/playwright --yarn
bunx playwright install --with-deps chromium
```

### 2. Configure Playwright

Create `playwright.config.ts`:

```ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: process.env.CI ? 'github' : 'html',
  use: {
    baseURL: process.env.BASE_URL ?? 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
})
```

### 3. Add package.json scripts

```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:debug": "playwright test --debug"
  }
}
```

### 4. Create test directory structure

```
e2e/
├── fixtures/          # Shared test fixtures and page objects
│   └── base.ts        # Extended test with axe-core
├── helpers/           # Testcontainers setup, utilities
└── *.spec.ts          # Test files
```

### 5. Set up axe-core base fixture

Create `e2e/fixtures/base.ts`:

```ts
import { test as base } from '@playwright/test'
import AxeBuilder from '@axe-core/playwright'

export const test = base.extend<{ makeAxeBuilder: () => AxeBuilder }>({
  makeAxeBuilder: async ({ page }, use) => {
    await use(() => new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']))
  },
})

export { expect } from '@playwright/test'
```

### 6. Verify

- [ ] `bunx playwright test --list` shows discovered tests
- [ ] Testcontainers can start Docker containers in CI
- [ ] axe-core fixture is available in all tests
- [ ] `e2e/` directory structure exists

### 7. Commit

Stage and commit: `Add Playwright e2e testing with Testcontainers and axe-core`
