---
title: "/plan-arbiter"
description: "Arbitrate competing plans. Use when choosing or merging proposals from agents, transcripts, visual plans, PR descriptions, files, or pasted strategies."
type: skill
sidebar:
  label: "/plan-arbiter"
---
![Diagram of the /plan-arbiter skill](/diagrams/skills/plan-arbiter.svg)

[Open the editable Excalidraw source](/diagrams/skills/plan-arbiter.excalidraw)

Read `references/builder-upstream.md` for the judging checklist.

Turn competing plans into one executable direction. Preserve the best ideas, reject weak assumptions, and produce a clear handoff instead of a blended mush.

## Workflow

1. Collect source plans: pasted text, local files, session IDs, transcripts, PRs, comments, visual-plan links, or chat history.
2. Normalize each plan: objective, scope, assumptions, unresolved questions, touched files, sequence, validation, rollback, complexity.
3. Cross-review against the real codebase, docs, specs, tests, screenshots, or external systems when relevant.
4. Decide: `Adopt`, `Hybrid`, or `Revise first`.
5. Produce one execution handoff with verification gates and rejected alternatives.

Planning is read-only unless the user explicitly asks implementation after the decision.

## Tie-breakers

1. Correctness and fit to the user's request.
2. Grounding in real files, APIs, tests, data, and UI behavior.
3. Lower irreversible risk.
4. Smaller shippable slice with stronger verification.
5. Clearer executor handoff.

## Output

```md
## Plan arbiter
Sources: <plans inspected>
Verdict: Adopt <plan>|Hybrid|Revise first
Why: <evidence-backed reason>
Execution plan: <ordered steps>
Rejected alternatives: <what and why>
Verification gates: <commands/checks>
Open questions: <only blockers>
```
