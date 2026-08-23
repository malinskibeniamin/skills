---
title: "/to-spec"
description: "Turn the current conversation into a tracker-ready specification."
type: skill
sidebar:
  label: "/to-spec"
---
![Diagram of the /to-spec skill](/diagrams/skills/to-spec.svg)

[Open the editable Excalidraw source](/diagrams/skills/to-spec.excalidraw)

This skill produces a spec (sometimes called a PRD) from settled conversation context and codebase
evidence. Synthesize without reopening settled decisions. Mark any material missing decision under
Further Notes instead of silently assuming it.

Use the issue-tracker and triage-label vocabulary under `docs/agents/` when present. If it is
missing, return the spec in chat and note `/work-automation-kit` as an optional setup follow-up.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the spec, and respect any ADRs in the area you're touching.

2. Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better - the ideal number is one.

If the spec relies on current third-party/API behavior, run `/read-the-damn-docs`. If multiple
solution or seam plans are plausible, run `/plan-arbiter`. Use `/visual-plan` only when the user
requested that additional review artifact.

3. Write the spec using the template below. Return it in chat by default; publish it to the
project issue tracker and apply `ready-for-agent` only when the user requested publication.

4. If the user wants implementation work broken down next, hand the approved spec to `/to-tickets`.

<spec-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A numbered list with one story per distinct in-scope actor outcome:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

**Completion:** every in-scope behavior, boundary, and recovery outcome maps to one story;
duplicate wording, implementation details, and out-of-scope behavior are absent.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do not include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts -- not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (that is, similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this spec.

## Further Notes

Any further notes about the feature.

</spec-template>
