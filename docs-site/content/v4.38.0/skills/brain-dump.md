---
title: "/brain-dump"
description: "Turn unstructured thoughts, notes, articles, files, or links into a grounded opportunity brief before grilling. Use when the user has a rough area but lacks a stable objective or focused question."
type: skill
sidebar:
  label: "/brain-dump"
---
![Diagram of the /brain-dump skill](/diagrams/skills/brain-dump.svg)

[Open the editable Excalidraw source](/diagrams/skills/brain-dump.excalidraw)

Turn raw signal into an optional discovery packet for a later `/grilling` session. Preserve
breadth: one dump may reveal several independent problems, jobs, tickets, or research tracks.
Stay in discovery. Return the brief in chat unless asked to save or publish it; do not
implement, create tickets, or turn opportunities into commitments.

## 1. Absorb before shaping

Treat the conversation, notes, attachments, files, and links as one dump. If the user says
they are still talking, acknowledge briefly and wait. Otherwise proceed without ceremony.
Read supplied material and repository evidence. For an article or link without a question,
extract its claim, conclusion, constraints, timing, and implications. When current standards,
APIs, or roadmaps matter, follow primary sources through `/read-the-damn-docs` or `/research`.

Separate:

- source facts and repository facts;
- the user's observations, preferences, and constraints;
- reasonable inferences, labelled as inferences;
- contradictions and genuinely unknown information.

Never ask the user to repeat an answer already present in the dump or evidence.

## 2. Reconstruct the surface

Extract actors, pains, outcomes, systems, triggers, constraints, ideas, rejected directions,
urgency, and success signals. Put implied answers in an **Answer ledger** with three states:

- **Settled** -- explicit or directly supported;
- **Tentative** -- inferred and safe to challenge;
- **Unknown** -- missing and capable of changing a direction.

Name the broad surface before proposing work; separate the need from suggested solutions.

## 3. Expand the opportunity map

Generate each distinct, supported direction; cluster duplicates. Usually show 2-5, but keep
more when justified. Include product, UX, engineering, docs, and research only when supported.

For each opportunity, state:

1. outcome, actor, and supporting evidence;
2. plausible work products, dependencies, risks, and open decisions;
3. cheapest next proof: lookup, prototype, measurement, or reversible slice.

Recommend a direction or compatible bundle by value, evidence, urgency, and reversibility.
Keep alternatives visible; the map does not promise that each item becomes backlog work.

## 4. Return the artifact

Use this structure, pruning empty sections:

```markdown
## Brain dump brief

### Orientation
<surface, central tension, and recommended starting direction or bundle>

### Source synthesis
<important conclusions, facts, implications, contradictions, and citations or paths>

## Answer ledger
| Likely grilling question | Extracted answer | State | Evidence |
|---|---|---|---|
| ... | ... | Settled / Tentative / Unknown | ... |

## Opportunity map
### <Opportunity>
- Outcome:
- Why this is plausible:
- Work products:
- Risks and dependencies:
- Cheapest next proof:

## Grilling handoff
- Settled context to preserve:
- Tentative assumptions to challenge:
- Material user decisions still open:
- Facts to look up without asking the user:
- Candidate prototypes or measurements:
```

Make it self-contained for the next phase, but link or cite sources instead of copying them.

## 5. Hand off to grilling

Continue with `/grilling` when material decisions remain. Pass every opportunity track. Ask only
about **Unknown** items that could invalidate or prioritize a track; challenge **Tentative** items
when the downside matters. Treat **Settled** items as answered unless evidence contradicts them.

Otherwise stop after the brief and recommend the next lookup, prototype, spec, plan, or action.
