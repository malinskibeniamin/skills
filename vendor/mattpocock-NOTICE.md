# Matt Pocock skills

Source: [mattpocock/skills](https://github.com/mattpocock/skills), reviewed at
[`a496f5513d4a4cf889bc48e189e579f4b0bdf6aa`](https://github.com/mattpocock/skills/tree/a496f5513d4a4cf889bc48e189e579f4b0bdf6aa)
(v1.3.2 plus subsequent main-branch changes).

All **38 skills** under `skills/`, every skill-local reference/helper/asset, the
upstream README and [MIT license](mattpocock/upstream/LICENSE) are retained byte-for-byte
in `mattpocock/upstream/`. [The lock](mattpocock.lock.json) records the immutable
revision, complete inventory, SHA-256 digests, executable modes and adapter/owner
mapping. This includes `pr` and its [original credits](mattpocock/upstream/skills/engineering/pr/CREDITS.md)
for Dex Horthy's `show-me` work.

Generated explicit-only adapters in `../matt-skills/` expose every source skill.
Existing unprefixed skills remain local adaptations, not byte-exact copies.
[Compatibility](../shared/MATT-POCOCK.md) owns host policy and authorization; no
upstream agents, hooks or schedules are activated by importing the source.

The separately reviewed [software-factory draft](software-factory-NOTICE.md) has
its own pin and files in `mattpocock/software-factory/`; this import preserves them.
Non-skill upstream infrastructure, docs site and repository automation are not imported.

## Refresh

Use any Git checkout containing the reviewed commit; source worktree edits are not
inputs. In this repository the `upstream` remote points to Matt's repository:

```bash
git fetch upstream
git rev-parse upstream/main # review this immutable revision before importing
python3 scripts/vendor-mattpocock.py --source . --revision <full-reviewed-sha>
bash scripts/generate-skill-catalog.sh
python3 scripts/vendor-mattpocock.py --check
bash evals/run.sh matt-refresh
```

Compare the old pin with the reviewed revision and update each affected local owner,
not just its source snapshot. Review every newly discovered skill's capabilities;
all receive an explicit-only adapter under the host contract. Update this notice
and the README pin/count. The importer refuses modified managed outputs, unsafe
source entries, missing attribution inputs and duplicate skill names; preserve and
reconcile local work before retrying. Repeating the same import and generators must
produce no additional diff. `--check` is local, read-only and network-free.

## Reconciliation at this pin

Compared with the previous adapted baseline `49dd158d1076134a641b33efb035946536778336`:

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
