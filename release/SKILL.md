---
name: release
description: Publish an immutable frontend-skills release across manifests, PR, tag, GitHub, Claude, and Codex.
disable-model-invocation: true
argument-hint: "[version]"
---

# Release

Publish this repository without letting metadata, tags, or runtime caches diverge. The
version argument must resolve to an exact stable SemVer such as `4.34.0`.

## 1. Establish the release point

1. Fetch `origin/main`; require a clean worktree on a feature branch based on latest main.
2. Read commits and merged PRs since the latest `v*` tag. Write release scope from evidence.
3. Require green CI at `origin/main`; reproduce and fix any failure before version work.
4. Prove the local tag, remote tag, and GitHub release are absent. Any collision stops.
5. Confirm the request carries merge permission and publication permission. An explicit
   `/release <version>` or "cut/publish <version>" does; planning or discussing a release does not.

## 2. Prepare test-first

1. Change `evals/test-improve-release-metadata.sh` to the target version first.
2. Run it and record the expected RED release-metadata failures.
3. Update `skill-manifest.json`, both plugin manifests, both marketplaces, their dated
   changelog entries, `CHANGELOG.md`, and the README install pin together.
4. If the skill surface changed, run the hook, catalog, and AGENTS generators. Never hand-edit
   generated Codex proxies.
5. Replay the focused release metadata and packaging evals to GREEN.

## 3. Verify the package

Run the repository quality gate, package tests, full shell eval suite, behavioral hook tests,
generator drift checks, JSON parsing, and `git diff --check`. Require both real isolated CLI
installers:

```bash
bash scripts/test-claude-plugin-install.sh
bash scripts/test-codex-plugin-install.sh
```

Run `/dogfood` against both packaged skill surfaces. Visual review is skipped when the diff has
no rendered customer surface. Review the fixed-point diff for standards, value, resilience,
packaging, and immutable-release risks.

## 4. Land before tagging

1. Commit, push, and open the release PR through `/go`; include the dogfood receipt and counts.
2. Monitor every required PR check and resolve every existing review thread.
3. Merge only under the merge permission established in step 1.
4. Fetch main and wait for green main-branch CI on the merge commit.
5. Create and push annotated `v<version>` at that merge commit, never at the feature commit.

## 5. Publish and replay

1. Run `gh release create v<version> --verify-tag --latest` with scoped notes and comparison link.
2. Verify the remote tag peels to the merge commit, its tree matches released main, and the
   repository's latest release is the new tag.
3. From fresh isolated Claude configuration, add the remote marketplace, install the plugin,
   and verify its version plus the newly released skill surface.
4. From fresh isolated Codex configuration, add the remote marketplace pinned to the new tag,
   install the plugin, and verify the same. Claude and Codex fresh isolated installs must pass.
5. Upgrade the user's live installations only when requested; both clients need restart/reload.

Finish with PR and release URLs, tag/merge identity, CI results, installer evidence, and one
visible terminal status.
