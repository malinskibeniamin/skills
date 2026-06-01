# Upgrade Dependency Reference

Templates for `/upgrade-dependency`.

## Harness integration protocol

- Manual: `/upgrade-dependency <pkg>`.
- `/snyk-ux-security`: owns reachability/Snyk state; calls this for remediation path.
- `/go`: dependency files changed -> require report/PR section or skip reason.
- `/commit-push-pr`: dependency diff -> add `Dependency upgrade path` PR section.
- `file-changed-deps`: nudge only. Run `/upgrade-dependency`, add report, or note skip reason. No auto-upgrade.

## Report template

Write `docs/dependency-upgrades/<package>-<from>-to-<target>.md`.

```md
# Dependency upgrade: <package> <from> -> <target>

## Summary
- Ecosystem:
- Manifest/lockfiles:
- Direct dep, parent dep, or transitive:
- Requested by:

## Version path
| Step | From | To | SemVer class or non-SemVer scale | Source | Migration/breakage | Action |
|---|---:|---:|---|---|---|---|

## Dependency tree
Target:  Parents:  Children:  Repo dependents:  Peers:  Plugins/adapters:

## Non-SemVer scale
Release cadence:  Change volume:  Diff size:  API churn:  Effort:  Danger/blast radius:

## Security notes
| Advisory | Source | Reachability/exploitability | Fixed version | Decision |
|---|---|---|---|---|

## Risk gate
Decision: apply now | create issue | plan only | ask user
Reason:
Explicit approval:

## Commands
```bash
# exact update + verify commands
```

## Verification
Lint:  Type check:  Tests:  Build/vet/security scan:
```

## GitHub issue template

Use for major, non-SemVer, missing changelog, unclear migration, peer/security risk.

```md
Title: Plan dependency upgrade: <package> <from> -> <target>

## Goal
Upgrade <package> <from> -> <target> with verified path.

## Version path
<paste report table>

## Breaking changes/migrations
- <version>: <change, source, required code change>

## Codemods/scripts
Available:  Safe to auto-run: yes/no, reason

## Related deps
Peers:  Plugins/adapters:  Parent deps if transitive:

## Security context
Advisories:  Reachability/exploitability:  Fixed versions:

## Risk gate
Why not auto-applied: major | non-SemVer/low SemVer confidence | missing/unclear changelog | peer risk | security uncertainty | high effort migration

## Plan
1. <step>
2. <step>
3. Verify: <commands>

## Delegation plan
One package per agent:  Shared blockers:  Merge order:

## Acceptance
- [ ] Manifest + lockfiles updated together
- [ ] Migration landed
- [ ] Related deps compatible
- [ ] Lint/type/test/build clean
- [ ] Security scan clean or documented
```

## Pull request template

Use after safe apply.

```md
## Summary
- Upgraded <package> <from> -> <target>
- Upgrade path: <report path>

## Risk gate
Decision: applied automatically
Why safe: patch/minor high SemVer confidence | explicit approval | security remediation

## Changes
Manifest/lockfiles:  Migrations:  Related deps:

## Security
Advisories fixed:  Reachability/exploitability:  Residual risk:

## Verification
- [ ] lint:fix
- [ ] type:check
- [ ] test
- [ ] build/vet/security scan if applicable
```

## Command notes

JS/Bun: `bun update <pkg>@<version>` -> `bun install`; add `bun install --yarn` when needed.

Go: `go get -u <module>@<version>` -> `go mod tidy`; keep `go.mod` + `go.sum` together.

Security ladder: direct/top-level dep -> parent dep -> override/resolution/replace last, with removal follow-up.

## Examples

- Safe minor: `/upgrade-dependency vite to latest` -> path, SemVer, changelog, peers, locks, PR.
- Risky major: `/upgrade-dependency react-router to latest` -> report + issue; apply after approval.
- Plan only: `/upgrade-dependency plan only for rspack` -> no code, report/issue only.
- Security: `/snyk-ux-security apps/frontend` -> triage reachability, then use this skill for remediation.
- Many packages: `/upgrade-dependency modernize frontend dependencies to latest stable` -> one package per subagent, merge reports, apply safe bumps.
