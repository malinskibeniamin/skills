---
name: to-spec
description: Turn the current conversation into a tracker-ready specification.
disable-model-invocation: true
---

Produce a spec/PRD from settled conversation and repo evidence. Do not reopen decisions; put material missing decisions in Further Notes rather than assume.

Use tracker/triage vocabulary from `docs/agents/`. If absent, return chat output and mention optional `/work-automation-kit` setup.

## Process

1. Explore current code. Use the domain glossary and respect relevant ADRs.
2. Choose the highest existing public test seam; propose a new one only when needed, minimizing seam count. Use `/read-the-damn-docs` for current external behavior, `/plan-arbiter` for plausible competing plans, and `/visual-plan` only when that extra artifact was requested.
3. Return the template in chat. Publish/apply `ready-for-agent` only when requested.
4. For implementation breakdown, hand the approved spec to `/to-tickets`.

<spec-template>

## Problem Statement

User-perspective problem.

## Solution

User-perspective solution.

## User Stories

Number one distinct in-scope actor outcome per story:

`As an <actor>, I want <feature>, so that <benefit>.`

**Completion:** every in-scope behavior, boundary, and recovery outcome maps to one story; omit duplicates, implementation detail, and out-of-scope behavior.

## Implementation Decisions

Settled module/interface, technical, architecture, schema, API, and interaction decisions. No file paths or code snippets that will stale. Exception: inline only decision-rich state machine/reducer/schema/type fragments from a prototype, labeled as such.

## Testing Decisions

State externally observable behavior, tested modules, chosen seams, and similar repo tests. Never test implementation detail.

## Out of Scope

Explicit exclusions.

## Further Notes

Unresolved material decisions and other notes.

</spec-template>
