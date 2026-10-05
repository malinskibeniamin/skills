---
name: grilling
description: Explore and stress-test plans, decisions, ideas, brainstorming approaches, and UI layouts when a material choice remains open.
---

Resolve consequential unknowns, not every detail: no production code or implementation while a material user-reserved decision is open. Invocation does not authorize delegation.

Plans/RFCs/replies: read [communication](../shared/communication.md).
Load skills per [dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## 1. Build evidence

Read request, plan, repo, tests, docs, references, and decisions. Ask only for user-owned preferences, scope, risk appetite, or decisions evidence cannot settle. Name the biggest blind spot. Prototype when behavior beats prose.

`/brain-dump` is optional. Preserve every opportunity track and start from its **Answer ledger**: never re-ask **Settled** entries; challenge **Tentative** only when downside matters; ask **Unknown** only when it could invalidate or prioritize a track.

## 2. Explore mode

With no direction, present 2-3 approaches with trade-offs, reversibility, evidence, and a recommendation. For competing plans, Call the Skill tool with "plan-arbiter". **Challenge variant:** with a direction, steelman the best alternative and say what would make it wrong.

For customer-facing UI, show an **ASCII wireframe** before questions: each materially different layout in fenced `text`, with real labels, controls, grouping, order, and fixed/scroll regions. Align borders; show structure, not pixels. Desktop/mobile only when composition differs; shared layouts use one sketch plus deltas.

Map the decision tree's answerable frontier. Ask the whole frontier in one numbered round using this **Question format**:

```markdown
**Q1 -- <question title>**
<question or choices>

**Recommended:** <answer>

---

**Q2 -- <question title>**
<question or choices>
```

A confident, reversible **Recommended:** answer is an assumption, not a question: state it in one line and continue. Ask only what evidence cannot settle and the user owns.

**Stop signal:** "no more questions", "just do it", "don't ask", or a bare endpoint ("draft PR") ends asking for the rest of the session. Adopt every open recommendation, list them as assumptions, and continue to the endpoint; pause only for an irreversible or user-reserved decision.

An unsettled prerequisite delays only its branch. Recompute the frontier each round. Keep fact-finding inline unless delegation is explicitly authorized; search environment, filesystem, tools, sources. User decisions stay theirs.

## 3. Exit

Resolve or reserve architecture-changing choices. Classify the rest as **lookup -> prototype -> reversible assumption -> pause trigger**. Exit when nothing unresolved can silently invalidate the next slice.

## 4. Plan gate

Build one **Evidence packet**: request, plan, spec/standards sources, paths, repo facts, assumptions, unresolved decisions.

- **Quick**: under three tasks, no material architecture/product/UX choice; check spec, standards, value inline.
- **Standard**: product/spec, engineering/standards, and design/UX reviewer hats inline.
- **Deep-risk**: Standard plus separate Skill tool calls for "resilience-review" and "steelman" for a credible high-impact or hard-to-reverse assumption.

Axes: Spec -> `plan-product-hat`; Standards -> `plan-engineering-hat`; design/UX -> `plan-design-hat`; plus adversarial/value. Deep-risk triggers: auth, migration, public API, destructive action, concurrency, Temporal, cross-service work, and one-way doors.

**Specialist registry:** Call the Skill tool separately with "av" for value and "golang" for planned Go or `go.mod` work; add specialists after repeated misses. Axes report `APPROVED`, `NEEDS_CHANGES`, `BLOCKED`, or `SKIPPED` with evidence/skip reason. Dedupe root causes; research facts; stop on blocking user decisions.

Confirm only for a requested plan/grill endpoint. [ETHOS: Discover Before Commitment]

Call the Skill tool with "domain-modeling" for `GLOSSARY.md` terms; ADR only for hard-to-reverse, surprising trade-offs.
