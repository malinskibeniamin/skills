# Gesture ingredients

Use the installed primitive's behavior first. These are starting points for custom
interactions, not a new physics engine or a frozen Motion/Vaul API table.

## Position, resistance and velocity

- Track from `visualPositionAtGrab + pointerDelta`, not the last settled target.
  When a gesture starts from a nonzero snap point, release offset alone is not position.
  Keep raw pointer travel distinct from the resisted display position.
- For an out-of-bounds distance `d >= 0`, a bounded resistance candidate is
  `r(d) = (L * c * d) / (L + c * d)`, with `L > 0` in CSS px and `c > 0` unitless.
  Display `boundary + sign * r(d)`; keep the in-bounds path 1:1. Match both boundary
  sides continuously. A hard boundary may be intentional; do not force elasticity.
- With Motion, `dragElastic` near `0.2` is an alternative tuning candidate, not an
  implementation of that exact formula. Use its installed constraint model rather
  than stacking custom resistance on top. Re-measure bounds after layout changes.
- Estimate release velocity from a recent, bounded sample window, not total distance
  divided by the whole drag duration. A pause before release should not retain an old
  flick. For raw Pointer Events, CSS px / milliseconds * 1000 gives CSS px/second;
  ignore nonpositive time deltas and reset samples after cancellation/re-grab.
- Project onto the allowed direction: a downward dismiss requires positive downward
  travel/velocity, not `abs(velocity)`. A reversed or perpendicular flick must not
  dismiss accidentally. Require recognized drag intent before treating velocity as commit.
- Candidate dismiss thresholds are 40-50% of available travel OR roughly 500 CSS px/s
  on the allowed axis. Calibrate to target size, scroll arbitration and real-device
  behavior; snap-point selection can use projected travel instead of dismissal rules.
- [Motion drag](https://motion.dev/docs/react-drag) exposes offset/velocity, elastic
  constraints and default release inertia. Disable `dragMomentum` when a custom
  release driver owns settling, or when repositioning should stop at the pointer.
  Check the installed API's units and spring model; do not mix duration/bounce tuning
  with physical stiffness/damping/mass parameters and assume both apply.
- Keep rejected drags' snap-back prompt. A small release bounce may convey applied
  force; large surfaces usually need less. Button/Escape closing need not inherit
  fling physics. Tune against product tokens and reduced motion, not bounce quotas.

## Sheets, toasts and linked surfaces

| Interaction | Preserve / tune |
|---|---|
| Scrollable sheet | Native content scroll until the primitive hands off at the correct edge; dedicated handle if same-axis arbitration is unreliable |
| Snap-point sheet | Current absolute position, allowed snap targets, resize/keyboard geometry, catch during close; focus/inertness follow modal state, not drag distance alone |
| Swipe-to-dismiss toast/card | Direction consistent with placement and product model; readable content and action buttons; persistent recovery for important errors |
| Drag to reorder | Stable item identity, cancel restores order, accessible move controls, scrolling container behavior |
| Pull to refresh | Explicit app-region ownership and loading state; retain browser refresh outside that region |

Scope `touch-action: pan-y pinch-zoom` for a custom horizontal drag; the vertical
counterpart is `pan-x pinch-zoom`. This permits the perpendicular native pan, not a
same-axis scroll/drag handoff. Configure the owning surface and ancestor intersection
before pointerdown; changing it mid-gesture cannot reclaim a browser-owned pan.
See [MDN touch-action](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/touch-action).

Exclude buttons, links, inputs and selectable content from drag initiation through
the primitive's supported mechanism (`data-vaul-no-drag` where supported). Pointer
capture retains events outside the handle, but does not override browser cancellation.
See [pointer capture](https://developer.mozilla.org/en-US/docs/Web/API/Element/setPointerCapture).
Give small handles a generous hit region (44 x 44 CSS px is a touch-oriented candidate),
without overlapping adjacent controls or making content unselectable.

Normalize one current progress value against measured travel, clamp it for overlay
opacity, and derive secondary visuals from it during tracking **and** settling.
Avoid a separate timer-based overlay animation that drifts when the user reverses.
On re-grab or cancel, invalidate pending completion work as well as stopping visuals.

For an existing Vaul-style edge sheet, the upstream curve
`cubic-bezier(0.32, 0.72, 0, 1)` over 500 ms is a reference, not a required override.
A small floating surface may suit about 200 ms. Match the component's resize/content
timing family without making it wait to become usable. CSS release can work if it
rebases from the current rendered transform; keyframes, CSS transitions and springs
all need explicit interruption ownership. A fixed curve does not carry arbitrary
release velocity just because it looks spring-like.

## Hold completion and cancellation

Show linear elapsed progress only while the intended pointer/key remains engaged.
Use one monotonic start time/deadline; a 2 s hold and ~200 ms reset are upstream
candidates, not universal destructive-action policy. Cancel on early release,
leaving the activation region, scrolling/capture loss, Escape, blur and unmount.
Ignore key repeat; a canceled deadline or stale animation completion must not commit.
Keep semantic activation and an explicit alternative, with the project's destructive
confirmation/undo policy intact. Under reduced motion, a static time/status indicator
can replace progress movement without changing the deadline or hiding cancellation.
