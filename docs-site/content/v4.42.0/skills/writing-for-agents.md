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


Repeated corrections/skill improvements: read [Poteto](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#harness-improvement).

For prose, read [Poteto](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#writing).

For skills, read [SKILL-MECHANICS.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/writing-for-agents/SKILL-MECHANICS.md).

## Depth

A **context pointer**: material + context load trigger. Progressive disclosure, shallowest first:

1. Inline universal steps.
2. Inline reference needed during them.
3. Link branch-only detail with a precise trigger.
4. Treat the environment as a source of truth; cache only expensive lookups.

Front-load triggers; name branches once. Keep mandatory steps inline.

## Executable instructions

- Use repo-term imperatives.
- Give steps observable completion criteria.
- Enforce deterministic rules in existing checks; link owning commands/configs before edits. Prose carries intent/exceptions, not duplicate rule catalogs. Instructions are not enforcement.
- Define leading terms only to replace repetition.
- Negation activates behavior. Prompt the **positive** target; reserve prohibitions for hard guardrails and pair with safe action.
- Split sequences only when later visible steps cause premature completion.

## Behavioral evaluations

Keep each candidate-facing prompt an organic request: hide grader, expected answer,
evaluator/model identity, and baselines. Give outcomes and public verification, not recipes.
Run the prompt-blinding preflight before paid evals.

## Compress

Delete behavior-neutral no-ops.

- One source per meaning.
- Drop identity repeated in paths/headings.
- Drop restatement, praise, narration and repeated conclusions.
- Use a rule or discriminating example.
- Keep rationale that prevents likely error.
- Fix unclear code/config instead of documenting mechanics.
- Link branch-only detail; co-locate rules, definitions and caveats.

Stop at correct selection, guardrails and proven completion.
