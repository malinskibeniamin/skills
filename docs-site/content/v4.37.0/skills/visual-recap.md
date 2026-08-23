---
title: "/visual-recap"
description: "Create an interactive visual recap for a PR, branch, commit, or diff."
type: skill
sidebar:
  label: "/visual-recap"
---
![Diagram of the /visual-recap skill](/diagrams/skills/visual-recap.svg)

[Open the editable Excalidraw source](/diagrams/skills/visual-recap.excalidraw)

Local override: translate upstream `npx @agent-native/core` examples to `bunx @agent-native/core`.

## Required references

Before creating a recap, read `references/agent-native-recap.md`. It owns the full create-visual-recap contract, never-inline rule, Plan MCP URL rules, diff-to-block mapping, redaction, security visibility, local-files privacy mode, and review feedback loop.

Read these only when relevant:

- `references/connection.md` -- connector discovery, reconnect steps, never-inline fallback.
- `references/local-files.md` -- no-hosted-DB/local-only recap mode.
- `references/wireframe.md` -- UI wireframe rules for visible diffs.

## Local harness overlay

- When the user explicitly invokes `/visual-recap`, create or link it to the named PR, branch,
  commit, or diff.
- Recap creation is extra artifact work; `/commit-push-pr` and `/go` do not invoke it
  automatically.
- For a meaningful architecture or data-flow shift, use `/excalidraw-diagram` to create
  `.excalidraw` source plus PNG or SVG. Keep the Agent-Native recap as the primary review
  surface: embed the rendered asset only when the current block catalog supports media;
  otherwise use its `diagram` block and include the source/export paths in the handoff.
  Prefer the built-in Mermaid path for a simple graph or when the canvas is unavailable.
- Keep recaps grounded in the real diff. Redact secrets and do not infer facts absent from changed lines.
- If the explicitly requested target has no meaningful visual structure, return that evidence
  instead of manufacturing a recap.
