# Effect migration reference

## Never Read the Reference Doc Whole

**This is the single most important rule in this skill.** `migration/v3-to-v4.md` is large enough to exhaust context. Reading it in one pass blows the context window and takes the migration with it.

Always search it and read only matched lines plus surrounding context. The file has four sections -- **Import Map**, **No Counterpart Imports**, **Removed Modules**, and **API Reference** (one `` ### `<v3 module path>` `` heading per module). Entries are grep-able one-liners of the form `` - `Old.symbol` -> `New.symbol`: <rationale> ``, and removals are explicit `` -> `none` `` entries with a stated alternative.

Concrete recipes:

```sh
# Look up a specific v3 symbol
rg -n 'AnthropicTokenizer\.layer' .repos/effect/migration/v3-to-v4.md

# Read a whole module's section via its heading
rg -n -A 40 '^### `@effect/platform/FileSystem`' .repos/effect/migration/v3-to-v4.md

# Resolve a v3 import path in the Import Map
rg -n '^@effect/platform/FileSystem ' .repos/effect/migration/v3-to-v4.md

# List every module section for a package
rg -n '^### `@effect/cluster/' .repos/effect/migration/v3-to-v4.md
```

Look up APIs as you encounter them, one search at a time. A miss in the Import Map is not a dead end -- check the **Removed Modules** and **No Counterpart Imports** sections before concluding anything.

## Repo-Level Changes

Faithful per-API lookup alone still yields a broken `package.json`. Handle these once, up front:

- **Package consolidation.** `@effect/platform`, `@effect/rpc`, `@effect/cluster`, and others merged into the core `effect` package -- remove them from `package.json` and rewrite their imports per the Import Map. Packages that remain separate (`@effect/platform-*`, `@effect/sql-*`, `@effect/ai-*`, `@effect/opentelemetry`, `@effect/atom-*`, `@effect/vitest`, and others) stay as dependencies. Consolidated v3 packages, including `@effect/sql` and `@effect/cli`, still have npm `latest` tags pointing to `0.x`; remove them instead of bumping every package to `latest`.
- **Version alignment.** Target the current stable `latest` 4.x release. All Effect ecosystem packages share one version number in v4. Every remaining `effect` / `@effect/*` dependency must use that same matching version.
- **Module paths and stability.** GA imports use paths such as `effect/http`, `effect/rpc`, and `effect/ai/LanguageModel`. Stability comes from JSDoc tags, not an import-path segment: `@stability unstable` APIs may break in minor releases; `@stability experimental` APIs may break in patch releases.
  For code written against a beta or RC, remove the old `unstable` segment (for example `effect/unstable/http` -> `effect/http`). There are no compatibility exports for the old paths; moving a module does not stabilize its API.
