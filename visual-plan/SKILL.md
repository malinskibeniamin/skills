---
name: visual-plan
description: Create interactive Agent-Native visual plans. Use for non-trivial UI, product, architecture, data, API, or competing-option plans needing diagrams, file maps, or prototypes.
---

# Visual Plan
Local override: translate upstream `npx @agent-native/core` examples to `bunx @agent-native/core`.

## Required references

Before creating or updating a visual plan, read `references/agent-native-plan.md`. It owns the full Agent-Native plan contract, Plan MCP usage, block catalog requirement, visual surface choice, comment loop, local-files privacy mode, and document quality rules.

Read these only when relevant:

- `references/connection.md` -- connector discovery, never-inline fallback, reconnect steps.
- `references/local-files.md` -- local/offline/private plan mode.
- `references/wireframe.md` -- wireframe HTML/CSS rules.
- `references/canvas.md` -- canvas/prototype review surface.
- `references/document-quality.md` -- standalone plan quality gates.
- `references/exemplar.md` -- example plan structure.

## Local harness overlay

- Use `/plan-arbiter` when multiple plans or agents disagree.
- Use `/grilling` before implementation when decisions remain open.
- Planning is read-only unless the user explicitly approves implementation.
