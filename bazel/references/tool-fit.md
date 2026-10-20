# Choose the build ownership boundary

Use when choosing a monorepo build system, introducing Bazel or proposing a
migration. For repairs in an existing Bazel-owned build, keep its ownership;
competitor research is not a reason to replace a working toolchain.

Checked 2026-10-20. These are candidate contracts to validate, not speed rankings
or a current-version starter. Verify the installed release before using an
opt-in from live documentation. Preserve pins until an upgrade is independently
justified; current guidance does not mean installing every latest release.

## Decide what the graph must own

- If the problem is scheduling existing app scripts, affected CI or sharing their
  outputs, first assess the current task orchestrator. More apps alone do not
  establish a need for compiler-action ownership.
- If native compilation, cross-language code generation and packaged runtimes
  need shared declared dependencies and execution platforms, evaluate an action
  graph. A task that wraps an entire native build leaves its internal graph and
  incremental compilation to the wrapped tool.
- A hybrid can be intentional. Name the owner of each dependency edge, generated
  output, cache key and watcher; avoid competing selectors or two independently
  maintained manifests. Define the handoff and verify changed inputs across it.

## Compare actual contracts, not categories

| Candidate | What to compare | Compatibility boundary |
|---|---|---|
| Bazel | Existing rules, configured action graph, toolchains, cache and remote execution | Prove the intended JS compiler/bundler/dev/runtime slice; language support is not complete app integration |
| Nx | Process-level task caching, Vite task integration, affected selection and Nx Agents distribution | Input-aware selection still requires complete inputs; wrapping a compiler does not expose all its actions. [Cache](https://nx.dev/docs/concepts/how-caching-works), [Agents](https://nx.dev/docs/features/ci-features/distribute-task-execution) |
| Turborepo | Existing package scripts, task outputs, dependency-aware watching and pruned image-build inputs | Preserve native framework watchers; a pruned workspace is not a verified deployable. [Watch](https://turborepo.dev/docs/reference/watch), [prune](https://turborepo.dev/docs/reference/prune) |
| Buck2 | Public Starlark rules and remote action execution | Public Node/TS rules exist; inspect config/resource restrictions rather than inferring React/Vite readiness from Meta's scale. [Node rule](https://buck2.build/docs/prelude/rules/nodejs/nodejs_library/), [remote execution](https://buck2.build/docs/users/remote_execution/) |
| Pants | Language-backend fit, inferred dependencies and remote processes | The checked 2.33 docs label JS beta and TS checking experimental; TypeScript uses project-level build mode. [JS](https://www.pantsbuild.org/stable/docs/javascript/overview), [TS](https://www.pantsbuild.org/stable/docs/javascript/overview/enabling-typescript-support) |
| Please | Declared targets, language plugins, host tools and remote executors | Validate actual frontend rules and developer/CI platforms; no modern React starter was verified in this review. [Plugins](https://please.build/plugins.html), [remote config](https://please.build/config.html#remote) |
| moon | Task hashing, proto-managed toolchains, Bun integration and affected CI | REAPI-compatible caching is not proof of compiler remote execution; verify cache authentication against the guide's TLS/mTLS warning. [Bun](https://moonrepo.dev/docs/guides/javascript/bun-handbook), [cache](https://moonrepo.dev/docs/guides/remote-cache) |

## Recheck fine-grained claims

- Nx's current [affected contract](https://nx.dev/docs/features/ci-features/affected)
  documents task/input-aware selection behind `NX_LEGACY_AFFECTED=false`.
  `dependsOn` ordering alone does not transmit changed inputs. Verify the task's
  dependency inputs/output-file inputs and use consistent selection mode across
  CI commands. The cache unit remains the configured task's process result.
- Turbo's [watch contract](https://turborepo.dev/docs/reference/watch) documents
  `futureFlags.watchUsingTaskInputs` instead of its default package-level watch
  invalidation. This is not a claim about compiler actions or all CI selection.
  Keep a framework's own watcher persistent; use restart behavior only when it
  cannot observe dependency changes. Verify generated inputs and browser state.
- Turbo's [prune configuration](https://turborepo.dev/docs/reference/configuration#pruneincludesglobalfiles)
  documents `pruneIncludesGlobalFiles`: global dependency files are not copied
  by default. Test the reduced build context without the original checkout's
  root configs, generated files or dependency directories hiding omissions.
- Separate selection granularity, cache unit, compiler incrementality and browser
  refresh. Task-input-aware invalidation does not automatically make each source
  file a separate cacheable compilation, and a cached bundle is not HMR.

## Compare one representative slice

Keep dependencies, compiler versions and required checks fixed. Use one app,
one native service and a shared schema where the repository has those boundaries.
Compare the current owner with one plausible candidate, not parallel migrations
to every tool. Follow [migration parity](migrations.md) and measure the
[edit matrix](monorepo-scale.md#prove-the-improvement).

Exercise leaf implementation versus exported-type edits, generated clients,
deleted files and root lock/toolchain/config changes. Observe skipped work as
well as executed work; shadow narrow selection against the broad gate. Test local
watcher readiness/state retention separately from independent type failures,
CI cache reuse and packaged-runtime startup/release checks.

Include rule/generator ownership, developer setup and operating cost in the
decision. Reusing a cache service requires verified protocol/authentication and
action identity; shared REAPI transport does not imply interchangeable cache
keys or artifacts across tools. Cache logs and outputs can contain sensitive data.
For source examples and their health limits, read
[alternative-tool examples](community-examples.md#alternative-tool-examples).
