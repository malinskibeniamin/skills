# tstack skill snapshot

All nine skills, every skill-local helper and agent metadata, README and MIT
license are copied unchanged from [t3dotgg/tstack at 7de017b3](https://github.com/t3dotgg/tstack/tree/7de017b3fc9d50c03cf3ecb98fb71e0ca65a78bd).
The [lock](tstack.lock.json) records the full revision, source paths, SHA-256
digests, executable modes and host registration for each skill.
Retain the [MIT license](tstack/LICENSE), copyright 2026 Theo Browne.

The [compatibility contract](../shared/TSTACK.md) owns local adaptations.
Eight adapters extend discovery in Claude and Codex; the ninth skill composes
the existing `full-send` owner. This snapshot supersedes the earlier absence of
canonical tstack sources, not the host's permissions or delivery endpoints.
It does not install reviewers, watchers, credentials or a T3 runtime.

## Refresh

Use a separate upstream Git checkout containing the reviewed full commit. The
importer reads committed objects, never dirty working-tree bytes. Review new
instructions, dependencies and license changes before selecting another pin.
Unknown or missing skills fail before writes; modified managed output blocks
refresh rather than erasing local work.

```sh
python3 scripts/vendor-tstack.py \
  --source /path/to/tstack \
  --revision 7de017b3fc9d50c03cf3ecb98fb71e0ca65a78bd
bash scripts/generate-skill-catalog.sh
bash scripts/generate-hook-configs.sh
python3 scripts/vendor-tstack.py --check
bash evals/run.sh tstack-vendored-skills
bash evals/run.sh packaging-integrity
bun run lint:fix
bun run type:check
```

A repeated import at the same pin must be byte- and mode-identical. The importer
owns `vendor/tstack`, its lock, eight `tstack-skills` adapters and their Claude
registrations. Catalog generation owns Codex proxies/metadata and router discovery;
hook-config generation owns derived manifest counts. Keep host composition and
this notice outside the immutable snapshot.

The `pr-wait` helper is an opt-in POSIX event watcher, not a merge/readiness gate;
its limitations and native T3 watcher preference live in compatibility. Import
integrity and deterministic prompt checks do not prove model adherence or review
quality. No performance or reviewer-accuracy improvement is claimed.
