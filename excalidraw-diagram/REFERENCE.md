# Excalidraw scene reference

## Element shorthand

The CLI accepts an agent-friendly element schema:

```json
[
  {
    "id": "api",
    "type": "rectangle",
    "x": 320,
    "y": 180,
    "width": 220,
    "height": 80,
    "text": "API",
    "fontFamily": "excalifont",
    "fontSize": 22,
    "strokeColor": "#4dabf7",
    "backgroundColor": "#1c4f73",
    "fillStyle": "solid",
    "roughness": 1,
    "roundness": { "type": 3 }
  },
  {
    "id": "request",
    "type": "arrow",
    "x": 0,
    "y": 0,
    "startElementId": "client",
    "endElementId": "api",
    "strokeColor": "#e9ecef",
    "roughness": 1,
    "endArrowhead": "arrow"
  }
]
```

- Label a shape with `text`; use a standalone text element for titles and callouts.
- Bind arrows with `startElementId` and `endElementId`.
- Use three or more `points` plus `roundness: {"type": 2}` for curved arrows.
- Create background zones first, primary shapes second, arrows third, annotations last.
- Keep stable, semantic IDs so `apply` can correct the scene atomically.

An `apply` patch has this shape:

```json
{
  "create": [],
  "update": [{ "id": "api", "set": { "width": 260 } }],
  "delete": []
}
```

## Shadcn-style preset

Use this preset for the dark hand-sketched diagrams shown in Shadcn documentation:

| Role | Value |
| --- | --- |
| Canvas | `#121212` solid background rectangle, `roughness: 0`, created first |
| Foreground | `#e9ecef` |
| Secondary text | `#adb5bd` |
| Blue | stroke `#4dabf7`, fill `#1c4f73` |
| Green | stroke `#40c057`, fill `#0b4f1c` |
| Amber | stroke `#f08c00`, fill `#402f00` |
| Red | stroke `#ff8787`, fill `#6b3232` |
| Drawing | `fontFamily: "excalifont"`, `roughness: 1`, `strokeWidth: 2` |

Use one tall or wide central structure, then place short callouts around it with curved
arrows. Preserve generous negative space. Prefer translucent or muted fills over bright
blocks. Use solid fills; reserve dashed strokes for nested groups and boundaries.

For paired themes, save a snapshot before recoloring. Export dark, apply a palette swap,
export light, then restore the preferred editable scene. A light preset uses canvas
`#ffffff`, foreground `#1e1e1e`, and pastel fills.

## Layout bounds

- Body text: at least 16 px; labels: 18-22 px; titles: 24-32 px.
- Labeled shapes: at least 120x60 px; estimate width as `max(160, characters x 12)`.
- Gaps: 40-80 px; give labeled arrows at least 120 px.
- Background zones: at least 50 px padding around children.
- Route arrows around unrelated shapes. Use elbowed or curved paths when a straight line
  would cross content.

## Visual gate

Inspect the rendered screenshot, not only scene JSON. Require:

1. Complete, readable labels with no truncation.
2. No unintended element or arrow-label overlap.
3. No arrow crossing an unrelated element.
4. Strong text/background contrast in the exported theme.
5. Balanced framing with all content visible and useful negative space.

Fix every visible issue, render again, and inspect the corrected image before export.
