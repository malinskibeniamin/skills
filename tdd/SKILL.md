---
name: tdd
description: "Develop through red-green-refactor. Use when writing tests, creating features, fixing bugs, designing test seams, preventing async leaks, or replacing duration waits."
paths:
  - "**/*.test.{ts,tsx}"
  - "**/*.spec.{ts,tsx}"
  - "**/*.integration.{ts,tsx}"
  - "**/*.unit.{ts,tsx}"
---

# Test-Driven Development

TDD protects meaningful behavior; it is not a tax on every changed file.

Use RED -> GREEN -> REFACTOR for bugs, regressions, and new or changed
contracts: domain rules, branches, state transitions, parsing, validation,
async effects, and integration behavior whose failure matters. Types,
re-exports, declarative wiring, static copy/styles, and behavior-preserving
deletion may need only existing focused verification.

Coverage can reveal a suspected blind spot. It is never a target or a reason
to invent tests.

## Test seams and anti-patterns

- **Seams**: test at public boundaries. Before a test, write down the seam and confirm pre-agreed seams with the user when the issue or existing convention does not make it obvious. No tests at unconfirmed internals.
- **Tautological tests**: do not recompute expected values the same way code does; use an independent source of truth: known-good literal, worked example, fixture, spec, or observed behavior.
- **Horizontal slices**: do not write all tests first, then all impl. Bulk tests test imagined behavior. Correct: vertical slices -- one RED->GREEN test+impl, then repeat.

If the public seam itself is unclear, use `/codebase-design`; do not invent an
internal seam for test convenience.

## Workflow

### 0. Contract

- Name the observable behavior at a public interface. Follow the project domain glossary and ADRs.
- Choose the smallest test that would fail if that behavior broke. One test may prove many lines.
- Add another case only for an independent credible risk, not every imaginable edge.
- For a resource-lifetime contract in a long-lived browser page, use a repeatable
  round trip and read [SPA soak testing](../e2e-testing/SOAK-TESTING.md). A fresh
  browser context cannot expose accumulation across interactions.
- If third-party behavior defines the contract, use `/read-the-damn-docs`.
- Read [tests.md](tests.md) when the seam or test shape is unclear.

### 1. RED

- Write one behavior test and verify it fails for the intended reason.
- Prefer real public interfaces; mock only external boundaries that cannot run locally.

### 2. GREEN

- Write the smallest obvious implementation that passes.
- Delete or reuse first; then prefer the language, platform, or installed dependency over custom machinery.
- Match the relevant `exemplars/` file's clarity and conventions, not its size.

### 3. REFACTOR

- Improve names and structure only when meaning becomes clearer or real duplication disappears.
- Stay green. Never weaken a behavior assertion merely to pass.
- Flag unit tests over 500ms and integration tests over 2s; prefer bulk input over per-keystroke simulation.
- Run `/dogfood` on material runnable behavior; observed defects become the next RED.

### 4. REPEAT

Repeat only for another required contract or independent credible risk.

For active work, monitor `vitest --watch`. Use condition-based waits and
`--detectAsyncLeaks` when the change creates async work.

## Test Classification

| Suffix | Purpose | DOM? |
|--------|---------|------|
| `.test.ts` | Unit -- pure logic | No |
| `.test.tsx` / `.integration.tsx` | Integration -- render components | Yes |
| `e2e/*.spec.ts` | E2E -- Playwright browser | Browser |

## Visual Regression Tests

When a route adds customer-visible behavior not already covered and the project
uses `@vitest/browser`, add the smallest useful `*.browser.test.tsx`. Skip
layout, redirect, and purely declarative routes.

## When Done

- Relevant tests pass without warnings.
- Async changes have no leaked work or duration-based waits.
- Tests survive internal refactors because they verify behavior, not implementation.
- No redundant case exists only to raise coverage.

See [REFERENCE.md](REFERENCE.md) for condition-based waiting, selectors,
portals, mocks, diagnostics, and targeted resilience examples.
