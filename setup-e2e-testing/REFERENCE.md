# E2E Testing Reference

## Test File Naming

- `e2e/*.spec.ts` — all e2e tests use `.spec.ts` extension
- Name files by feature/workflow: `login.spec.ts`, `create-topic.spec.ts`
- Group related tests in `test.describe` blocks

## Test ID Conventions

Use `data-testid` attributes for stable selectors:

| Pattern | Example |
|---------|---------|
| `{feature}-{element}` | `data-testid="login-submit-button"` |
| `{feature}-{element}-{index}` | `data-testid="topic-row-0"` |
| `{feature}-{state}` | `data-testid="login-error-message"` |

Selector priority: `getByRole` > `getByLabel` > `getByText` > `getByTestId` > CSS selectors.

## Accessibility Testing with axe-core

Run accessibility audits in every test that navigates to a new page:

```ts
import { test, expect } from '../fixtures/base'

test('create topic page is accessible', async ({ page, makeAxeBuilder }) => {
  await page.goto('/topics/create')

  const results = await makeAxeBuilder().analyze()
  expect(results.violations).toEqual([])
})
```

### Exclude known issues temporarily

```ts
const results = await makeAxeBuilder()
  .exclude('.third-party-widget')  // vendor component we can't control
  .analyze()
```

### Test specific WCAG rules

```ts
const results = await makeAxeBuilder()
  .withRules(['color-contrast', 'label', 'aria-required-attr'])
  .analyze()
```

## Testcontainers Setup

Spin up real backend services for integration-level e2e tests:

```ts
import { GenericContainer, Wait } from 'testcontainers'

let container: StartedTestContainer

test.beforeAll(async () => {
  container = await new GenericContainer('redpandadata/redpanda:latest')
    .withExposedPorts(9092, 8082)
    .withWaitStrategy(Wait.forLogMessage('Successfully started Redpanda'))
    .start()

  process.env.BASE_URL = `http://${container.getHost()}:${container.getMappedPort(8082)}`
})

test.afterAll(async () => {
  await container.stop()
})
```

### Docker Compose for multi-service stacks

```ts
import { DockerComposeEnvironment } from 'testcontainers'

let environment: StartedDockerComposeEnvironment

test.beforeAll(async () => {
  environment = await new DockerComposeEnvironment('.', 'docker-compose.test.yml')
    .withWaitStrategy('api', Wait.forHealthCheck())
    .up()
})

test.afterAll(async () => {
  await environment.down()
})
```

## Test Patterns

### Forms

```ts
test('submit create topic form', async ({ page }) => {
  await page.goto('/topics/create')

  await page.getByLabel('Topic name').fill('my-topic')
  await page.getByLabel('Partitions').fill('3')
  await page.getByRole('button', { name: 'Create' }).click()

  await expect(page.getByText('Topic created')).toBeVisible()
})
```

### Tables

```ts
test('topics table shows entries', async ({ page }) => {
  await page.goto('/topics')

  const rows = page.getByRole('row')
  await expect(rows).toHaveCount(6) // header + 5 data rows

  // Verify specific cell content
  await expect(rows.nth(1).getByRole('cell').first()).toHaveText('my-topic')
})
```

### Multi-step workflows

```ts
test('wizard flow completes', async ({ page }) => {
  await page.goto('/connectors/create')

  // Step 1
  await page.getByRole('button', { name: 'S3 Sink' }).click()
  await page.getByRole('button', { name: 'Next' }).click()

  // Step 2
  await page.getByLabel('Bucket').fill('my-bucket')
  await page.getByRole('button', { name: 'Next' }).click()

  // Step 3 — review and submit
  await expect(page.getByText('my-bucket')).toBeVisible()
  await page.getByRole('button', { name: 'Create' }).click()

  await expect(page.getByText('Connector created')).toBeVisible()
})
```

### Waiting for async operations

```ts
// Wait for network idle after navigation
await page.goto('/topics', { waitUntil: 'networkidle' })

// Wait for specific API response
const responsePromise = page.waitForResponse('**/api/topics')
await page.getByRole('button', { name: 'Refresh' }).click()
await responsePromise

// Wait for element state
await expect(page.getByRole('table')).toBeVisible({ timeout: 10_000 })
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

Key agent-browser commands: `open <url>`, `snapshot`, `screenshot`, `fill @ref "value"`, `press Enter`, `wait --text "X"`, `close`.
