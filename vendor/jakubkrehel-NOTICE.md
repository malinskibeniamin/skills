# Jakub Krehel interface skills

All 14 skills are copied unchanged from
[jakubkrehel/skills](https://github.com/jakubkrehel/skills/tree/592aedc44d7d5b3e29740984252902f3e5402a1c),
commit `592aedc44d7d5b3e29740984252902f3e5402a1c` (plugin version 1.17.0).
The snapshot contains all 94 skill-local files, including references, OpenAI
metadata, viewer assets, generators and tests, plus README and LICENSE: 96 files.

Copyright (c) 2026 Jakub Krehel. The original [MIT license](jakubkrehel/LICENSE)
remains beside the source. The import excludes upstream root agent instructions,
plugin manifests and host configuration; these must not replace this harness.

[Compatibility and owners](../shared/INTERFACES.md) adapt the source outside the
snapshot. Fourteen generated adapters expose the source names on Claude and
Codex. Five upstream explicit-only policies are preserved. Existing skills load
relevant domain guidance or plain references rather than starting another stack.
Importing activates no hooks, agents, browsers, viewers, installs or background jobs.

## Review and refresh

Use a separate upstream clone. Inspect the pinned diff, license, complete inventory,
invocation policies, links and executable helpers before choosing a new commit.
Update the importer's reviewed inventory and compatibility only when required.

```sh
git clone https://github.com/jakubkrehel/skills /tmp/jakubkrehel-skills
python3 scripts/vendor-jakubkrehel.py \
  --source /tmp/jakubkrehel-skills \
  --revision 592aedc44d7d5b3e29740984252902f3e5402a1c
bash scripts/generate-skill-catalog.sh
bash evals/run.sh jakubkrehel-vendored-skills
```

The importer reads committed Git blobs, never dirty source files. The lock records
repository, full SHA, reviewed registrations/invocation policies, SHA-256 digests and
file modes. Repeating the import produces no diff. `--check` is offline/read-only
and rejects missing/extra files, altered bytes/modes, adapter drift and duplicate
owners. Refresh refuses existing unmanaged or drifted outputs, symlinks, moving
refs, unknown/missing skills and changed invocation policies before writing.

Keep local changes in adapters' generator, the compatibility document and existing
host owners, not in `vendor/jakubkrehel/`. Run the public CLI fixtures, distribution
checks, source helper tests, lint/types and generated catalog checks after refresh.
Prompt/discovery checks do not prove model compliance or interface-review quality.
Teardown helper tests copy unchanged resources into an isolated CommonJS directory,
as required by the host contract for ESM consumers. Browser/export integration requires a drawing, dependencies and approved
browser tooling; passing its helper tests does not establish export correctness.
