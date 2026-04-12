# Test-Driven Development Reference

## Condition-Based Waiting

Replace arbitrary timeouts with actual condition polling. Flaky tests are almost always timing assumptions.

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

## Reactive TDD with Monitor

Use the **Monitor** tool to run the test runner in watch mode during implementation. This turns the RED→GREEN→REFACTOR cycle from discrete steps into a continuous feedback loop.

```
Monitor: bun test --watch
```

**How it works:**
1. Start Monitor on your test runner's watch mode
2. Write a failing test (RED) — Monitor immediately reports the failure
3. Write minimal code — Monitor reports pass (GREEN) as soon as you save
4. Refactor — Monitor confirms you stay green after each change

**Runner-specific watch commands:**

| Runner | Watch command |
|--------|-------------|
| Vitest | `bun test --watch` or `npx vitest --watch` |
| Jest | `npx jest --watch` |

**When to use**: during Phase 3 (Implement) for rapid iteration. Especially valuable when making multiple small changes — you see red/green transitions without running tests manually each time.

## Async Leak Detection with Monitor

Use Monitor to stream async leak detection so you can react to the first leak immediately:

```
Monitor: bun test --run --detectAsyncLeaks
```

For Jest: `Monitor: npx jest --detectOpenHandles --forceExit`

This surfaces open handles as they're detected, rather than buffering the entire test output and checking the exit code afterward.

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

Tune `vitest.config.*` for faster test runs. These settings compound — apply all that fit.

### pool: 'threads'

Worker threads have less spawn overhead than forked processes (the default). Import times drop ~30%.

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

Pure-logic tests (`.test.ts`, node env) share a single thread context instead of re-isolating per file. Saves per-file startup cost.

```ts
// vitest.config.mts (unit tests)
export default defineConfig({
  test: {
    pool: 'threads',
    isolate: false,  // safe: no DOM, no global side effects
  },
})
```

**Do NOT disable isolation for integration tests** — happy-dom/jsdom tests can leak DOM state between files.

### What NOT to change (and why)

| Setting | Why skip |
|---|---|
| `isolate: false` for integration | DOM state leaks between test files |
| `experimental.fsModuleCache` | Still experimental — stale cache issues in CI |
| Sharding | Overkill for suites under 30s |

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
| "This is too simple to test" | Simple things become complex. Test it now. |
| "The test would just duplicate the implementation" | Then test the behavior, not the implementation. |
| "I can't test this without mocking everything" | Redesign for testability. Heavy mocking = design problem. |
| "Tests slow down development" | Tests catch bugs that slow down development 10x more. |
| "I'll just verify it manually" | Manual verification doesn't prevent regressions. |
