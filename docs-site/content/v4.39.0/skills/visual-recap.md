---
title: "/visual-recap"
description: "Create an interactive visual recap for a PR, branch, commit, or diff."
type: skill
sidebar:
  label: "/visual-recap"
---
![Diagram of the /visual-recap skill](/diagrams/skills/visual-recap.svg)

[Open the editable Excalidraw source](/diagrams/skills/visual-recap.excalidraw)


Translate upstream `npx @agent-native/core` to `bunx @agent-native/core`.

Before recap, read `references/agent-native-recap.md`; it owns create-visual-recap, never-inline, Plan MCP URL, diff blocks, redaction, security, local privacy, feedback.

Load only when needed: `references/connection.md` for connector/reconnect/fallback; `references/local-files.md` for local-only; `references/wireframe.md` for visible UI diffs.

## Overlay

- For meaningful causal structure, follow [`../shared/intent-map.md`](https://github.com/malinskibeniamin/skills/blob/v4.39.0/shared/intent-map.md); ground every node/edge in the diff, label inference, and reuse the recap diagram surface.
- Only explicit `/visual-recap` creates/links the named PR/branch/commit/diff; `/commit-push-pr` and `/go` never invoke automatically.
- For meaningful architecture/data flow, `/excalidraw-diagram` creates `.excalidraw` plus PNG/SVG. Agent-Native remains primary: embed supported media, else diagram block plus source/export paths. Use Mermaid for simple graph/unavailable canvas.
- Ground in real diff, redact secrets, never infer beyond changed lines.
- If target has no visual structure, return that evidence instead of inventing a recap.
