# Migrate an existing build

Use when introducing Bazel beside another build, consolidating repositories or
changing target granularity. Preserve observable build/runtime behavior before
optimizing the graph. This is migration guidance, not permission to change the
application's framework, dependencies or deployment infrastructure.
When the build-system choice is still open, read [tool fit](tool-fit.md) first;
app count or a faster core engine alone does not justify replacing the owner.

## Establish parity before increasing granularity

- Inventory what the existing build compiles, tests, generates and packages.
  Record dependency versions, runtime resources, platform variants, configuration,
  editor inputs and the current deployment/test contract. Match those semantics
  first; a successful compile covers only part of the migration.
- Prove a representative app/service with its owners: build, typecheck where
  relevant, tests, local development, packaged startup and the existing release
  checks. A faster compiler does not compensate for a broken editor or watcher.
- Keep initial compilation boundaries close to the working build. Split expensive
  units after parity, using measured invalidation and critical-path evidence.
  A target per source file is not the migration goal. Preserve dependency versions
  before combining the migration with upgrades or dependency cleanup.

[Airbnb's JVM migration](https://airbnb.tech/infrastructure/migrating-airbnbs-jvm-monorepo-to-bazel/)
used generated BUILD files and remote execution, but found that finer granularity
during migration complicated configuration and deployable parity. Its retrospective
recommends preserving the old behavior before optimizing. Adapt the lesson to the
language and runtime; this is not a prescribed JVM recipe for every repository.

## Compare actions without mistaking them for runtime parity

For automated migrations, capture the reference build's compile/link actions once
per source revision and configuration, then compare Bazel `aquery` output in a
deterministic loop. Check tools, flags, inputs, link behavior and outputs;
normalize only understood semantic differences and keep suppressions reviewable.
Equivalent action descriptions are useful evidence, not proof of packaged runtime
behavior, hermeticity or maintainable graph design.

[any2bazel's pinned action-diff approach](https://github.com/EngFlow/any2bazel/blob/c1ca1b4e3583f5321934a25dae84af954c6a021c/README.md)
illustrates this loop. Its inspected MVP excludes codegen, custom commands and
packaging; verify frontend coverage instead of treating a zero diff as complete
migration. Review generated configuration dimensions and oversized shell actions
before adoption. Fix host dependencies in the reference build rather than copying
them into Bazel. Keep runtime/release probes below as the cutover contract.

## Give parallel builds an owner and an exit

If both builds must coexist, name the authoritative dependency metadata and the
generator that keeps the second graph current. Run its drift check in CI. Cache
generator indexes only with their source revision/configuration, then refresh the
changed scope rather than trusting an unversioned index. Plan how long coexistence
is needed and what evidence permits cutover; do not create two independently
maintained manifests as a default integration strategy.

Preserve an existing, tested fallback during migration where it is justified by
the repository's operational policy. A fallback must run the same required checks
and expose its use; cache/executor failure is not successful validation.

## Verify the delivered runtime, then cut over

Run the packaged artifact without undeclared source-tree files or workspace
dependencies. Exercise startup, generated schemas/clients, dynamic imports or
reflection, plugins, config-loaded resources and representative requests where
the application uses them. Import-based BUILD generation cannot infer every
runtime dependency. Compare the old and new artifact behavior; require byte
identity only when the release contract needs it.

Cut over after the existing CI/release matrix and developer workflows pass.
Retire the old graph deliberately, then optimize granularity, cache behavior and
execution placement against measured workloads. Keep publication/deployment
authorization separate from building a replacement artifact.
