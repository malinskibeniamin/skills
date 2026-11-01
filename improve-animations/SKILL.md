---
name: improve-animations
description: "Audit existing web UI motion and prioritize concrete improvements or self-contained implementation plans. Use for a motion roadmap; animate owns implementation and diff review."
---

Find the highest-value fixes in motion that should remain. Adapted from Emil Kowalski;
[source and compatibility](../shared/EMIL-SKILLS-CREDITS.md). Audit/plan requests return
findings without source edits. Save plans only when requested. Explicit implementation
requests continue through [animate](../animate/SKILL.md) and the project's delivery gates,
in the current context; no automatic executors, agents or worktrees.

## Audit

1. Map the requested surface, installed motion library/version, component primitives,
   existing tokens, input paths and product context. Identify expected frequency without
   inventing usage counts. Respect documented tradeoffs; confirm each cited location.
2. Load [animate](../animate/SKILL.md) and its [craft reference](../animate/REFERENCE.md).
   Audit purpose/frequency, easing/duration, physicality/origin, interruption,
   rendering cost, accessibility, token cohesion and genuine missed opportunities.
   Apply these axes inline. For unnecessary motion, route to
   [remove-animations](../remove-animations/SKILL.md) rather than polishing it.
3. Vet findings against actual state changes and existing decisions. Distinguish
   reproducible defects from craft suggestions and unmeasured performance suspicions.
   Rank by user impact and effort; show severity, category, `file:line`, evidence and
   fix. An empty result is valid; do not force additions or fixed finding counts.
4. When plans are requested, make each independently executable: current revision,
   problem/current excerpt, exact targets and token values, repository exemplar,
   ordered edits, scope/dependencies, rollback and focused verification commands.
   Include rapid reversal, keyboard/touch, reduced motion and a real feel-check;
   name any device evidence still needed. Revalidate stale plans against current code.

For the sequence `remove-animations -> improve-animations -> animation-performance`,
subtract first, assess retained motion second, then profile the remaining frame problems.
The sequence preserves the requested endpoint; an audit does not authorize fixes.

Load [animation-performance](../animation-performance/SKILL.md) for frame bottlenecks;
static code inspection cannot prove smoothness. Load dependencies through the
[dependency-loading contract](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
