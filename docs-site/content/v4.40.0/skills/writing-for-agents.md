---
description: "Writing documents for agents. Use when creating or editing skills, or modifying AGENTS.md or CLAUDE.md."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["writing for agents"]}
sidebar: {"label":"/writing-for-agents"}
title: "/writing-for-agents"
type: "skill"
---
![Diagram of the /writing-for-agents skill](/diagrams/skills/writing-for-agents.svg)

[Open the editable Excalidraw source](/diagrams/skills/writing-for-agents.excalidraw)


For skills, read [SKILL-MECHANICS.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/writing-for-agents/SKILL-MECHANICS.md).

## Depth

A **context pointer** names external material and its trigger: context load. Progressive disclosure uses the shallowest depth:

1. Inline universal steps.
2. Inline reference needed during them.
3. Link branch-only detail with a precise trigger.
4. Treat the environment as a source of truth; cache only expensive lookups.

Front-load triggers; name branches once. Keep mandatory steps inline.

## Executable instructions

- Use imperatives and repo terms.
- Give steps observable completion criteria.
- Enforce deterministic rules in existing checks; link owning commands/configs before edits. Prose carries intent/exceptions, not duplicate rule catalogs. Instructions are not enforcement.
- Define a leading term only when it replaces repetition.
- Negation activates behavior. Prompt the **positive** target; reserve prohibitions for hard guardrails and pair with safe action.
- Split sequences only when later visible steps cause premature completion.

## Behavioral evaluations

Keep each candidate-facing prompt an organic request: hide grader, expected answer,
evaluator/model identity, and baselines. Give outcomes and public verification, not recipes.
Run the prompt-blinding preflight before paid evals.

## Compress

Delete no-ops: removal changes no behavior.

- One meaning, one source of truth.
- Remove identity already in filename/target/heading.
- Remove request restatement, praise, narration, repeated conclusions.
- Replace explanation with a rule or one discriminating example.
- Keep rationale only when it prevents likely error.
- Fix unclear code/config instead of documenting mechanics.
- Move branch-only detail behind a pointer; co-locate rule, definition, caveats.

Stop when the shortest version selects correctly, preserves guardrails and proves completion.
