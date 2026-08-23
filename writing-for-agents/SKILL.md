---
name: writing-for-agents
description: Writing documents for agents. Use when creating or editing skills, or modifying AGENTS.md or CLAUDE.md.
---

# Writing for Agents

Write agent instructions that change behavior with the least context. This applies to
skills, `AGENTS.md`, `CLAUDE.md`, and linked references.

When writing a skill, read [SKILL-MECHANICS.md](SKILL-MECHANICS.md) for frontmatter, invocation choice, and routers.

## Put information at the right depth

A **context pointer** names material outside the loaded document and states when to read
it. The pointer spends context load; omitting it spends human recall.

**Progressive disclosure** uses the shallowest justified depth:

1. Inline steps every execution needs.
2. Inline reference needed while performing those steps.
3. Link branch-specific reference through a precise context pointer.
4. Treat the environment as a source of truth; cache only expensive lookups. Leave facts
   to configuration, layout, or `--help`.

Front-load a strong trigger in each pointer. Name distinct branches once. Do not hide a
mandatory step in a reference.

## Write executable instructions

- Use imperative language and the repository's terms.
- End every step with an observable completion criterion.
- Define a leading word only when it replaces repeated explanation and improves recall.
- Negation activates the behavior it names. Prompt the **positive** target; keep a
  prohibition only for a hard guardrail, paired with the safe action.
- Split a sequence only when visible later steps cause premature completion.

## Compress before publishing

Hunt no-ops: for every line, ask what behavior changes if it is deleted. Delete the line
when the answer is none.

- Keep each meaning in one source of truth.
- Remove identity already carried by the file, target, or heading.
- Remove request restatements, praise, process narration, and repeated conclusions.
- Replace explanation with a precise rule or one discriminating example.
- Keep reasons only when they prevent a likely wrong action.
- Make unclear code or configuration clearer instead of documenting obvious mechanics.
- Move branch-only detail behind a pointer; co-locate its definition, rule, and caveats.

Stop when the shortest version still selects the right branch, preserves every guardrail,
and makes completion testable.
