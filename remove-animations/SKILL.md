---
name: remove-animations
description: "Remove or reduce unnecessary web UI motion: repeated reveals, decorative loops, delayed keyboard actions and reanimated data. Subtraction only; use animate for retained motion."
---

Subtract motion that delays the task without explaining a meaningful change.
Adapted from Emil Kowalski; [source and compatibility](../shared/EMIL-SKILLS-CREDITS.md).
An audit or question returns findings without edits; a removal request implements
through the project's TDD and delivery gates. Loading grants no broader authority.

## Removal loop

1. Map motion in the requested scope: component, trigger, driver, properties, tokens,
   purpose and observed or expected frequency. Respect documented design decisions.
   Treat frequency as a heuristic, not invented daily-use analytics.
2. Keep motion that conveys feedback, spatial continuity, state or explanation.
   Consider rare delight in context. Prioritize removing repeated scroll reveals,
   decorative loops, chart redraws/count-ups on every mount, list staggers and waiting
   periods on keyboard or frequent navigation. Preserve equivalent keyboard feedback,
   loading indicators and essential status meaning; instant state changes are valid.
3. Choose delete, reduce or keep, with `file:line` and the deciding reason. Reduce only
   the existing effect: drop spatial movement or stagger, shorten excessive delay,
   or stop a decorative loop. Reuse existing tokens; add no new animation or easing.
   Tooltip groups should not repeat the initial delay as the pointer moves between them.
4. Before editing, trace hidden initial states, fill modes, observers, animation-end
   callbacks, duration-sized timers, exit/unmount lifecycles and deferred focus.
   Remove hidden starts with reveals. Move completion/focus work to the actual state
   change, exactly once, rather than leaving a wait for a deleted event.
   If layout motion masks a jump, retain it and report the underlying layout problem.
5. Delete only proven orphans: keyframes, variants, motion imports, wrappers and tokens.
   Retain any wrapper with other behavior. Dependency removal is outside this motion-only
   cleanup; report unused libraries without changing the manifest or lockfile.
6. Verify visible content, immediate close/unmount, focus restoration, keyboard/touch,
   rapid reversal and reduced motion at the real entrypoint. Run focused tests and
   repository checks; confirm removed names have no remaining references.

## Handoff

Report changed locations with before -> verdict -> reason, deliberately kept motion
with its purpose, orphan cleanup and verification limits. Do not invent kept examples
to fill a quota or claim perceived speed/frame-rate gains from code inspection.

For retained motion needing craft fixes, load [animate](../animate/SKILL.md); for a
prioritized audit or roadmap, load [improve-animations](../improve-animations/SKILL.md).
For measured jank, load [animation-performance](../animation-performance/SKILL.md).
Use the [dependency-loading contract](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
