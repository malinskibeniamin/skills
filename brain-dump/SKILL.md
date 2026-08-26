---
name: brain-dump
description: Turn raw thoughts, monologues, notes, files, or links into a multi-opportunity brief before grilling.
---

Optional discovery before `/grilling`. Unstructured thoughts or a monologue may reveal several independent tracks; preserve them instead of forcing one objective.

Return the brief in chat unless asked to save or publish. Do not implement, create tickets, or commit to opportunities.

## 1. Absorb

Treat the conversation, notes, attachments, articles, files, and links as one dump. If the user is still talking, acknowledge and wait; otherwise proceed. Read supplied material and repo evidence. Extract external claims, conclusions, constraints, timing, and implications; use `/read-the-damn-docs` or `/research` when current primary sources matter.

Separate source/repo facts, user observations, labelled inferences, contradictions, and unknowns. Never ask the user to repeat an answer already present.

## 2. Reconstruct

Extract actors, pains, outcomes, systems, triggers, constraints, ideas, rejected directions, urgency, and success signals. Name the surface; separate need from solution. Record implied answers in an **Answer ledger**:

- **Settled**: explicit or directly supported.
- **Tentative**: inferred and safe to challenge.
- **Unknown**: missing and able to change direction.

## 3. Map opportunities

Cluster duplicates and list each distinct, supported direction. Usually show 2-5; keep more only for genuinely broader work. Include disciplines only when evidence supports them.

For each opportunity give outcome/actor, evidence, work products, dependencies/risks/decisions, and cheapest proof: lookup, prototype, measurement, or reversible slice. Recommend by value, evidence, urgency, and reversibility; keep alternatives visible.

## 4. Return

Prune empty sections from this structure:

```markdown
## Brain dump brief

### Orientation
<surface, tension, recommendation>

### Source synthesis
<facts, implications, contradictions, citations or paths>

## Answer ledger
| Likely grilling question | Extracted answer | State | Evidence |
|---|---|---|---|
| ... | ... | Settled / Tentative / Unknown | ... |

## Opportunity map
### <Opportunity>
- Outcome:
- Evidence:
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

Keep it self-contained; link or cite sources instead of copying them.

## 5. Hand off

Continue with `/grilling` for material user decisions and pass every track. Ask only **Unknown** items that could invalidate or prioritize it; challenge **Tentative** items when downside matters; preserve **Settled** answers unless contradicted. Otherwise recommend the next lookup, prototype, spec, plan, or execution skill.
