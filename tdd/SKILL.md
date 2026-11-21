---
name: tdd
description: "Develop through red-green-refactor. Use when writing tests, creating features, fixing bugs, designing test seams, preventing async leaks, or replacing duration waits."
paths:
  - "**/*.test.{ts,tsx}"
  - "**/*.spec.{ts,tsx}"
  - "**/*.integration.{ts,tsx}"
  - "**/*.unit.{ts,tsx}"
---

For behavior/verifier checks, read [Poteto](../shared/POTETO-NATIVE.md#verification).

Apply [proportionate verification](../shared/verifiability.md#proportionate-verification).
Reuse coverage; RED -> GREEN -> REFACTOR only for credible uncovered regressions.
Routine edits: focused checks, not new tests. Coverage is never a target.
Follow [dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Test seams and anti-patterns

- **Seams:** name public boundaries, catches and misses. Confirm unclear contracts; load "codebase-design".
- **Tautological tests:** use an independent source of truth: literal, worked example, fixture, spec, or observation.
- **Dependency re-tests:** trust documented utilities; test only our distinct domain/integration risks.
- **Source-text proxies:** Delete token scans posing as runtime proof. Test public seams; use static analysis for syntax and content assertions only for public output.
- Use vertical slices: one RED test plus GREEN implementation; bulk tests guess behavior.

## Workflow

### Contract

- Public behavior: follow `GLOSSARY.md`, its `GLOSSARY-MAP.md` when present, and ADRs.
- T3/Effect tests: resolve [native context](../shared/T3CODE-NATIVE.md#resolve-context) (`tdd`).
- New/changed tests: smallest failing contract; apply the [authoring gate](../test-audit/SKILL.md#authoring-gate).
- For inference/assignability/overload/displayed-type contracts, load [test development](../t3code-skills/test-development/SKILL.md).
- Invariants: [property](PROPERTY-BASED-TESTING.md); rewrites: [differential](DIFFERENTIAL-TESTING.md). Require an independent oracle and replay.
- Browser resource lifetimes: repeat round trips per [SOAK-TESTING.md](../e2e-testing/SOAK-TESTING.md); fresh contexts hide accumulation.
- Load "read-the-damn-docs" for external contracts; [tests.md](tests.md) for unclear shape.

### RED

Verify one behavior test fails as intended per the [authoring gate](../test-audit/SKILL.md#authoring-gate).
Mock unavailable external boundaries only; keep the behavior at risk real.

### GREEN

Meet the same expectation with the smallest implementation. Delete/reuse first: language, platform, installed dependency. Match `exemplars/`.

### REFACTOR

Apply [verifiability](../shared/verifiability.md); stay green, never weaken assertions. Flag units over 500ms, integrations over 2s; prefer bulk input. Call the Skill tool with "dogfood" on material green slices; defects become RED.

### REPEAT

Repeat for another contract or credible risk. Use `vitest --watch`, condition-based waits, and `--detectAsyncLeaks` for new async work.

## Visual Regression

Inspect small copy/style edits; no automatic snapshots/runner. For visual risks, reuse
screenshot tests, review updates and rerun normally. Use [PR visual evidence](../commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)
only when helpful/required; non-visible edits need no screenshots.

## Done

Pass without warnings, async leaks or duration waits; survive refactors. Examples: [REFERENCE.md](REFERENCE.md).
