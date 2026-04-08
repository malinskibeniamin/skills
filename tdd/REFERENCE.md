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

## Deep Modules

From "A Philosophy of Software Design": prefer **deep modules** (small interface + lots of hidden implementation) over **shallow modules** (large interface + thin passthrough).

    Deep (good):                    Shallow (avoid):
    +-------------------+           +-------------------------------+
    |  Small Interface  |           |       Large Interface         |
    +-------------------+           +-------------------------------+
    |                   |           |  Thin Implementation          |
    |  Deep Impl        |           +-------------------------------+
    |                   |
    +-------------------+

When designing: Can I reduce methods? Simplify params? Hide more complexity inside?

## Interface Design for Testability

1. **Accept dependencies, don't create them** — inject, don't construct internally
2. **Return results, don't produce side effects** — `calculateDiscount(cart): Discount` not `applyDiscount(cart): void`
3. **Small surface area** — fewer methods = fewer tests needed, fewer params = simpler setup

## Good vs Bad Tests

```ts
// GOOD: Tests observable behavior through public interface
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});

// BAD: Tests implementation details via mocks
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});

// BAD: Bypasses interface to verify
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: Verifies through interface
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

Red flags: mocking internal collaborators, testing private methods, asserting on call counts/order, test name describes HOW not WHAT.

## When to Mock

Mock at **system boundaries** only: external APIs, databases (prefer test DB), time/randomness, file system.

**Don't mock**: your own classes/modules, internal collaborators, anything you control.

Design for mockability at boundaries:
- Use dependency injection — pass external deps in, don't create them internally
- Prefer SDK-style interfaces (each function independently mockable) over generic fetchers

## Refactor Candidates

After TDD cycle, look for:
- **Duplication** → extract function/class
- **Long methods** → break into private helpers (keep tests on public interface)
- **Shallow modules** → combine or deepen
- **Feature envy** → move logic to where data lives
- **Primitive obsession** → introduce value objects
- **Existing code** the new code reveals as problematic

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
