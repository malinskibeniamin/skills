---
name: tdd
description: "Develop through red-green-refactor. Use when writing tests, creating features, fixing bugs, designing test seams, preventing async leaks, or replacing duration waits."
paths:
  - "**/*.test.{ts,tsx}"
  - "**/*.spec.{ts,tsx}"
  - "**/*.integration.{ts,tsx}"
  - "**/*.unit.{ts,tsx}"
---

RED -> GREEN -> REFACTOR protects domain rules, branches, state, validation, async effects, and integration contracts. Types, wiring, copy/styles, and behavior-preserving deletion may use focused verification. Coverage is never a target.
Load skills per [dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Test seams and anti-patterns

- **Seams:** test public boundaries. Name the seam; confirm with the user when issue/convention leave it unclear. No tests at unconfirmed internals. Call the Skill tool with "codebase-design"; never invent a convenient seam.
- **Tautological tests:** expected values need an independent source of truth: literal, worked example, fixture, spec, or observation.
- **Source-text proxies:** delete implementation/CSS/markup/config token scans posing as runtime proof. Test behavior at a public seam; use static analysis for syntax. Content assertions are for public output only.
- **Vertical slices:** use vertical slices, one RED test plus GREEN implementation; bulk tests encode imagined behavior.

## Workflow

### Contract

- Name public behavior; follow `GLOSSARY.md`, its `GLOSSARY-MAP.md` when present, and ADRs.
- Choose the smallest failing test; Call the Skill tool with "test-audit" for the [authoring gate](../test-audit/SKILL.md#authoring-gate) on new/changed tests.
- For high-cardinality/state-sequence invariants, read [PROPERTY-BASED-TESTING.md](PROPERTY-BASED-TESTING.md); require an independent oracle and replay.
- Browser resource lifetimes: repeat round trips per [SOAK-TESTING.md](../e2e-testing/SOAK-TESTING.md); fresh contexts hide accumulation.
- Call the Skill tool with "read-the-damn-docs" for external contracts; read [tests.md](tests.md) when shape is unclear.

### RED

Write one behavior test; verify its intended failure. Use public interfaces; mock unavailable external boundaries only.

### GREEN

Write the smallest passing implementation. Delete/reuse first; prefer language, platform, installed dependency. Match `exemplars/` conventions, not size.

### REFACTOR

Improve names/structure for meaning or real deduplication. Stay green; never weaken assertions. Flag units over 500ms, integrations over 2s; prefer bulk input to per-keystroke simulation. Call the Skill tool with "dogfood" on material green slices; defects become RED.

### REPEAT

Repeat only for another contract or independent credible risk. During active work use `vitest --watch`, condition-based waits, and `--detectAsyncLeaks` for new async work.

## Visual Regression

Visible copy/styles/layout/assets/states use the existing screenshot assertion runner. Follow [PR visual evidence](../commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5): base capture, shared consumers, reviewed updates, normal rerun, embedded images. Non-visible edits need no screenshots.

## Done

Tests pass without warnings, async leaks, or duration waits; survive refactors. Examples: [REFERENCE.md](REFERENCE.md).
