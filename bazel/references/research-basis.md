# Research basis and refresh

Snapshot: 2026-10-19. Window: 2025-10-19T12:44:37Z through
2026-10-19T12:44:37Z. Two private monorepositories were examined with authenticated
Git/GitHub access. This distributed summary omits private identities, source
excerpts, endpoints, reviewer identities and private links.

## Evidence to instruction

| Observed source/history | Instruction it motivates |
|---|---|
| Go tree: 135 reachable non-merge commits touching Bazel-path files; 42 first-parent changes; 1,350 current BUILD files | BUILD coverage and imported history do not establish mainline adoption or CI ownership |
| Go predecessor history starts in February; mainline imports its application in October; root consolidation follows in October | Distinguish predecessor chronology from adoption; preserve one root and current root-relative labels |
| Root Go generator runs Gazelle then module tidy; automatic hooks warn/skip, explicit tasks fail | Use strict tasks to verify Bazel freshness, not generic generator/CI success |
| Proposed broad Go CI/cache rollout removed before the merged local-development change | Verify the merged end state; do not restore superseded intermediate plans |
| C++ tree: 2,729 reachable non-merge Bazel-path commits; 80 first-parent changes; 600 current BUILD files | Imported component activity is not a year of operation of the new monorepo |
| C++ predecessor history reaches July; October imports consolidate component modules/toolchains | Read root configuration and component macros together; standalone rules can be obsolete |
| C++ CI policy encoded in graph metadata alongside always-run sanitizer/release tiers | Preserve graph-driven integration selection and its platform/presubmit boundaries |
| Stamping split from test configs; remote outputs changed to lazy materialization | Preserve cacheable test identities while explicitly materializing direct output consumers |
| Sanitizer fail-on-report fix and shared compile-input/editor aspect | Verify exit behavior and declared runtime inputs; analysis alone creates no editor inputs |

Counts include imported reachable history and all authors. Bazel-path means
`BUILD`, `BUILD.bazel`, `.bzl`, `MODULE.bazel*` and `.bazel*` files; it is not all
CI/tooling activity. First-parent counts include merges, reachable counts exclude
merges. These are code-change inventories, not execution telemetry, personal
usage, benchmark results or proof of runtime savings. No Bazel workloads were
executed for this documentation task. Available histories do not establish a
full year of mainline Bazel operation in either repository.

## Refresh against the checkout

Follow current module/rc -> wrapper/macro -> workflow/selector -> adjacent tests.
Use merged PR diffs to resolve rollout or import scope, and compare first-parent
history with imported ancestry before making chronological claims. Re-measure
performance before claiming a speedup. Private audit artifacts are not runtime
dependencies of this skill.

Public API references, checked during the audit:

- [Configured versus unconfigured queries](https://bazel.build/query/cquery)
- [Action graph queries](https://bazel.build/query/aquery)
- [Bzlmod lockfile modes](https://bazel.build/external/lockfile)
- [Remote caching and upload policy](https://bazel.build/remote/caching)

## Public frontend and scale extension

The original private-history review above covers Go/C++ usage, not frontend
adoption. A separate public-source review on the same date informs the
[TypeScript/React profile](typescript-react.md), [scale design](monorepo-scale.md)
and [pinned example assessment](community-examples.md). Those recommendations are
source-informed proposals, not findings that the private repositories run that
frontend stack or demonstrated speedups. No community examples or selector tools
were executed during this documentation review.

A public-source follow-up on 2026-10-20 added CockroachDB's native watcher
handoff, refreshed BuildBuddy's source snapshot, and compared first-party
Canva/Wix/Airbnb/Dropbox/Uber retrospectives. It informs migration sequencing,
selection cost and release-test ownership, not the original private audit window
or evidence of measured performance. The [example assessment](community-examples.md)
distinguishes production source, historical accounts and maintainer fixtures.

The same day's [tool-fit comparison](tool-fit.md) examined Nx, Turborepo, Buck2,
Pants, Please and moon documentation, plus pinned Grafana/TypeSpec/Cal.diy source.
It separates task-aware selection, cache units, remote execution and frontend
workflow maturity. Live-document opt-ins need installed-version verification;
none was adopted or benchmarked here. This does not expand the private-history
window or make a comparative speed claim.
The final refresh rechecked rules_js v3.5.1 and rules_ts v3.10.1 as the latest
published releases and confirmed the Vite 8 sandbox issue remained open. These
observations do not establish compatibility of an untested compiler/bundler pair.

## BazelCon 2026 follow-up

Public-source refresh: 2026-10-24. The supplied [Julio Merino recap](https://jmmv.dev/2026/10/bazelcon-2026-recap.html)
motivates the questions below; it is an attendee's account, not a release contract.
Primary documentation/source supplies the operational guidance:

- [actiond README](https://github.com/hermeticbuild/actiond/blob/5a0335c607a367f02f2dfcea380799e3bcbac767/README.md)
  and [architecture](https://github.com/hermeticbuild/actiond/blob/5a0335c607a367f02f2dfcea380799e3bcbac767/ARCHITECTURE.md):
  local Linux REAPI execution, lazy actiondfs inputs, client settings and platform
  limits inform [local execution](local-execution.md). The snapshot already covers
  more hosts than the recap's macOS example; recheck release support before use.
- [Bazel configurations](https://bazel.build/extending/config#memory-and-performance-considerations)
  and [memory trade-offs](https://bazel.build/advanced/performance/memory) inform
  configured-graph and concurrent-worktree guidance in [scale](monorepo-scale.md).
- [Bazel 9.1.1 release notes](https://github.com/bazelbuild/bazel/releases/tag/9.1.1)
  and [NativeLink CDC requirements](https://docs.nativelink.com/how-to/stores/chunking-and-dedup)
  qualify the recap's chunking recommendation with patch-level integrity checks.
- [any2bazel source](https://github.com/EngFlow/any2bazel/blob/c1ca1b4e3583f5321934a25dae84af954c6a021c/README.md)
  informs [action equivalence](migrations.md), including the inspected tool's
  codegen/custom-command/packaging exclusions.

Rust rewrite plans, JVM checkpointing, persistent test-runner prototypes and
competing Starlark typing systems are leads to revalidate, not defaults to
enable. Published Bazel 10 candidate APIs are covered by the later release refresh
below, not inferred from conference plans. This refresh did not run actiond,
migrate a build, benchmark Bazel or establish a security guarantee.
Published performance numbers remain specific
to their authors' workloads; the private-history window above is unchanged.

## Release refresh

Public-source refresh: 2026-10-28. The [release guidance](releases.md) uses the
upstream 10.0.0rc2, 9.3.1, 8.8.2 and 7.7.2 release notes and GitHub prerelease
metadata. It separates same-line bundled-JDK trust-store patches from opt-in
Bazel 10 migration, including changed defaults, Bzlmod closure and execution
platform checks. This does not expand the private-history audit window, establish
consumer compatibility or claim measured performance or complete security coverage.
