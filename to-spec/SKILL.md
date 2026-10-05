---
name: to-spec
description: Turn the current conversation into a tracker-ready specification.
disable-model-invocation: true
---

Produce a spec/PRD from settled conversation/repo evidence. Keep settled decisions; put material gaps in Further Notes, never assume.
Load skills per [dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

Use `docs/agents/` tracker/triage vocabulary; if absent, return chat output and recommend `/work-automation-kit` to the human.

## Process

1. Explore current code; use `GLOSSARY.md` (via `GLOSSARY-MAP.md` when present) and relevant ADRs.
2. Choose the highest existing public test seam; minimize new seams. Call the Skill tool separately with "read-the-damn-docs" for external behavior, "plan-arbiter" for competing plans, "visual-plan" only for a requested artifact.
3. Return the template in chat. Publish/apply `ready-for-agent` only when requested.
4. Tell the human to run `/to-tickets` with the approved spec for breakdown.

<spec-template>

## Problem Statement

User-perspective problem.

## Solution

User-perspective solution.

## User Stories

Number one in-scope actor outcome per story:

`As an <actor>, I want <feature>, so that <benefit>.`

**Completion:** map every in-scope behavior, boundary, recovery outcome to one story. Omit duplicates, internals, out-of-scope behavior.

## Implementation Decisions

Settled module/interface, architecture, schema, API, interaction decisions. No stale-prone paths/code except labeled, decision-rich prototype state machine/reducer/schema/type fragments.

## Testing Decisions

Name observable behavior, modules, seams, and similar repo tests; never implementation detail.

## Out of Scope

Explicit exclusions.

## Further Notes

Unresolved material decisions and other notes.

</spec-template>
