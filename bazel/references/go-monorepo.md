# Go monorepos: generator ownership and selective adoption

Use when the checkout has Go modules, Task wrappers and Gazelle-owned BUILD files.
Revalidate the commands below against `Taskfile.yml`, task includes, root BUILD,
`MODULE.bazel` and the current Bazel-development guide before execution.

## Discover the supported lane

In the surveyed tree, root Bazel serves a local Tilt environment and one imported
Go/Rust application. Other Go tests and image publishing still use their existing
Go/ko pipeline. A repository-wide BUILD inventory is not a migration mandate.

Read `docs/bazel-local.md` when present. Follow the current owning task for ordinary
Go verification; use Bazel where the requested target belongs to that lane. Do not
add shadow CI, mode switches, fleet-wide checks or replace image builders merely
to repair a local Bazel build.

## Keep generated graph and module metadata together

The observed explicit tasks are:

```bash
./taskw gazelle
./taskw buildifier
./taskw buildifier MODE=check
```

The Gazelle task regenerates BUILD files and runs `bazel mod tidy` with lock
updates. Root Go SDK/dependency extensions read `go.mod`; update Go dependencies
there, not in a second hand-maintained Bazel dependency inventory. Let tidy
reconcile extension `use_repo` declarations; inspect that and the lockfile diff.

Automatic hooks in `generate` and `fmt` are **best effort** for Bazel tooling;
`SKIP_BAZEL=true` skips them, and ordinary Go CI uses that escape hatch. The
explicit Bazel tasks are strict. Therefore a green generic generator, formatter
or Go CI job does not prove BUILD freshness. Run the explicit checks for a Bazel
change and retain any installation/resolution error as a verification limit.

Inspect root Gazelle directives before touching generated Go/proto rules. The
surveyed tree disables Gazelle proto generation because the existing proto
pipeline owns generated Go. Its external Go dependency configuration regenerates
upstream BUILD metadata to avoid unresolved upstream labels. Preserve those
ownership choices; do not add a second proto generator or patch every generated
dependency label by hand.

## Preserve mixed-language and local-development inputs

- Inspect the imported application's root-relative labels and wrapper. Its image
  includes a Rust guest binary and a root filesystem; a passing Go test or plain
  Go binary build is insufficient image verification.
- Read Tilt's compile resource before changing its generator/build order. It
  batches binaries for live updates; image rebuilds and binary synchronization
  are distinct paths. Preserve its explicit local-cluster context guard.
- Use the install task for Bazelisk and declared sandbox writable directories.
  A missing toolchain cache directory can fail every sandboxed action before
  application compilation. Create the declared directory through that task,
  not by making arbitrary host paths writable.
- Preserve digest-pinned base images and release-specific Rust settings when
  changing images. Inspect separate build, local image-load and publish targets;
  do not execute the publisher just to verify compilation.

## Verification boundary

For Go dependency/source changes that affect Bazel: run strict regeneration,
check for unexpected graph churn, run buildifier check, then the owning Bazel
build/test. Retain the existing non-Bazel Go check when that is also a supported
consumer. For image inputs, build the image/rootfs target without publishing.

Local disk-cache policy and CI setup differ. Read the **current** setup action;
remote-cache/lockfile-enforcement rollout experiments were removed from the
surveyed mainline scope before merge. Do not resurrect them from commit messages.
