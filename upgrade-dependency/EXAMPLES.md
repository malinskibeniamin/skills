# Upgrade Dependency Examples

## Safe minor

`/upgrade-dependency vite to latest`

Build path, confirm SemVer, read changelog/release notes, apply if peers compatible, update lockfiles, verify, PR.

## Risky major

`/upgrade-dependency react-router to latest`

Detect migration risk, write report, create GitHub issue, stop unless approved.

## Plan only

`/upgrade-dependency plan only for rspack`

No code. Report + issue: version path, breakages, codemods, plugins/adapters, verify plan.

## Security remediation

`/snyk-ux-security apps/frontend`

Snyk triages reachability, then asks `/upgrade-dependency` to remediate. Safe applies; risky -> issue with advisory evidence.

## Multiple packages

`/upgrade-dependency modernize frontend dependencies to latest stable`

One package per subagent. Walk tree, merge reports, apply independent safe bumps, issue risky/coupled upgrades.
