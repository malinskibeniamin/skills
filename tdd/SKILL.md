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

**No production code without a failing test first.** No exceptions.

## Anti-Pattern: Horizontal Slices

**DO NOT write all tests first, then all implementation.** Bulk tests test *imagined* behavior, not *actual* behavior.

**Correct**: Vertical slices. One test → one implementation → repeat.

    WRONG:  RED: test1,test2,test3  →  GREEN: impl1,impl2,impl3
    RIGHT:  RED→GREEN: test1→impl1  →  RED→GREEN: test2→impl2

## Workflow

### 0. PLAN — Coverage gap analysis, then confirm what to test

- Run `vitest run --coverage.enabled --coverage.reporter=text` to get current coverage
- Identify uncovered lines/branches/functions in changed files — these are your test targets
- Confirm behaviors with user (prioritize gaps over already-covered code)
- Identify deep module opportunities (small interface, deep impl)
- Design interfaces for testability

### 1. RED — Failing test (tracer bullet)

- ONE test, ONE behavior, clear name
- Real code, not mocks (unless unavoidable)
- Verify it fails for RIGHT reason

### 2. GREEN — Minimal code to pass

- Only enough to pass. No premature optimization.
- Run test. See green.

### 3. REFACTOR — Clean up while green

- Remove duplication, improve naming, deepen modules
- Tests after every change — stay green
- **Never refactor while RED.** Get to GREEN first.
- Check test execution time — flag unit tests >500ms, integration >2s
- Avoid per-keystroke simulation in tests (slow, flaky). Prefer bulk input methods.
- Commit when clean

### Reactive TDD with Monitor

`Monitor: vitest --watch` — streams pass/fail as you edit. Edit → fail → fix → pass → refactor → repeat.

### 4. REPEAT — Next behavior

RED → GREEN → REFACTOR per remaining behavior. One at a time.

### Per-Cycle Checklist

- [ ] Test describes behavior, not implementation
- [ ] Test uses public interface only
- [ ] Test survives internal refactor
- [ ] Code minimal for this test
- [ ] No speculative features

## Test Classification

| Suffix | Purpose | DOM? |
|--------|---------|------|
| `.test.ts` | Unit — pure logic | No |
| `.test.tsx` / `.integration.tsx` | Integration — renders components | Yes |
| `e2e/*.spec.ts` | E2E — Playwright browser | Browser |

## Visual Regression Tests (Route Files)

New TanStack Router routes need `*.browser.test.tsx` sibling — only if project uses vitest browser mode (existing `*.browser.test.*` files or `@vitest/browser` dep). Skip for layout/redirect-only routes. See [REFERENCE.md](REFERENCE.md) for example.

## When Done

- [ ] All pass (`vitest run`)
- [ ] No async leaks (`vitest run --detectAsyncLeaks`) — Stop hook runs this automatically
- [ ] No setTimeout hacks — condition-based waiting
- [ ] Coverage gaps closed — re-run `vitest run --coverage.enabled --coverage.reporter=text` and verify changed files have adequate line + branch coverage
- [ ] Selector priority: `getByRole` > `getByText` > `getByTestId` > `querySelector`
- [ ] Portal tests: `defaultOpen` for content tests, `waitFor` for close assertions
- [ ] Tests verify behavior, not implementation
- [ ] Consider `expect.soft()` for multi-assertion state tests

See [REFERENCE.md](REFERENCE.md) for element selectors, portal testing, mock patterns, diagnostics, Vitest config.
