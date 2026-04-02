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

## Testing Anti-Patterns

| Anti-pattern | Why it's wrong | Fix |
|---|---|---|
| Testing mock behavior | Tests pass but real code breaks | Use real implementations, mock only I/O boundaries |
| `setTimeout` in tests | Flaky on slow machines / CI | Condition-based waiting |
| Test-only methods in production | Couples tests to implementation | Test via public API only |
| Incomplete mocks (missing fields) | Real API has fields mock doesn't | Use real types, verify with schema |
| Integration tests as afterthought | Bugs hide in seams between units | Write integration tests alongside units |
| `getByTestId` for everything | Misses accessibility issues | `getByRole` verifies both behavior and a11y |

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
