---
name: install-anti-slop
description: Install the curated anti-slop Oxlint plugin in TypeScript or JavaScript repositories that already use Oxlint. Use when asked to add anti-slop, prevent type-evidence laundering, or update an existing vendored anti-slop core.
---

# Install anti-slop

Vendor the three-rule anti-slop core into an existing Oxlint repository. Keep the
repository's package manager, lint owner, configuration style, and unrelated work intact.

## Install

1. Read the repository instructions and `git status`. Find its package manager, direct
   `oxlint` dependency, Oxlint or Vite+ configuration, and any existing anti-slop copy.
2. Require an existing direct `oxlint` dependency. If absent, leave the repository
   unchanged and explain that anti-slop alone does not justify adding a second linter.
3. Resolve the installed Oxlint version from the package manager or lockfile. Install
   `@oxlint/plugins` at that exact version as a development dependency.
4. From the target repository, copy the bundled plugin:

   ```bash
   node <skill-directory>/scripts/install.mjs
   ```

   The default destination is `tools/oxlint/anti-slop/`. Pass another repository-relative
   destination when local tooling uses a different layout. The installer refuses path
   escapes and existing destinations. Use `--force` only after backing up and reviewing an
   existing local fork.
5. Merge the plugin into the existing configuration without replacing other entries:

   ```ts
   {
     ignorePatterns: ["tools/oxlint/anti-slop/**"],
     jsPlugins: [
       { name: "anti-slop", specifier: "./tools/oxlint/anti-slop/index.ts" },
     ],
     rules: {
       "anti-slop/no-chained-type-assertions": "error",
       "anti-slop/no-unknown-type-aliases": "error",
       "anti-slop/no-widen-then-assert": "error",
     },
   }
   ```

   For Vite+, merge the same entries under `lint` and add the vendored path to
   `fmt.ignorePatterns`.
6. Run the repository's lint and typecheck commands. Treat an install request as migration
   scope and fix resulting findings in owned code unless the user explicitly requested
   config-only work. Never weaken rules or add suppressions to make checks pass.
7. Review the diff and report the copied path, exact dependency versions, configuration
   changes, verification, and unresolved findings.

## Ownership

The bundled core is a local fork of
[`dmmulroy/anti-slop` v0.1.2](https://github.com/dmmulroy/anti-slop/tree/e8c4880471b23ab7f216fba7b27d173a6ef07d4c).
It intentionally includes only rules that reject type-evidence laundering. The copied
`LICENSE` preserves the upstream MIT terms. Treat installed files as project-owned and
review upstream changes before porting them.
