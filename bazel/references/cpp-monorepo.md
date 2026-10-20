# C++ monorepos: configured actions and CI tiers

Use for first-party C++ macros, hermetic toolchains, platform/configuration
failures, editor compilation databases or graph-driven CI. Resolve component
names and commands from the current checkout; examples use placeholder labels.

## Keep the shared toolchain contract

Read the root module/rc and the component's loaded `.bzl` macros. In the surveyed
tree, imported products now share one hermetic LLVM setup. Their older standalone
toolchain files and commands are not current monorepo policy.

- Use the owning macro rather than introducing bare `cc_*` rules that bypass its
  C++ dialect, allocator, sanitizer/runfiles or exception contract. Different
  components may have different macros and exception policies.
- Put flags that must follow a library into its macro/target; root `.bazelrc`
  settings are not inherited when another root module consumes that library.
  Put machine choices in the existing user rc; scope a component-only warning
  exception by its path rather than weakening every first-party compile.
- Inspect target **and execution** platforms. Cross-compiling a Linux binary on
  macOS still needs build tools executable on macOS. A compiler on the host PATH
  is not a substitute for the selected hermetic toolchain/sysroot.
- Preserve CPU/OS/accelerator constraints. Linux-only, CUDA, Metal, live-kernel and
  fuzz targets intentionally need different capabilities/configs. Do not force a
  target compatible merely to make a wildcard command green.
- Treat a toolchain upgrade as a matrix change: native and cross compilation,
  debug/sanitizer and release linking, generated headers, foreign builds and
  sanitizer runtimes. `configure_make` preprocessor probes may consume
  `CPPFLAGS`, not just `CFLAGS`; inspect the actual action before patching it.

## Verify the configuration that matters

Use the component's checked-in build script where it owns flags and target scope.
Inspect its implementation when component prose conflicts with the root config.

The surveyed root defines `asan`, `release`, `tests-nolto`, `tsan`, `coverage` and
`local`; these are repository conventions, not built-in Bazel configs. Start with
the affected test, then the prescribed component/root matrix. `local` enables
live-kernel coverage; a simulation-only run does not verify those backends.

Keep sanitizer failures observable. A test that logs a UBSan diagnostic and exits
zero is not a sound sanitizer gate. Check runtime failure settings and declared
runfiles for suppression files/runtimes; otherwise a missing file or unchanged
cache key can invalidate the gate. Add only narrowly justified suppressions,
retaining first-party coverage.

Separate optimization from provenance stamping. The surveyed root moved stamping
out of release/test configs into a packaging-only `stamp` config: embedding a
changing commit identity invalidated otherwise reusable test actions. Preserve
the package target's stamped-artifact requirement without stamping every test.
Do not import this config into another repository without checking its policy.

## CI is two tiers, not one affected-test list

In the surveyed tree, the regular Bazel tier builds/tests the whole compatible
tree in sanitizer and release legs, using caching for unchanged actions. The
selector controls **additional integration shards and platform jobs**, not which
ordinary unit tests exist.

Read `ci/select_jobs.py`, `bazel/ci/defs.bzl`, the component's shard macro and
current workflows before changing CI:

- Integration shards are declared test targets with data/image dependencies and
  macro-owned `integration` / `ci-suite:` tags. The regular wildcard test command
  excludes them; a passing wildcard does not cover them.
- Nearest-ancestor `ci_policy` overrides apply **per attribute**. An
  `own_component` presubmit policy can defer cross-component reachability to a
  full/nightly run; it does not mean that dependency has no effect.
- BUILD edits seed the package's targets, not just a BUILD-file label. Root
  configuration, Starlark and CI edits may require full selection because source
  `rdeps` alone cannot describe their impact. Use the existing selector/tests,
  not a replacement directory filter or an ad hoc list of changed tests.
- Package selected shard images only after required test legs pass. A local
  focused run, the PR's rebased tree and a nightly full run have different
  coverage; report which one supplied the evidence.

## Cache and editor traps

Remote-cache configs are runner-network-specific; local builds need not be able
to reach them. Preserve read-only developer versus CI upload policy and the
backend's supported digest function. Do not copy an internal cache URL into a
new machine's config or switch digest algorithms for an assumed speedup.

With minimal remote downloads, a cache hit need not put every output on disk.
Consumers that directly read binaries or headers must request materialization
on their own command, such as the repository's use of
`--remote_download_toplevel`. Keep ordinary builds on their existing policy.

For clangd, use the current shared generator when available:

```bash
bazel run //bazel/cc_gen -- --help
```

Check its accepted flags and target patterns. The surveyed generator builds an
aspect's compile-input output group **before** reading `CppCompile` actions with
`aquery`, materializing generated headers, toolchain headers and virtual includes.
Use matching configs for its build and analysis rather than adding flags that
discard the analysis cache. Match the editor's clangd to the toolchain; report
partial database generation or incompatible accelerator targets instead of
claiming complete editor coverage.
