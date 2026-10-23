---
name: animate
description: "Build, review, or plan purposeful web UI motion. Use for transitions, easing, springs, gestures, motion audits, or animation opportunities; not video production or native apps."
---

Choose motion that explains a state change without delaying the user's task.
Adapted from Emil Kowalski; [source and selection](../shared/EMIL-SKILLS-CREDITS.md).
Recorded product walkthroughs use the [demo recording stack](../demo/RECORDING.md),
not UI animation. `/demo` remains user-invoked; this pointer grants no publication scope.

## Endpoint

- Build/fix: implement the requested motion through the project's TDD and delivery gates.
- Review: report evidenced defects; leave source unchanged.
- Audit/plan/opportunities: rank improvements or justified additions; leave source unchanged.
  Save plans only when requested. Do not turn an audit into an execution wave.

## Decision sequence

1. Inspect the component, existing motion tokens, installed library/version, input paths,
   and product context. Use the existing UI primitives before inventing a component.
2. Name the purpose: feedback, spatial continuity, state indication, explanation,
   or rare delight. Repeated navigation, command palettes, and data-reading surfaces
   favor instant changes. Frequency is a heuristic, not an invented daily-use metric.
   Keyboard users get equivalent feedback without a waiting period.
3. Choose the cheapest faithful driver: CSS transitions for state changes;
   `@starting-style` for supported entry transitions; WAAPI for imperative control;
   an installed spring/motion library for gestures, layout, or exit lifecycles.
   Read installed types and current official docs before using library-specific APIs.
4. Prefer explicit `transform`/`opacity` transitions. Retarget from the current value;
   preserve exit state until completion and handle interruption/unmount cleanup.
   Scale anchored surfaces from their trigger; keep centered dialogs centered.
5. Reuse tokens. For new tokens and component-specific starting points, read
   [REFERENCE.md](REFERENCE.md); profile instead of assuming hardware acceleration.
6. Respect reduced motion, hover capability, focus, and cancellation from the start.
   Remove non-essential movement; instant state changes are valid. Keep essential
   meaning available without animation. Gate hover with `(hover: hover) and (pointer: fine)`.
7. Exercise enter/exit, rapid reversal, repeated activation, keyboard, reduced motion,
   and touch paths at the real entrypoint. Record what was observed and what needs a device.

## Review and planning

Review purpose/frequency, easing/timing, origin, interruption, frame cost, accessibility,
and cohesion. Cite `file:line` plus visible or trace evidence; distinguish craft suggestions
from reproducible defects. Existing deliberate tradeoffs are context, not automatic findings.

For opportunity searches, show the eligible location, purpose, expected frequency,
recipe, and rejected candidates. No surviving opportunity is a valid result.
For a roadmap, rank confirmed findings by user impact and effort; include exact target
values, existing tokens, scope, rollback, and a real feel-check in each requested plan.

Report the decision, ingredients, verification, and limits briefly. A code-only review
cannot approve perceived feel or claim measured smoothness. For measured frame problems,
load [animation-performance](../animation-performance/SKILL.md); for general visual critique,
load [visual-review](../visual-review/SKILL.md) per the
[dependency-loading contract](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
