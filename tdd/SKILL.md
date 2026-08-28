---
name: tdd
description: "Develop through red-green-refactor. Use when writing tests, creating features, fixing bugs, designing test seams, preventing async leaks, or replacing duration waits."
paths:
  - "**/*.test.{ts,tsx}"
  - "**/*.spec.{ts,tsx}"
  - "**/*.integration.{ts,tsx}"
  - "**/*.unit.{ts,tsx}"
---

TDD protects meaningful behavior. Use RED -> GREEN -> REFACTOR for changed domain rules, branches, state, parsing, validation, async effects, and integration contracts. Types, re-exports, wiring, static copy/styles, and behavior-preserving deletion may need focused verification. Coverage may expose a blind spot but is never a target.

## Test seams and anti-patterns

- **Seams:** test public boundaries. Name the seam first; confirm pre-agreed seams with the user when issue and convention leave it unclear. No tests at unconfirmed internals. Use `/codebase-design` rather than inventing a seam for convenience.
- **Tautological tests:** expected values need an independent source of truth: literal, worked example, fixture, spec, or observation.
- **Source-text proxies:** delete tests that read implementation source, CSS, markup, or config and assert tokens or regexes as proof of runtime behavior. Replace them at a public seam when a credible contract remains; use static analysis when syntax is the contract. Keep content assertions only when the file or serialized text is itself public output.
- **Vertical slices:** use vertical slices: one RED test plus GREEN implementation at a time; bulk tests encode imagined behavior.

## Workflow

### Contract

- Name observable behavior at a public interface; follow the domain glossary and ADRs.
- Choose the smallest test that fails if it breaks. Add cases only for independent credible risks.
- For high-cardinality/state-sequence invariants, read [PROPERTY-BASED-TESTING.md](PROPERTY-BASED-TESTING.md); require an independent oracle and replay.
- For long-lived browser resource lifetimes, use repeatable round trips and [SOAK-TESTING.md](../e2e-testing/SOAK-TESTING.md); fresh contexts cannot reveal accumulation.
- Use `/read-the-damn-docs` for external contracts and [tests.md](tests.md) when shape is unclear.

### RED

Write one behavior test and verify the intended failure. Prefer real public interfaces; mock only unavailable external boundaries.

### GREEN

Write the smallest passing implementation. Delete/reuse first, then prefer the language, platform, or installed dependency. Match relevant `exemplars/` conventions, not size.

### REFACTOR

Improve names/structure only for clearer meaning or real deduplication. Stay green; never weaken assertions. Flag unit tests over 500ms and integrations over 2s; prefer bulk input over per-keystroke simulation. Run `/dogfood` on material green slices; defects become RED.

### REPEAT

Repeat only for another contract or independent credible risk. During active work use `vitest --watch`, condition-based waits, and `--detectAsyncLeaks` for new async work.

## Visual Regression

When uncovered customer-visible route behavior uses `@vitest/browser`, add the smallest useful `*.browser.test.tsx`; skip layout, redirects, and declarative routes.

## Done

Relevant tests pass without warnings; async work has no leaks or duration waits; tests survive internal refactors; no case exists only for coverage. See [REFERENCE.md](REFERENCE.md) for waits, selectors, portals, mocks, diagnostics, and resilience examples.
