# REA skill snapshot

The published `rea-agents@6.8.0` npm archive supplies the unchanged
`skills/reverse-engineer-anything/` tree, including all seven reference guides,
plus its original LICENSE and package.json. Those 10 files
are reference material, not an installed REA runtime. No executable runtime,
native engine, upstream plugin manifest, root agent instruction or setup script
is vendored. Copyright (c) 2026 morluto; [MIT license](rea/LICENSE).

The [upstream runtime attribution](https://github.com/morluto/rea/blob/160d821ac9a0310afcb8d1fc427862dd6508add5/THIRD_PARTY_NOTICES.md)
describes dependencies, native engines and assets not shipped here. Keep it with
the separately acquired runtime, not this skill-only snapshot: its relative
links require the wider upstream tree. Future third-party skill helpers/assets
require their own reviewed license trail before import.

[The lock](rea.lock.json) records the npm tarball URL and SHA-512 integrity,
release version, Node requirements, complete selected file SHA-256 digests and
modes. Source commit
[`160d821ac9a0310afcb8d1fc427862dd6508add5`](https://github.com/morluto/rea/commit/160d821ac9a0310afcb8d1fc427862dd6508add5)
comes from the npm release's SLSA provenance. The registry metadata and provenance
were inspected and the archive digest checked; the importer does not verify
attestation signatures or prove that the source commit reproduces the tarball.
Generated release instructions are intentionally selected from the package,
not repository main's potentially newer authored skill.

[Host compatibility](../shared/REA.md) owns local scope and permission adaptations.
`scripts/vendor-rea.py` generates the thin adapter and opt-in MCP config from the
same release. The Claude manifest registers only the skill; the catalog generator
produces the Codex proxy and routing entry. Neither host enables REA by default.

## Verify and refresh

Offline/read-only:

```bash
python3 scripts/vendor-rea.py --check
bash evals/run.sh rea-vendored-skills
```

For a refresh, inspect the official release, license, skill/reference diff,
invocation policy and any helpers before approving new inputs. Download the
exact tarball named by the release's registry metadata into a separate temporary
directory; independently review `dist.integrity` and the source commit in its
provenance. Do not compute a new trusted digest from an unreviewed download.

```bash
python3 scripts/vendor-rea.py \
  --archive /absolute/path/to/rea-agents-6.8.0.tgz \
  --revision 160d821ac9a0310afcb8d1fc427862dd6508add5 \
  --integrity 'sha512-9QDeRnGqEDzABZyr04eLnBXBv/c6I9/TWu/6M0MD4pEfkySI/BIgwTODIbAReX3C1x6hjw9+Jlx4A2yUSPZ9ww=='
bash scripts/generate-skill-catalog.sh
bash evals/run.sh rea-vendored-skills
bun run lint:fix
bun run type:check
```

Repeat import must produce no diff. The importer reads only local archive bytes,
checks integrity before parsing, preserves file modes, and refuses traversal,
selected links/duplicates, unreviewed skills/policies, missing linked references,
drifted or unmanaged outputs and symlinked managed paths before publication.
The selected payload is bounded to 4 MiB and compressed archive to 32 MiB.
Validation failures preserve existing work; this is not an atomic transaction
against concurrent editors or filesystem failures. Run with no concurrent writer.

Keep adaptations outside `vendor/rea/`. Review security fixes as upstream changes
or an explicit patch pipeline, not hand-edited snapshot files. Refresh does not
update anyone's active runtime registration; separately review/migrate it to the
new config pin. Run the fixture smoke with that runtime and exercise MCP in an
isolated client before claiming connection coverage. Offline checks prove bytes,
packaging and importer behavior, not model compliance or all REA capabilities.

Primary sources: [release metadata](https://registry.npmjs.org/rea-agents/6.8.0),
[npm provenance](https://registry.npmjs.org/-/npm/v1/attestations/rea-agents@6.8.0),
[upstream installation](https://github.com/morluto/rea/blob/160d821ac9a0310afcb8d1fc427862dd6508add5/docs/installation.md).
