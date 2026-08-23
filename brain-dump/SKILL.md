---
name: brain-dump
description: Turn unstructured thoughts, monologues, notes, articles, files, or links into a grounded, multi-opportunity brief before grilling. Use when the user knows a rough surface area but lacks a stable objective, concrete problem, or focused question.
---

# Brain Dump

Turn raw signal into an optional discovery packet that makes a later `/grilling` session
shorter and sharper. Preserve breadth: one dump may reveal several independent problems,
jobs, tickets, or research tracks. Do not force it into one objective.

Stay in discovery. Return the brief in chat unless the user asks to save or publish it. Do
not implement, create tickets, or turn candidate opportunities into commitments.

## 1. Absorb before shaping

Treat the full conversation, pasted notes, attachments, files, and links as one dump. If the
user explicitly says they are still talking, acknowledge briefly and wait. Otherwise proceed
without a ceremonial question.

Read supplied material and relevant repository evidence. For an article or link without a
question, extract its central claim, conclusion, constraints, timing, and implications. When
current standards, protocols, APIs, or roadmaps matter, follow them to their primary sources
through `/read-the-damn-docs` or `/research`.

Separate:

- source facts and repository facts;
- the user's observations, preferences, and constraints;
- reasonable inferences, labelled as inferences;
- contradictions and genuinely unknown information.

Never ask the user to repeat an answer already present in the dump or evidence.

## 2. Reconstruct the surface

Extract the actors, pains, desired outcomes, affected systems, triggers, constraints, existing
ideas, rejected directions, urgency, and success signals. Translate implied answers into an
**Answer ledger** with one of three states:

- **Settled** -- explicit or directly supported;
- **Tentative** -- inferred and safe to challenge;
- **Unknown** -- missing and capable of changing a direction.

Name the broad surface before proposing work. Distinguish the underlying need from any solution
the dump happened to mention.

## 3. Expand the opportunity map

Generate every materially distinct, evidence-supported direction; cluster duplicates rather
than padding the list. Usually show 2-5, but keep more when the dump genuinely spans more work.
Include product, UX, feature, bug, test, resilience, documentation, architecture, developer
experience, CI, performance, migration, and research directions only when supported.

For each opportunity, state:

1. the outcome and affected actor;
2. the evidence or signal behind it;
3. plausible work products;
4. dependencies, risks, and open decisions;
5. the cheapest next proof: lookup, prototype, measurement, or reversible slice.

Recommend a starting direction or compatible bundle based on value, evidence, urgency, and
reversibility. Keep alternatives visible. An opportunity map is not a promise that every item
should become backlog work.

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

Make the artifact self-contained enough for the next phase, but link or cite source material
instead of copying it.

## 5. Hand off to grilling

Continue with `/grilling` when material user decisions remain. Pass the whole brief, including
every opportunity track. Ask only about **Unknown** items that could invalidate or prioritize a
track; challenge **Tentative** items when the downside matters. Treat **Settled** items as already
answered unless new evidence contradicts them.

If no material user decision remains, stop after the brief and recommend the next appropriate
lookup, prototype, spec, plan, or execution skill instead of inventing grilling questions.
