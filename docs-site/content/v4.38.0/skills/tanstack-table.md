---
title: "/tanstack-table"
description: "Apply repository-specific TanStack Table enforcement after loading installed-package guidance through TanStack Intent. Use when building, reviewing, or migrating tables and data grids."
type: skill
sidebar:
  label: "/tanstack-table"
---
![Diagram of the /tanstack-table skill](/diagrams/skills/tanstack-table.svg)

[Open the editable Excalidraw source](/diagrams/skills/tanstack-table.excalidraw)

Follow `/tanstack-intent` first. Discover the installed Table adapter and core packages,
then load every task-matching `use` id. Intent owns current API syntax, version status,
migration guidance, state semantics, and framework-specific patterns.

## Local enforcement

The `tanstack-table-check` hook is a version-gated regression floor, not API
documentation. It resolves the nearest declared or installed package version and applies
its V9 checks only to V9 projects. The installed Intent guidance remains authoritative.

If the hook conflicts with loaded package guidance, stop and fix the harness and its evals.
Do not bypass the official API or preserve stale local prose merely to satisfy the hook.

Completion evidence includes the installed package version, loaded Intent `use` ids,
focused Table tests, typecheck, and lint.
