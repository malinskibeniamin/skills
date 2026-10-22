# Software factory source and adaptations

The local `/software-factory` is a planning adapter over Matt Pocock's **draft**
[PR #1316](https://github.com/mattpocock/skills/pull/1316), reviewed 2026-10-22 at
[`b59cab42bf1206e1363eafc37f71b21c3bcaa12f`](https://github.com/mattpocock/skills/tree/b59cab42bf1206e1363eafc37f71b21c3bcaa12f/skills/in-progress/software-factory).
At that check the skill was in `skills/in-progress/`, absent from upstream `main`
(`5beb35b040e3de97e54fa9e386d7e42d15c295c2`) and excluded from upstream plugin registration.
This local opt-in integration is not an upstream release or endorsement.

## Source and local ownership

[The complete source](mattpocock/software-factory/SKILL.md), its five local references,
and upstream [MIT license](mattpocock/software-factory/LICENSE) are copied byte-for-byte.
SHA-256 digests are enforced in [the focused eval](../evals/test-software-factory.sh).
The snapshot is reference material, not a runnable checkout; file modes are `0644`.

Local [instructions](../software-factory/SKILL.md) preserve the requested endpoint and
explicit authorization boundaries; add a fit decision and bounded pilot; and distinguish
interactive T3 worktrees from remote disposable runners. The local
[orchestrator survey](../software-factory/ORCHESTRATORS.md) fills a requested slot not
surveyed upstream. [Harness fit](../software-factory/HARNESS-FIT.md) records local evidence
and unknown value. No hooks, permissions, runtime, scheduler, or model routing changes.

Upstream surveys are dated orientation. Their prices, preview statuses, product claims,
and security recommendations have **not** all been independently verified here. In
particular, recheck token event suppression exceptions and runner isolation rather than
treating the snapshot's summaries as guarantees. Read current primary documentation for
the selected candidate before recommending expenditure or writing infrastructure.

## Refresh

Resolve and review one full upstream SHA, including every skill-local dependency and
license. Check PR/merge status separately; do not silently follow the moving draft branch.
From the repository root, reproduce the current import with:

```sh
sha=b59cab42bf1206e1363eafc37f71b21c3bcaa12f
target=vendor/mattpocock/software-factory
mkdir -p "$target"
for file in SKILL.md EXAMPLE-TASKS.md GIT-HOSTS.md TICKET-TRACKERS.md RUNNERS.md OBSERVABILITY-PLATFORMS.md; do
  gh api "repos/mattpocock/skills/contents/skills/in-progress/software-factory/$file?ref=$sha" \
    -H 'Accept: application/vnd.github.raw+json' > "$target/$file" || exit 1
done
gh api "repos/mattpocock/skills/contents/LICENSE?ref=$sha" \
  -H 'Accept: application/vnd.github.raw+json' > "$target/LICENSE" || exit 1
chmod 644 "$target"/*
```

Inspect the complete diff, reconcile new/removed dependencies, verify upstream bytes
independently, and update the pin and digest assertions together. Keep all adaptations
outside the snapshot. Regenerate discovery with `bash scripts/generate-skill-catalog.sh`;
run its `--check`, `bash evals/run.sh software-factory`, packaging-integrity, and
skill-md-hygiene evals, plus `bun run lint:fix` and `bun run type:check`.
