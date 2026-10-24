---
description: "Generate, refine, and export editable Excalidraw diagrams from prompts or Mermaid. Use for hand-drawn architecture, component anatomy, flows, and annotated technical illustrations."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["excalidraw diagram"]}
sidebar: {"label":"/excalidraw-diagram"}
title: "/excalidraw-diagram"
type: "skill"
---
![Diagram of the /excalidraw-diagram skill](/diagrams/skills/excalidraw-diagram.svg)

[Open the editable Excalidraw source](/diagrams/skills/excalidraw-diagram.excalidraw)


Create editable native elements. Read [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/excalidraw-diagram/REFERENCE.md) for scene format, canvas/SVG, and visual language; [PR-WORKFLOW.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/excalidraw-diagram/PR-WORKFLOW.md) for backend PRs and maintained docs.

## Local default

Author or update a native `.excalidraw` file, then render with the pinned official CLI:

```bash
EXCALIDRAW_NO_UPDATE_NOTIFIER=1 bunx @excalidraw/cli@0.2.0 render diagram.excalidraw --out diagram.png
```

Node 22+, installed Chrome/Chromium/Edge/Firefox; temporary browser profile, no account or API key. PNG only, no layout. Use `bunx` cache, not consumer dependencies; Mermaid, live editing, and SVG use the optional canvas reference.

## Workflow

1. Choose destination: disposable `.context/excalidraw/<slug>/` or requested durable path. Never overwrite silently.
2. Preserve source before replacement; on canvas use `snapshot save <name>` or `export --out <file>` before clear/replace.
3. Choose authority: `.mmd` for Mermaid deliverables; `.excalidraw` after direct editing. Validate Mermaid in its target renderer.
4. Mermaid owns standard flow/sequence/state/relationships; direct elements own exact placement, anatomy, logos, zones, and callouts.
5. Give mutable elements stable IDs. Author native elements locally; canvas shorthand uses one `mermaid`, `add`, or `apply` for the first slice.
6. After Mermaid, `describe` elements before export/correction. If screenshot renders but scene is empty, keep `.mmd` authoritative or rebuild direct; never claim an empty `.excalidraw` is editable.
7. Render PNG, or canvas `describe` then `screenshot` -> view -> fix collisions, clipping, contrast, and crossed arrows. Repeat until clean.
8. Verify non-empty native elements and visible labels; keep `.excalidraw` plus PNG or SVG together. Mermaid-only fallback stays `.mmd` plus render, not an editable Excalidraw claim.
9. Report paths, mode, canonical source, accessible description, and manual browser work.

## Safety

- `clear --yes`, `import --replace`, and restoration are destructive; preserve first.
- `share` uploads the scene; use only for a requested public link.
- Excalidraw+ sync is opt-in; Git stays authoritative. Backend diagram failures are nonblocking; report missing evidence and continue delivery.
- Use SVG/imported brand assets for exact logos; never approximate protected marks.
- Stop only canvas servers you started.
