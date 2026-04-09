---
name: tdd
description: "Test-driven development with red-green-refactor loop. Use when writing tests, creating new features, or fixing bugs. Includes planning phase, tracer bullets, async leak detection, deep module design, and condition-based waiting."
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

## Anti-Pattern: Horizontal Slices

**DO NOT write all tests first, then all implementation.** This produces crap tests — tests written in bulk test *imagined* behavior, not *actual* behavior. You end up testing shapes (data structures, function signatures) rather than user-facing behavior.

**Correct approach**: Vertical slices. One test → one implementation → repeat. Each test responds to what you learned from the previous cycle.

    WRONG:  RED: test1,test2,test3  →  GREEN: impl1,impl2,impl3
    RIGHT:  RED→GREEN: test1→impl1  →  RED→GREEN: test2→impl2

## Workflow

### 0. PLAN — Confirm what to test

Before writing any code:
- Confirm with user which behaviors to test (prioritize — **you can't test everything**)
- Identify opportunities for deep modules (small interface, deep implementation)
- Design interfaces for testability (accept deps, return results, small surface)

### 1. RED — Write a failing test (tracer bullet)

Start with ONE test that confirms ONE behavior — your tracer bullet proving the path works end-to-end.

- One minimal test with a clear name
- Use real code, not mocks (unless unavoidable)
- Watch it fail. Verify it fails for the RIGHT reason.

### 2. GREEN — Write minimal code to pass

- Only enough code to make the test pass
- No premature optimization or extra features
- Run the test. See green.

### 3. REFACTOR — Clean up while green

- Remove duplication, improve naming, deepen modules
- Run tests after every change — stay green
- **Never refactor while RED.** Get to GREEN first.
- Commit when clean

### 4. REPEAT — Next behavior

For each remaining behavior: RED → GREEN → REFACTOR. One test at a time. Don't anticipate future tests.

### Per-Cycle Checklist

- [ ] Test describes behavior, not implementation
- [ ] Test uses public interface only
- [ ] Test would survive internal refactor
- [ ] Code is minimal for this test
- [ ] No speculative features added

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

See [REFERENCE.md](REFERENCE.md) for diagnostic commands, Vitest config optimization, anti-patterns, and condition-based waiting patterns.
