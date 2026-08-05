---
name: excalidraw-diagram
description: Generate, refine, and export editable Excalidraw diagrams from prompts or Mermaid. Use for hand-drawn architecture, component anatomy, flows, and annotated technical illustrations.
---

# Excalidraw Diagram

Generate real Excalidraw elements, not a bitmap imitation. Keep one editable source of
truth and derive presentation assets from it.

Read [REFERENCE.md](REFERENCE.md) before Mermaid conversion, direct element creation, or
matching the Shadcn-style visual language.

## Canvas

Run every canvas command through the pinned CLI:

```bash
export EXPRESS_SERVER_URL="http://127.0.0.1:${CONDUCTOR_PORT:-3000}"
bunx mcp-excalidraw-server@1.1.0 <command>
```

Let `bunx` use its shared cache; do not add the CLI to the consuming repository. The
environment selects Conductor's allocated port when present and otherwise uses port 3000.
Run `start`, open `$EXPRESS_SERVER_URL` in an isolated browser, keep the tab open, then
confirm `status` reports a browser client. If isolated browser automation is unavailable,
ask the user to open the reported URL once.

## Workflow

1. Choose a destination. Use `.context/excalidraw/<slug>/` for disposable work; use the
   requested project path for durable assets. Avoid overwriting existing files.
2. Preserve any existing canvas with `snapshot save <name>` or `export --out <file>`
   before clearing it or importing with `--replace`.
3. Choose one canonical source. For a Mermaid deliverable, keep `.mmd` authoritative and
   validate it in the target renderer. For an Excalidraw deliverable, Mermaid is import
   scaffolding; after direct edits, `.excalidraw` is authoritative.
4. Route standard flow, sequence, state, or relationship structure through Mermaid; use direct elements
   for exact placement, component anatomy, logos, zones, or free-form callouts.
5. Create the whole first slice in one `mermaid`, `add`, or `apply` call. Give meaningful
   IDs to anything likely to move or change.
6. After `mermaid`, run `describe` and require converted elements before export or direct
   correction. If a screenshot renders but the described scene stays empty, keep `.mmd`
   canonical or rebuild with direct elements; never report an empty `.excalidraw` as editable.
7. Run `describe`, then `screenshot --out <check.png>` -> view the image -> fix collisions,
   clipping, weak contrast, and crossed arrows with one `apply` patch. Repeat until clean.
8. Export a non-empty `.excalidraw` plus PNG or SVG for a synchronized canvas. Otherwise
   export `.mmd` plus the rendered asset while Mermaid remains authoritative. For project
   assets, keep the editable source beside the render unless the user requests a flat file.
9. Report final paths, diagram mode, canonical source, accessible description location, and
   any manual browser edit still required.

## Commands

```bash
# Mermaid
bunx mcp-excalidraw-server@1.1.0 mermaid diagram.mmd

# Direct scene or atomic correction
bunx mcp-excalidraw-server@1.1.0 add elements.json
bunx mcp-excalidraw-server@1.1.0 apply patch.json

# Inspect and export
bunx mcp-excalidraw-server@1.1.0 describe
bunx mcp-excalidraw-server@1.1.0 screenshot --out check.png
bunx mcp-excalidraw-server@1.1.0 export --out diagram.excalidraw
bunx mcp-excalidraw-server@1.1.0 screenshot --format svg --out diagram.svg
```

## Safety

- Treat `clear --yes`, `import --replace`, and snapshot restoration as destructive canvas
  operations; preserve the current scene first.
- Use `share` only when the user requests a public Excalidraw link because it uploads the
  scene.
- Use SVG or imported brand assets for exact logos; do not approximate protected marks.
- Stop the local server with `stop` after file export when no further edits are expected.
