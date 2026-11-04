# Automatic priority skill refresh

The daily **Refresh priority skills** workflow fetches five fixed upstreams, runs the
existing trusted importers, and maintains one draft PR. It never executes upstream
helpers, replaces local workflow owners, approves, or merges. Compatibility failures
retain that source's existing snapshot and appear in the draft and failed run.
Repository permission to create bot PRs is required; it is not enabled by this code.

## Sources and entrypoints

| Source | Repository | Trusted importer |
| --- | --- | --- |
| pstack | [cursor/plugins, `pstack/`](https://github.com/cursor/plugins/tree/main/pstack) | `scripts/vendor-poteto.py` |
| Matt Pocock | [mattpocock/skills](https://github.com/mattpocock/skills) | `scripts/vendor-mattpocock.py` |
| T3 Code | [pingdotgg/t3code](https://github.com/pingdotgg/t3code) | `scripts/vendor-t3code-skills.py` |
| tstack | [t3dotgg/tstack](https://github.com/t3dotgg/tstack) | `scripts/vendor-tstack.py` |
| Emil Kowalski | [emilkowalski/skills](https://github.com/emilkowalski/skills) | `scripts/vendor-emil.py` |

The workflow runs daily at 08:29 UTC from the default branch. GitHub schedules are
best-effort, not a freshness SLA. It fetches each `main` into a temporary bare object
store and resolves a full commit SHA before reading any content. Changes outside the
watched skill/support/license inputs do not advance locks or create update-only churn.
T3 also watches support files recorded by its importer. Sources, refs and executables
cannot be substituted through workflow inputs.

## Operation

- Run **Refresh priority skills** manually for an immediate refresh. Its `dry_run`
  input fetches and validates without publishing; scheduled runs publish by default.
- The dedicated branch is `ben-malinski/maintenance/priority-skill-updates`. Updates
  use one commit on the current default base, an explicit expected-head push lease,
  and draft/head/base readback. One open bot-owned draft is reused.
- Human commits or marking the PR ready hands ownership back to the human: automation
  refuses to overwrite it. Close an unwanted draft to dismiss that exact candidate;
  a changed candidate may propose a new draft. No unrelated branches are rewritten.
- The draft includes immutable comparisons and exact compatibility failures.
  Successful sources can refresh independently; blocked sources keep their old pins.
  Unknown catalogs, changed licenses and integrity drift are not bypassed. The run
  stays failed until those blockers are reconciled through the owning importer.
- Catalog generation runs in an isolated candidate; only managed snapshots, adapters,
  licenses, registrations and catalog outputs can be applied. Root policy, scripts
  and workflows are protected. Importing source data does not adopt new local policy
  or rewrite Emil's hand-maintained design adaptations.

## GitHub setup and checks

The job requests `contents: write`, `pull-requests: write`, and `actions: write`.
An owner must allow Actions to create PRs under **Settings > Actions > General >
Workflow permissions**. GitHub names the switch "Allow GitHub Actions to create and
approve pull requests"; the updater never approves. Do not change hosted approval,
merge, or branch protection rules to make this work. No new secret is required.

The updater explicitly dispatches the existing read-only `evals.yml` on the update
branch, rather than requiring a human to approve token-created PR checks. Runs already
recorded for the same head are not dispatched again. See GitHub's
[workflow triggering rules](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow).
A dispatch or draft is not evidence that checks passed.

The older [T3 harness watcher](../.github/workflows/watch-t3code-harness.yml) remains
report-only for broader harness policy; this workflow actually refreshes skill
snapshots. Neither automatically merges.

## Local verification and rollback

```sh
python3 scripts/refresh-skill-upstreams.py             # read-only live dry run; JSON
python3 scripts/refresh-skill-upstreams.py --apply     # managed patch; clean checkout only
bash evals/run.sh refresh-skill-upstreams             # offline CLI/Git/transport contracts
```

Offline fixtures can provide `--sources DIRECTORY`, with Git stores named `pstack`,
`mattpocock`, `t3code`, `tstack`, and `emil`. Offline overrides cannot publish.
Revert an update PR to restore its previous pins. Disable this workflow to stop
refreshes; no plugin-install hooks or persistent local process are involved.
