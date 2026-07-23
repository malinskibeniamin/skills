---
name: grilling
description: Explore options, then interview the user relentlessly about a plan, decision, or idea, with a 3-hat plan gate and optional domain-doc capture. Use when brainstorming approaches, starting new features, thinking before coding, stress-testing reasoning, as the lifecycle phase 2b gate, or on any 'grill' trigger phrase.
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

Finding *facts* is your job, never mine. Explore the environment -- filesystem, tools, and available sources -- rather than asking me. Claude-hosted sessions may dispatch a fact-finding subagent; Native Codex keeps fact-finding inline unless the user explicitly authorized delegation. Do not block independent questions: a running exploration is an unsettled prerequisite, so only its downstream questions wait while the rest of the frontier proceeds. The *decisions* are mine -- put each to me and wait.

The interview ends when the frontier is empty: every branch visited, nothing left silently assumed. Do not act on it until I confirm we have reached a shared understanding.

## Plan gate (lifecycle phase 2b)

Once a coherent plan exists, run three reviewer hats per findings-schema. Claude-hosted sessions
run `/stay-within-limits`, then spawn them **in parallel** with the selected Claude profile.
Re-check before each wave. Always add one independent GPT-5.6 Sol xhigh combined plan check
via `/codex`; when Claude is disabled, Sol covers all three hats. Native Codex runs all hats inline
unless the user explicitly requests agents or invokes `/swarm`; skill activation
alone is not consent:

- **`plan-product-hat`**: persona, pain, success metric, scope, reversibility, TTV
- **`plan-engineering-hat`**: architecture, error paths, perf, security, test strategy, rollback -- includes the Murphy pass (what breaks first in prod?); the full Murphy panel (`/resilience-review`) runs on the diff at review time, not on the plan
- **`plan-design-hat`**: flow, a11y, copy, visual consistency, states (empty/loading/error)

Merge: dedupe all `must_answer` questions into one list; user answers each; plan updates inline. Any `BLOCKED` hat halts the plan until addressed or overridden. All `APPROVED` (or explicit override) -> implement. Competing plans/transcripts/visual plans -> run `/plan-arbiter` after the hats (Adopt / Hybrid / Revise first).

Skip the fan-out only when ALL hold: trivial bug fix, <3 tasks, no architectural/product/UX decisions. [ETHOS: Grill Before Build]

## With docs (domain capture)

When terms or ADR-worthy decisions crystallize mid-grill, run `/domain-modeling` inline rather than batching:

- **Challenge against the glossary**: a term conflicting with `CONTEXT.md` gets called out immediately ("your glossary defines 'cancellation' as X, you seem to mean Y -- which?").
- **Sharpen fuzzy language**: propose a precise canonical term for vague or overloaded words.
- **Stress-test with concrete scenarios** that probe boundaries between concepts.
- **Cross-reference with code**: when the user states how something works, check whether the code agrees; surface contradictions.
- **Update `CONTEXT.md` inline** as terms resolve (glossary only -- never a spec or scratch pad).
- **Offer ADRs sparingly**: only when hard to reverse AND surprising without context AND a real trade-off. Formats: see `domain-modeling/CONTEXT-FORMAT.md` and `domain-modeling/ADR-FORMAT.md`.
