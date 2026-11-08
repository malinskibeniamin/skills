---
name: gestures
description: "Build or fix web drag, swipe, sheet, reorder, and hold interactions: direct tracking, rubber banding, release velocity, momentum, snap points, and interruption. Not native React Native or Swift."
---

Make direct manipulation follow the pointer, then settle predictably after release.
Adapted from Emil Kowalski; [source and compatibility](../shared/EMIL-SKILLS-CREDITS.md).
Questions/reviews return guidance or findings without edits; build/fix follows project
TDD, verification and delivery. Loading this skill grants no installs or device access.

## Choose the owner

Inspect the component, input paths, installed library/version and existing UI wrapper.
Reuse its drawer, dialog, toast or reorder primitive before hand-rolling physics.
Consider Vaul only if it fits the stack and requested scope; retain its focus trap,
Escape, focus return, scroll locking and dismissal behavior. A gesture is not a reason
to replace a working library. Check installed types and current official docs for APIs.

## Gesture loop

1. **Define intent.** Identify the axis, handle, bounds/snap points, commit action,
   cancel path and non-drag alternative. Prefer native scroll/snap when it fits.
   Separate press feedback from activation; preserve accessible click/submit controls.
2. **Arbitrate input.** Let scrolling, text selection and interactive children keep
   their native behavior. For custom pointer handling, track the active pointer id,
   capture only the owned drag, and handle `pointercancel`, `lostpointercapture`,
   extra pointers and unmount. Cancellation must not commit a dismiss/delete/reorder.
   Set scoped `touch-action` before the gesture; preserve pinch zoom. For phone/browser
   symptoms, load [mobile-native](../mobile-native/SKILL.md).
3. **Track directly.** Within bounds, map pointer displacement 1:1 from the element's
   current visual position. Use the library's motion value or a direct transform,
   without a tracking spring/transition or per-move React renders. Apply resistance
   only beyond the permitted boundary. Avoid driving large descendant trees through
   an inherited per-frame CSS variable; profile the actual update path.
4. **Resolve release.** Read current displacement and recent signed velocity on the
   owned axis. Choose a snap/dismiss target from distance OR a deliberate flick in
   the allowed direction; use consistent units. Reposition-only drags can stop on
   release. Fling interactions can use inertia; spring settling can inherit velocity.
   Keep one release driver: library momentum and a custom spring must not compete.
5. **Stay catchable.** On re-grab, stop the release driver, read its current position,
   and rebase the new drag origin there. Retarget from the current value/velocity
   where supported. Neither a spring nor CSS automatically guarantees this handoff.
   Keep related overlay/scale values derived from the same drag progress; prevent
   stale completion callbacks from unmounting or committing after interruption.
6. **Settle accessibly.** Under reduced motion, retain necessary direct tracking but
   remove decorative bounce and long momentum; settle promptly or instantly. Keep
   the outcome available via buttons/keyboard and a non-drag pointer path. Holds show
   elapsed time linearly, cancel on early release/escape/lost capture, and commit once.
   A hold is not the sole way to perform an action or a substitute for confirmation.

For threshold units, resistance, sheets and hold-specific checks, read
[REFERENCE.md](REFERENCE.md). Treat its numbers as tuning candidates, not fixed rules.
For multi-element timing and transition craft, load [animate](../animate/SKILL.md);
for measured drag stutter, load [animation-performance](../animation-performance/SKILL.md).
Use the [dependency-loading contract](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Verify and hand off

Exercise slow drag, short fast flick, reverse direction, boundary resistance, snap-back,
re-grab during settling, nested scroll, child activation, cancellation, multiple pointers,
resize/unmount and reduced motion. Test keyboard/non-drag equivalence and retained focus.
Use the real component; record normal-speed/frame-stepped interaction only when needed
to resolve continuity. Code inspection cannot prove feel, frame rate or phone behavior.
Physical-device checks require available authorized hardware; report missing coverage
without exposing a dev server or installing tooling just to satisfy this skill.

Report track/release choices, thresholds and units, cancellation/alternative behavior,
observed verification and remaining device limits. Keep review findings separate from taste.
