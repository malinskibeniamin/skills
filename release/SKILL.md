---
name: release
description: Publish an immutable frontend-skills release across manifests, PR, tag, GitHub, Claude, and Codex.
disable-model-invocation: true
argument-hint: "[version]"
---

Publish without metadata, tags, or caches diverging. Version must be exact stable SemVer such as `4.34.0`.

## 1. Establish

1. Fetch `origin/main`; require a clean worktree on a feature branch based on latest main.
2. Derive scope from commits/merged PRs since latest `v*` tag.
3. Require green `origin/main` CI; reproduce/fix failures before versioning.
4. Prove local tag, remote tag, GitHub release absent; collision stops.
5. Require merge and publication permission. `/release <version>` or `cut/publish <version>` grants it; discussion does not.

## 2. Prepare test-first

1. First change `evals/test-improve-release-metadata.sh`; record expected RED metadata failures.
2. Update `skill-manifest.json`, plugin manifests, both marketplaces, dated changelogs, `CHANGELOG.md`, README pin together.
3. For skill-surface changes run hook/catalog/AGENTS generators; never hand-edit generated Codex proxies.
4. Freeze docs with `bun run docs:version v<version>`; commit new snapshot and `versions.archived`, never edit old snapshots.
5. Replay release metadata/packaging evals GREEN.

## 3. Verify

Run quality gate, package tests, full shell evals, hook behavior, generator drift, JSON parsing, `git diff --check`, and real isolated installers:

```bash
bash scripts/test-claude-plugin-install.sh
bash scripts/test-codex-plugin-install.sh
```

Run `/dogfood` on both packaged surfaces; skip visual review only without rendered customer surface. Review fixed-point diff for standards, value, resilience, packaging, immutable-release risk.

## 4. Land then tag

1. Commit/push/open release PR through `/go`; include dogfood receipt/counts.
2. Resolve all checks and existing review threads.
3. Merge only with established merge permission.
4. Fetch main; require green main CI at merge commit.
5. Create/push annotated `v<version>` at merge commit, never feature commit.

## 5. Publish/replay

1. `gh release create v<version> --verify-tag --latest` with scoped notes/comparison.
2. Verify remote tag peels to merge commit, tree equals released main, and latest release is new tag.
3. From fresh isolated Claude config: add remote marketplace, install, verify version/new skill surface.
4. From fresh isolated Codex config: add marketplace pinned to tag, install, verify same. Both must pass.
5. Upgrade live installs only when requested; clients require restart/reload.

Report PR/release URLs, tag/merge identity, CI, installer evidence, and one visible terminal status.
