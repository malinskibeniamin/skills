---
description: "Diagnose measured web animation jank, dropped frames, busy-thread motion, per-frame React work, CSS variable invalidation, or GPU layer cost."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["animation performance"]}
sidebar: {"label":"/animation-performance"}
title: "/animation-performance"
type: "skill"
---
![Diagram of the /animation-performance skill](/diagrams/skills/animation-performance.svg)

[Open the editable Excalidraw source](/diagrams/skills/animation-performance.excalidraw)


Find the frame bottleneck before changing motion. Adapted from Emil Kowalski;
[provenance](https://github.com/malinskibeniamin/skills/blob/v4.40.0/shared/EMIL-SKILLS-CREDITS.md). Audit means report; an explicit fix
request continues through verification and the project's delivery gates.

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
   | Individual Motion transforms miss acceleration | Try full `transform`, after checking installed version |
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
- A scale is not a universal height/padding substitute; it scales text and leaves flow
  unchanged. Preserve correctness before choosing a cheaper rendering path.
- Profile blur/filter/clip-path on supported browsers; a fixed pixel cutoff proves nothing.
- Cancel frame loops, observers, and animations on unmount; release temporary layer hints.
  React Compiler owns memoization; avoid adding memo wrappers as a substitute for diagnosis.

When route loading, bundle cost, or backend work dominates rather than frames, load
[ux-performance](https://github.com/malinskibeniamin/skills/blob/v4.40.0/ux-performance/SKILL.md) per the
[dependency-loading contract](https://github.com/malinskibeniamin/skills/blob/v4.40.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
