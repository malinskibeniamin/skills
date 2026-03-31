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

## Debugging Failed Tests

1. **Trace viewer**: `bunx playwright show-trace trace.zip` — recorded on first retry
2. **Screenshots**: saved on failure in `test-results/`
3. **UI mode**: `bun run test:e2e:ui` — step through tests visually
4. **Debug mode**: `bun run test:e2e:debug` — pause on each action with inspector

## Agent-Browser (Optional)

[agent-browser](https://github.com/vercel-labs/agent-browser) is a headless Rust CLI for AI-driven browser automation. It complements Playwright — use Playwright for test execution, agent-browser for test scaffolding and visual verification.

### Installation

```bash
npm install -g agent-browser
agent-browser install
```

### Test Scaffolding

Use agent-browser to inspect a page and generate Playwright test selectors from the accessibility tree:

```bash
# Open page and get accessibility snapshot with element refs
agent-browser open http://localhost:3000/topics
agent-browser snapshot

# Output includes refs like @e1, @e2, @e3...
# Use these to understand the page structure and generate selectors
```

The `snapshot` output maps directly to Playwright's `getByRole` selectors — use it to identify the correct roles, names, and hierarchy before writing tests.

### Visual Verification

After deploying or making changes, verify the page rendered correctly:

```bash
# Take annotated screenshot with numbered element labels
agent-browser open http://localhost:3000/topics
agent-browser screenshot --annotate topics-annotated.png

# Full-page screenshot for visual comparison
agent-browser screenshot --full-page topics-full.png

# Close when done
agent-browser close
```

### Smoke Testing Flow

```bash
# Open page, interact, verify
agent-browser open http://localhost:3000/login
agent-browser fill @e2 "test@example.com"
agent-browser fill @e3 "password123"
agent-browser press Enter
agent-browser wait --text "Dashboard"
agent-browser screenshot post-login.png
agent-browser close
```

### Batch Operations

For multi-step verification, use batch mode:

```bash
echo '[
  ["open", "http://localhost:3000/topics"],
  ["wait", "--load-state", "networkidle"],
  ["snapshot"],
  ["screenshot", "--annotate", "topics.png"]
]' | agent-browser batch --json
```

### When to Use Agent-Browser vs Playwright

| Task | Use |
|------|-----|
| Running test suites | Playwright (`bun run test:e2e`) |
| Generating test selectors | agent-browser `snapshot` |
| Visual smoke test after deploy | agent-browser `screenshot` |
| Interactive test debugging | Playwright UI mode |
| CI test execution | Playwright |
| AI-driven page inspection | agent-browser |

## CI Configuration

```yaml
- name: Run e2e tests
  run: bun run test:e2e
  env:
    CI: true
```

Ensure CI runners have Docker available for Testcontainers. Use `retries: 2` in CI config to handle flaky network conditions.
