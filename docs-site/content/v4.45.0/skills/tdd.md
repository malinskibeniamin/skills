---
description: "Develop through red-green-refactor. Use when writing tests, creating features, fixing bugs, designing test seams, preventing async leaks, or replacing duration waits."
related: ["/skills/development-lifecycle","/skills/review"]
search: {"boost":3,"keywords":["tdd","test driven development","red green refactor"]}
sidebar: {"label":"/tdd"}
title: "/tdd"
type: "skill"
---
![Diagram of the /tdd skill](/diagrams/skills/tdd.svg)

[Open the editable Excalidraw source](/diagrams/skills/tdd.excalidraw)


For behavior/verifier checks, read [Poteto](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/POTETO-NATIVE.md#verification).

Apply [proportionate verification](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/verifiability.md#proportionate-verification).
Reuse coverage; RED -> GREEN -> REFACTOR only for credible uncovered regressions.
Routine edits: focused checks, not new tests. Coverage is never a target.
Load skills per [dependency loading](https://github.com/malinskibeniamin/skills/blob/v4.45.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Test seams and anti-patterns

- **Seams:** name public boundaries and catches/misses; confirm unclear contracts. Load "codebase-design"; avoid unconfirmed internals.
- **Tautological tests:** expected values need an independent source of truth: literal, worked example, fixture, spec, or observation.
- **Dependency re-tests:** trust documented utilities; test only our distinct domain/integration risks.
- **Source-text proxies:** delete implementation/CSS/markup/config token scans posing as runtime proof. Test behavior at a public seam; use static analysis for syntax. Content assertions are for public output only.
- Use vertical slices: one RED test plus GREEN implementation; bulk tests guess behavior.

## Workflow

### Contract

- Public behavior: follow `GLOSSARY.md`, its `GLOSSARY-MAP.md` when present, and ADRs.
- T3/Effect tests: resolve [native context](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/T3CODE-NATIVE.md#resolve-context) (`tdd`).
- New/changed tests: smallest failing contract; apply the [authoring gate](https://github.com/malinskibeniamin/skills/blob/v4.45.0/test-audit/SKILL.md#authoring-gate).
- For inference/assignability/overload/displayed-type contracts, load [test development](https://github.com/malinskibeniamin/skills/blob/v4.45.0/t3code-skills/test-development/SKILL.md).
- High-cardinality/state-sequence invariants: [PROPERTY-BASED-TESTING.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/tdd/PROPERTY-BASED-TESTING.md); require an independent oracle and replay.
- Browser resource lifetimes: repeat round trips per [SOAK-TESTING.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/e2e-testing/SOAK-TESTING.md); fresh contexts hide accumulation.
- Load "read-the-damn-docs" for external contracts; [tests.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/tdd/tests.md) for unclear shape.

### RED

Verify one behavior test fails as intended; mock unavailable external boundaries only.

### GREEN

Write the smallest passing implementation. Delete/reuse first; prefer language, platform, installed dependency. Match `exemplars/`, not size.

### REFACTOR

Apply [verifiability](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/verifiability.md); stay green, never weaken assertions. Flag units over 500ms, integrations over 2s; prefer bulk input. Call the Skill tool with "dogfood" on material green slices; defects become RED.

### REPEAT

Repeat for another contract or credible risk. Use `vitest --watch`, condition-based waits, and `--detectAsyncLeaks` for new async work.

## Visual Regression

Inspect small copy/style edits; no automatic snapshots/runner. For visual risks, reuse
screenshot tests, review updates and rerun normally. Use [PR visual evidence](https://github.com/malinskibeniamin/skills/blob/v4.45.0/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)
only when helpful/required; non-visible edits need no screenshots.

## Done

Tests pass without warnings, async leaks, or duration waits; survive refactors. Examples: [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/tdd/REFERENCE.md).
