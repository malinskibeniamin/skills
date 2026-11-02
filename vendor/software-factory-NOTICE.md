# Software factory source and adaptations

The local `/software-factory` is a planning adapter over Matt Pocock's merged,
in-progress [PR #1316](https://github.com/mattpocock/skills/pull/1316), reviewed at
[`4ae2317ddb22b046e26455e4f9c9b3aaaf62212d`](https://github.com/mattpocock/skills/tree/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/in-progress/software-factory).
The source remains in `skills/in-progress/`; merging it is not a stable-release
endorsement. It supersedes the previously separate draft pin `b59cab42bf1206e1363eafc37f71b21c3bcaa12f`.

## Source and local ownership

[The complete source](mattpocock/upstream/skills/in-progress/software-factory/SKILL.md)
and its five references share [the full-suite lock](mattpocock.lock.json), which
records their immutable revision, SHA-256 digests and executable modes. The upstream
[MIT license](mattpocock/upstream/LICENSE) applies. Both `/software-factory` and explicit-only `/matt-software-factory` reach the same
current source through the existing owner. The frozen draft in
`mattpocock/software-factory/` remains only for published versioned-document links;
it is not the active planning source. Its original MIT license and bytes stay intact.

Local [instructions](../software-factory/SKILL.md) preserve the requested endpoint
and authorization boundaries; add a fit assessment and bounded pilot; and distinguish
interactive T3 worktrees from remote disposable runners. The local
[orchestrator survey](../software-factory/ORCHESTRATORS.md) fills a slot not surveyed
upstream. [Harness fit](../software-factory/HARNESS-FIT.md) records evidence and
unknown value. This import changes no hooks, permissions, runtime, scheduler or
model routing and starts no factory.

Upstream surveys are dated orientation, not verified current prices, features or
security guarantees. Read current primary documentation before recommending
expenditure or writing infrastructure; verify event suppression and runner isolation.

## Refresh

Use the complete-suite importer described in [Matt provenance](mattpocock-NOTICE.md):

```sh
python3 scripts/vendor-mattpocock.py --source /path/to/upstream --revision <reviewed-full-sha>
bash scripts/generate-skill-catalog.sh
python3 scripts/vendor-mattpocock.py --check
bash evals/run.sh matt-refresh
bash evals/run.sh software-factory
```

Review every source/reference/license change, reconcile the local planning owner,
and regenerate discovery rather than editing managed adapters. The factory eval
checks current owner routing, complete resources, lock digests/modes and routing
away from the superseded snapshot. Run packaging and Markdown checks, `bun run lint:fix`
and `bun run type:check` before delivery.
