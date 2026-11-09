---
name: animation-performance
description: "Diagnose measured web animation jank, dropped frames, busy-thread motion, per-frame React work, CSS variable invalidation, or GPU layer cost."
---

Find the frame bottleneck before changing motion. Adapted from Emil Kowalski;
[provenance](../shared/EMIL-SKILLS-CREDITS.md). Audit means report; an explicit fix
request continues through verification and the project's delivery gates.

For optimization/fixes, read the shared [experiment loop](../quantify-impact/REFERENCE.md#optimization-experiments)
before edits; it owns original/accepted baselines, keep/revert decisions and unresolved leads.

If motion is smooth but makes the user wait, use [animate](../animate/SKILL.md#choose-the-motion-lane)
to separate unnecessary motion from timing problems. Shortening a duration does not prove
that dropped frames were fixed; a compositor-friendly animation can still feel sluggish.

## Loop

1. Capture the failing interaction: route, data size, animation driver/properties,
   browser/device, refresh rate, and overlapping navigation/loading. Save a baseline
   Performance trace under `.context/`; static code suspicion is not measured jank.
2. Locate the late-frame work: JavaScript/React, style invalidation, layout, paint,
   composition, or excessive layer memory. Frame time is about 16.7 ms at 60 Hz
   and 8.3 ms at 120 Hz; a smooth desktop run does not prove phone performance.
3. Test one cause with the smallest equivalent change:

   | Evidence | Candidate |
   |---|---|
   | Layout each frame | Transform decoration instead; retain required flow geometry |
   | Expensive shadow/blur paint | Smaller painted area or simpler effect; compare visual semantics |
   | Busy JS during motion | Eligible CSS/WAAPI path; confirm actual compositor execution |
   | React render every frame | Motion values or bounded ref updates; retain semantic React state |
   | Cost grows with descendants | Localize inherited CSS-variable writes to the moving element |
   | Individual Motion transforms miss acceleration | Check version/path: Motion 14.2+ can combine HTML shorthands; try full `transform` on older versions |
   | Layer setup causes observed hitch | Scoped, temporary `will-change`; remove if gain is unproven |

4. Replay identical base/candidate conditions and compare late frames, layout/paint,
   and memory. Recheck rapid reversal, cancellation, reduced motion, focus, and visual
   equivalence. Reject displaced cost and changes smaller than run-to-run variance.
5. Report cause, `file:line`, trace path, before/after measurements, and device limits.
   No device access means that hardware-specific result remains unverified, not fabricated.

## Constraints

- Name transition properties instead of `all`; default to `transform`/`opacity`.
- Hardware acceleration is progressive enhancement. CSS, WAAPI, and Motion are not
  blanket guarantees; verify [current Motion guidance](https://motion.dev/docs/performance)
  and the installed library path. CPU throttling does not emulate GPU or phone memory.
- Motion 14.2+ can combine HTML `x`/`y`/`scale`/`rotate` into an eligible WAAPI transform;
  preserve those shorthands when appropriate. Layout/layoutId, `onUpdate`,
  `transformTemplate`, inertia and frame-driven values still need main-thread work.
- A scale is not a universal height/padding substitute; it scales text and leaves flow
  unchanged. Preserve correctness before choosing a cheaper rendering path.
- Profile blur/filter/clip-path on supported browsers; a fixed pixel cutoff proves nothing.
- Cancel frame loops, observers, and animations on unmount; release temporary layer hints.
  React Compiler owns memoization; avoid adding memo wrappers as a substitute for diagnosis.

When route loading, bundle cost, or backend work dominates rather than frames, load
[ux-performance](../ux-performance/SKILL.md) per the
[dependency-loading contract](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
