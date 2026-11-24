---
name: release
description: Publish an immutable frontend-skills release across manifests, PR, tag, GitHub, Claude, and Codex.
disable-model-invocation: true
argument-hint: "[version]"
---

Green merges publish automatically. Use this [recovery procedure](../README.md#releases-and-automatic-updates) only when the publisher is idle. Use exact stable SemVer, e.g. `4.34.0`.

## 1. Establish

1. Fetch `origin/main`; use a clean worktree on a branch based on it.
2. Derive scope from commits/merged PRs since latest `v*` tag.
3. Require green `origin/main` CI; reproduce/fix failures before versioning.
4. Stop on collision with any local/remote tag or GitHub release.
5. Require merge/publication permission (e.g. `/release <version>` or `cut/publish <version>`, not discussion).

## 2. Prepare test-first

1. Record RED release metadata failures with `python3 scripts/release-version.py check`.
2. Run `python3 scripts/release-version.py prepare --version <version> --note "<note>"` to update
   `skill-manifest.json`, plugin manifests, both marketplaces, changelogs and README pin together.
3. For skill-surface changes run hook/catalog/AGENTS generators; never hand-edit generated Codex proxies.
4. Keep live docs on `main` only.
5. Replay release metadata/packaging evals GREEN.

## 3. Verify

Run quality gate, package tests, full shell evals, hook behavior, generator drift, JSON parsing, `git diff --check`, and real isolated installers:

```bash
bash scripts/test-claude-plugin-install.sh
bash scripts/test-codex-plugin-install.sh
```

Dogfood both packages; visually review rendered surfaces. Review the final diff for standards, value, resilience, packaging and immutability.

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

Documentation archives are opt-in. Only on explicit user request, run
`bun run docs:version v<version>`, commit the snapshot and `versions.archived`,
and update archive evals. Preserve published snapshots.

Report PR/release URLs, tag/merge identity, CI, installer evidence, and one visible terminal status.
