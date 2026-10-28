# Release-aware upgrades

Use for Bazel upgrades, bundled-JDK trust failures or Bazel 10 migration tests.
Checked 2026-10-28 against these exact upstream releases; this is not a moving
latest-version policy. Preserve the repository pin until its upgrade is in scope.

## Choose the release line before changing flags

| Release | Upstream status | Decision |
|---|---|---|
| [9.3.1](https://github.com/bazelbuild/bazel/releases/tag/9.3.1) | Patch LTS; compatible with 9.x starting at 9.0.1 | Evaluate the same-line patch for a 9.x repository; check the 9.0.1 compatibility caveat for 9.0.0 |
| [8.8.2](https://github.com/bazelbuild/bazel/releases/tag/8.8.2) | Patch LTS; compatible with 8.0 | Evaluate the same-line patch for an 8.x repository |
| [7.7.2](https://github.com/bazelbuild/bazel/releases/tag/7.7.2) | Patch LTS; compatible with 7.0 | Evaluate the same-line patch for a 7.x repository |
| [10.0.0rc2](https://github.com/bazelbuild/bazel/releases/tag/10.0.0rc2) | Prerelease candidate for a major LTS release | Test separately; do not turn an RC into the stable default |

## Bundled JDK trust store

All four remove distrusted eMudhra and Sectigo AAA root certificates from the
bundled JDK after reported private-key leakage. Prefer an applicable same-line
patch over a major migration just to obtain this trust-store update. Inspect
`bazel info java-runtime` and startup overrides: a custom server JVM or `nojdk`
distribution needs its own trust-store assessment. The Bazel patch does not update
every action's Java toolchain or the host trust store. Exercise authenticated
repository downloads and cache/executor TLS after updating; repair certificate
chains at their owner instead of disabling verification or restoring distrusted roots.

The implementation runs `keytool` **after `jlink`** against the reduced runtime's
`lib/security/cacerts`, matching six SHA-256 certificate fingerprints rather
than trusting alias names. They identify AAA Certificate Services and the five
emSign roots G1, G2, G3 ECC, C1 and C3 ECC. Upstream adds a bundled-keystore
regression test. The backports are [9.3.1](https://github.com/bazelbuild/bazel/pull/31920),
[8.8.2](https://github.com/bazelbuild/bazel/pull/31921),
[7.7.2](https://github.com/bazelbuild/bazel/pull/31954) and
[10.0.0rc2](https://github.com/bazelbuild/bazel/pull/31925).
Custom packagers should inspect the final packaged keystore, not only the source
JDK or a successful minimization step. Actual service certificate-chain acceptance
still needs a TLS replay with the selected JVM.

## 9.3.1: four fixes, not a new feature train

The [9.3.0 to 9.3.1 comparison](https://github.com/bazelbuild/bazel/compare/9.3.0...9.3.1)
contains four fix commits plus release metadata. Besides the trust-store change:

- **Late output loss:** cached output blobs can disappear before
  `finalizeAction` materializes them. Previously this could fail with
  `unable to finalize action` even though rewinding was enabled. The prefetcher
  now reports the missing output through lost-input handling; the failed producer
  reruns without accepting the same stale disk/remote action-cache result and
  uploads regenerated outputs. Symlink actions can require rewinding their
  input producers too. This particularly affects partially retained disk caches
  after 9.3.0's trust of AC entries when rewinding is on. Upstream tests cover
  symlink-to-output and output-symlink-to-sibling cases with
  `--remote_download_toplevel` / `--remote_download_regex`, plus remote eviction.
  Replay those shapes instead of clearing every cache.
  [Fix #31902](https://github.com/bazelbuild/bazel/pull/31902),
  [disk-cache tests](https://github.com/bazelbuild/bazel/blob/9.3.1/src/test/java/com/google/devtools/build/lib/remote/DiskCacheIntegrationTest.java).
- **Aliases plus cache discard:** Skymeld with `--notrack_incremental_state` or
  `--discard_analysis_cache` could discard packages of top-level/intermediate
  aliases, retaining only the final actual target's package. Execution could then
  crash with `ALREADY_DECLARED_CHILD_MISSING`. The fix retains every alias-chain
  package and the actual package. Test a multi-package alias chain alongside a
  regular target under the repository's existing discard policy; do not globally
  disable incremental state to exercise this on ordinary builds.
  [Fix #31912](https://github.com/bazelbuild/bazel/pull/31912),
  [upstream regression](https://github.com/bazelbuild/bazel/blob/9.3.1/src/test/shell/integration/discard_analysis_cache_test.sh).
- **Lock acquisition:** failed acquisition now closes its opened file channel
  immediately and preserves close failures as suppressed exceptions. On POSIX,
  delayed garbage-collector closure of that descriptor could release a later lock
  held by the same process on the same file. This is a correctness fix, not merely
  a file-descriptor optimization. Replay contention/failure followed by later
  acquisition; never delete another process's lock as the repair.
  [Fix #31896](https://github.com/bazelbuild/bazel/pull/31896),
  [source and POSIX rationale](https://github.com/bazelbuild/bazel/blob/9.3.1/src/main/java/com/google/devtools/build/lib/util/FileSystemLock.java).

The [9.0.1 compatibility note](https://github.com/bazelbuild/bazel/releases/tag/9.0.1)
explains the 9.0.0 caveat: fixed enforcement exposes removed native `CcInfo` use
in older rulesets. Check compatible `rules_go` / `rules_nodejs` pins rather than
assuming every 9.0.0 build survives a patch unchanged.

`--rewind_lost_inputs` already defaults true in 9.3.1. The late-output fix does
not establish inclusion of rc2's separate tree-template/symlink recovery or
experimental changed-output consistency guard; check those backports explicitly.

## 8.8.2: narrowly scoped trust-store maintenance

The [8.8.1 to 8.8.2 comparison](https://github.com/bazelbuild/bazel/compare/8.8.1...8.8.2)
has the certificate-removal implementation/test commit and the release commit.
Changed files are `src/minimize_jdk.sh`, the bundled-JDK shell test and
`CHANGELOG.md`. There is no separate feature, rules API, Bzlmod migration or
9.3.1 rewind/alias/lock backport in this delta. Keep the 8.x rules/toolchain
contract while testing the packaged JDK, authenticated fetches and cache TLS.
This narrow delta is not proof that a custom JVM or every service chain is safe.

## 7.7.2: inspect the source beyond the single release-note bullet

The [tag comparison](https://github.com/bazelbuild/bazel/compare/7.7.1...7.7.2)
contains three new commits. The certificate commit also contains changes not
named by its title or the published summary:

- Bazel's own self-extracting binary assembly replaces `zip -qA` with the Java
  `adjust_sfx` tool. It recalculates central-directory/local-header offsets after
  prepending a launcher. `ZipReader` gains explicit unadjusted-SFX handling;
  ZIP64 central-directory size and end-record scanning across buffer/comment
  boundaries are corrected. Added tests cover adjusted archives, ZIP64 with
  non-overflowing ZIP32 fields, a near-buffer-boundary signature and comments.
  Review the actual [implementation commit](https://github.com/bazelbuild/bazel/commit/820b9acafc6f687f32d7e14b52cf37bcfd652299),
  not just its certificate title. For source-built/repackaged Bazel, replay
  executable extraction and these archive shapes. This does not prescribe a
  change to every consuming repository's packaging rules.
- That commit also updates Bazel's own CI/bootstrap/module-lock metadata and
  switches certain upstream shell tests to Python 3. These are not language-rule
  upgrades or a new Python requirement for every consumer action.
- A separate [release-pipeline backport #31974](https://github.com/bazelbuild/bazel/pull/31974)
  adopts `gh`, `gcloud storage` and Secret Manager handling and avoids assigning
  GitHub's Latest badge to a maintenance release. These affect upstream release
  publishing, not application BUILD semantics; do not copy its credentials or
  release infrastructure into a consumer.

7.7.1's release commit is not an ancestor of 7.7.2; its sole file is `CHANGELOG.md`.
The [reverse comparison](https://github.com/bazelbuild/bazel/compare/7.7.2...7.7.1)
therefore shows release-metadata divergence, not evidence that a runtime fix was
reverted. Check trees/commit contents before making ancestry-based rollback claims.

## Test Bazel 10 changes in an opt-in configuration

For a major upgrade, read [Bazel 10 migration and capabilities](bazel-10-migration.md).
For an existing candidate deployment, read the separate
[rc1 to rc2 source-level changes](bazel-10-rc2.md). The cumulative major-release
notes and the candidate-to-candidate diff answer different questions.

Prioritize explicit source exports/test-only edges, exec-setting propagation,
strict lock/vendor closure, platform selection, host tool/locale assumptions and
cache-output correctness. Then evaluate new rule/query/coverage APIs and backend
capabilities. The major guide records exact 9.3.1 versus rc2 defaults; the rc2
guide covers repository materialization, connection-pool recovery, ECDSA mTLS,
the off-by-default rewind consistency guard and smaller correctness fixes.

Before adopting either a patch or the RC, run the repository's generator/lock
checks, affected tests, supported platform matrix and packaged-runtime probes.
For a major upgrade, compare configured actions and developer workflows using
[migration parity](migrations.md). Report exact versions, executed versus cached
tests and skipped legs; these release notes are not workload validation or a
security certification.
