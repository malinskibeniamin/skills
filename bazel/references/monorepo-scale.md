# Hundreds of polyglot apps

Use for monorepo topology, local orchestration, CI selection, caching or release
design. This is a proposed architecture to validate, not a measured speedup.
For initial Bazel adoption or repository consolidation, establish
[migration parity](migrations.md) before optimizing target granularity.
When choosing or replacing the build owner, read [tool fit](tool-fit.md) to
distinguish task orchestration from compiler-action ownership.

## Four different incremental loops

```text
declared source/schema -> library -> tests + app artifact
                         │               │
                    local dev/HMR    cache + CI selection
                                         │
                                immutable release -> deploy
```

Bazel reuses actions for requested targets. A Git-aware selector decides which
targets CI requests. Vite refreshes browser modules. A release controller decides
which artifacts/configurations to roll out. None substitutes for the others.

## Graph and ownership

- Model independently owned apps, reusable libraries and schemas as packages;
  make direct language, generated-source and runtime-file dependencies explicit.
  Use visibility to prevent accidental app-to-app coupling and dependency cycles.
  Put shared cross-language contracts in codegen targets consumed by each language,
  not scripts that write undeclared files into source trees.
- Register pinned language toolchains once at the workspace root. Distinguish
  target from execution platform, especially Apple Silicon development versus
  Linux release artifacts and native npm addons. Remote caching cannot make
  incompatible platform actions interchangeable.
- Wrap proven language rules with small repository macros for common test,
  visibility and artifact policy. Automate BUILD maintenance where supported;
  require generator/formatter drift checks. Avoid a mega-action that shells out to
  every language build or hashes the whole repo for each app. It erases the useful
  graph boundaries. Consult the [polyglot example](community-examples.md).

## Local work: selected closure, not hundreds of processes

- Provide the existing repo's one-command entrypoint for one app/service stack:
  generated contracts, needed backend services, frontend devserver and readiness
  checks. Start only that closure; use configured shared services/mocks where
  appropriate. Backend dependencies still require restart/reload policy, ports,
  logs and teardown; Bazel is not a service orchestrator.
- Keep one persistent devserver per selected frontend. Use a synchronized dev
  sandbox, or an existing repo-owned handoff from Bazel prerequisite builds to
  native framework/checker watchers. [CockroachDB's handoff](community-examples.md#concrete-source-map)
  releases the Bazel lock after initial UI/protobuf builds; this does not prove
  later generated inputs refresh automatically. Exercise those changes and own
  regeneration, watcher readiness and teardown. Let framework HMR handle module
  changes; restart backend processes when their runnable outputs change.
  Avoid spawning one competing Bazel watcher per repository app; coordinate the
  selected stack and avoid unnecessary output bases that duplicate disk/server
  state. Separate bases remain appropriate for genuinely isolated configurations.
- Preserve warm analysis/action caches. Stable rc/config choices and persistent
  workers help only when supported by the pinned rules. Measure server startup,
  graph analysis, execution, filesystem watching and artifact downloads separately.
  See [Bazel iteration guidance](https://bazel.build/advanced/performance/iteration-speed).

## CI: establish correctness before narrowing

1. Start with a broad, cached build/test gate for the supported matrix. If analysis,
   target discovery or job setup dominates, compare configured graphs at the CI
   baseline and candidate using maintained tooling such as
   [target-determinator](https://github.com/bazel-contrib/target-determinator/blob/d4b6125546979713431e63b5c3e65810fa989446/README.md)
   or [bazel-diff](https://github.com/Tinder/bazel-diff/blob/e5471d05541a0760cb7b300f340ce346516b398c/README.md).
   Pin and test the selector; these are external tools, not stock Bazel subcommands.
2. Record exact baseline/candidate SHAs and selected labels/configs. Use the CI's
   intended comparison (for example, last green target-branch commit versus merge
   candidate); a missing/shallow baseline needs recovery, not an empty selection.
   Account for deleted/renamed files and targets in both graphs. Directory filters
   or head-only reverse-dependency queries miss removed edges and rule changes.
   If graph/hash generation dominates pipeline startup, precompute metadata off
   that critical path. Bind reuse to source revision, configuration and selector
   version; missing or incompatible metadata requires recomputation or the broad
   gate, not a stale empty set. [Canva and Wix](community-examples.md#production-retrospectives)
   illustrate different implementations, not a requirement for a graph database
   or their CI-specific memory/analysis flags.
3. Validate BUILD/Starlark, lockfile, toolchain, rc, platform and selector changes
   explicitly. Broad fallback is safer than an unproven narrow set. Preserve
   repository-required always-run integration/security/release tiers. Exercise each
   supported configuration; `select()` and incompatible targets change the graph.
   Selector failure must fail or invoke the broad gate, never report zero impact.
4. Shadow selection against the broad gate before trusting skips, and retain
   scheduled broad coverage. Test deletion, shared API/schema edits, root config
   edits and unrelated edits. A selector cannot find undeclared dependencies.
   Check its own cache keys: the inspected Target Determinator excludes host,
   user/system rc and environment; do not share that result cache across machines
   or reuse it across uncontrolled environments.
5. Shard by measured action/resource cost, not one setup-heavy job per app. Keep
   stable flags and execution images across compatible workers; cancel obsolete
   candidate jobs. BuildBuddy's [broad cached tests](community-examples.md) show
   that Git selection is an optimization to earn, not a prerequisite for Bazel.

## Caches and execution

Use repository-download, local disk and remote action caches for their distinct
purposes. Give shared cache write credentials only to trusted writers; untrusted
PR code must not receive secrets or poison trusted cache entries. Downloads also
need confidentiality controls. Separate cache namespaces where trust requires it;
avoid per-commit namespaces that destroy reuse. Bound disk retention and inspect
miss reasons, transferred bytes and retrieval latency, not just hit percentages.
See [remote caching](https://bazel.build/remote/caching).

Add [remote execution](https://bazel.build/remote/rbe) when measured uncached
parallel work warrants it. First declare tools/inputs/environment, pin executor
images and validate sandboxed behavior. Host-installed tools, network-dependent
actions and undeclared credentials do not become hermetic by moving machines.
Keep interactive watchers local. Preserve lazy output downloads, but materialize
artifacts that local devservers, packagers and deployment tools actually consume.

## Release only changed deliverables

Build cacheable static assets, binaries, packages or OCI images; put mutable
registry pushes and deployments in separate explicitly authorized steps. For
static web apps, use hashed assets plus an HTML/manifest release and deep-link
fallback. For SSR/Node, package the server entrypoint, generated files, runtime
dependencies and assets. OCI layers can separate stable dependencies from changing
app files; inspect the [rules_js image example](community-examples.md).

Give each deployable an explicit release-test contract covering its runtime and
integration obligations. Affected presubmit tests alone do not establish release
readiness. Preserve mandatory repository-wide gates alongside app-owned checks;
do not infer permission to bypass them from another team's selective releases.
[Dropbox's historical design](community-examples.md#production-retrospectives)
separates affected-test selection from team-owned release tests.

Map app artifact targets to deployment units. Compare each verified artifact digest
and deploy configuration with the last deployed release; changed source alone
does not prove a changed deliverable, and unchanged bytes do not excuse a changed
runtime config. Build once per platform, promote the same digest, and retain
provenance, health/smoke checks and rollback. Keep commit/time stamping at the
release boundary rather than invalidating all tests/libraries. Shared API or schema
changes still require compatibility and rollout ordering across affected services.
Selective deployment is not a Bazel cache feature or browser HMR.
If global commit stamping changes every artifact digest, select releases using
reproducible unstamped content identity first; provenance should not turn unrelated
commits into changed apps.

## Prove the improvement

Compare the same machine/executor, configs and target set for cold, warm, no-op,
leaf implementation, shared API/schema, lockfile/toolchain and unrelated edits.
Separate developer, fresh-CI and warm-remote-cache scenarios. Capture wall time,
analysis/critical path, executed/cached actions, downloaded bytes, peak resources
and selected-versus-broad test results with Bazel profiles/BEP and CI timing.
Include HMR latency/state retention and deploy smoke tests where claimed. Diagnose
the dominant cost before adding workers. Canva's [CI case study](https://www.canva.dev/blog/engineering/faster-ci-builds-at-canva/)
illustrates job overhead and hermeticity as well as execution scaling; its results
are not a benchmark for this repository.

## Configured query probes

Substitute existing labels and a repository-defined configuration:

```bash
CONFIG=asan # Replace with a config defined by this repository.
bazel query 'tests(//path/to/...)'
bazel cquery 'deps(//path/to:target)' --config="$CONFIG"
bazel aquery 'mnemonic("CppCompile", deps(//path/to:target))' --config="$CONFIG"
```
