# Bazel 10.0.0rc2: what changed after rc1

Use when choosing between candidate pins or diagnosing regressions in experimental
repository caching, action rewinding, toolchain changes or remote connections.
The [exact tag comparison](https://github.com/bazelbuild/bazel/compare/10.0.0rc1...10.0.0rc2)
contains 27 commits: 26 implementation/test changes and one release-module/pin
update. rc1 is `649a7bed0cfa`; rc2 is `e6042f9c2260`. The release page's
`Baseline` identifies rc1, but its body is cumulative major-line documentation,
not a complete rc2 changelog. Many candidate fixes have `RELNOTES: None`.

Read [major-line migration](bazel-10-migration.md) for default flips, API additions
and removals. The source-derived changes below do not establish consumer
compatibility or justify treating a prerelease as stable.

## Rewinding is not a determinism guarantee

rc2 introduces `--experimental_check_rewound_action_outputs`, **off by default**.
If regeneration changes retained output contents, Bazel can fail with
`REWOUND_ACTION_OUTPUT_CHANGED` rather than silently allowing inconsistent
consumers. It checks lost and sibling files, tree membership/content and symlink
metadata. Storage-location changes alone do not count as content changes.
[Backport and limitations](https://github.com/bazelbuild/bazel/pull/31814),
[tagged comparison implementation](https://github.com/bazelbuild/bazel/blob/10.0.0rc2/src/main/java/com/google/devtools/build/lib/skyframe/RewoundActionOutputChecker.java).

This is best-effort detection, not repair or a hermeticity/security guarantee:

- It needs previous action-output metadata. Rich artifact data, digestless
  contents and some shared-action ownership cases are outside its coverage.
- It does not roll back filesystem writes/cache publication or invalidate all
  completed consumers. An upstream regeneration can also change downstream inputs.
- It does not change the trigger for rewinding, retry policy or circuit breaker.
  First remove nondeterministic/undeclared inputs from the owning action.

Use an opt-in diagnostic configuration and an owned eviction reproduction.
Require unchanged outputs to keep passing and a controlled changed-output case
to fail before relying on the guard. Merely accepting the flag is not that proof.

Other rc2 rewind fixes repair distinct failure modes:

| Change | Prior failure | Targeted replay |
|---|---|---|
| [Shared-download attribution #31689](https://github.com/bazelbuild/bazel/pull/31689) | Different symlink inputs sharing one download received the first caller's lost-input identity, preventing recovery for other callers | Evict one shared blob and read it through different action inputs |
| [Shared-action synchronization #31667](https://github.com/bazelbuild/bazel/pull/31667) | Owner-keyed locks failed to protect equivalent actions' shared outputs during regeneration/uploads | Concurrent consumers of the same generated output under different owners |
| [Tree-template symlinks #31865](https://github.com/bazelbuild/bazel/pull/31865) | Rewinding a symlink/template without its expansion actions repeatedly failed to recreate a lost child | Symlink to a tree produced by `ctx.actions.map_directory`, then evict a child |

These changes do not prove that 9.3.1's related symlink-output patch includes
every template/shared-action fix. Verify backports individually.

## Repository materialization and fetch lifecycle

Most of these concern the experimental remote repository-contents cache, not
ordinary action-cache hits. Use the repository-cache flag/config actually under
evaluation and keep cache eligibility, host keys and symlink restrictions intact.

| rc2 change | Operational consequence and verification |
|---|---|
| [LF-only input-batch splitting #31643](https://github.com/bazelbuild/bazel/pull/31643) | Carriage returns in recorded input names no longer create phantom inputs/refetch growth; test exact input bytes, not just printable names |
| [FileValue dependency #31670](https://github.com/bazelbuild/bazel/pull/31670) | Corrects invalidation of newly cached repo directories; replay cache deletion/recreation between commands |
| [Release only held locks #31675](https://github.com/bazelbuild/bazel/pull/31675) | Rejecting an invalid cache path before acquisition no longer causes an internal crash during teardown; verify the original error remains visible |
| [Atomic marker files #31635](https://github.com/bazelbuild/bazel/pull/31635) | An interrupted marker write cannot leave an accepted prefix omitting recorded inputs; avoid interpreting partial on-disk metadata as freshness |
| [Clean failed optional downloads #31640](https://github.com/bazelbuild/bazel/pull/31640) | `download_and_extract(allow_fail=True)` removes random temporary directories before returning failure; deterministic fallback contents stay reproducible |
| [Reuse valid local files #31682](https://github.com/bazelbuild/bazel/pull/31682) | A correctly downloaded cached-repo file can be read locally even after remote loss/transport failure; confirm expected bytes rather than refetching reflexively |
| [Top-level source materialization #31638](https://github.com/bazelbuild/bazel/pull/31638) | `bazel run` of a remotely cached source executable works without merged analysis/execution; build success alone previously left the executable absent |
| [Directory-symlink prefetch #31822](https://github.com/bazelbuild/bazel/pull/31822) | Prefetch creates resolved files and reproduces parent symlinks instead of replacing them with directories; replay partial then whole-repo materialization |
| [Native multi-file patches #31668](https://github.com/bazelbuild/bazel/pull/31668) | A new `---` file header after a completed hunk now starts the next patch without requiring `diff --git` separators; verify every patched file even when the command reports success |

The optional-download fix preserves explicit, rule-owned fallback behavior; it is
not permission to suppress required fetch/authentication failures.

## Connections, TLS and long-lived servers

| rc2 change | Failure addressed | Verification boundary |
|---|---|---|
| [HTTP cancellation #31664](https://github.com/bazelbuild/bazel/pull/31664) | A cancelled request queued for a connection could later send an unwanted download | Cancel under a bounded connection pool, then prove a live caller can use the released connection |
| [Queued channel interruption #31634](https://github.com/bazelbuild/bazel/pull/31634) | Interrupted waiters left active subscriptions/callbacks | Interrupt a queued gRPC caller and replay another request |
| [Connection permits #31629](https://github.com/bazelbuild/bazel/pull/31629) | Cancellation/concurrent close races could permanently lose pool permits | Repeat cancellation/reconnection on the same server, not fresh processes alone |
| [ECDSA client certificates #31799](https://github.com/bazelbuild/bazel/pull/31799) | The tcnative/JDK key-manager boundary rejected valid ECDSA-CA-signed client certificates | Test actual mTLS with the certificate chain; do not disable JDK certificate checking as the fix |
| [Output-checker retention #31761](https://github.com/bazelbuild/bazel/pull/31761) | Each command retained all earlier output-checker download sets | Measure repeated-command heap on one long-lived server, not a single batch invocation |
| [Bundled CA removal #31925](https://github.com/bazelbuild/bazel/pull/31925) | Bundled JDK still trusted the six distrusted certificates | Apply the [shared trust-store checks](releases.md#bundled-jdk-trust-store) to the selected server JVM |

The ECDSA fix updates `netty-tcnative` from 2.0.70.Final to 2.0.84.Final. It is
separate from removing distrusted trust anchors; neither implies arbitrary TLS
configurations are validated. Preserve authentication and hostname verification.

## Analysis, query and rule correctness

| rc2 change | Consequence and targeted replay |
|---|---|
| [Provider equality #31626](https://github.com/bazelbuild/bazel/pull/31626) | Changes to constraint defaults/refinement or `use_target_platform_constraints` now invalidate toolchain resolution correctly; edit those fields between commands |
| [Reverse-dependency cleanup #31749](https://github.com/bazelbuild/bazel/pull/31749) | Removes repeated scans when deleting reverse deps; measure large graph deletion/GC rather than promising a general build speedup |
| [Filtered parallel graph walks #31684](https://github.com/bazelbuild/bazel/pull/31684) | Avoids whole-graph value unwrapping/locking for selected node types and restores changed-file scan cost; compare the same no-op/edit/query scenarios |
| [genquery errors #31818](https://github.com/bazelbuild/bazel/pull/31818) | `--keep_going` now reports failing extension/strict-lock scope errors instead of crashing; failure must remain failure |
| [Unicode cquery proto #31756](https://github.com/bazelbuild/bazel/pull/31756) | `configured_rule_input` labels stop being double-encoded; test non-ASCII labels in graph/impact tooling |
| [Slash-named platforms #31707](https://github.com/bazelbuild/bazel/pull/31707) | Legacy output naming replaces `/` with `_` instead of rejecting the platform; names are still not globally unique configuration identities |
| [Custom genrule names #31698](https://github.com/bazelbuild/bazel/pull/31698) | A Starlark rule exported as `genrule` no longer triggers native-only `output_to_bindir` access and an internal crash |
| [Release metadata #31977](https://github.com/bazelbuild/bazel/pull/31977) | Sets Bazel's own module version to `10.0.0`, refreshes lock metadata and changes its bootstrap `.bazelversion` from 9.2.0 to 9.3.1; neither that module version nor bootstrap pin changes the artifact's RC status or selects a consumer's version |

## Evidence and limits

The research inspected all 27 commit messages and the changed source/tests for
the material contracts above, not only release prose. Exact-version behavioral
probes are recorded in [research basis](research-basis.md#release-refresh).
Source/test inspection is not an execution result: the remote repo-cache,
concurrent rewind, ECDSA-mTLS and long-lived heap scenarios still require the
consumer's backend and workload. No upstream performance number is adopted as a
local speedup, and this reference is not an independent security audit.
