# Good and Bad Tests

## Good Tests

**Integration-style**: test through real interfaces, not mocks of internal parts.

```typescript
// GOOD: tests observable behaviour
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

Characteristics:

- Tests behaviour users / callers care about
- Uses public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion per test

## Bad Tests

**Implementation-detail tests**: coupled to internal structure.

```typescript
// BAD: tests implementation details
test("checkout calls paymentService.process", async () => {
  const mockPayment = vi.spyOn(paymentService, "process");
  await checkout(cart, payment);
  expect(mockPayment).toHaveBeenCalledWith(cart.total);
});
```

Red flags:

- Mocking internal collaborators
- Testing private methods
- Asserting on call counts / order of internal collaborators
- Test breaks when refactoring without behaviour change
- Test name describes HOW not WHAT
- Verifying through external means instead of through the interface

```typescript
// BAD: bypasses interface to verify
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: verifies through interface
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

## Heuristic

If you rename an internal function and tests fail, those tests were testing implementation, not behaviour. Refactor the test, not the production code.

## Tautological Tests

Expected value must not restate the implementation. Use an independent source of truth: a known literal, worked example, fixture, spec, or externally observed behavior.

```typescript
// BAD: expected value recomputes the same algorithm
test("calculateTotal sums line items", () => {
  const items = [{ price: 10 }, { price: 5 }];
  const expected = items.reduce((sum, item) => sum + item.price, 0);
  expect(calculateTotal(items)).toBe(expected);
});

// GOOD: expected value is a known literal
test("calculateTotal sums line items", () => {
  expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);
});
```

## Source-Text Proxies

Do not claim runtime behavior by searching implementation files. These tests pass for
commented, dead, overridden, or unreachable code and fail on behavior-preserving refactors.

```typescript
// BAD: proves only that one CSS token exists
test("theme follows the system dark preference", async () => {
  const css = await Bun.file("src/app.css").text();
  expect(css).toContain("@media (prefers-color-scheme: dark)");
});

// GOOD: observes the browser contract
test("theme follows the system dark preference", async ({ page }) => {
  await page.emulateMedia({ colorScheme: "dark" });
  await page.goto("/");
  await expect(page.getByRole("main")).toHaveCSS(
    "background-color",
    "rgb(17, 24, 39)",
  );
});
```

Delete the proxy when no credible behavior needs protection. Replace it at a public seam
when behavior matters. File-content assertions remain valid when the file or serialized
text is public output, such as generator output; prefer parsing it when semantics matter.
Use lint, type, schema, or AST checks for syntax-only repository rules.
