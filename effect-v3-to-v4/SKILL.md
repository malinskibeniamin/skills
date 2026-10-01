---
name: effect-v3-to-v4
description: Use when migrating a codebase from Effect v3 to Effect v4, upgrading `effect` or any `@effect/*` package across the v3/v4 boundary.
disable-model-invocation: true
---

# Effect v3 to v4 migration

Resolve renames, removals, and signature changes from upstream migration data,
not guessed replacements.

## Workflow

1. Set up and validate the local checkouts below.
2. Read `.repos/effect/MIGRATION.md` once and list `.repos/effect/migration/`.
3. Read [REFERENCE.md](REFERENCE.md), then migrate `package.json` before the first
   type-check: remove consolidated packages and align the remaining versions.
4. Run the project's type-check for an initial error inventory.
5. Resolve each error using the reading order below, fix its call sites, and
   repeat until clean. Work inline unless the user explicitly requests delegation.
6. Run the project's tests and quality gates; report results and unresolved gaps.
   Respect the requested endpoint and the repository's completion contract.

## Local checkouts

Use two independent shallow clones of the canonical Effect repository:

```sh
git clone --depth 1 --single-branch --branch main https://github.com/Effect-TS/effect .repos/effect
git clone --depth 1 --single-branch --branch v3 https://github.com/Effect-TS/effect .repos/effect-v3
```

- `.repos/effect`: v4 migration guides and source.
- `.repos/effect-v3`: v3 source, only for clarifying old semantics.

Before reusing either directory, verify its origin, branch, version, and worktree
status. The v4 checkout must include `MIGRATION.md` and `migration/v3-to-v4.md`:

```sh
git -C .repos/effect remote get-url origin
git -C .repos/effect branch --show-current
git -C .repos/effect status --short
node -p "require('./.repos/effect/packages/effect/package.json').version"
```

Repeat those checks for `.repos/effect-v3` (branch `v3`, version `3.x`). For v4,
require canonical `Effect-TS/effect` origin, branch `main`, and version `4.x`.
An old `Effect-TS/effect-smol` checkout is not a valid migration source. Preserve
existing directories and user changes; report a mismatch and choose a separate,
unused clone destination, updating the lookup paths. Do not delete or reset them.

## Reading order

1. `.repos/effect/MIGRATION.md`: migration background and topic index, once.
2. `.repos/effect/migration/v3-to-v4.md`: first stop for every API. Search matching
   symbols or module headings and read only bounded surrounding context.
   **Never read this generated reference whole.**
3. `.repos/effect/migration/*.md`: load a topic guide when a mapping needs a
   structural rewrite, not just a rename.
4. `.repos/effect/packages/*/src/`, including `unstable/`: confirm the replacement's
   real signature before using it.
5. `.repos/effect-v3`: escalation only for unclear old semantics.

[REFERENCE.md](REFERENCE.md) contains lookup recipes and package-level changes.
Check Removed Modules and No Counterpart Imports before treating a mapping as
missing. Report unmapped gaps rather than inventing APIs.

## Guardrails

- Migrate call sites to v4; do not reintroduce a v3-shaped compatibility layer.
- Resolve type errors through the reference and source, not `any`, casts, or
  type-check suppressions.
- Every replacement must trace to a mapping, topic guide, or v4 source.
- With explicit delegation, give each agent disjoint files, symbols to resolve,
  the reading order, and these guardrails. Require edits and mappings back; retain
  the error inventory centrally. No nested delegation without separate consent.

## Done condition

The project type-checks against v4 and the repository's required gates pass.
Report type-check and test outcomes (or why a check could not run), constructed
replacements, and unmapped gaps. Do not weaken tests to pass or claim completion
while required verification is blocked.
