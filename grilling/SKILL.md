---
name: grilling
description: Grill plans, decisions, and ideas. Use for brainstorming approaches, starting features, pre-code planning, stress tests, or lifecycle phase 2b.
---

# Grilling

**GATE: no code, no files, no implementation until a direction is presented, grilled, and approved.**

## Explore mode (no direction yet)

When invoked before a coherent direction exists ("brainstorm", "explore options", "should we use X or Y?", new feature/architecture choice):

1. Explore context -- read files, docs, recent commits.
2. Clarify -- map the current decision tree and ask its whole frontier in one numbered round.
3. Propose 2-3 approaches with trade-offs. Optional: HTML mockup -> `agent-browser` -> annotated screenshot.
4. Multiple competing plans/options (incl. from other agents) -> `/plan-arbiter` to pick adopt/hybrid/revise.
5. Present the chosen direction, then grill it (below).

**Challenge variant** (reviewing a proposed approach or risky refactor): question every assumption -- "Why this? What breaks if X changes? Empty list? 10,000 items?" -- present alternatives, push back on weak reasoning; consensus only when all concerns are addressed. "Should we use X or Y?" -> explore, then challenge the winner.

**Standing questions** (mined from years of unresolved review debates -- ask whichever applies):
- Risky UI swap: "If this ships broken, is the revert path a flag flip or a deploy? Who flips it, and when does the losing branch get deleted?" (flag lifecycle: removal is the definition of done)
- New dependency: "Does a planned platform migration make this redundant within a quarter?" and "Is this >=~40 lines of tricky domain logic (dates, money, parsing -> take the library) or a trivial util (keep it local)?"
- New abstraction/helper: "Where is the second call site?" -- no extraction without one.
- New escape hatch, ignore, or compat shim: "Will the next LLM session imitate and spread this?" -- if yes, fix at source or gate it mechanically.

## Grill (direction exists)

Interview me relentlessly until we reach a shared understanding. Map this as a **decision tree**: every decision branches into the decisions that depend on it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are settled -- questions answerable now without guessing at another open answer. Ask the whole frontier in one numbered round and provide your recommended answer for each question. Then wait.

Each answer round reshapes the tree. Settled decisions push the frontier outward and unblock dependent questions. Recompute the frontier before the next round; a question that depends on another answer still open this round belongs to a later round.

Finding *facts* is your job, never mine. Explore the environment -- filesystem, tools, and available sources -- rather than asking me. Keep fact-finding inline unless I explicitly authorize delegation or invoke `/swarm`. Do not block independent questions: an unsettled prerequisite delays only its downstream questions while the rest of the frontier proceeds. The *decisions* are mine -- put each to me and wait.

The interview ends when the frontier is empty: every branch visited, nothing left silently assumed. Do not act on it until I confirm we have reached a shared understanding.

## Plan gate (lifecycle phase 2b)

Once a coherent plan exists, review it with the shared
[plan findings contract](../agents/references/plan-findings-schema.md). Apply every
required axis and all three reviewer hats inline in the current context. Do not spawn
plan agents or start a recursive model call unless I explicitly request delegation or
invoke `/swarm`.

**Evidence packet:** gather the exact plan, request and Spec sources, Standards sources,
planned paths, repo facts, assumptions, tier, and specialist matches once. Give every
axis the same packet. Find facts yourself; `must_answer` contains user decisions only.

**Axes:** keep Spec and Standards separate.
- **Spec (`plan-product-hat`)**: requirements, persona, pain, success, scope, reversibility, TTV.
- **Standards (`plan-engineering-hat`)**: documented rules, architecture, failure paths, tests, rollback, Murphy.
- **Design (`plan-design-hat`)**: flow, a11y, copy, consistency, empty/loading/error.

**Tiers:**

| Tier | Trigger | Axes |
|---|---|---|
| **Quick** | All hold: trivial bug, fewer than 3 tasks, no architectural/product/UX decision | Orchestrator checks Spec, Standards, and adversarial/value inline. Name every skipped hat and specialist with a one-line `skip_reason`; no fan-out. |
| **Standard** | Default within this gate | Three plan hats, inline adversarial/value, and every matched specialist. |
| **Deep-risk** | Credible high-impact or hard-to-reverse surface | Standard plus a plan-time `/resilience-review` and `/steelman` of the highest-risk eligible assumption. |

Deep-risk triggers include auth/security, migrations, public APIs, destructive actions,
concurrency/Temporal, cross-service changes, and one-way doors. Size alone is not risk.
Steelman the highest-risk factual, causal, or architectural assumption; preferences,
goals, and scope choices get an evidence-backed skip reason.

**Adversarial/value:** inline, ask what makes the plan wrong even if implemented
perfectly and whether the smallest plan is worth its cost.

**Specialist registry:** conditional axes use the same packet and schema. Initially,
`*.go`, `go.mod`, or planned Go implementation around a backend proto routes through
`/golang` for bounds, APIs, errors, concurrency, Temporal, tests, rollout, and
controllers. `/golang-review` waits for a diff. Add routes only after repeated misses.

**Merge:** validate the plan schema; dedupe findings and `must_answer` by root cause;
preserve Spec and Standards; keep the strongest evidence. Every axis reports
`APPROVED`, `NEEDS_CHANGES`, `BLOCKED`, or `SKIPPED`; a skip needs a one-line skip
reason. Update the plan for changes. Blocking findings halt until answered or explicitly
overridden. Then ask for implementation confirmation. Competing plans go through
`/plan-arbiter`.

The lifecycle invokes this gate only for explicit grilling/planning or unresolved
material architectural, product, or UX decisions. Ordinary well-scoped
build/fix/implement work states its concise plan and continues without this stop.
[ETHOS: Grill Before Build]

## With docs (domain capture)

When terms or ADR-worthy decisions crystallize mid-grill, run `/domain-modeling` inline rather than batching:

- **Challenge against the glossary**: a term conflicting with `CONTEXT.md` gets called out immediately ("your glossary defines 'cancellation' as X, you seem to mean Y -- which?").
- **Sharpen fuzzy language**: propose a precise canonical term for vague or overloaded words.
- **Stress-test with concrete scenarios** that probe boundaries between concepts.
- **Cross-reference with code**: when the user states how something works, check whether the code agrees; surface contradictions.
- **Update `CONTEXT.md` inline** as terms resolve (glossary only -- never a spec or scratch pad).
- **Offer ADRs sparingly**: only when hard to reverse AND surprising without context AND a real trade-off. Formats: see `domain-modeling/CONTEXT-FORMAT.md` and `domain-modeling/ADR-FORMAT.md`.
