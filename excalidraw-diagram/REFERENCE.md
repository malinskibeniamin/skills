# Excalidraw scene reference

## Native local scenes

The [official CLI](https://github.com/excalidraw/cli#render-to-png) renders existing
scene JSON locally; it is not a drawing DSL. Write native elements or export them
from the optional canvas. This small editable scene can be saved as `diagram.excalidraw`
and rendered with the command in the skill:

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "https://excalidraw.com",
  "elements": [
    {"id":"api","type":"rectangle","x":40,"y":40,"width":180,"height":80,"backgroundColor":"#dbeafe","fillStyle":"solid","boundElements":[{"id":"api-label","type":"text"},{"id":"request","type":"arrow"}]},
    {"id":"api-label","type":"text","x":60,"y":67.5,"width":140,"height":25,"text":"API","originalText":"API","fontSize":20,"fontFamily":5,"textAlign":"center","verticalAlign":"middle","containerId":"api","lineHeight":1.25},
    {"id":"store","type":"rectangle","x":340,"y":40,"width":180,"height":80,"backgroundColor":"#dcfce7","fillStyle":"solid","boundElements":[{"id":"store-label","type":"text"},{"id":"request","type":"arrow"}]},
    {"id":"store-label","type":"text","x":360,"y":67.5,"width":140,"height":25,"text":"Store","originalText":"Store","fontSize":20,"fontFamily":5,"textAlign":"center","verticalAlign":"middle","containerId":"store","lineHeight":1.25},
    {"id":"request","type":"arrow","x":224,"y":80,"width":112,"height":0,"points":[[0,0],[112,0]],"startBinding":{"elementId":"api","focus":0,"gap":4},"endBinding":{"elementId":"store","focus":0,"gap":4},"endArrowhead":"arrow"}
  ],
  "appState": {"viewBackgroundColor":"#ffffff"},
  "files": {}
}
```

Native labels are separate text elements bound through `containerId` and reciprocal
`boundElements`; native arrows use `startBinding`/`endBinding`. Use numeric native font
IDs (`5` is Excalifont), not canvas font names. Preserve unrelated elements, IDs, and
embedded `files` on edits. Keep before/after renders at the same theme, scale, and framing.
The renderer ignores external images/embeds; embed image bytes in `files` instead.
If browser discovery fails, pass `--browser-path <executable>` or set
`EXCALIDRAW_BROWSER_PATH`; use an isolated browser binary/profile, not a person's session.

## Optional live canvas and SVG

For Mermaid conversion, spatial editing, or SVG export, use the existing third-party
canvas CLI, distinct from the official renderer:

```bash
export EXPRESS_SERVER_URL="http://127.0.0.1:${CONDUCTOR_PORT:-3000}"
bunx mcp-excalidraw-server@2.1.2 <command>
```

SVG renders without a browser or canvas server:

```bash
bunx mcp-excalidraw-server@2.1.2 render diagram.excalidraw --format svg --out diagram.svg
```

For canvas editing, run `start`; preserve existing content before replacement and use a
task-owned port. Only Mermaid conversion or live viewing needs an isolated browser;
require `status` to show a client before Mermaid. If isolation is unavailable, author
native JSON and render locally without blocking delivery. Stop only servers you started.
The [v2.1.2 release](https://github.com/yctimlin/mcp_excalidraw/releases/tag/v2.1.2)
fixes native export labels, atomic imports, and text sizing; do not retain the old v1 export path.

Commands: `mermaid diagram.mmd`; `add elements.json`; `apply patch.json`; `describe`;
`screenshot --out check.png`; `export --out diagram.excalidraw`;
`screenshot --format svg --out diagram.svg`. Inspect the exported scene for native
elements, then use the official CLI for PNG. Keep the same scene authoritative for SVG
and PNG, not independently recreated diagrams. Stop only your server when done.

### Canvas element shorthand

The canvas CLI accepts an agent-friendly schema; this is not native `.excalidraw` JSON:

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

## Mermaid conversion

Use Mermaid for standard graph-shaped structure, then switch to direct elements only when
spatial composition carries meaning. Complexity is not a reason to switch tools: keep one
claim per diagram and split it first. For flow and architecture views, aim for 5-10 nodes;
use subgraphs for meaningful groups, one reading direction, and color only for emphasis.

Choose the diagram by the question:

- Flowchart: what happens next or where a decision branches.
- Sequence: who exchanges messages, and in what order.
- State: which lifecycle transitions are valid.
- Relationship or sparse ER view: which things connect. Split attribute-heavy schemas.

Every durable Mermaid source includes `accTitle` and `accDescr`. A caption or nearby prose
must also explain the point; the diagram supplements the text. Treat Mermaid-to-Excalidraw
conversion as visual scaffolding, not preservation of accessibility metadata.

Keep one canonical source:

- Mermaid deliverable: `.mmd` is the source of truth. Render from it and validate with the
  repository build or target renderer at representative wide and narrow widths.
- Excalidraw deliverable: after any direct canvas edit, `.excalidraw` is the source of truth.
  Retain the Mermaid input only as clearly named import provenance, never as synchronized
  editable source.

For a durable PNG or SVG, place a concise accessible description beside the image in its
host document or handoff. Pair color with labels, shapes, or line styles so color is never
the only carrier of meaning.

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
6. Meaning remains clear without relying on color alone.

Fix every visible issue, render again, and inspect the corrected image before export.
