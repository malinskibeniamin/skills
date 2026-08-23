---
name: grilling
description: Explore and stress-test plans, decisions, ideas, brainstorming approaches, and UI layouts when a material choice remains open.
---

Grilling resolves consequential unknowns, not every detail. Allow no production code or implementation while a material user-reserved decision is open. Invocation does not authorize delegation.

## 1. Build evidence

Read the request, plan, repo, tests, docs, references, and decisions. Facts are the agent's job; ask only for preferences, scope, risk appetite, or decisions evidence cannot answer. Name the blind spot most likely to invalidate the direction. Prototype when behavior answers faster than prose.

`/brain-dump` is optional. Preserve every opportunity track and start from its **Answer ledger**: never re-ask **Settled** entries; challenge **Tentative** only when downside matters; ask **Unknown** only when it could invalidate or prioritize a track.

## 2. Explore mode

With no direction, present 2-3 approaches with trade-offs, reversibility, evidence, and a recommendation. Route competing plans to `/plan-arbiter`. **Challenge variant:** with a direction, steelman the best alternative and say what would make it wrong.

For customer-facing UI, show an **ASCII wireframe** before questions. Sketch each materially different layout in a fenced `text` block with real labels, controls, grouping, order, and fixed/scroll regions. Keep borders aligned; treat it as structure, not pixel accuracy. Show desktop and mobile only when composition changes. Shared layouts need one sketch plus deltas.

Map a decision tree to its currently answerable frontier. Ask the whole frontier in one numbered round using this **Question format**:

```markdown
**Q1 -- <question title>**
<question or choices>

**Recommended:** <answer>

---

**Q2 -- <question title>**
<question or choices>
```

An unsettled prerequisite delays only its branch while the rest of the frontier proceeds. Recompute the frontier after every round. Keep fact-finding inline unless the user explicitly authorizes delegation; search the environment, filesystem, tools, and sources. The user's decisions are theirs.

## 3. Exit

Resolve or reserve architecture-changing choices. Classify the rest as **lookup -> prototype -> reversible assumption -> pause trigger**. Exit when nothing unresolved can silently invalidate the next slice.

## 4. Plan gate

Build one **Evidence packet**: request, plan, spec and standards sources, planned paths, repo facts, assumptions, and unresolved decisions.

- **Quick**: under three tasks and no material architecture/product/UX choice; check spec, standards, and value inline.
- **Standard**: product/spec, engineering/standards, and design/UX reviewer hats inline.
- **Deep-risk**: Standard plus `/resilience-review` and `/steelman` for a credible high-impact or hard-to-reverse assumption.

Axes: Spec -> `plan-product-hat`; Standards -> `plan-engineering-hat`; design/UX -> `plan-design-hat`; plus adversarial/value. Deep-risk triggers: auth, migration, public API, destructive action, concurrency, Temporal, cross-service work, and one-way doors.

**Specialist registry:** planned Go or `go.mod` work uses `/golang`; add specialists only after repeated misses. Each axis reports `APPROVED`, `NEEDS_CHANGES`, `BLOCKED`, or `SKIPPED` with evidence and any skip reason. Dedupe by root cause; research facts and stop on blocking user decisions.

Require confirmation only when the user requested a plan/grill endpoint. [ETHOS: Discover Before Commitment]

Use `/domain-modeling` for terms in `CONTEXT.md`; add an ADR only for a hard-to-reverse, surprising trade-off.
