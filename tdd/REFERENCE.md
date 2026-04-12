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
| "This is too simple to test" | Simple things become complex. Test now. |
| "The test would just duplicate the implementation" | Test behavior, not implementation. |
| "I can't test this without mocking everything" | Redesign for testability. Heavy mocking = design problem. |
| "Tests slow down development" | Tests catch bugs that slow development 10x more. |
| "I'll just verify it manually" | Manual verification no prevent regressions. |