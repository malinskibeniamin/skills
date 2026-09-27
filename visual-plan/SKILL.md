---
name: visual-plan
description: Create interactive Agent-Native visual plans with diagrams, file maps, annotated code, and UI review. Use when planning non-trivial product, UI, architecture, data, API, or competing options.
---

Translate upstream `npx @agent-native/core` to `bunx @agent-native/core`.

Before edits, read `references/agent-native-plan.md` for contract, MCP, blocks, surfaces, comments, privacy, and quality.

Load only when relevant: `references/connection.md` for connector/fallback; `references/local-files.md` private/offline; `references/wireframe.md` HTML/CSS; `references/canvas.md` prototype surface; `references/document-quality.md` standalone gates; `references/exemplar.md` structure.

For substantial plans, follow [`../shared/intent-map.md`](../shared/intent-map.md); render its first-read graph in the existing Agent-Native diagram/canvas, not a second artifact.

Disagreement -> `/plan-arbiter`; open decisions -> `/grilling`; one in-chat view -> `/show-me`. Planning is read-only until explicit implementation approval.
