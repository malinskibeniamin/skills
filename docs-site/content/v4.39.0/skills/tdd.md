---
title: "/tdd"
description: "Develop through red-green-refactor. Use when writing tests, creating features, fixing bugs, designing test seams, preventing async leaks, or replacing duration waits."
type: skill
sidebar:
  label: "/tdd"
---
![Diagram of the /tdd skill](/diagrams/skills/tdd.svg)

[Open the editable Excalidraw source](/diagrams/skills/tdd.excalidraw)


TDD protects meaningful behavior. RED -> GREEN -> REFACTOR for domain rules, branches, state, validation, async effects, and integration contracts. Types, wiring, copy/styles, and behavior-preserving deletion may use focused verification. Coverage is never a target.

## Test seams and anti-patterns

- **Seams:** test public boundaries. Name the seam first; confirm pre-agreed seams with the user when issue and convention leave it unclear. No tests at unconfirmed internals. Use `/codebase-design` rather than inventing a seam for convenience.
- **Tautological tests:** expected values need an independent source of truth: literal, worked example, fixture, spec, or observation.
- **Source-text proxies:** delete tests that scan implementation, CSS, markup, or config for tokens or regexes as runtime proof. Replace at a public seam when behavior matters; use static analysis for syntax. Keep content assertions for public output only.
- **Vertical slices:** use vertical slices: one RED test plus GREEN implementation at a time; bulk tests encode imagined behavior.

## Workflow

### Contract

- Name public behavior; follow the domain glossary and ADRs.
- Choose the smallest test that fails if it breaks; new or changed tests pass the [authoring gate](https://github.com/malinskibeniamin/skills/blob/v4.39.0/test-audit/SKILL.md#authoring-gate).
- For high-cardinality/state-sequence invariants, read [PROPERTY-BASED-TESTING.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/tdd/PROPERTY-BASED-TESTING.md); require an independent oracle and replay.
- For long-lived browser resource lifetimes, use repeatable round trips and [SOAK-TESTING.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/e2e-testing/SOAK-TESTING.md); fresh contexts cannot reveal accumulation.
- Use `/read-the-damn-docs` for external contracts and [tests.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/tdd/tests.md) when shape is unclear.

### RED

Write one behavior test; verify its intended failure. Use public interfaces; mock unavailable external boundaries only.

### GREEN

Write the smallest passing implementation. Delete/reuse first, then prefer the language, platform, or installed dependency. Match relevant `exemplars/` conventions, not size.

### REFACTOR

Improve names/structure only for clearer meaning or real deduplication. Stay green; never weaken assertions. Flag unit tests over 500ms and integrations over 2s; prefer bulk input over per-keystroke simulation. Run `/dogfood` on material green slices; defects become RED.

### REPEAT

Repeat only for another contract or independent credible risk. During active work use `vitest --watch`, condition-based waits, and `--detectAsyncLeaks` for new async work.

## Visual Regression

For any visible change, including copy, styles, layout, assets, and states, use the existing screenshot assertion runner. Follow [PR visual evidence](https://github.com/malinskibeniamin/skills/blob/v4.39.0/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5): base capture, shared consumers, reviewed snapshot updates, normal rerun, embedded images. Non-visible edits need no screenshot test.

## Done

Tests pass without warnings, async leaks, or duration waits; survive refactors. See [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/tdd/REFERENCE.md) for waits, selectors, portals, mocks, diagnostics, and resilience examples.
