---
name: install-anti-slop
description: Install curated anti-slop checks in TypeScript or JavaScript repositories using Oxlint or Biome, including Ultracite with the Biome backend. Use when asked to add anti-slop, prevent type-evidence laundering, or update an existing local anti-slop profile.
---

# Install anti-slop

Add the profile through the repository's existing linter. Preserve its package manager,
lint owner, configuration style, and unrelated work. Never introduce a second linter only
for anti-slop.

## Select the profile

1. Read the repository instructions and `git status`. Inspect direct dependencies, the
   lockfile, and existing Biome, Ultracite, Oxlint, or Vite+ configuration.
2. Choose exactly one existing backend:
   - **Oxlint:** install the curated three-rule semantic profile.
   - **Biome or Ultracite with Biome:** install the two-rule structural profile. Biome's
     [GritQL plugins](https://biomejs.dev/linter/plugins/) do not expose symbol or scope
     analysis, so this profile intentionally omits `no-widen-then-assert`; its unknown-alias
     check covers direct `unknown` and direct union members, not alias chains.
3. If neither supported linter exists, leave the repository unchanged and explain why.

## Oxlint

1. Resolve the installed `oxlint` version from the package manager or lockfile. Install
   `@oxlint/plugins` at that exact version as a development dependency.
2. Copy the bundled plugin from the target repository:

   ```bash
   node <skill-directory>/scripts/install.mjs
   ```

   The default destination is `tools/oxlint/anti-slop/`.
3. Merge the plugin into the existing configuration without replacing other entries:

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

## Biome

1. Require Biome 2.5.9 or newer. An Ultracite configuration extending
   `ultracite/biome/*` qualifies.
2. Copy the GritQL plugins:

   ```bash
   node <skill-directory>/scripts/install.mjs --biome
   ```

   The default destination is `tools/biome/anti-slop/`.
3. Merge both paths into the existing `plugins` array:

   ```json
   {
     "plugins": [
       {
         "path": "./tools/biome/anti-slop/no-chained-type-assertions.grit",
         "includes": ["**/*.ts", "**/*.tsx", "**/*.mts", "**/*.cts"]
       },
       {
         "path": "./tools/biome/anti-slop/no-direct-unknown-type-aliases.grit",
         "includes": ["**/*.ts", "**/*.tsx", "**/*.mts", "**/*.cts"]
       }
     ]
   }
   ```

## Finish

The installer rejects path escapes and existing destinations. Pass a different
repository-relative destination when needed. Use `--force` only after backing up and
reviewing an existing anti-slop installation.

Run the repository's lint and typecheck commands. Treat an install request as migration
scope and fix resulting findings in owned code unless the user explicitly requested
config-only work. Never weaken checks or add suppressions merely to pass. Report the
profile, copied path, dependency and configuration changes, verification, and unresolved
findings.

## Ownership

The Oxlint core is a local fork of
[`dmmulroy/anti-slop` v0.1.2](https://github.com/dmmulroy/anti-slop/tree/e8c4880471b23ab7f216fba7b27d173a6ef07d4c).
Its copied `LICENSE` preserves the upstream MIT terms. The Biome GritQL profile is a
structural adaptation with the narrower contract documented above. Treat installed files
as project-owned and review upstream or Biome changes before porting them.
