# Source and refresh

Adapted from [caldoai/skills, untangle-codebase](https://github.com/caldoai/skills/blob/f3cf47774975a7d9fca45730babf4ff7ad765ada/skills/untangle-codebase/SKILL.md)
at commit `f3cf47774975a7d9fca45730babf4ff7ad765ada`.
Copyright (c) 2026 Maze; the [MIT license](../vendor/caldoai/LICENSE) is retained.
The complete skill (one file, no local companions) and license are copied unchanged
under `vendor/caldoai/`. The [lock](../vendor/caldoai.lock.json) records repository,
revision, Git blob SHA, SHA-256 and mode for each file.

Only the local [adaptation](SKILL.md) is registered. It retains the change-together
diagnosis and root-cause redesign while preserving host consent, scope, behavior and
delivery rules. Optional comment/test pruning remains opt-in; unspecified choices do
not block structural work. It makes no upstream productivity claims. Codex discovery
and the router catalog come from `scripts/generate-skill-catalog.sh`.

## Refresh

Review a new immutable commit, license and complete skill-local inventory first.
From a separate upstream clone, extract the reviewed committed blobs, not working-tree
edits (replace the SHA only after review):

```sh
git -C /tmp/caldoai-skills archive f3cf47774975a7d9fca45730babf4ff7ad765ada \
  LICENSE skills/untangle-codebase | tar -x -C "$HARNESS_ROOT/vendor/caldoai"
```

Reconcile removed/new files with `git ls-tree -r <sha> -- LICENSE skills/untangle-codebase`;
keep every skill-local companion and its mode. Rebuild the lock's `files` records using
those blob IDs/modes and `hashlib.sha256(path.read_bytes()).hexdigest()`. Update the lock
revision, this source pointer and the pinned digests in `evals/test-untangle-codebase.sh`.
Keep local adaptations outside the snapshot; import runs no upstream code or hooks.

Run `bash scripts/generate-skill-catalog.sh`, then
`bash evals/run.sh untangle-codebase` and the repository lint/type checks.
Re-extracting the same commit and regenerating discovery must produce no diff.
These checks prove source/discovery/prompt integrity, not model adherence or refactor quality.
