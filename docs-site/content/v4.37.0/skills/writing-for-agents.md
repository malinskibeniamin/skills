---
title: "/writing-for-agents"
description: "Writing documents for agents. Use when creating or editing skills, or modifying AGENTS.md or CLAUDE.md."
type: skill
sidebar:
  label: "/writing-for-agents"
---
![Diagram of the /writing-for-agents skill](/diagrams/skills/writing-for-agents.svg)

[Open the editable Excalidraw source](/diagrams/skills/writing-for-agents.excalidraw)

Reference for any document an agent consumes: a skill, `AGENTS.md`, `CLAUDE.md`, or a document reached through a pointer. Packaging differs; the writing does not. The goal is a predictable process, not identical output.

When writing a skill, read [SKILL-MECHANICS.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/writing-for-agents/SKILL-MECHANICS.md) for frontmatter, invocation choice, and routers.

## Context pointers

A **context pointer** is loaded text that names out-of-context material and encodes when to reach it. A skill description and an `AGENTS.md` line naming another document are the same object. Wording, not the target, determines whether the agent follows it reliably.

A pointer states what the material is and the distinct **branches** that trigger it. Because an always-loaded pointer spends tokens and attention every turn:

- Front-load a strong leading word.
- Keep one trigger per branch; synonyms for one branch are duplication.
- Remove identity already carried by the target document.

Sharpen a weak pointer before inlining its target.

## The two loads

- **Context load** -- always-loaded material spending tokens and attention every turn.
- **Cognitive load** -- what the human must remember exists and when to invoke it.

Material behind a pointer avoids body-level context load at the cost of the pointer line. Material without a pointer relies entirely on human memory. Cognitive load is the price of human agency, not a number to minimize blindly.

## Information hierarchy

Documents mix two content types: **steps**, the ordered work an agent performs, and **reference**, the rules and facts it consults. Place each item on the shallowest justified rung:

1. **In-file step** -- primary ordered action.
2. **In-file reference** -- immediately useful supporting material.
3. **Disclosed reference** -- another file loaded through a context pointer.

**Progressive disclosure** moves material down this ladder. Inline what every branch needs; disclose what only some branches need. Reference that buries mandatory steps is a variance bug, not merely a long document.

**Co-location** keeps a concept's definition, rules, and caveats together once its rung is chosen. Scattering fragments one meaning; duplication repeats it.

## Steps and completion criteria

Every step ends on a **completion criterion**:

- **Clarity** -- can the agent distinguish done from not done? Vague bounds invite premature completion.
- **Demand** -- does the criterion require every relevant item, or merely request a list?

Sharpen the bound first. If an irreducibly fuzzy step is still rushed, split the sequence across a real context boundary so later steps stop pulling attention forward. Demand drives the legwork an agent performs without needing a separate "be thorough" instruction.

## When to split

Split a sequence only when visible post-completion steps cause premature completion. Skill-specific invocation splits are in [SKILL-MECHANICS.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/writing-for-agents/SKILL-MECHANICS.md).

## Leading words

A **leading word** is a compact pretrained concept the agent thinks with, such as _tracer bullet_, _frontier_, or _red_. It compresses repeated explanation and anchors both execution in the body and invocation in a pointer. Prefer an existing word over a coined one that needs its own definition.

Hunt repeated phrases that one strong word can replace. The gain is fewer tokens and a sharper retrieval hook.

**Negation** is the adjacent failure mode: a prohibition activates the behavior it names. Prompt the **positive** target instead. Keep a prohibition only when it is a hard guardrail that cannot be stated positively, and pair it with what to do.

## Pruning

- Keep each meaning in one source of truth. Duplication inflates prominence and maintenance cost.
- Treat the environment as a source of truth: scripts, config, layout, and `--help` already answer cheap lookups. A document is a cache; keep it only for expensive lookups, unwritten conventions, reasons, and hidden gotchas.
- Check every line for relevance. Unpruned documents accumulate stale sediment.
- Hunt no-ops sentence by sentence. If an instruction does not change behavior from the model's default, delete the sentence rather than polishing it.
- Treat sprawl as an information-hierarchy failure: disclose by branch or split a genuinely rushed sequence.
