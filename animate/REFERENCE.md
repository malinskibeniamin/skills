# Motion ingredients

Starting points adapted from Emil Kowalski, not universal performance or taste laws.
Existing product tokens and measured interaction needs win.

## Timing

| Moment | Starting duration | Curve |
|---|---|---|
| Press feedback | 100-160 ms | ease-out |
| Tooltip/small popover | 125-200 ms | ease-out |
| Dropdown/select | 150-250 ms | ease-out |
| Dialog/drawer | Start at 200-300 ms; longer travel needs a reason | ease-out |
| On-screen movement/morph | Match distance and interruption | ease-in-out |
| Color/hover | Short, unobtrusive | ease |
| Continuous progress | Match actual progress | linear |

UI should usually settle within 300 ms. Marketing explanations and deliberate holds
have different purposes; do not apply an interaction budget to an entire film.

When a project has no motion tokens, these upstream curves are candidates:

```css
--ease-out: cubic-bezier(0.23, 1, 0.32, 1);
--ease-in-out: cubic-bezier(0.77, 0, 0.175, 1);
--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);
```

Prefer a quick initial response over slow ease-in entrances. Match the established
personality; a custom curve is not inherently better than a well-chosen built-in.

## Component recipes

| Surface | Ingredients | Preserve |
|---|---|---|
| Button | Optional press scale near `0.97`, 100-160 ms | Focus ring, keyboard activation, existing Button variants |
| Anchored popover | `opacity: 0`, scale near `0.95` to settled, trigger origin | Primitive placement/origin variable, focus return, dismissal |
| Tooltip | Initial delay; adjacent tooltips can switch instantly | Provider timing, touch behavior, accessible description |
| Dialog | Subtle opacity/scale; centered origin | Focus trap, inert background, Escape, exit lifecycle |
| Drawer/toast | Translate by own size, enter/exit through same edge | Library gestures, scroll arbitration, safe area, announcements |
| Accordion | Height animation only if layout expansion is necessary | Flow geometry, focus, content visibility, measured frame cost |
| Tab indicator | Translate/resize decoration, not readable content | One accessible tablist; decorative duplicate has no focusable children |
| Stagger | Optional 30-80 ms between occasional group entrances | Immediate interaction; skip under reduced motion or frequent use |
| Hold to confirm | Upstream starting point: 2 s linear hold, 200 ms cancel | Clear destructive intent, release/cancel, keyboard alternative |

Scaling changes children and does not reserve layout space. It cannot replace every
height/width change; keep actual flow correct and measure the smallest necessary layout animation.
Never replace a dialog, drawer, or toast primitive with a visual-only recipe.

For gesture work, preserve velocity across retargeting, arbitrate scroll versus drag,
capture/release pointers, handle `pointercancel` and multiple pointers, and clean up listeners.
Use the installed library's spring model; do not mix physical and duration-based parameters.
Upstream's duration-based starting point is `duration: 0.5, bounce: 0.2` where supported.
Avoid bounce on dense data surfaces; test on the target device.

## Rendering cautions

CSS and WAAPI can run eligible animation on the compositor; neither guarantees it.
Motion can use WAAPI or a main-thread path. A full transform string can help when
individual transforms use unaccelerated CSS variables; confirm the installed implementation.
Prefer percentages for content-relative travel when needed for correctness.

`filter`, `clip-path`, shadows, large layers, and blur need cross-browser profiling.
`drop-shadow()` is not visually identical to `box-shadow`; compare output before swapping.
Use `will-change` only for a measured benefit, on the smallest surface, for a bounded lifetime.

## Feel-check

Use the real interaction at normal speed first, then slow motion/frame stepping to inspect
origin and interruption. Exercise busy navigation, variable content size, long text,
rapid reopen, canceled gestures, unmounts, and reduced motion. Keep feedback/meaning
available when all decorative animation is removed; do not wait for `animationend`
as the only route to completing a user action.
