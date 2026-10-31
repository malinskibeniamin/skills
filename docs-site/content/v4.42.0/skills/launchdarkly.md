---
description: "Audit LaunchDarkly flags with ldcli: existence, audiences, blast radius, archive readiness, and cleanup in Integration and Production."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["launchdarkly"]}
sidebar: {"label":"/launchdarkly"}
title: "/launchdarkly"
type: "skill"
---
![Diagram of the /launchdarkly skill](/diagrams/skills/launchdarkly.svg)

[Open the editable Excalidraw source](/diagrams/skills/launchdarkly.excalidraw)


Use the official `ldcli` only for LaunchDarkly operations. Read
[CLI preflight](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/ldcli.md); reuse authentication without printing tokens or
config. Audit requests are read-only: "can we kill it?" asks for a recommendation,
not a targeting change, deprecation, archive, deletion, or code removal.

## Scope

Resolve the project from the request or repository configuration. Otherwise list
projects with `ldcli projects list --help` and ask which project; never assume
`default`. Paginate before claiming an account-wide count.

**Use Integration (`integration`) and Production (`production`) only.** Discover
these exact keys with `ldcli environments list`; a missing/inaccessible required
environment is unknown, not empty or disabled. Ignore testing, staging,
preproduction, development, and other unused environments in the cleanup heuristic.
If a project uses different keys, resolve that mapping before adapting the command;
do not silently substitute another environment.

## Inspect a flag

Read `ldcli flags get --help`, then fetch full configuration for each selected
environment. Report existence, creation date, archive/deprecation state, on/off,
and the values actually served. Distinguish missing flags from authentication,
permission, project, and environment failures. Missing does not authorize creation;
follow [CLI changes](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/ldcli.md#change) only when requested.

For "who can see it?", trace default variation, individual/context targets, ordered
rules, segments, percentage/experiment rollouts, and prerequisites. `on: true`
alone does not mean everyone receives the feature. Resolve indexes against
`variations[].value`; never assume index zero means enabled. Describe audiences
without exposing context identifiers unnecessarily. Separate feature recipients
from dashboard permissions and maintainers. For multivariate flags, establish
which value means enabled; otherwise report unknown.

For detailed dependency, code-reference, or archive analysis, read
[lifecycle and evidence](https://github.com/malinskibeniamin/skills/blob/v4.42.0/launchdarkly/references/lifecycle.md).

## Count long-enabled cleanup candidates

With Bun available, run from this skill's installation directory:

```bash
bun run scripts/audit.ts --project <project-key>
```

The command paginates inventories, fetches full targeting with `--summary 0`, and
checks scoped change history through `ldcli`. It never writes to LaunchDarkly.
Keep raw output local and out of commits or public PRs.

Count each non-archived flag once when all hold at UTC `auditedAt`:

- Created **strictly more than 30 × 24 hours ago**.
- Targeting is on in **both Integration and Production**, and all possible default,
  rule, target, and positive-weight rollout outcomes serve boolean `true`.
- No selected configuration or flag history change in the **last 14 × 24 hours**.
  A change exactly at the cutoff excludes the flag. Use selected-environment
  resource specifiers, not all-environment history that disqualifies unused edits.
  Shared metadata changes affecting selected environments also count as changes.

Unresolved prerequisites, non-boolean enabled values, malformed/missing targeting,
and inaccessible history are **unknown**, not verified candidates. Resolve them
before claiming an exact total. Matching means **candidate for removing the flag
check while preserving the released feature**, not "turn the feature off" or
"safe to archive now".

## Return evidence

Lead with `candidateCount`, project, both environment keys, UTC audit time, and
`scannedCount`. List candidate keys with `createdAt` and
`lastTargetingChangeAt`; the latter is not a global last-change timestamp.
Name ignored environments and unknowns. `exactCount: null` / exit 2 means a lower
bound; exit 1 means inventory failed and no count is proven. Aggregate only
complete project reports; restricted token access cannot prove account-wide scope.

State archive blockers separately. Snapshot reads are not atomic; rerun before
acting. Stop after the report unless the user explicitly requests a change.
