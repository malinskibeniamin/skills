# TypeScript and React

Use for frontend targets, Node services, or introducing Bazel beside an existing
JavaScript toolchain. Preserve the application's framework, package manager,
compiler, tests and React Compiler configuration; Bazel integration is not
permission to migrate them.
When replacing or running beside another build, read [migration parity and
cutover](migrations.md) before changing dependency versions or target granularity.
If the owner is undecided, compare [task orchestration and action graphs](tool-fit.md)
before converting a working frontend build; keep existing Bazel ownership for repairs.

## Establish one working vertical slice

1. Pin a compatible Bazel, Node, JS/TS rules, compiler and bundler combination.
   For a new Bzlmod setup, investigate `rules_nodejs` for Node toolchains,
   `aspect_rules_js` for npm dependencies/binaries and `aspect_rules_ts` for TS
   targets. Modern `rules_nodejs` toolchains are distinct from the legacy
   `build_bazel_rules_nodejs`/`@bazel/typescript` stack. Follow the selected
   releases, not imports copied from an older tutorial. See the
   [module/toolchain example](https://github.com/aspect-build/bazel-examples/blob/a7213e3b0f4b820667c262d026b8143bcbd25509/tools/nodejs.MODULE.bazel).
2. Connect the authoritative lockfile to `npm_translate_lock`; link packages
   with generated `npm_link_all_packages` targets in consuming BUILD packages.
   The inspected implementation consumes a pnpm lock and can import npm/Yarn
   locks through conversion. It does not establish direct Bun-lock support.
   For Bun repositories, resolve an explicitly supported integration before
   implementation; avoid a second independently maintained dependency graph.
   Audit lifecycle/native install hooks, platform binaries, registry auth and
   declared patches. See the [lock rule's actual attributes](https://github.com/aspect-build/rules_js/blob/e67442a2ccf329841c9227d66ee013afcf5633c6/npm/private/npm_translate_lock.bzl).
3. Wire one app and one shared library through the target contracts below.
   Include CSS, assets, HTML, configs, generated routes/clients, package exports
   and runtime dependencies. Declaring an import alias in tsconfig does not add
   a Bazel edge or configure the bundler/test runner.
4. Prove dev updates, independent type errors, tests, production build and served
   production assets before repeating the pattern across apps. Introduce small
   repo-owned macros only after this slice establishes the common contract.

## Keep these contracts separate

| Target role | Contract |
|---|---|
| Library | `ts_project` with explicit direct `deps`, coherent tsconfig and declaration outputs for consumers; include runtime assets separately |
| Type gate | Compiler checks run independently of the dev transform/bundle; CI must request the checking target/test, not only emitted JS |
| Tests | Existing unit/component runner exposed as Bazel tests with declared config, environment, browser/runtime and fixtures |
| Bundle | Vite CLI through a generated npm binary plus `js_run_binary` (or the generated action wrapper), declared source/tool/config closure and `out_dirs` matching Vite's output |
| Dev | Persistent framework server through `js_run_devserver` + ibazel with declared source/generated/npm `data`, or an existing [native watcher handoff](monorepo-scale.md#local-work-selected-closure-not-hundreds-of-processes) after Bazel prerequisites |
| Release | Static bundle, Node runtime closure or OCI image depending on the existing deployment model; separate publication/deployment side effects |

For complete, inspectable wiring, compare the
[React/Vite dev and build targets](https://github.com/bazelbuild/examples/blob/45bfd9d9b3d1b8e940890aa90a60483e8179331d/frontend/react/BUILD.bazel)
with the newer [rules_js Vite build fixture](https://github.com/aspect-build/rules_js/blob/e67442a2ccf329841c9227d66ee013afcf5633c6/examples/vite6/BUILD.bazel).
These are structural examples, not a verified current-version starter; read their
[limitations](community-examples.md). The generated npm `bin` load path depends
on the importing workspace package. Discover it rather than inventing a label.

## Incremental typechecking and browser updates

- Give shared libraries stable declaration boundaries. Implementation-only edits
  can leave downstream type actions cached when declarations stay byte-identical;
  runtime consumers still need changed JS. Avoid one whole-repository `ts_project`
  or one target per trivial file: choose package boundaries from reuse, ownership
  and measured invalidation cost.
- Separate fast transforms from checking when useful. `rules_ts` supports custom
  `transpiler` and `isolated_typecheck`; the latter requires compatible `noCheck`
  and `isolatedDeclarations` behavior. Request its generated typecheck tests in CI.
  Verify compiler/worker compatibility before substituting TS7/`tsgo` for `tsc`.
  See [rule contracts](https://github.com/aspect-build/rules_ts/blob/7f76b72dcb5d2022d8b3db4c70ae9ae676d72969/ts/defs.bzl)
  and the [isolated checking fixture](https://github.com/aspect-build/rules_ts/blob/7f76b72dcb5d2022d8b3db4c70ae9ae676d72969/examples/isolated_typecheck/backend/BUILD.bazel).
- Let Vite and its React plugin perform HMR/Fast Refresh, not a Bazel production
  bundle on every keystroke. Vite transpilation does not establish type safety.
  Preserve the repo's React Compiler plugin in that transform pipeline. See
  [Vite's HMR and typechecking boundaries](https://vite.dev/guide/features).
  Keep workspace package exports/resolution consistent across editor, checker,
  bundler and tests; verify one React runtime across linked libraries. Production
  bundling may rerun for the whole affected app: code splitting and browser HMR
  do not imply module-granular Bazel bundle actions.
- `js_run_devserver` runs in a custom dev sandbox; under ibazel it synchronizes
  changed declared data while the server watches those files. Check new/deleted
  files, generated outputs, symlink resolution, writable cache locations and
  config changes. A normal source edit should not restart the whole stack;
  full reloads remain valid outside a refresh boundary. See the
  [devserver contract](https://github.com/aspect-build/rules_js/blob/e67442a2ccf329841c9227d66ee013afcf5633c6/js/private/js_run_devserver.bzl).
- Test the exact pinned combination on developer and CI platforms. On 2026-10-20,
  [Vite 8 native path resolution still had an open sandbox issue](https://github.com/aspect-build/rules_js/issues/2888).
  Recheck its state before choosing a version; do not solve incompatibility by
  globally disabling sandboxing.

## Acceptance probe

Use a real consuming app: change a component and retain eligible browser state;
change CSS; edit a shared implementation then its exported type; add/delete a
file; regenerate a client; introduce a type error that still transpiles. Observe
which actions run, which checks fail and whether unrelated apps remain untouched.
Serve the built artifact and exercise a deep link plus asset loading. For SSR,
also test server startup, request handling and hydration from the packaged runtime
without workspace `node_modules`. Bundle existence alone is not browser proof.
