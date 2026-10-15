# Mobile platform branches

Apply only to the reported surface; these are not global reset requirements.

## Keyboard and viewport

`dvh` tracks dynamic browser chrome, not a portable guarantee about software keyboards.
Test the actual browser's keyboard resizing behavior. Chromium's optional
`interactive-widget=resizes-content` can help where supported; Safari and embedded
webviews can differ. Use existing `visualViewport` handling for keyboard overlap when
needed, with listener cleanup. Avoid adding a second viewport controller.

Keep input text at least 16 CSS px where iOS focus zoom occurs. `1rem` qualifies only
if its computed value does. Use appropriate `type`, `inputMode`, `autoCapitalize`,
and `enterKeyHint` for the field; do not change validation semantics to alter a keyboard.

Safe-area padding should add to normal spacing, not replace it:

```css
.bottom-bar {
  padding-bottom: calc(1rem + env(safe-area-inset-bottom, 0px));
}
```

## Gesture arbitration

`touch-action` names what the browser may handle, not what the app handles.
For a custom horizontal drag, `pan-y pinch-zoom` keeps page scrolling and user zoom.
For a custom vertical drag handle, consider `pan-x pinch-zoom` only on the handle.
For an ordinary control, `manipulation` permits scrolling and pinch zoom while disabling
double-tap zoom. Preserve native link behavior; do not apply interaction resets to content.

Prefer a native horizontal scroller plus scroll snapping before custom gesture code.
Custom dragging must handle capture, release, `pointercancel`, scroll arbitration,
multiple pointers, reduced motion, and a non-drag alternative.

## Scroll and installed mode

Use inner-scroller containment to stop unwanted background chaining. Disable root
overscroll only for an app-owned canvas or shell that genuinely needs it; preserve
refresh and scrolling on normal documents. Avoid blanket `touchmove` cancellation.

Match `theme-color` to the resolved header/surface theme, not automatically the brand accent.
OS media tags alone are insufficient when the app has a user-selected theme override.
Inspect installed PWA manifest and status-bar metadata only when standalone mode is a target.
Keep manifest identity and launch behavior unchanged during a visual correction.

## Primary references

- [Touch-action semantics and zoom](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/touch-action)
- [Viewport meta options](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/meta/name/viewport)
- [Visual Viewport API](https://developer.mozilla.org/en-US/docs/Web/API/Visual_Viewport_API)
- [Overscroll containment](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/overscroll-behavior)
