# Matt Pocock skills

Source: [mattpocock/skills](https://github.com/mattpocock/skills), reviewed at
[`71009050da79506823464512ee76d71bbc014ce1`](https://github.com/mattpocock/skills/tree/71009050da79506823464512ee76d71bbc014ce1)
(the `animatic-skill` draft branch, [PR #1422](https://github.com/mattpocock/skills/pull/1422)).

All **41 skills** under `skills/` at that base, plus the supplemental `constrain`
draft below (**42 total**), every skill-local reference/helper/asset, the
upstream README and [MIT license](mattpocock/upstream/LICENSE) are retained
in `mattpocock/upstream/`, with the narrowly scoped helper patches below. All other
source files are byte-exact. [The lock](mattpocock.lock.json) records the immutable
revision, original and patched inventories, patch-input digests, executable modes and adapter/owner
mapping. This includes `pr` and its [original credits](mattpocock/upstream/skills/engineering/pr/CREDITS.md)
for Dex Horthy's `show-me` work.

Generated explicit-only adapters in `../matt-skills/` expose every source skill.
Existing unprefixed skills remain local adaptations, not byte-exact copies.
[Compatibility](../shared/MATT-POCOCK.md) owns host policy and authorization; no
upstream agents, hooks or schedules are activated by importing the source.

The merged in-progress [software-factory source](mattpocock/upstream/skills/in-progress/software-factory/SKILL.md)
now shares this pin and its existing planning owner. It supersedes the separate draft
snapshot; [compatibility and refresh](software-factory-NOTICE.md) retain local safety controls.
Non-skill upstream infrastructure, docs site and repository automation are not imported.

## Constrain draft supplement

The complete `skills/in-progress/constrain/` directory (entrypoint and OpenAI
invocation metadata) is pinned byte-exact to
[`f4413d9e642c3c1e274afdfad5d990ccf5552d10`](https://github.com/mattpocock/skills/tree/f4413d9e642c3c1e274afdfad5d990ccf5552d10/skills/in-progress/constrain)
from Matt's draft [PR #1441](https://github.com/mattpocock/skills/pull/1441).
Its license is byte-identical to the retained MIT license. The lock's `supplements`
records this independent source revision, selected directory and license digest;
`upstream_files` and `files` include both inputs. Existing base bytes and reviewed
animatic patches are unchanged. Replacing the base with this sibling draft would
remove animatic, so the supplement adds only the requested skill, not its whole branch.

Both `/constrain` and `/matt-constrain` load the [local owner](../constrain/SKILL.md).
It preserves user confirmation, inline research without delegation consent, existing
lint engines, strictness and suppression controls. Routing, retro and agent-writing
guidance recommend it for deliberate API/import-graph restrictions; they cannot
invoke it automatically. Importing applies no restrictions to this harness or its
consumers. Upstream reports no real-project trial yet; instruction/distribution
checks do not establish agent adherence or improved task success.

## Reviewed helper patches

[`0001-private-calibration-workspace.patch`](mattpocock-patches/0001-private-calibration-workspace.patch)
addresses CodeQL alerts 21 and 22 on PR #335. Calibration previously placed a predictable
PID-named WAV, narration text and SAPI job list directly in shared temporary storage.
It now creates narration text and SAPI job files exclusively with owner-only mode
`0o600`, and uses `fs.mkdtempSync` to create a private workspace, with cleanup on success,
exceptions and the helper's explicit failure exit. The upstream revision stays fixed.
[`0002-failed-speech-and-linked-assets.patch`](mattpocock-patches/0002-failed-speech-and-linked-assets.patch)
propagates custom speech-command errors through cleanup before conversion, retries
errored jobs even if they wrote readable WAVs, and removes failed output rather than
caching partial narration. Custom HTML is always re-rendered because linked CSS,
images, fonts and scripts are not covered by its page hash. Generated self-contained
frames and embedded images retain content-based caching.

The importer applies these reviewed patches in a disposable tree, rejects changes
outside the animatic helper or to file inventory/modes, and records `upstream_files`,
`patches` and resulting `files` separately. `--check` validates patch-input and output
digests without altering the repository. A failed patch application stops the refresh;
review upstream changes before replacing or retiring a patch. No scanner exclusion
or alert dismissal is used. Run `bash evals/run.sh animatic` for the CLI regressions.
Speech and browser boundary fixtures exercise retry/cache decisions without installing
runtime tools; they do not prove real speech synthesis or browser rendering.

## Refresh

Use any Git checkout containing the reviewed commit; source worktree edits are not
inputs. Fetch into a temporary source checkout without changing the host's remotes:

```bash
source_dir=$(mktemp -d)
git clone https://github.com/mattpocock/skills.git "$source_dir/upstream"
git -C "$source_dir/upstream" rev-parse HEAD # review this immutable revision before importing
python3 scripts/vendor-mattpocock.py --source "$source_dir/upstream" --revision <full-reviewed-sha>
bash scripts/generate-skill-catalog.sh
python3 scripts/vendor-mattpocock.py --check
bash evals/run.sh matt-refresh
bun run docs:translate:check # refresh affected locale pages when local skills change
```

Compare the old pin with the reviewed revision and update each affected local owner,
not just its source snapshot. Review every newly discovered skill's capabilities;
all receive an explicit-only adapter under the host contract. Update this notice
and the README pin/count. The importer refuses modified managed outputs, unsafe
source entries, missing attribution inputs and duplicate skill names; preserve and
reconcile local work before retrying. Repeating the same import and generators must
produce no additional diff, even when other vendors follow Matt's registrations.
Refresh output identifies added, changed and removed skills for reconciliation;
removing a source adapter does not retire its local owner. `--check` is local,
read-only and network-free. Remove the disposable source checkout after verification.

Supplemental pins are preserved on ordinary refreshes. Fetch their locked commits
into the same source Git store first; the priority updater does this automatically.
To reproduce this supplement explicitly, keeping the base above:

```bash
git -C "$source_dir/upstream" fetch origin f4413d9e642c3c1e274afdfad5d990ccf5552d10
python3 scripts/vendor-mattpocock.py --source "$source_dir/upstream" \
  --revision 71009050da79506823464512ee76d71bbc014ce1 \
  --supplement f4413d9e642c3c1e274afdfad5d990ccf5552d10:skills/in-progress/constrain
```

Repeat `--supplement <full-sha>:skills/<category>/<skill>` for multiple drafts;
an explicit list replaces the previous list. The importer rejects missing skills,
unsafe entries, license differences and collisions with base source. When a draft
merges into the reviewed base, retire that supplement explicitly (use
`--no-supplements` when none remain); do not silently overwrite or discard a pin.

## Reconciliation at this pin

The animatic draft adds `animatic` and `setup-animatic`, with their complete frame
kit, scripts and voice recipes. The unprefixed host owners preserve setup,
remote-target, secret, generated-guidance and publication boundaries. Importing
the source installs no runtime tools. Runtime dependencies are fetched only when
a separately authorized setup/build runs; those packages are not vendored or
pinned by this source lock. The only other skill changes from the prior pin are
two software-factory clarifications: CI jobs are not factory tasks, and exploration
leaves evidenced findings without pushing. The planning owner retains that scope.

The prior main-branch refresh added the merged software-factory design language and surveys,
routes its adapter through the existing planning owner, and reuses shared wikis for
chief-of-staff. Retro procedures remain scoped and recommend-only without edit authority.

A same-pin integration pass verifies the full suite without snapshot churn, preserves
cross-vendor registration order and reports removed sources. The
[family coverage map](../shared/MATT-POCOCK.md#integration-coverage) records existing coverage
and focused improvements to ticket-graph safety, test-seam limits, read-only architecture
assessment, empty review scope and questionnaire audience grounding.

Earlier reconciliations from the adapted baseline `49dd158d1076134a641b33efb035946536778336` remain:

- Authorized review, design, architecture, research, grilling and wayfinding agents
  now use fresh contexts; consent and inline fallbacks remain local policy.
- `implement-spec` uses one fresh implementer per ticket and a fresh review-repair
  implementer, retaining integration-branch and requested-endpoint ownership.
- Setup recognizes legacy domain docs and verifies the chosen hosted tracker.
  GitHub templates retain closing explanations, verify fork targets, read PR bodies
  separately and count only open blockers. GitLab templates fix MR JSON output and
  discover fallback child links through the map's relationship API.
- The updated chief-of-staff wiki/memory instructions are retained in full as an
  explicit-only experiment, bounded by host consent and persistence rules.
- `pr` already contained the current upstream template and summary views. Its local
  evidence/business-value/session rules remain; source and credits are now pinned
  and directly linked. Previously omitted misc and experimental skills are included.
