---
name: test-driven-development
description: "Use when writing tests, creating new features, or fixing bugs. RED-GREEN-REFACTOR: write failing test first, implement minimal code, then refactor. Includes async leak detection, test classification, and condition-based waiting."
paths:
  - "**/*.test.{ts,tsx}"
  - "**/*.spec.{ts,tsx}"
  - "**/*.integration.{ts,tsx}"
  - "**/*.unit.{ts,tsx}"
---

# Test-Driven Development

## Iron Law

**No production code without a failing test first.**

No exceptions. Not for "simple" changes. Not for "obvious" fixes. Not under time pressure.

## RED-GREEN-REFACTOR

### 1. RED — Write a failing test

- One minimal test with a clear name
- Use real code, not mocks (unless unavoidable)
- Watch it fail. Verify it fails for the RIGHT reason.

### 2. GREEN — Write minimal code to pass

- Only enough code to make the test pass
- No premature optimization or extra features
- Run the test. See green.

### 3. REFACTOR — Clean up while green

- Remove duplication, improve naming
- Run tests after every change — stay green
- Commit when clean

## Test Classification

| Suffix | Purpose | DOM? | Example |
|--------|---------|------|---------|
| `.test.ts` | Unit — pure logic | No | `parse-config.test.ts` |
| `.test.tsx` / `.integration.tsx` | Integration — renders components | Yes | `UserTable.test.tsx` |
| `e2e/*.spec.ts` | E2E — Playwright browser tests | Browser | `login.spec.ts` |

## When Done Checklist

- [ ] All tests pass (`bun test --run`)
- [ ] No async leaks (`bun test --run --detectAsyncLeaks`)
- [ ] No `setTimeout`/`waitForTimeout` hacks — use condition-based waiting
- [ ] Prefer `getByRole` over `getByTestId` for accessibility assertions
- [ ] Tests verify behavior, not implementation

See [REFERENCE.md](REFERENCE.md) for diagnostic commands, anti-patterns, and condition-based waiting patterns.
