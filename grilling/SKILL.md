---
name: grilling
description: Interview the user relentlessly about a plan or design, with a 3-hat plan gate and optional domain-doc capture. Use when stress-testing a plan before building, as the lifecycle phase 2b gate, or on any 'grill' trigger phrase.
---

# Grilling

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing. Asking multiple questions at once is bewildering.

If a *fact* can be found by exploring the codebase, look it up rather than asking me. The *decisions*, though, are mine -- put each one to me and wait for my answer.

Do not enact the plan until I confirm we have reached a shared understanding.

## Plan gate (lifecycle phase 2b)

Once a coherent plan exists, spawn three reviewer hats **in parallel** (single message, multiple Agent calls), per findings-schema:

- **`plan-product-hat`**: persona, pain, success metric, scope, reversibility, TTV
- **`plan-engineering-hat`**: architecture, error paths, perf, security, test strategy, rollback
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
