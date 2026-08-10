---
name: tanstack-intent
description: Use TanStack Intent whenever any TanStack package is mentioned, referenced, imported, configured, reviewed, upgraded, or worked on. Load the installed package's version-matched guidance before answering or changing code, including Router, Query, Table, Form, Start, Store, Virtual, DB, and AI.
---

# TanStack Intent

Ask TanStack Intent which installed-package docs apply before answering, planning,
reviewing, or editing. This applies when a TanStack package is mentioned, referenced, or
worked on, even if the task does not name a local TanStack skill.

## Load the package guidance

1. Identify every relevant `@tanstack/*` package from the request, imports, and nearest
   `package.json`. Use the installed dependency, not a remembered major version.
2. From the package root, discover its shipped skills:

   ```bash
   bunx @tanstack/intent@latest list --json
   ```

3. Match each task to the returned `skills[].packageName`, `description`, and `use` fields.
   Load every matching `use` id exactly as returned:

   ```bash
   bunx @tanstack/intent@latest load "$use_id"
   ```

4. Load any `requires` named by that skill before applying it. For compositions, load
   guidance for every owner involved, such as Table plus Query or Router plus Query.

Use the repository's command runner when it is not Bun. Do not guess skill ids or select a
similarly named framework package.

## Authority

- Installed, version-matched Intent guidance owns TanStack API syntax, version status,
  migration steps, and framework-specific behavior.
- Local `/tanstack-router` and `/tanstack-table` guidance adds repository policy and
  deterministic checks only after Intent loads.
- If local guidance or a hook conflicts with the installed Intent skill, treat that as a
  harness defect. Follow the package guidance and repair the harness rather than coding
  around the conflict.
- If the package is not installed or exposes no matching skill, state that Intent could
  not supply version-matched guidance, then use `/read-the-damn-docs` against official
  TanStack sources. Never fill the gap from memory silently.

For project setup, read [SETUP.md](SETUP.md). Completion evidence names the loaded
`package@version` and `use` ids.
