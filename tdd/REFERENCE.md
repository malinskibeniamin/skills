# Test-Driven Development Reference

## Condition-Based Waiting

Replace arbitrary timeouts with condition polling. Flaky tests almost always timing assumptions.

```ts
// BAD — arbitrary delay, passes on fast machines, fails on CI
await new Promise(r => setTimeout(r, 500))
await page.waitForTimeout(1000)

// GOOD — wait for actual condition (retries until true or timeout)
await waitFor(() => expect(element).toBeVisible())
await expect.poll(() => fetchStatus()).toBe('ready')
await page.waitForSelector('[data-testid="loaded"]')

// GOOD — event-based waiting
await waitForEvent(manager, threadId, 'DONE')
```

Result: 60% → 100% pass rate, 40% faster execution.

## Custom Fixtures (test.extend())

Encapsulate reusable setup into declarative fixtures. Tests become assertion-only sequences.

```ts
import { test as base } from 'vitest'

// Define fixture with setup + teardown
const test = base.extend<{ db: TestDatabase }>({
  db: async ({}, use) => {
    const db = await createTestDatabase()
    await use(db)       // test runs here
    await db.cleanup()  // teardown after test
  },
})

// Compose fixtures — fixture can depend on another fixture
const test = base.extend<{ db: TestDatabase; user: User }>({
  db: async ({}, use) => { /* ... */ await use(db) },
  user: async ({ db }, use) => {
    const user = await db.createUser({ name: 'test' })
    await use(user)
  },
})

// Tests are pure assertions
test('user has default role', async ({ user }) => {
  expect(user.role).toBe('viewer')
})
```

**Auto-fixtures**: Set `{ auto: true }` for fixtures that run for every test without explicit reference (mock API servers, database seeding):

```ts
const test = base.extend<{ mockApi: void }>({
  mockApi: [async ({}, use) => {
    const server = setupMockServer()
    await use()
    server.close()
  }, { auto: true }],
})
```

Same API as Playwright's `test.extend()` — patterns transfer between unit and E2E tests.

## Advanced Assertions

### Custom Matchers (expect.extend())

Domain-specific assertions improve readability and centralize validation logic.

```ts
// vitest.setup.ts (add to setupFiles in vitest config)
import { expect } from 'vitest'
import { z } from 'zod'

expect.extend({
  toMatchSchema(received, schema: z.ZodSchema) {
    const result = schema.safeParse(received)
    return {
      pass: result.success,
      message: () => result.success
        ? `Expected value not to match schema`
        : `Schema validation failed: ${result.error.message}`,
    }
  },
})

// Usage
test('API response matches schema', () => {
  expect(response).toMatchSchema(UserSchema)
})
```

Type declaration (add to `vitest.d.ts` or setup file):

```ts
import type { Assertion, AsymmetricMatchersContaining } from 'vitest'

interface CustomMatchers<R = unknown> {
  toMatchSchema(schema: z.ZodSchema): R
}

declare module 'vitest' {
  interface Assertion<T = any> extends CustomMatchers<T> {}
  interface AsymmetricMatchersContaining extends CustomMatchers {}
}
```

### Asymmetric Matchers

Custom matchers from `expect.extend()` work in asymmetric position — mix literal values with pattern matchers in nested structures:

```ts
expect(response).toEqual({
  id: expect.any(String),
  data: expect.objectContaining({ status: 'ok' }),
  metadata: expect.toMatchSchema(MetadataSchema),  // custom matcher, asymmetric
})
```

### Custom Equality Testers

Teach Vitest that semantically equivalent objects are equal (Money types, units of measure, date representations):

```ts
// vitest.setup.ts
import { expect } from 'vitest'

function measurementTester(a: unknown, b: unknown): boolean | undefined {
  if (a instanceof Measurement && b instanceof Measurement) {
    return a.toBaseUnit() === b.toBaseUnit()
  }
  return undefined  // not our types — defer to default equality
}

expect.addEqualityTesters([measurementTester])
```

Register in `setupFiles`. Expensive testers slow all deep equality checks — keep logic fast.

### Retryable Assertions (expect.poll())

`expect.poll()` retries callback until assertion passes. Cleaner than `waitFor` when async source isn't Promise-based (polling APIs, DOM side effects, event-driven state):

```ts
// Polls fetchStatus() every 50ms until it returns 'ready' (or timeout)
await expect.poll(() => fetchStatus()).toBe('ready')

// Custom interval and timeout
await expect.poll(() => document.querySelectorAll('.item').length, {
  interval: 100,  // check every 100ms (default: 50ms)
  timeout: 5000,  // give up after 5s (default: 1000ms)
}).toBeGreaterThan(3)
```

Use `expect.poll()` for eventual assertions. Use `waitFor()` when you need to await a Promise chain.

### Soft Assertions (expect.soft())

Run all assertions even when one fails. Surfaces every broken expectation in one pass instead of stopping at first failure:

```ts
test('user profile has all required fields', () => {
  expect.soft(profile.name).toBe('Alice')
  expect.soft(profile.email).toContain('@')
  expect.soft(profile.role).toBe('admin')
  // All three report on failure — not just the first
})
```

Soft assertions still fail the test. They just don't short-circuit. Use for complex state validation where you need the full picture to debug efficiently.

## Reactive TDD with Monitor

Use **Monitor** tool — run test runner in watch mode during implementation. Turns RED→GREEN→REFACTOR from discrete steps into continuous feedback loop.

```
Monitor: bun test --watch
```

**How it works:**
1. Start Monitor on test runner watch mode
2. Write failing test (RED) — Monitor reports failure immediately
3. Write minimal code — Monitor reports pass (GREEN) on save
4. Refactor — Monitor confirms green after each change

**Runner-specific watch commands:**

| Runner | Watch command |
|--------|-------------|
| Vitest | `bun test --watch` or `npx vitest --watch` |
| Jest | `npx jest --watch` |

**When to use**: Phase 3 (Implement) for rapid iteration. Valuable when making multiple small changes — see red/green transitions without running tests manually.

## Async Leak Detection with Monitor

Monitor streams async leak detection — react to first leak immediately:

```
Monitor: bun test --run --detectAsyncLeaks
```

For Jest: `Monitor: npx jest --detectOpenHandles --forceExit`

Surfaces open handles as detected, not buffered until exit.

## Diagnostic Commands

```bash
# Detect async leaks (Vitest)
bun test --run --detectAsyncLeaks

# Detect open handles (Jest)
npx jest --detectOpenHandles --forceExit

# Profile slow tests (Vitest)
bun test --run --reporter=verbose --pool=forks

# Find slow selectors in integration tests
grep -rn 'getByRole' --include='*.integration.*' | wc -l
```

## Vitest Config Optimization

Tune `vitest.config.*` for faster runs. Settings compound — apply all that fit.

### pool: 'threads'

Worker threads less spawn overhead than forked processes (default). Import times drop ~30%.

```ts
// vitest.config.mts
export default defineConfig({
  test: {
    pool: 'threads',
  },
})
```

Use for **both** unit and integration configs. Safe everywhere.

### isolate: false (unit tests only)

Pure-logic tests (`.test.ts`, node env) share single thread context instead of re-isolating per file. Saves per-file startup cost.

```ts
// vitest.config.mts (unit tests)
export default defineConfig({
  test: {
    pool: 'threads',
    isolate: false,  // safe: no DOM, no global side effects
  },
})
```

**Do NOT disable isolation for integration tests** — happy-dom/jsdom tests leak DOM state between files.

### Multi-Workspace Configuration

Monorepos with different runtimes (Node, edge, browser) need separate Vitest configs sharing one root:

```ts
// vitest.workspace.ts
export default [
  { extends: './vitest.config.mts', test: { name: 'unit', include: ['src/**/*.test.ts'] } },
  { extends: './vitest.config.mts', test: { name: 'integration', environment: 'happy-dom', include: ['src/**/*.test.tsx'] } },
  { extends: './vitest.edge.mts', test: { name: 'edge', include: ['edge/**/*.test.ts'] } },
]
```

Each workspace gets its own pool, environment, and isolation settings. Use for multi-runtime monorepos — not for splitting unit/integration in single-runtime projects (use `include`/`exclude` globs for that).

### Concurrent Tests (it.concurrent)

Run independent tests within a single file concurrently. Distinct from `pool:'threads'` which parallelizes across files.

```ts
describe.concurrent('independent API calls', () => {
  it('fetches users', async ({ expect }) => { /* ... */ })
  it('fetches roles', async ({ expect }) => { /* ... */ })
  it('fetches permissions', async ({ expect }) => { /* ... */ })
})

// Or per-test:
it.concurrent('fast independent test', async ({ expect }) => { /* ... */ })
```

Safety requirements:
- Tests must not share mutable state
- Each test sets up own fixtures (or use `test.extend()` — fixtures isolate by default)
- **Do NOT combine with `isolate: false`** — concurrent tests sharing single thread context will race on mutable state

### What NOT to change (and why)

| Setting | Why skip |
|---|---|
| `isolate: false` for integration | DOM state leaks between test files |
| `experimental.fsModuleCache` | Still experimental — stale cache issues in CI |
| `isolate: false` + `it.concurrent` | Race conditions — concurrent tests need isolation |
| Sharding | See [CI Pipeline REFERENCE](../setup-ci-pipeline/REFERENCE.md) — useful for suites >60s |

### Benchmarks (real project, 23 unit + 12 integration files)

| Category | Metric | Before | After |
|---|---|---|---|
| Unit | Duration | 650ms | 350ms (46% faster) |
| Unit | Import time | 3.0s | 2.2s (27% faster) |
| Integration | Duration | 2.59s | 2.04s (21% faster) |
| Integration | Import time | 7.9s | 5.5s (30% faster) |

## Framework Detection

| Runner | Detect | Related tests |
|--------|--------|---------------|
| Vitest | `node_modules/.bin/vitest` | `vitest --run --related <files>` |
| Jest | `node_modules/.bin/jest` | `jest --findRelatedTests <files>` |
| Bun | `bun test --help` | `bun test <co-located files>` |

## Common Agent Excuses

| Excuse | Counter |
|---|---|
| "I'll add the test later" | No. Write failing test FIRST (RED phase). |
| "This is too simple to test" | Simple things become complex. Test now. |
| "The test would just duplicate the implementation" | Test behavior, not implementation. |
| "I can't test this without mocking everything" | Redesign for testability. Heavy mocking = design problem. |
| "Tests slow down development" | Tests catch bugs that slow development 10x more. |
| "I'll just verify it manually" | Manual verification no prevent regressions. |