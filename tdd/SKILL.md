---
name: tdd
description: "Test-driven development with red-green-refactor loop. Use when writing tests, creating new features, or fixing bugs. Includes planning phase, tracer bullets, async leak detection, /codebase-design interface design, and condition-based waiting."
paths:
  - "**/*.test.{ts,tsx}"
  - "**/*.spec.{ts,tsx}"
  - "**/*.integration.{ts,tsx}"
  - "**/*.unit.{ts,tsx}"
---

# Test-Driven Development

## Iron Law

**No prod code without failing test first.** No exceptions.

## Test seams and anti-patterns

- **Seams**: test at public boundaries. Before a test, write down the seam and confirm pre-agreed seams with the user when the issue or existing convention does not make it obvious. No tests at unconfirmed internals.
- **Tautological tests**: do not recompute expected values the same way code does; use an independent source of truth: known-good literal, worked example, fixture, spec, or observed behavior.
- **Horizontal slices**: do not write all tests first, then all impl. Bulk tests test imagined behavior. Correct: vertical slices -- one RED->GREEN test+impl, then repeat.

## State Machine

Full state diagram: [REFERENCE.md#state-machine](REFERENCE.md#state-machine).

## Workflow

### 0. PLAN -- Coverage gap analysis

- Use project's domain glossary for test/interface names; respect ADRs in the area
- Run `vitest run --coverage.enabled --coverage.reporter=text`
- Find uncovered lines/branches/functions in changed files -> test targets
- If expected behavior comes from third-party API/browser/CLI docs, run `/read-the-damn-docs` and cite the exact rule.
- Confirm behaviors w/ user; `/resilience-review` failures become RED tests
- Run `/codebase-design` for deep-module/interface design; test behaviour through public interface, not implementation ([tests.md](tests.md))

### 1. RED -- Failing test (tracer bullet)

- ONE test, ONE behavior, clear name
- Real code, no mocks (unless unavoidable -- see [mocking.md](mocking.md))
- Verify fails for RIGHT reason

### 2. GREEN -- Minimal code to pass

- Only enough to pass | run `/deslop` write mode: deletion, reuse-in-codebase, standard library, native platform, already-installed dependency, one-line before custom code | no speculative helpers/options.
- Match the shape of the matching `exemplars/` file (component/hook/route/test) -- naming rhythm, comment restraint, structure; not its content.
- Run test | see green

### 3. REFACTOR -- Clean up while green

- Kill duplication | fix naming | deepen modules
- Tests after every change -- stay green
- **Never refactor while RED.** Get GREEN first.
- Flag unit tests >500ms, integration >2s
- Avoid per-keystroke sim (slow, flaky) -> bulk input
- Commit when clean

### Reactive TDD with Monitor

`Monitor: vitest --watch` -- stream pass/fail as edit. Edit->fail->fix->pass->refactor->repeat.

### 4. REPEAT -- Next behavior

RED->GREEN->REFACTOR per behavior. One at a time.

### Per-Cycle Checklist

- [ ] Test describe behavior, not impl
- [ ] Test use public interface only
- [ ] Test survive internal refactor
- [ ] Code minimal for this test
- [ ] No speculative features

## Test Classification

| Suffix | Purpose | DOM? |
|--------|---------|------|
| `.test.ts` | Unit -- pure logic | No |
| `.test.tsx` / `.integration.tsx` | Integration -- render components | Yes |
| `e2e/*.spec.ts` | E2E -- Playwright browser | Browser |

## Visual Regression Tests (Route Files)

New TanStack Router routes need `*.browser.test.tsx` sibling -- only if project use vitest browser mode (existing `*.browser.test.*` files or `@vitest/browser` dep). Skip layout/redirect-only routes. See [REFERENCE.md](REFERENCE.md).

## When Done

- [ ] All pass (`vitest run`) with **zero warnings** -- hooks (test-warning-check, ci-warning-audit) block otherwise; fix at source
- [ ] No async leaks (`vitest run --detectAsyncLeaks`)
- [ ] No `setTimeout` hacks -- condition-based wait
- [ ] Coverage gaps closed -- re-run coverage, verify changed files
- [ ] Selector priority: `getByRole` > `getByText` > `getByTestId` > `querySelector`
- [ ] Portal tests: `defaultOpen` for content tests | `waitFor` for close assertions
- [ ] Tests verify behavior, not impl | `expect.soft()` for multi-assertion state tests
- [ ] CI green
See [REFERENCE.md](REFERENCE.md) for element selectors, portal testing, mock patterns, diagnostics, Vitest config.
