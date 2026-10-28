# Bazel 10: migration and new capabilities

Use when evaluating 10.0.0rc2 against an existing build. This is a candidate,
not authorization to replace a stable pin. The [cumulative release notes](https://github.com/bazelbuild/bazel/releases/tag/10.0.0rc2)
describe the major line; [rc2-specific fixes](bazel-10-rc2.md) describe the later
27-commit delta. Check both, including ruleset compatibility and the effective rc.
The guidance below selects migration decisions, not a promise that every new
feature is absent from every 9.x patch.

## Rehearse the actual default changes

| Option | 9.3.1 | 10.0.0rc2 | Required check |
|---|---|---|---|
| `--incompatible_no_implicit_file_export` | false | true | Replace accidental cross-package source access with an intended filegroup or scoped `exports_files` |
| `--incompatible_check_testonly_for_output_files` | false | true | An output-file dependency now respects its producer's `testonly`; repair production-to-test edges |
| `--incompatible_exclude_starlark_flags_from_exec_config` | false | true | Exec dependencies see defaults unless selected custom flags propagate |
| `--experimental_split_coverage_postprocessing` | false | true | Verify remote coverage postprocessing, not only test success |
| `--experimental_fetch_all_coverage_outputs` | false | true | Check coverage completeness and download cost on the real backend |
| `--rewind_lost_inputs` | true | true | Already enabled in this 9.x patch; replay eviction recovery rather than claiming a new 9.3.1-to-10 default |

The values above were checked with the exact binaries' `help build --long`,
except the undocumented exec flag, whose defaults were checked in tagged
[9.3.1 CoreOptions](https://github.com/bazelbuild/bazel/blob/9.3.1/src/main/java/com/google/devtools/build/lib/analysis/config/CoreOptions.java)
and [10.0.0rc2 CoreOptions](https://github.com/bazelbuild/bazel/blob/10.0.0rc2/src/main/java/com/google/devtools/build/lib/analysis/config/CoreOptions.java).
An option missing from ordinary help is not necessarily unsupported.

For execution settings, first determine whether the variation belongs in the
execution platform/toolchain. Where a custom flag really must propagate,
`--experimental_propagate_custom_flag=//package:setting` is the targeted escape
hatch in this candidate. Probe both target and exec configurations; blanket
restoration of all target flags can recreate configured-graph fan-out.

Where the repository wrapper supports a version override, select only the three
incompatible flips for a 9.x rehearsal using
[Bazelisk's comma-separated allowlist](https://github.com/bazelbuild/bazelisk#useful-environment-variables-for---migrate-and---bisect):

```bash
TARGET=//path/to:existing_test # Replace with a discovered repository target.
BAZELISK_INCOMPATIBLE_FLAGS=--incompatible_no_implicit_file_export,--incompatible_check_testonly_for_output_files,--incompatible_exclude_starlark_flags_from_exec_config \
  USE_BAZEL_VERSION=9.3.1 bazelisk --migrate test "$TARGET"
```

Exercise the two experimental coverage options separately on the same target.
Then test the candidate itself: removed APIs, changed no-op behavior and rc2
fixes cannot all be simulated with 9.x flags. Preserve caches unless a specific
reproduction requires isolation; `BAZELISK_CLEAN` is not a migration prerequisite.

## Bzlmod, fetching and repository rules

- **Lock closure:** `bazel mod tidy` evaluates dependency-only extensions as well
  as directly used ones and can replace `bazel mod deps` for updating the lock.
  Expect additional fetches and a larger vendored closure. `bazel vendor --lockfile_deps`
  includes repositories needed for lock updates with fetching disabled. Inspect
  the resulting lock/vendor diff and run an offline replay, not just tidy.
  [Tidy change](https://github.com/bazelbuild/bazel/pull/31329),
  [vendor change](https://github.com/bazelbuild/bazel/pull/31562).
- **Module compatibility:** `module(compatibility_level=...)` and
  `bazel_dep(max_compatibility_level=...)` are now no-ops, on different functions.
  The release prose groups them imprecisely; the [tagged API](https://github.com/bazelbuild/bazel/blob/10.0.0rc2/src/main/java/com/google/devtools/build/lib/bazel/bzlmod/ModuleFileGlobals.java)
  is authoritative. Remove reliance on compatibility-level conflict detection;
  maintain actionable build-time checks and ruleset migration guidance instead.
- **Rejected declarations:** remove `bazel_dep` self-dependencies. A root module
  must not `use_repo` an extension repository overridden/injected with the root
  itself; other modules may still import it. Use the existing self-repository
  name. Registry patch/overlay integrity strings must be non-empty. Replace
  removed `new_git_repository` loads/calls with `git_repository`.
  [Self-dependencies](https://github.com/bazelbuild/bazel/pull/31552),
  [self-imports](https://github.com/bazelbuild/bazel/pull/31553),
  [integrity](https://github.com/bazelbuild/bazel/pull/29017),
  [Git rule removal](https://github.com/bazelbuild/bazel/pull/29226).
- **Extension authors:** bump `module_extension(facts_version=...)` when persisted
  facts change schema. `module_ctx.tag_sort_key(tag)` orders tags across classes;
  changing the root `dev_dependency` on `use_extension` now reruns affected
  extensions. Reproducible facts are restored after external changes, rollback
  validation under `--lockfile_mode=error` is fixed, shutdown avoids stale lock
  writes, and `include()` cycles now fail instead of hanging. Exercise versioned
  facts, dev/non-dev switches and strict-lock rollback.
  [Facts version](https://github.com/bazelbuild/bazel/pull/29556),
  [tag ordering](https://github.com/bazelbuild/bazel/pull/29343),
  [dev dependency](https://github.com/bazelbuild/bazel/pull/30738),
  [strict rollback](https://github.com/bazelbuild/bazel/pull/28718).
- **Repository APIs:** Brotli archives, `strip_components` extraction,
  `git_repository(add_prefix=...)`, patching a selected directory and
  `watch_tree(exclude=...)` expand rule options. Verify symlink/hardlink behavior
  when changing extraction layout. Download failure structs expose `error`;
  propagate required-download errors instead of silently generating empty repos.
  [Extraction](https://github.com/bazelbuild/bazel/pull/29281),
  [link handling](https://github.com/bazelbuild/bazel/pull/30044),
  [patch directory](https://github.com/bazelbuild/bazel/pull/30987),
  [watch exclusions](https://github.com/bazelbuild/bazel/pull/29444).
- **Authentication and mirrors:** credential-helper failures now stop HTTP fetches;
  JSON `null` means unset. `NETRC` is honored by `read_user_netrc`. SOCKS proxy
  schemes and `urlencode($1)` downloader rewrites are supported; TLS-handshake
  failures fail over to mirrors sooner. Test the actual auth/proxy/mirror chain,
  including denied credentials; do not restore anonymous continuation or weaken TLS.
  [Helper failures](https://github.com/bazelbuild/bazel/pull/30647),
  [null values](https://github.com/bazelbuild/bazel/pull/30874),
  [NETRC](https://github.com/bazelbuild/bazel/pull/31378),
  [SOCKS](https://github.com/bazelbuild/bazel/pull/29274).

The remote repository-contents cache is distinct from the action cache. It now
covers reproducible repo rules more broadly, keys entries by host OS/CPU and
supports non-gRPC backends. Cross-repo/main-repo symlinks exclude repos from
caching. Revalidate reproducibility and cache eligibility; the
[rc2 materialization/cancellation fixes](bazel-10-rc2.md#repository-materialization-and-fetch-lifecycle)
matter particularly here. Environment edits, hermetic Linux actions and a prior
forced fetch no longer cause several unnecessary refetch/reload cases; measure
your own fetch behavior before assigning savings.

## Platforms, transitions and rule APIs

- Replace removed `platform(remote_execution_properties=...)` with
  `exec_properties`. Replace removed `@bazel_tools//src/conditions:host_windows`
  and `:remote` checks with the relevant execution/target platform or toolchain;
  the client's OS is not the executor's OS.
- `--use_target_platform_for_tests` is a no-op. Register an execution platform
  satisfying the target constraints. A test can now cross-compile without any
  compatible executor and fail only when run; analysis success is not test coverage.
  [Test platform change](https://github.com/bazelbuild/bazel/pull/30351),
  [cross-build behavior](https://github.com/bazelbuild/bazel/pull/30493).
- `transition.and_then(...)` composes Starlark and native transitions, including
  `config.exec()`. `constraint_setting(refines_constraint_value=...)` expresses
  an additional required constraint for non-default values. Check the resulting
  configured graph; composing transitions is not a reduction in configuration cost.
  [Composition](https://github.com/bazelbuild/bazel/pull/29542),
  [refinement](https://github.com/bazelbuild/bazel/pull/29655).
- `ctx.package_relative_label(...)` resolves user strings relative to the target's
  package, unlike `Label(...)` in a `.bzl` file. Prefer it when that is the intended
  ownership boundary. `Label.repo_root` replaces deprecated `workspace_root`.
  `DefaultInfo.executable` now works on configured targets/direct providers and
  providers returned by `ctx.super()`.
  [Package labels](https://github.com/bazelbuild/bazel/issues/28102),
  [repository root](https://github.com/bazelbuild/bazel/pull/31173),
  [executable](https://github.com/bazelbuild/bazel/pull/30741).
- `ctx.actions.run(stdout=out)` can replace shell redirection. Declare an ordinary
  output file, pass it only through `stdout`, and omit it from `outputs`; the
  [implementation rejects duplicate declaration](https://github.com/bazelbuild/bazel/blob/10.0.0rc2/src/main/java/com/google/devtools/build/lib/analysis/starlark/StarlarkActionFactory.java).
  Source files, directories and declared symlinks are not valid `stdout` values.
  This does not redirect stderr. Test exit status and produced bytes, not just analysis.
- A custom Starlark rule named `test_suite` no longer behaves as the native suite.
  `template_ctx.run` rejects its own output directories in `tools`; pass files
  produced by sibling actions. `min`/`max` key callbacks cannot mutate the sequence
  being traversed, and `splitlines()` no longer treats U+0085 as a line break.
  Test custom rules/macros rather than relying on their names or Python semantics.
- `fail(..., stack_trace=False)` gives concise user errors; diagnostic code must
  tolerate the new `Error:` prefix. `--force_starlark_stack_trace` restores traces
  for debugging. These are diagnostics, not reasons to swallow failures.
  [Tagged fail API](https://github.com/bazelbuild/bazel/blob/10.0.0rc2/src/main/java/net/starlark/java/eval/MethodLibrary.java).

## Local execution, runtime and host differences

The [local-execution changes](https://github.com/bazelbuild/bazel/releases/tag/10.0.0rc2#local-execution)
need action-level tests, not a blanket host-environment rollback:

- Strict action `PATH` drops `/usr/local/bin`. Declare the selected tool instead
  of accidentally relying on a developer-installed binary.
- `use_default_shell_env=True` actions default `LC_CTYPE` to `C.UTF-8`. On older
  macOS, the notes prescribe `--action_env=LC_CTYPE=UTF-8` when needed. The exact
  `--action_env==LC_CTYPE` spelling unsets it to restore the previous behavior.
  Test Unicode/locale-sensitive tools with the actual action environment.
- `resources:cpu` and `resources:memory` in `exec_properties` affect local
  scheduling estimates. They are not hard resource/security limits. Reassess
  aggregate local/worktree concurrency and compare with existing resource sets.
- Hermetic Linux bind mounts become correctly read-only. Fix writes to mounted
  inputs by declaring outputs; do not make the sandbox writable globally.
- `unused_inputs_list` preserves filename whitespace. Custom producers must emit
  the actual exec paths, not padded lines. Worker sandboxing can be selected by
  mnemonic; test isolation before selectively changing it.
- macOS sandboxed actions may bind sockets even when network access is blocked;
  binding a socket is not proof of external connectivity. Test processes receive
  the full local termination-grace period for cleanup after timeout.

The bundled server runtime moves to JDK 27; custom `--server_javabase` and `nojdk`
builds can use JREs. This does not upgrade Java compilation/runtime toolchains.
Startup now prefers system IPv6 address ordering, so diagnose IPv4-only failures
at that layer. Platform-specific `startup:linux`, `startup:macos` and
`startup:windows` sections are supported; inspect merged startup options.
Recursive rc imports are bounded at 512. Empty `--test_tmpdir=` resets the rc
value to the execroot default; use `--test_tmpdir=.` only when workspace-relative
behavior is intended. [General changes](https://github.com/bazelbuild/bazel/releases/tag/10.0.0rc2#general).

## Caches, remote execution and configured-graph performance

- Rewinding retries lost outputs, but regenerating different bytes can leave
  already-completed consumers inconsistent. rc2 adds the off-by-default
  [best-effort consistency guard](bazel-10-rc2.md#rewinding-is-not-a-determinism-guarantee);
  it detects some failures, not repairs them. Preserve direct-output materialization.
- `--disk_cache` accepts an implicit default path under `<outputUserRoot>/cache/disk`
  and boolean enable/disable forms. Copy-on-write uploads and GC-race handling
  change storage behavior; disk cache hits no longer get unconditional digest
  verification. Retain trust/integrity policy and exercise partial cache eviction.
- Empty values can clear remote endpoint/auth/TLS/scrubbing settings inherited
  from rc files. Verify effective credentials and endpoint changes; an empty override
  can remove required authentication. Changing endpoints or instance names now
  invalidates cached execution results. HTTP cache 408/429 retries and default gRPC
  keepalive change failure timing, not backend availability guarantees.
- CDC has selectable chunking algorithms and bounded per-blob transfers but still
  needs server split/splice support. Keep [patch-level integrity checks](monorepo-scale.md#large-artifacts-and-content-defined-chunking)
  and a chunking/non-chunking client matrix; neither this RC nor a flag name proves
  compatibility with an arbitrary REAPI backend.
- `persistentWorkerProtocol` is forwarded to remote execution services for the
  `requires-worker-protocol` execution requirement. Negotiate support with the
  backend; local worker support does not imply a remote persistent-worker feature.
- Under `--experimental_output_paths=strip`, archived tree artifacts gain support,
  while actions relying on Bazel's legacy mnemonic allowlist must opt in through
  execution requirements. Check the owning ruleset's path-mapping support before
  promising reuse across configurations. This is not analysis deduplication.
- Fixes reduce quadratic Starlark-flag analysis work and excessive
  `RepoMappingManifest` CPU use. `--experimental_keep_change_prunable_nodes_during_gc`
  trades retained graph state against future recomputation. Measure analysis time,
  heap and no-op/edit behavior; no upstream benchmark establishes your speedup.

Sources: [remote changes](https://github.com/bazelbuild/bazel/releases/tag/10.0.0rc2#remote-execution),
[path-mapping contract](https://github.com/bazelbuild/bazel/pull/29806),
[archived trees](https://github.com/bazelbuild/bazel/pull/29567),
[retained graph nodes](https://github.com/bazelbuild/bazel/pull/29965).

## Query, coverage, language/platform and automation consumers

| Consumer | What changes | Verification |
|---|---|---|
| Target selection | `--target_query` / `--target_query_file` select build/test targets from an unconfigured query | Compare selected labels, empty/error cases and the existing Git-aware selector; do not substitute this for `cquery` |
| Graph diagnostics | `aquery config(expr, word)`; `bazel config` accepts output-path prefixes; `dump --skyframe=keys` and `changed` expose graph state | Use the failing configs and a bounded `--skykey_filter`; keys/deltas are not execution traces |
| Output parsers | Full Starlark kinds, parallel streamed-proto serialization, triple-quoted multiline query strings and comma-grouped CLI counts | Prefer structured output; test Unicode and ordering assumptions, including [rc2's proto fix](bazel-10-rc2.md#analysis-query-and-rule-correctness) |
| Logs and BEP/BES | `--expand_param_files`; uncached-only test summaries; parent-before-child BEP order; build-metrics `instance_id`; improved infrastructure failure classification/upload diagnostics | Scrub arguments, retain full test outcomes independently of display filtering, and test your event joins/parsers |
| C++ | Generated toolchain-header include scanning fixed; FDO accepts repository labels; optional `warn_backrefs_defined` feature for LLD C static libraries | Exercise generated headers, profiles and linker warnings on the pinned toolchain; no global warning suppression |
| Coverage | Remote coverage defaults change; `BAZEL_LLVM_PROFILE_FILE` overrides the default `%h-%p-%m.profraw`; combined-report action stability improves | Prove report contents and collision-free profiles across processes/hosts, not just a green `coverage` invocation |
| Java | Recovery from several lost `.jdeps` inputs is fixed | Replay remote-cache eviction with the Java rules/toolchain; server JDK 27 is a separate contract |
| Android | `MODULE.tools` implicitly depends on `rules_android` 0.8.0; mobile-install error ordering improves; fragment-removal flag introduced but not flipped | Check actual loaded Android rules and APIs before deleting or replacing them |
| Windows | Shell path precedence returns to 8.x behavior; launcher manifest, long paths, empty env, parameter-file quoting and `run_under` forwarding are fixed | Run real Windows shell/launcher tests with empty arguments, trailing backslashes and long/non-ASCII paths; macOS results do not cover them |

These rows follow the corresponding sections of the
[tagged notes](https://github.com/bazelbuild/bazel/releases/tag/10.0.0rc2), including
[coverage](https://github.com/bazelbuild/bazel/pull/26807) and
[BEP metrics](https://github.com/bazelbuild/bazel/pull/29817).

## Removed, renamed, accepted-but-ineffective and future options

Audit rc imports and wrappers against the [full appendix](https://github.com/bazelbuild/bazel/releases/tag/10.0.0rc2#appendix),
not a search-and-replace of every `experimental_` prefix:

- Removed families include legacy Android dex/resource processing, Apple SDK and
  simulator selection, old fileset/exec-output options and `--test_result_expiration`.
  Identify the owning external rule's replacement before dropping an option.
- Graduated names cover action/disk/install-base GC, platform CPU naming and the
  remote downloader plus its local-fallback/credential propagation options.
  Check the exact replacement and its credential policy.
- Accepted no-ops include old autoload/native-rule migration toggles, Python
  options, `--apple_platforms`, sibling-repository layout, experimental remote
  analysis-cache options and additive-execution-info control. Accepted syntax
  does not prove a feature is active. Multiple `--modify_execution_info` values
  are now always applied in order, so recheck combined execution properties.
- Future-major candidates include private-default `config_setting` visibility,
  external source-directory package boundaries, eager `select` key resolution,
  Starlark host-transition removal, required mnemonics/extension metadata and
  matching aspect-hint providers, and strict symbolic-macro attributes. The
  Android/Apple/ObjC fragment-removal options also remain future flips. Probe
  these separately; do not present them as already enabled by 10.0.0rc2.

Before cutover, retain the old working configuration, validate the complete
supported build/test/runtime matrix and compare generated/lock/vendor metadata.
Treat candidate-only APIs as version-gated until the stable release is actually
published and the repository chooses to adopt it.
