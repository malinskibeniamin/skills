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
Use asymmetric enter/exit timing when justified: deliberate holds can take longer;
release and cancellation stay snappy without delaying input.

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

For direct manipulation, load [gestures](../gestures/SKILL.md) for track/release physics,
scroll arbitration, cancellation and re-grab continuity. Keep those rules with that owner.

## Choreography

When several elements respond to one event, first reduce the moving parts. Assign the
lead, support, decoration and static roles; not every role needs an animation. A moving
panel usually carries already-visible content instead of adding a second child entrance.

| Relationship | Choose when | Watch for |
|---|---|---|
| Together | One visual object or state change | Container, content and overlay should not drift into separate timing families |
| Overlap | Order explains reading hierarchy or cause while both can coexist | Cap the total timeline, not just the delay per item |
| Sequence | Concurrent rich views obscure meaning or visibly collide | The wait must explain the change, not gate an unrelated action |
| Carry | A parent can supply the shared spatial move | Nested transforms, clipping and layout ownership |

- Default frequent menus, command palettes, keyboard-triggered UI and returning data
  to together/instant. For an occasional stagger, 30–80 ms gaps are candidates; bound
  the **last delay plus duration**, so a long list cannot produce a waiting queue.
  Vary hierarchy where useful; uniform timing is not inherently a defect.
- Keep secondary accents tied to the cause, impact or settle of the lead, not arbitrary
  timers. Repeated activation should not replay an unnecessary buildup. Exit related
  items together rather than reverse-staggering the user's departure.
- For a removing item whose siblings should close the gap immediately, consider
  Motion's `popLayout`. Its exiting node leaves flow; preserve the containing block,
  measurements and ref requirements for custom children. Avoid absolute positioning
  as a blanket fix for intentional flow or focus behavior.
- A view swap can crossfade concurrently; Motion's default `sync` already runs enter
  and exit together. `popLayout` additionally changes flow. Use `wait` only for a
  meaningful sequential swap (it supports one child), not as a default for all morphs.
  Read the installed API and [AnimatePresence docs](https://motion.dev/docs/react-animate-presence).
- Keep stable keys and direction data available to exiting children. Navigation direction
  follows the product's spatial model and RTL, not a hardcoded forward-equals-left rule.
  Size-dependent timing can be clamped; a few finite transitions can use explicit tokens.
  Measure previous bounds outside render; do not mutate refs in `useMemo` to track history.
- Prefer declarative CSS/variants for simple relationships; use imperative sequences only
  for genuine cross-event dependencies. Stop old controls **before** starting new work.
  Give each run an identity/cancellation signal; after every await, check it is still
  current before chaining, committing state or starting an idle loop. Stopping animation
  alone does not invalidate its async continuation. Clean up timers/controls on unmount.
- Keep one semantic interactive view. Any decorative crossfade duplicate is inert,
  hidden from assistive technology and stripped of duplicate IDs/active controls.
  Never gate a valid click on a decorative hover buildup finishing.
- Reduced motion collapses spatial movement and delays; appear together or change
  instantly. Meaningful explanatory steps can remain discrete without animated travel.

For a complex sequence, a small inline timeline (element, role, start, duration,
relationship) can expose waits before implementation. Skip empty roles and output quotas.
Replay rapid Next/Back, close/reopen, content resize and unmount mid-sequence; inspect
normal speed first, then scrub only the moments needed to resolve perceived continuity.

## Rendering cautions

CSS and WAAPI can run eligible animation on the compositor; neither guarantees it.
Motion can use WAAPI or a main-thread path. From Motion 14.2, independent HTML
`x`/`y`/`scale`/`rotate` animations can combine into an eligible accelerated transform;
keep those shorthands when supported. A full transform string can help older paths.
Layout/layoutId, `onUpdate`, `transformTemplate`, inertia and frame-driven values
still need main-thread work. Confirm the installed version and actual animation path
with [Motion's performance guide](https://motion.dev/docs/performance); neither syntax
nor a version number proves compositor execution.
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
