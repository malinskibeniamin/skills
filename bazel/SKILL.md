---
name: bazel
description: Build, test, and diagnose Bazel monorepos across Go, C++, TypeScript and React. Use for BUILD/Starlark, Bzlmod, toolchains, caching, dev loops, affected CI and release artifacts.
---

Make the declared build graph reproduce the requested behavior. Repository-owned
wrappers, macros, pins and CI policy outrank this general guidance.

## Establish the build contract

- Resolve the Bazel workspace root, `.bazelversion`, root `MODULE.bazel`, applicable `.bazelrc` imports,
  component instructions and the actual CI entrypoint. Use the pinned Bazel through the repository's
  Bazelisk/wrapper, not a globally upgraded binary. Keep per-machine overrides in the existing ignored user rc
  file. Verify newer flags, Starlark annotation syntax and rules against those pins; conference demos and
  roadmap items are not released API contracts.
- For version upgrades, bundled-JDK trust failures or Bazel 10 compatibility,
  read [release guidance](references/releases.md). Keep same-line patch updates
  separate from opt-in release-candidate testing.
- Distinguish **what has BUILD files** from **what Bazel owns today**. Generated
  targets do not prove CI adoption. Check merged source, not an intermediate
  commit, draft rollout or predecessor repository.
- Preserve a monorepo's one-root-module boundary. Consolidate dependency/toolchain declarations at that root;
  a new nested `MODULE.bazel` can hide a subtree from wildcard discovery. Treat an intentionally separate
  workspace as a separate build, not something to merge opportunistically.
- For a Go/Task/Gazelle tree, read [Go monorepos](references/go-monorepo.md).
  For C++, cross-compilation, accelerators or graph-selected integration, read
  [C++ monorepos](references/cpp-monorepo.md). For frontend/Node integration, read
  [TypeScript and React](references/typescript-react.md). Load only relevant profiles.
- For topology, local orchestration, affected CI, caching/execution or releases,
  read [monorepo scale](references/monorepo-scale.md). For scaffold research, read
  the pinned [community examples and limitations](references/community-examples.md).

## Choose the incremental loop

Keep action reuse, Git-aware target selection, browser HMR and deployment separate. Bazel owns declared
build/test/artifact dependencies; the frontend tool owns Fast Refresh, and orchestration owns service
lifecycle and rollout. Start only the local app's needed closure, not every app. Preserve existing
frameworks/package managers; prove one vertical slice before standardizing it. Measure cold/warm/no-op and
representative edits before promising speed; adding Bazel does not prove a gain.

## Find the owner before editing

Read the nearest BUILD file and any loaded macro. Discover existing labels rather
than guessing a binary, image or test target. Keep dependency, generated-source
and runtime-file edges explicit; `deps` and test `data` solve different problems.

Choose the graph for the question ([query semantics](https://bazel.build/query/cquery),
[action graph](https://bazel.build/query/aquery)):

| Question | Tool |
|---|---|
| Which tests/consumers exist or reach a file? | `query`, `tests(...)`, bounded `rdeps(...)` |
| Which `select()` branch/platform/dependency is active? | `cquery` with the failing build's configs |
| Which compiler, flags, inputs or outputs form the action? | `aquery` with those same configs |

`query` includes possible configuration branches; it is not proof a target ran.
`aquery` describes actions; it does not materialize their generated inputs.
Treat partial/error output as incomplete evidence, never an empty impact set.

## Change and verify

1. Reproduce a defect with a failing target or public-contract test. For build-only
   changes, use the failing analysis, compile, formatter or rule test as RED.
2. Edit the owning source, generator input or macro. Regenerate derived BUILD
   files with the repository's generator; use its formatter and inspect the
   resulting diff. Preserve intentional visibility, compatibility, tags and data.
3. For dependency changes, update the authoritative language manifest and/or root
   module as appropriate, then run the declared module-tidy/lock update. Commit
   the resulting metadata together. Honor CI's lockfile mode; repair stale locks
   locally instead of deleting them or relaxing CI. See
   [lockfile modes](https://bazel.build/external/lockfile).
4. Build/test the smallest changed target in the relevant configuration, then its
   affected consumers. Shared macros, root dependency/toolchain/config changes
   need the wider repository-prescribed matrix. Platform-incompatible, manual and
   filtered integration targets are not passes; name the untested legs.

## Diagnose without destroying the evidence

- Replay exact labels/configs and target/execution platforms with `--announce_rc`
  and `--verbose_failures`. Add `--sandbox_debug` only to the failing reproduction;
  inspect merged rc options and action inputs before changing flags.
- Separate analysis/label errors, repository fetch/auth failures, toolchain or
  platform mismatch, sandbox/runfiles failures, cache transport and test failures.
  Fix the responsible layer rather than globally disabling sandboxing, warnings,
  sanitizers or compatibility constraints.
- For macOS symlink escapes, native-tool path resolution, sandbox setup cost or
  local VM execution through REAPI, read [local execution](references/local-execution.md).
- Keep repository-download caches, action caches and remote execution distinct.
  A remote cache is not a remote executor. Follow the checked-in cache/upload
  policy; do not copy private endpoints or credentials into tracked config.
- Preserve warm caches initially. `clean`, `expunge`, deleting lockfiles or adding
  a fresh output base are not first-line fixes. If isolation becomes necessary,
  state the hypothesis and limit the reset to the owned reproduction.
- To rerun tests, use scoped `--nocache_test_results`; cached results otherwise
  remain valid for declared inputs. Report cached versus executed honestly. Output consumers
  may need explicit materialization with [minimal-download caching](https://bazel.build/remote/caching).

Report the changed graph contract, exact targets/configs, results and skipped/blocked
legs. Building an image does not authorize pushing or deploying it. For provenance
and refresh limits, read [research basis](references/research-basis.md).
