---
name: grilling
description: Explore and stress-test plans, decisions, ideas, brainstorming approaches, and UI layouts when a material choice remains open.
---

# Grilling

Grilling discovers consequential unknowns; it does not demand certainty about every
implementation detail. During grilling, no production code or implementation while a
material user-reserved decision is open. Invocation does not authorize delegation.

## 1. Build the evidence packet

Read the request, plan, repository, tests, docs, references, and recent decisions. Facts
are the agent's job. Ask the user only for preferences, scope, risk appetite, and
decisions that cannot be learned from evidence.

Name the blind spot most likely to invalidate the current direction. If seeing behavior
would answer it faster than prose, build or request a disposable prototype first.

## 2. Explore mode

When no direction exists, present 2-3 approaches with trade-offs, reversibility, and
evidence. Recommend one. Competing plans go through `/plan-arbiter`.

For customer-facing UI choices, put an **ASCII wireframe** before the question round.
Sketch each materially different proposed layout in a fenced `text` block using printable
ASCII. Keep box borders aligned and narrow enough to scan. Use the proposal's real labels,
controls, grouping, order, and fixed or scrolling regions instead of generic placeholders.
Treat the sketch as structure, not pixel accuracy; label inferred content.
Show desktop and mobile only when composition changes at a breakpoint. If approaches share a
layout, sketch it once and annotate their visual or behavioral deltas.

**Challenge variant:** when a direction exists, steelman the best alternative and
identify what would make the current choice wrong.

Map a decision tree. Its frontier is every currently answerable decision. Ask the whole frontier
in one numbered round with a recommendation for each.

Use this fixed **Question format** so the user can scan and answer by number:

```markdown
**Q1 -- <question title>**
<question body or choices>

**Recommended:** <answer>
```

An unsettled prerequisite delays only its branch while the rest of the frontier proceeds.
Recompute the frontier after every answer round.

Keep fact-finding inline unless the user explicitly authorizes delegation. Search the
environment, filesystem, tools, and sources. The user's decisions are theirs.

Useful challenges:

- Risky UI replacement: rollback path, owner, and deletion condition.
- Dependency: evidence it beats local code and will survive planned migration.
- Abstraction: demonstrated second call site.
- Escape hatch: whether the next session will copy it.
- Scale or failure claim: the concrete input, timing, or system condition that proves it.

## 3. Exit with classified unknowns

Architecture-changing decisions must be resolved or explicitly reserved for the user.
Classify everything else: **lookup -> prototype -> reversible assumption -> pause trigger**.
The interview ends when no unresolved item can silently invalidate the next slice, not
when all future details are known.

## 4. Plan gate

Gather one **Evidence packet**: request, plan, spec sources, standards sources, planned
paths, repo facts, assumptions, and unresolved decisions.

Use the smallest gate matching the risk:

- **Quick**: trivial bug, fewer than three tasks, no material architecture/product/UX
  choice. Check spec, standards, and value inline.
- **Standard**: product/spec, engineering/standards, and design/UX hats inline.
- **Deep-risk**: standard plus resilience review and a steelman for a credible
  high-impact or hard-to-reverse assumption.

Axes: Spec -> `plan-product-hat`; Standards -> `plan-engineering-hat`; design/UX ->
`plan-design-hat`; plus adversarial/value. Run them inline.

Deep-risk triggers: auth, migration, public API, destructive actions, concurrency, Temporal, cross-service changes, and one-way doors. Add `/resilience-review` and `/steelman`.

**Specialist registry:** planned Go or `go.mod` work uses `/golang`; add another
specialist only after repeated misses.

For each applicable axis, report `APPROVED`, `NEEDS_CHANGES`, `BLOCKED`, or `SKIPPED`
with evidence; a skip needs a skip reason. Dedupe findings by root cause. Blocking user
decisions halt; facts trigger research or a prototype.

Require confirmation only when the user requested a plan/grill endpoint. [ETHOS: Discover Before Commitment]

Use `/domain-modeling` to capture domain terms in `CONTEXT.md`, and an ADR only when the
decision is hard to reverse, surprising without context, and has a real trade-off.
