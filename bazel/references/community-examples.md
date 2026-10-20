# Community examples and selection evidence

Initial snapshot: 2026-10-19; production-source follow-up: 2026-10-20.
Choose examples by the question they answer, not stars or brand.
Source inspection establishes patterns, not a certified healthy codebase
or proof that hundreds of apps run quickly. These repositories were not built
locally during this audit.

## Recommended reading by role

| Source at inspected commit | Evidence and useful pattern | Limits |
|---|---|---|
| [BuildBuddy](https://github.com/buildbuddy-io/buildbuddy/tree/15882ddf1aee6ff08cda2ce603b3a344c1d3950f), changed Oct 20 | Production React/TS + Go tree; explicit frontend dependencies, SWC/TS macro, esbuild bundle, Go embedding and release targets | Custom macros and deployment assumptions, not a Vite starter. Sampled CI was still running |
| [CockroachDB](https://github.com/cockroachdb/cockroach/tree/d30c905fff79ef825adc96bcc647f1872a90f2ff), changed Sep 23 | Product UI workflow: Bazel shared UI/protobuf prerequisites, then persistent framework and TS watchers against a running cluster | Console uses React 16/TS 5.1.6. Workflow exemplar, not a modern frontend starter or verified generated-input refresh contract |
| [Aspect polyglot examples](https://github.com/aspect-build/bazel-examples/tree/a7213e3b0f4b820667c262d026b8143bcbd25509), changed Oct 17 | Root module includes language fragments, shared tooling, schema consumers, OCI examples and CI entrypoints | Teaching/reference repo, not proof of production scale. Sampled core CI passed; automation failures also present. `aspect` workflows extend Bazel |
| [rules_js](https://github.com/aspect-build/rules_js/tree/e67442a2ccf329841c9227d66ee013afcf5633c6), changed Oct 17 | Maintainer-owned Vite/React build fixture, devserver implementation and OCI end-to-end example; release v3.5.1 observed Sep 30 | Fixture/repro coverage, not a production app. Sampled CI mixed; verify version-specific sandbox issues |
| [rules_ts](https://github.com/aspect-build/rules_ts/tree/7f76b72dcb5d2022d8b3db4c70ae9ae676d72969), changed Oct 15 | JSX/declaration and isolated-checking fixtures; explicit transpiler contracts; release v3.10.1 observed Aug 21 | Rule behavior, not proof a given compiler/bundler pair works. Sampled CI mixed |
| [Angular](https://github.com/angular/angular/tree/fd9e5635d8cabfe90972c04391be8d89f9a6e895), changed Oct 19 | Large TS framework with central macros, declaration targets and strict-dependency checks | Learn graph/governance patterns, not React architecture. Sampled Actions mostly skipped benchmarks; full CI health unknown |

Listed repositories were unarchived at their respective checks. Dates are
inspected default-branch commit dates, not claims of continuous maintenance.
Actions observations are bounded samples, not exhaustive checks or proof tied to
every listed commit.

## Concrete source map

- **React + Go artifact:** BuildBuddy's
  [app dependencies](https://github.com/buildbuddy-io/buildbuddy/blob/15882ddf1aee6ff08cda2ce603b3a344c1d3950f/app/root/BUILD.bazel),
  [TS macro](https://github.com/buildbuddy-io/buildbuddy/blob/15882ddf1aee6ff08cda2ce603b3a344c1d3950f/rules/typescript/index.bzl),
  [bundle/embedding boundary](https://github.com/buildbuddy-io/buildbuddy/blob/15882ddf1aee6ff08cda2ce603b3a344c1d3950f/enterprise/app/BUILD.bazel)
  and [CI configuration](https://github.com/buildbuddy-io/buildbuddy/blob/15882ddf1aee6ff08cda2ce603b3a344c1d3950f/buildbuddy.yaml).
  Fastbuild serves runfiles instead of embedding the release bundle. Broad cached
  tests coexist with separate release builds; isolated TS checking is still a TODO.
  Its [manifest](https://github.com/buildbuddy-io/buildbuddy/blob/15882ddf1aee6ff08cda2ce603b3a344c1d3950f/package.json)
  and macro select different TS major versions for different roles; manifest
  versions alone do not prove compiler/validator compatibility.
- **Native frontend watcher handoff:** CockroachDB's
  [UI workflow](https://github.com/cockroachdb/cockroach/blob/d30c905fff79ef825adc96bcc647f1872a90f2ff/pkg/ui/README.md)
  and [launcher](https://github.com/cockroachdb/cockroach/blob/d30c905fff79ef825adc96bcc647f1872a90f2ff/pkg/cmd/dev/ui.go).
  `./dev ui watch` builds prerequisites, then runs pnpm/Webpack/TS watchers and a
  proxy to the selected cluster. The launcher rejects externally linked packages
  Bazel cannot track. Verify later generated-input changes and process cleanup
  before adapting this alternative to a synchronized dev sandbox. The
  [console manifest](https://github.com/cockroachdb/cockroach/blob/d30c905fff79ef825adc96bcc647f1872a90f2ff/pkg/ui/workspaces/db-console/package.json)
  explains why its versions are not a modern stack recommendation.
- **Polyglot root:** Aspect's
  [root module](https://github.com/aspect-build/bazel-examples/blob/a7213e3b0f4b820667c262d026b8143bcbd25509/MODULE.bazel),
  [Node/toolchain fragment](https://github.com/aspect-build/bazel-examples/blob/a7213e3b0f4b820667c262d026b8143bcbd25509/tools/nodejs.MODULE.bazel)
  and [CI](https://github.com/aspect-build/bazel-examples/blob/a7213e3b0f4b820667c262d026b8143bcbd25509/.github/workflows/ci.yaml).
  `bazel lint`, `format`, `gazelle` and `delivery` in its wrapper are Aspect
  extensions, not portable stock-Bazel commands.
- **Frontend primitives:** rules_js
  [Vite 6/React fixture](https://github.com/aspect-build/rules_js/tree/e67442a2ccf329841c9227d66ee013afcf5633c6/examples/vite6)
  and [Node OCI fixture](https://github.com/aspect-build/rules_js/blob/e67442a2ccf329841c9227d66ee013afcf5633c6/e2e/js_image_oci/src/BUILD.bazel);
  rules_ts [isolated checking](https://github.com/aspect-build/rules_ts/tree/7f76b72dcb5d2022d8b3db4c70ae9ae676d72969/examples/isolated_typecheck).
  The OCI fixture documents a macOS-to-Linux Node toolchain caveat and uses a
  shell-bearing base image; verify runtime/platform requirements before copying it.
- **Large TS graph:** Angular's
  [shared macros](https://github.com/angular/angular/blob/fd9e5635d8cabfe90972c04391be8d89f9a6e895/tools/defaults.bzl)
  and [core BUILD](https://github.com/angular/angular/blob/fd9e5635d8cabfe90972c04391be8d89f9a6e895/packages/core/BUILD.bazel).
  Its wrapper adds strict-dependency tests alongside typechecking/declarations.

## Production retrospectives

These first-party accounts explain design decisions, not current configuration
contracts or measured gains for this repository. Read the linked source when
adapting a pattern; validate it against the intended checkout.

| Account | Reusable decision | Boundary |
|---|---|---|
| [Canva, July 2024](https://www.canva.dev/blog/engineering/faster-ci-builds-at-canva/) | Consolidate setup-heavy jobs and make frontend integration/a11y tests hermetic. Move target-hash work out of pipeline generation; use precomputed hashes at job runtime with a broad Bazel fallback | Canva removed expensive diffing from pipeline generation, then reintroduced selection. It did not permanently abandon affected-target selection |
| [Wix, July 2025](https://www.wix.engineering/post/from-60-repos-to-one-how-wix-tackled-monorepo-migration-part-2) | Maintain an incremental dependency graph when full-graph selection becomes the bottleneck | Neptune and large-heap/analysis-discard settings are their infrastructure choices, not universal local defaults. The article is not a complete selector-correctness specification |
| [Airbnb JVM migration](https://airbnb.tech/infrastructure/migrating-airbnbs-jvm-monorepo-to-bazel/) | Generate BUILD files, cache mainline generator indexes and use shared execution infrastructure. Prove packaged startup/integration, including reflective dependencies | Finer granularity during migration delayed parity. Preserve existing build behavior first; see [migration guidance](migrations.md) |
| [Dropbox, December 2019](https://dropbox.tech/infrastructure/continuous-integration-and-deployment-with-bazel) | Separate affected-test batching from explicit team-owned release tests per deployable | Historical design, not evidence of current infrastructure. Automatic inference did not match teams' release-test expectations; preserve your repository's required gates |
| [Uber, May 2020](https://www.uber.com/us/en/blog/go-monorepo-bazel/) | Use Gazelle and extensions to maintain Go/protobuf BUILD metadata | Historical Go monorepo account, not evidence that every Uber language shares one repository |

## Useful examples that are not modern defaults

- [Official frontend examples](https://github.com/bazelbuild/examples/tree/45bfd9d9b3d1b8e940890aa90a60483e8179331d/frontend),
  changed Sep 15: React/Vite dev/build/test wiring and React Router SSR/typegen.
  The React package still pins TS 4.9.3 and Vite 5.4.21; its build smoke test checks
  filenames, not browser behavior. The React Router README explicitly lists an
  unresolved typecheck/IDE integration task. Read them for wiring, not as a
  verified current stack or complete SSR setup.
- [Jazelle](https://github.com/uber-web/jazelle/tree/308faa2486cc973cf9a54de5554b93ca9e4605c7),
  changed Sep 15: workspace/task orchestration comparison. Sampled tests passed,
  but inspected docs/config still use Node 16, Bazel 5.1/WORKSPACE and Yarn 1.
  Fresh activity and green samples do not make that stack a modern scaffold.

## Recheck before adopting

Inspect the candidate's current releases and source for the intended stack,
lock/toolchain pins, actual CI commands, tests, deployment artifacts and unresolved
compatibility issues. Run the slice in [TypeScript/React](typescript-react.md),
then measure [scale behavior](monorepo-scale.md). Prefer source paths and immutable
commits for reproducibility; use current issue/release state for compatibility.

## Alternative-tool examples

Use for a build-system choice, not as a reason to migrate an existing Bazel build.
Read [tool fit](tool-fit.md) for the current contracts and a bounded comparison.
These additional sources were checked 2026-10-20; none was built or benchmarked.

- **Grafana:** [Nx configuration](https://github.com/grafana/grafana/blob/57bca96f71ef3cfdbe0a134ffb31bfee7c289bd1/nx.json),
  [frontend scripts](https://github.com/grafana/grafana/blob/57bca96f71ef3cfdbe0a134ffb31bfee7c289bd1/package.json)
  and [Go/JS build handoff](https://github.com/grafana/grafana/blob/57bca96f71ef3cfdbe0a134ffb31bfee7c289bd1/Makefile).
  A polyglot product can retain native language builds beside frontend task
  caching. This does not establish automatic cross-language action dependencies;
  the filtered build-CI query was unavailable, so overall health is unknown.
- **Microsoft TypeSpec:** [task inputs/outputs](https://github.com/microsoft/typespec/blob/50240c7db77895b261ab2a511f7f79e5650db59b/turbo.json)
  and [build/watch scripts](https://github.com/microsoft/typespec/blob/50240c7db77895b261ab2a511f7f79e5650db59b/package.json).
  Current source uses Turbo with a compiler-owned build-mode watcher, not Nx.
  Sampled CI passed for that SHA; this is not a runtime/performance certification.
- **Cal.diy:** [app selection scripts](https://github.com/calcom/cal.diy/blob/0f19cc46ef6b6426ee398c670575b3c96be7af9e/package.json)
  and [task boundaries](https://github.com/calcom/cal.diy/blob/0f19cc46ef6b6426ee398c670575b3c96be7af9e/turbo.json)
  separate cached builds from uncached deployment/database side effects. The
  old `calcom/cal.com` URL redirected here; do not present this as evidence of
  current hosted Cal.com infrastructure. Sampled push workflows included failed
  release/localization jobs, so it is not a uniformly green template. Its broad
  global environment hashing is an example to assess, not an invalidation optimum.

All three were unarchived with recent default-branch activity. Those maintenance
signals and isolated green jobs cannot certify codebase health or hundred-app scale.
