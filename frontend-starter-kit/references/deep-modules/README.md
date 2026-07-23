# Deep modules

Opt-in setup for TypeScript repos whose packages should expose small root entry points and hide implementation in subfolders. Use `/codebase-design` first to confirm this boundary; do not impose it on an existing layout without approval.

## Enforced shape

```text
src/packages/<name>/
  index.ts          # public entry point
  client.ts         # another public entry point
  index.test.ts     # co-located test through an entry point
  lib/              # private implementation
```

Root production files are entry points. Any subfolder is private. Tests stay **co-located** with the public root file they exercise and import through that entry point; test files are never importable production surface. Several focused entry points are preferred over one barrel.

## Setup

1. Confirm Bun from `bun.lock` or `bun.lockb`; otherwise run the `toolchain` profile first.
2. Choose `src/packages` when `src/` exists, otherwise `packages`. If the repo already has another package root, confirm it rather than moving files.
3. If dependency-cruiser config exists, merge the rules instead of overwriting it.
4. Run `bun add -d dependency-cruiser`.
5. Copy [dependency-cruiser.config.cjs](dependency-cruiser.config.cjs) to `.dependency-cruiser.cjs` and set `PACKAGES_ROOT`.
6. Add `"lint:boundaries": "depcruise <packages-root>"` and include it in the same umbrella check as type checking.
7. Select the smallest existing package with a root test importing its public entry point. If no package exists yet, stop rather than committing a speculative example scaffold.

## Prove the boundary

Run a **PASS -> FAIL -> PASS** check:

1. `bun run lint:boundaries` passes on the selected public import.
2. Temporarily change that test to import a private `lib/` file; the command fails with `tests-through-entrypoints`.
3. Restore the public import; the command passes again.

The profile is incomplete until the deliberate violation fails.

Document the layout beside the package root in `README.md`, then add one context pointer from `CLAUDE.md` when present, otherwise `AGENTS.md`. State that consumers import only root entry points, implementation belongs in `lib/`, tests are co-located at the root, and barrels are discouraged.
