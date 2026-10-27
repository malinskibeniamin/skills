# Release-aware upgrades

Use for Bazel upgrades, bundled-JDK trust failures or Bazel 10 migration tests.
Checked 2026-10-28 against these exact upstream releases; this is not a moving
latest-version policy. Preserve the repository pin until its upgrade is in scope.

## Choose the release line before changing flags

| Release | Upstream status | Decision |
|---|---|---|
| [9.3.1](https://github.com/bazelbuild/bazel/releases/tag/9.3.1) | Patch LTS; compatible with 9.x starting at 9.0.1 | Evaluate the same-line patch for a 9.x repository; check the 9.0.1 compatibility caveat for 9.0.0 |
| [8.8.2](https://github.com/bazelbuild/bazel/releases/tag/8.8.2) | Patch LTS; compatible with 8.0 | Evaluate the same-line patch for an 8.x repository |
| [7.7.2](https://github.com/bazelbuild/bazel/releases/tag/7.7.2) | Patch LTS; compatible with 7.0 | Evaluate the same-line patch for a 7.x repository |
| [10.0.0rc2](https://github.com/bazelbuild/bazel/releases/tag/10.0.0rc2) | Prerelease candidate for a major LTS release | Test separately; do not turn an RC into the stable default |

All four remove distrusted eMudhra and Sectigo AAA root certificates from the
bundled JDK after reported private-key leakage. Prefer an applicable same-line
patch over a major migration just to obtain this trust-store update. Inspect
`bazel info java-runtime` and startup overrides: a custom server JVM or `nojdk`
distribution needs its own trust-store assessment. The Bazel patch does not update
every action's Java toolchain or the host trust store. Exercise authenticated
repository downloads and cache/executor TLS after updating; repair certificate
chains at their owner instead of disabling verification or restoring distrusted roots.

For 9.3.1, also replay affected top-level alias chains with the repository's
pre-execution cache-discard policy, failed lock acquisition and remote-output
downloads. Its fixes cover lost alias packages, a leaked lock-file channel and
outputs lost before download. A lock-channel fix is not permission to delete locks.
Compare defaults on the exact pins: `help build --long` reports
`--rewind_lost_inputs=true` in both 9.3.1 and 10.0.0rc2. Major-line notes can include
changes already backported to a later patch of the previous line.

## Test Bazel 10 changes in an opt-in configuration

Use the repository wrapper with an explicit candidate version in an isolated
evaluation. Record effective rc options and rules/toolchain pins. The
[RC notes](https://github.com/bazelbuild/bazel/releases/tag/10.0.0rc2)
describe changes relative to the previous major line, not just changes since rc1.
Use that version's help/source before copying options into a 7/8/9 configuration.

- **Migration flags:** the RC lists `--incompatible_no_implicit_file_export`,
  `--incompatible_exclude_starlark_flags_from_exec_config` and
  `--incompatible_check_testonly_for_output_files` as flipped. Export intended
  cross-package source files explicitly with appropriate visibility, preserve
  settings genuinely needed by execution dependencies and repair test-only edges.
  Use [Bazelisk migration controls](https://github.com/bazelbuild/bazelisk#useful-environment-variables-for---migrate-and---bisect)
  to select supported flips for a 9.x rehearsal; that rehearsal does not cover
  every removed API or changed default. Flags listed for a future major release,
  such as symbolic-macro strict attributes, are not already flipped in 10.
- **Bzlmod:** `bazel mod tidy` now evaluates dependency-only extensions too.
  Review the full resulting lockfile and vendored closure; test offline use when
  relevant. `bazel vendor --lockfile_deps` includes repositories needed for lock
  updates. Remove rejected `bazel_dep` self-dependencies and root `use_repo`
  self-imports of repositories overridden with the root module. Module
  `compatibility_level` and `max_compatibility_level` are no-ops in 10; keep
  explicit compatibility checks instead of treating those fields as enforcement.
- **Platforms:** replace removed `remote_execution_properties` with
  `exec_properties`; migrate removed `@bazel_tools//src/conditions:host_windows`
  and `:remote` conditions to the appropriate toolchain/platform contract.
  `--use_target_platform_for_tests` is a no-op: register an execution platform
  satisfying the target constraints. Cross-compiling a test can pass analysis
  without a compatible executor; require an actual test run for execution proof.
- **Local tools:** strict action `PATH` no longer includes `/usr/local/bin`, and
  default-shell actions receive `LC_CTYPE=C.UTF-8`. Declare tools and locale
  requirements in the owning rule/toolchain; verify older macOS hosts rather than
  adding a blanket host-PATH or sandbox exception. The bundled JDK is now 27;
  distinguish the Bazel server runtime from application Java toolchains.
- **Remote outputs and coverage:** `--rewind_lost_inputs` now defaults on for
  recovery from evicted remote/disk outputs. Keep direct-consumer materialization
  explicit and test eviction/recovery; this does not guarantee backend retention.
  Remote coverage defaults also flip (`--experimental_split_coverage_postprocessing`
  and `--experimental_fetch_all_coverage_outputs`); verify collected reports in
  the real executor configuration. Keep [chunking integrity/backend checks](monorepo-scale.md#large-artifacts-and-content-defined-chunking)
  separate from rewinding and lazy downloads.
- **Diagnostics and selection:** `--target_query` / `--target_query_file` feed
  unconfigured query results to build/test; they do not replace configured impact
  analysis or a Git-aware selector. `--expand_param_files` exposes response-file
  contents in failure/subcommand logs; scrub sensitive arguments before sharing.
  `aquery` gains `config(expr, word)` for configuration-scoped action inspection.

Before adopting either a patch or the RC, run the repository's generator/lock
checks, affected tests, supported platform matrix and packaged-runtime probes.
For a major upgrade, compare configured actions and developer workflows using
[migration parity](migrations.md). Report exact versions, executed versus cached
tests and skipped legs; these release notes are not workload validation or a
security certification.
