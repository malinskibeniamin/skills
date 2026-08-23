---
name: visual-plan
description: Create interactive Agent-Native visual plans with diagrams, file maps, annotated code, and UI review. Use when planning non-trivial product, UI, architecture, data, API, or competing options.
---

Translate upstream `npx @agent-native/core` to `bunx @agent-native/core`.

Before create/update, read `references/agent-native-plan.md`; it owns Agent-Native contract, Plan MCP, block catalog, surface choice, comment loop, local privacy, quality.

Load only when relevant: `references/connection.md` for connector/fallback; `references/local-files.md` private/offline; `references/wireframe.md` HTML/CSS; `references/canvas.md` prototype surface; `references/document-quality.md` standalone gates; `references/exemplar.md` structure.

For substantial plans, follow [`../shared/intent-map.md`](../shared/intent-map.md); render its first-read graph in the existing Agent-Native diagram/canvas, not a second artifact.

Use `/plan-arbiter` for disagreement and `/grilling` for open decisions. Planning is read-only until explicit implementation approval.
