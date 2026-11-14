# Jakub Krehel interface skills

All 15 upstream skill entrypoints and references come from
[jakubkrehel/skills](https://github.com/jakubkrehel/skills/tree/031c5bf20429b1ae73e0994bed107bdb259a13fb),
commit `031c5bf20429b1ae73e0994bed107bdb259a13fb` (reviewed compatible revision).
The snapshot contains all 96 skill-local files, including references, OpenAI
metadata, viewer assets, generators and tests, plus README and LICENSE: 98 files.
Three teardown helper/test files receive the reviewed
[security patch](jakubkrehel-patches/0001-teardown-input-safety.patch). It checks
worker origins, numeric debugging ports and drawing IDs, escapes script-delimiter characters
in CDP code data, and makes the test's script matcher case-insensitive. No scanner
exclusions or alert dismissals are used. This supersedes the initial raw-copy plan;
all other source bytes and the MIT notice remain unchanged.

This is the last compatible revision before upstream removed `teardown` at
`37744ed8`. Preserve that installed capability and its security patch rather than
silently retiring it. The refresh includes corrected WCAG timing, label hit areas,
dialog inertness, color conversion, text-box examples, viewport claims, reduced-motion
recipes and icon-swap guidance. AFK is retained only as source data: its unattended,
cross-project workflow is not registered or adopted. The importer explicitly allows
that reviewed source-only skill while still rejecting unknown skills, missing
installed skills and changed invocation policies. All 14 existing adapters remain.

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
  --revision 031c5bf20429b1ae73e0994bed107bdb259a13fb
bash scripts/generate-skill-catalog.sh
bash evals/run.sh jakubkrehel-vendored-skills
```

The importer reads committed Git blobs, never dirty source files. The lock records
repository, full SHA, reviewed registrations/invocation policies, original upstream
and patched SHA-256 digests/modes, and patch input digests. Patches apply to a
disposable tree and must preserve the inventory and change only teardown helpers. Repeating the import produces no diff. `--check` is offline/read-only
and rejects missing/extra files, altered bytes/modes, adapter drift and duplicate
owners. Refresh refuses existing unmanaged or drifted outputs, symlinks, moving
refs, unknown/missing skills and changed invocation policies before writing.

Keep local changes in the adapters' generator, reviewed security patches,
compatibility document and existing owners, not hand-edited `vendor/jakubkrehel/`
output. Refresh validates the previous output before applying reviewed patch changes;
an invalid patch writes nothing to managed output. Run the public CLI fixtures, distribution
checks, source helper tests, lint/types and generated catalog checks after refresh.
Prompt/discovery checks do not prove model compliance or interface-review quality.
Teardown helper tests copy unchanged resources into an isolated CommonJS directory,
as required by the host contract for ESM consumers. Browser/export integration requires a drawing, dependencies and approved
browser tooling; passing its helper tests does not establish export correctness.
