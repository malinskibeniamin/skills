# Lifecycle and evidence

Read for blast radius, deprecation, or archive recommendations. Discover reads
with installed `ldcli --help`, `ldcli resources`, and resource/subcommand help.
Report missing CLI capabilities/access; do not substitute raw HTTP, MCP, or UI.

## Command contract

Verified against `ldcli 3.12.0`; installed help owns version-specific options:

```bash
ldcli environments list --project <project> --limit 20 --offset 0 --output json
ldcli flags list --project <project> --env integration --summary 0 --limit 20 --offset 0 --output json
ldcli flags get --project <project> --flag <flag> --env production --output json
ldcli audit-log list --spec 'proj/<project>:env/integration:flag/<flag>' --after <cutoff-minus-one-ms> --limit 1 --output json
```

Repeat targeting/history reads for both selected environments. `creationDate` and
environment `lastModified` are Unix milliseconds. Default list responses omit full
targeting: missing arrays do not prove no rules/targets. Follow list `_links.next`
offsets through the same CLI command; reject incomplete/changing inventories.

For “any change since cutoff?”, limit 1 is enough: any entry disqualifies; empty
items must also have no next link. Use resource specifiers, not name searches or
only targeting `lastModified`. The 14-day window fits the documented 30-day
minimum change history; if account retention/access cannot cover it, mark unknown.
Do not extrapolate this test to longer history windows.

## Blast radius

Separate observed, inferred, and unknown impact:

- **Audience:** selected-environment rules, segments, targets, prerequisites, and
  rollouts. Percentages alone cannot establish affected user counts.
- **Consumers:** discover `code-refs` and `flags` reads for code references,
  SDK/application usage, context kinds, client/server exposure, older deployed
  clients, and SDK fallback values. Missing references do not prove no consumers.
- **Dependencies:** inspect outbound prerequisites and reverse dependents by key
  across paginated full flags. Include archived/deprecated flags when checking
  archive blockers; archived dependents can retain prerequisite relationships.
- **Controls:** discover `experiments`, `scheduled-changes`, `workflows`, and
  `flag-triggers` reads. Check operational/permission gates, ownership, experiments,
  guarded/progressive rollouts, schedules, and rollback needs. Missing access is
  an evidence gap, not clearance.
- **Repository:** search exact keys in the user's application repo, then inspect
  callers/tests. This skills repository is not the application.

Integration/Production constrain the heuristic, not lifecycle scope. Archiving or
deprecating can affect the whole project, including unused environments; disclose
that before an explicitly requested mutation.

## Recommendation

| Evidence | Recommendation |
| --- | --- |
| Meets 30/14-day heuristic | Candidate for code cleanup, preserving the enabled behavior; review retirement blockers. |
| Older client-side versions still evaluate it | Consider deprecation, which hides the flag but continues evaluation. |
| Consumers removed and archive checks satisfied | Candidate to archive after deployment and fallback verification. |
| Prerequisite for another flag | Archive blocked until relationships are removed, even for archived dependents. |
| Active evaluations, experiments, schedules, rollback need, or unknowns | Keep, investigate, or sequence cleanup; not safe to archive yet. |

Archiving stops normal evaluation; callers receive their SDK fallback, not
necessarily today's enabled variation. Deprecation is available for client-side
flags, not a universal intermediate state. Deletion is separately destructive.
For requested mutations, follow the shared CLI change workflow: read current
state, verify exact scope/rollback, perform only authorized changes, and read back.
Audit/count requests authorize none of those mutations.

## Primary sources

- [Flag values and environment state](https://launchdarkly.com/docs/api/feature-flags/get-feature-flag)
- [Flag list summary and pagination](https://launchdarkly.com/docs/api/feature-flags/list-feature-flags)
- [History resource and time filters](https://launchdarkly.com/docs/api/audit-log/list-audit-log-entries)
- [History retention](https://launchdarkly.com/docs/home/releases/change-history)
- [Deprecation](https://launchdarkly.com/docs/home/flags/deprecate)
- [Archive checks and fallback behavior](https://launchdarkly.com/docs/home/flags/archive)
