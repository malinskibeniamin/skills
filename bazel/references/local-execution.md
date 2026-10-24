# Local sandboxing and REAPI execution

Use for sandbox escapes, expensive input-tree setup, or evaluating a local VM
executor such as actiond. Preserve the repository's existing execution owner;
this is an opt-in evaluation, not a reason to install a daemon for every build.

## Diagnose the boundary

- Separate **declared-input correctness** from **host security isolation**.
  Stock [Bazel sandboxing](https://bazel.build/docs/sandboxing) is not a universal
  boundary against hostile tools or absolute-path reads. Inspect the actual
  strategy and its host filesystem/network access before claiming isolation.
- Reproduce one affected action with its exact configuration. Inspect declared
  inputs, runfiles, toolchain binaries, environment and resolved paths. A tool
  following a symlink to discover undeclared siblings is a dependency leak, not
  justification for adding the whole workspace as input.
- Native tools may bypass language-level filesystem interception. Revalidate
  path resolution when replacing a Node-based compiler/bundler with a native
  binary; a Node patch does not establish containment for a Go/Rust tool.
- Measure input-tree setup separately from action execution. A filesystem-backed
  sandbox can avoid eager symlink forests, but mount, metadata and first-execution
  overhead still matter. Hard links expose source files to writes; APFS clones
  have filesystem/volume limits. [FSKit](https://developer.apple.com/documentation/fskit/)
  requires app-extension deployment. Require a measured reproduction before
  replacing the sandbox backend.

## Evaluate actiond as a local executor, not a sandbox-off switch

The pinned [actiond architecture](https://github.com/hermeticbuild/actiond/blob/5a0335c607a367f02f2dfcea380799e3bcbac767/ARCHITECTURE.md)
uses REAPI to send actions to a persistent local Linux VM. Its kernel filesystem,
actiondfs, exposes declared CAS inputs lazily instead of constructing a symlink
forest per action. The CAS and ActionCache live in the guest. This changes action
placement and containment; it is not stock Bazel's native macOS sandbox.

1. Check the chosen release's host/CPU, virtualization, Bazel and rules support.
   Keep Linux-compatible **execution** toolchains separate from the requested
   **target** platform. A local Linux VM cannot run Xcode or macOS SDK tools;
   preserve native execution for actions that require them.
2. Follow the pinned [client contract](https://github.com/hermeticbuild/actiond/blob/5a0335c607a367f02f2dfcea380799e3bcbac767/README.md#point-bazel-at-actiond)
   in a named opt-in configuration. That snapshot points `--remote_executor` and
   `--remote_cache` at the local worker, selects remote spawn/genrule strategies,
   disables local fallback and local-result uploads, and disables unsupported
   remote cache compression. Recheck capabilities before composing other remote
   flags; a REAPI endpoint does not imply every optional feature is supported.
3. For a hermeticity probe, force a new action identity with an owned declared
   input change and disable remote cache acceptance (`--noremote_accept_cached`
   where supported). `--nocache_test_results` reruns tests, not all their build
   dependencies. Disable local/dynamic fallback and inspect execution metadata
   for strategy overrides or local-only actions. A cache hit or successful local
   fallback does not prove VM execution. An executor outage must remain visible.
4. Fix missing tools, libraries and runtime inputs in their owning rule/toolchain.
   Record selected runtime properties, including any supplied Bash/libc. One
   passing action does not certify repository fetching, local actions or the
   whole build as hermetic or secure.
5. Verify output identity or required runtime behavior, test exit codes, runfiles
   and host-side output materialization. Compare cold/warm, small-edit and
   concurrent-worktree runs, including VM memory, CAS growth and queue time.
   Treat upstream benchmarks as workload-specific, not promised speedups.

Keep the listener local unless authenticated sharing is deliberately configured.
Retain the worker's owned cache root across runs, and coordinate its lifecycle
across worktrees. Sharing an executor/CAS does not merge Bazel servers or their
analysis heaps; budget those separately in [monorepo scale](monorepo-scale.md).
