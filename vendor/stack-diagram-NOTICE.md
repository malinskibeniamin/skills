# Stack-diagram source and refresh

The complete skill from [caru-ini/stack-diagram](https://github.com/caru-ini/stack-diagram)
is pinned to [commit `9175bde8449cc8f5390d6eb72ecc2e1f5bfe21f3`](https://github.com/caru-ini/stack-diagram/tree/9175bde8449cc8f5390d6eb72ecc2e1f5bfe21f3).
All 19 skill-local files plus the root LICENSE are copied byte-for-byte: entrypoint,
references, four Python helpers, HTML template, generic pictograms and bundled fonts.
Upstream promotional screenshots, README, workflow and Git configuration are excluded;
none is needed by the skill. No logos are bundled or fetched during installation.

Copyright (c) 2026 caru-ini. The root [MIT license](stack-diagram/LICENSE) and
[skill license/trademark notice](stack-diagram/skills/stack-diagram/LICENSE) remain
in the snapshot. Geist and JetBrains Mono retain their separate
[Geist OFL notice](stack-diagram/skills/stack-diagram/assets/fonts/OFL-Geist.txt),
[JetBrains Mono OFL notice](stack-diagram/skills/stack-diagram/assets/fonts/OFL-JetBrainsMono.txt)
and [font provenance](stack-diagram/skills/stack-diagram/assets/fonts/README.md).
Brand marks fetched later retain their owners' trademarks and source licenses.

The [lock](stack-diagram.lock.json) records repository, full revision, SHA-256 digest
and permission mode for every file. [Host compatibility](../shared/STACK-DIAGRAM.md)
and the [adapter](../stack-diagram/SKILL.md) live outside the snapshot. Claude's
manifest is the registration owner; the catalog generator derives Codex discovery.
No hooks, installs, browsers, network calls or background work activate on import.

The 2026-11-08 refresh adds official AWS, Google Cloud and Azure icon-package
lookup, matching cloud-group styling, and wider-canvas PNG rendering. Cloud icon
packages are fetched only during an explicitly scoped diagram task and stay
outside the repository; the original font, skill and root licenses are unchanged.
The new `share.py` gallery helper remains complete upstream source, not an enabled
publication workflow. Host compatibility suppresses unsolicited gallery offers
and requires an explicit request plus exact-content approval before any upload
or identity disclosure. Importing or rendering a diagram executes no gallery code.

The current refresh adds official Kubernetes community resource icons from a pinned
source. The helper resolves aliases without fetching until an icon task requests it.
Keep the Kubernetes Icons Set attribution and existing download/publication boundaries.

## Review and refresh

Review the upstream commit diff, skill-local inventory, licenses, script behavior
and network sources before selecting a new full SHA. Then use a separate clone:

```sh
git clone https://github.com/caru-ini/stack-diagram /tmp/stack-diagram-upstream
python3 scripts/vendor-stack-diagram.py \
  --source /tmp/stack-diagram-upstream \
  --revision 9175bde8449cc8f5390d6eb72ecc2e1f5bfe21f3
bash scripts/generate-skill-catalog.sh
bash evals/run.sh stack-diagram-vendored-skills
```

The importer reads committed blobs, not working-tree files, and preserves modes.
An identical rerun produces no diff. `python3 scripts/vendor-stack-diagram.py --check`
is offline/read-only; it rejects missing/extra/changed files, modes and symlinks.
Refresh refuses moving refs, incomplete resources, unreviewed license changes,
unsafe Git entries and existing unmanaged or drifted output before writing.
New licenses or required-resource changes need an importer review first.

After refresh, rerun the public CLI/distribution tests, build a realistic diagram,
render and inspect both themes, and run repository lint/type checks. Build tests do
not establish visual quality, external logo availability or model adherence.
