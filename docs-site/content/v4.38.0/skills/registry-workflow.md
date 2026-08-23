---
title: "/registry-workflow"
description: "Maintain component registries through taxonomy and sync discipline. Use when changing a shadcn registry or design system, syncing components, or analyzing consumer drift."
type: skill
sidebar:
  label: "/registry-workflow"
---
![Diagram of the /registry-workflow skill](/diagrams/skills/registry-workflow.svg)

[Open the editable Excalidraw source](/diagrams/skills/registry-workflow.excalidraw)

Read [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/registry-workflow/REFERENCE.md) for taxonomy examples, drift commands, filtering, and
governance.

## Modes

### Classify components

Assign the highest matching level; use it to set test depth.

| Level | Signals | Tests |
|---|---|---|
| Atom | one primitive, 0-1 state, no custom keyboard or portal | 3-4 |
| Molecule | 2-3 atoms, up to 2 state values, small handler, optional portal | 5-8 |
| Organism | 3+ state values, 3+ registry imports, custom keyboard, portal | 8-15 |

Radix-provided keyboard navigation does not count as custom code.

### Analyze consumer drift

1. Match registry components to consumer files.
2. Run `git diff --no-index --ignore-all-space`.
3. Filter import aliases, client directives, comments, and whitespace.
4. Classify every remaining component:
   - `Upstream`: reusable functional change.
   - `Skip-Import-Only`: path or directive noise.
   - `Skip-Outdated`: consumer trails registry; sync downward.
   - `Skip-Business-Logic`: routes, endpoints, analytics, feature flags, or domain values.
5. Report one status per component. Re-implement mixed reusable fixes cleanly upstream.

### Maintain the registry

- Ship registry syncs separately from feature work.
- Keep consumer-specific behavior outside managed files.
- Breaking changes require a codemod, changelog entry, migration example, and consumer
  smoke tests.
- Keep registry components router/framework agnostic.
- Fix recurring consumer misuse in the component API.
- Write changesets as upgrade decisions: affected components, before/after, and rationale.

## Hook setup

Copy `scripts/ui-registry-warn.sh` and `scripts/registry-check.sh` to `.claude/hooks/`,
make them executable, then register:

- PostToolUse `Edit|Write`: `ui-registry-warn.sh`
- Stop: `registry-check.sh`
- Keep the shared split-file convention: route pages use `*.page.tsx`; reusable pieces
  live under `components/`.

## Completion

- Both hooks execute.
- Editing component directories warns.
- Changing `redpanda-ui/` without `registry.json` blocks.
- Updating `registry.json` without a changeset blocks.
