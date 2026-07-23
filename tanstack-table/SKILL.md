---
name: tanstack-table
description: TanStack Table V9 React patterns for reactive reads, granular subscriptions, state ownership, feature registration, and migration safety. Use when building, reviewing, or migrating tables and data grids with @tanstack/react-table.
---

# TanStack Table V9

Run `/read-the-damn-docs` before changing APIs: V9 is still published under the beta tag. Inspect the nearest `package.json`; do not apply V9 guidance to V8. Start with the official [V9 reactivity article](https://tanstack.com/blog/tanstack-table-v9-reactivity), [migration guide](https://tanstack.com/table/beta/docs/framework/react/guide/migrating), and [table-state guide](https://tanstack.com/table/beta/docs/framework/react/guide/table-state).

## Reactivity contract

- `table.state` is the selected reactive view returned by `useTable`.
- `table.store.state` and `table.atoms.<slice>.get()` are snapshot reads, not React subscriptions.
- Use `table.Subscribe`, standalone `Subscribe`, or `useSelector` when rendered UI must follow a store or atom.
- Row, cell, column, and header objects are stable. Their method calls hide state dependencies from React Compiler. Extracted child components and context consumers need a subscription boundary at that component or an ancestor.
- Inline table markup using the default `useTable` selector usually needs no extra boundary. Optimize only after a measured or structural render problem.
- A selector that opts the parent out with `() => null` makes every dynamic subtree responsible for its own narrow subscription.

Prefer a per-slice atom and selector for one row or column. Select only the value rendered, such as `selection[row.id]`; select multiple store slices only when one rendered block truly needs all of them.

## State ownership

Each slice has one owner: Table internal state, controlled `state` plus `on*Change`, or an external writable atom. External atoms win over controlled state for the same slice. `table.reset()` does not reset external atoms; reset the owned atom or use the feature reset API that updates it. Prefer feature methods over direct `baseAtoms` writes.

## Clean V9 surface

- Use `useTable` with explicit features; `useLegacyTable` is deprecated migration debt.
- Call row/cell/column/header methods on their instance; V9 prototype methods cannot be destructured safely.
- Register individual filter, sort, and aggregation functions instead of full registries.
- In V9, "some rows selected" means at least one. An indeterminate select-all control must also check that not all matching rows are selected.

The `tanstack-table-check` hook blocks mechanically provable V9 mistakes and warns where subscription ownership needs human confirmation.
