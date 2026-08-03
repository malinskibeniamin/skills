---
name: excalidraw-diagram
description: Generate, refine, and export editable Excalidraw diagrams from prompts or Mermaid. Use for hand-drawn architecture, component anatomy, flows, and annotated technical illustrations.
---

# Excalidraw Diagram

Generate real Excalidraw elements, not a bitmap imitation. Keep the editable scene as
the source of truth and derive presentation assets from it.

Read [REFERENCE.md](REFERENCE.md) before direct element creation or when matching the
Shadcn-style visual language.

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
3. Route standard flow, sequence, or relationship structure through Mermaid; use direct elements
   for exact placement, component anatomy, logos, zones, or free-form callouts.
4. Create the whole first slice in one `mermaid`, `add`, or `apply` call. Give meaningful
   IDs to anything likely to move or change.
5. Run `describe`, then `screenshot --out <check.png>` -> view the image -> fix collisions,
   clipping, weak contrast, and crossed arrows with one `apply` patch. Repeat until clean.
6. Export `.excalidraw` source plus PNG or SVG. For project assets, keep the editable
   source beside the rendered output unless the user explicitly requests a flattened file.
7. Report final paths, diagram mode, and any manual browser edit still required.

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
