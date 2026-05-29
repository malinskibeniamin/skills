# Upgrade Dependency Examples

## Safe minor

```text
/upgrade-dependency vite to latest
```

Expected: build upgrade path, confirm SemVer confidence, read changelog/release notes, apply if peers are compatible, update lockfiles, verify, open PR.

## Risky major

```text
/upgrade-dependency react-router to latest
```

Expected: build upgrade path, detect major migration risk, write local report, create GitHub issue, stop unless user explicitly approves apply.

## Plan only

```text
/upgrade-dependency plan only for rspack
```

Expected: no code changes. Produce report and issue with version path, breaking changes, codemods, related plugins/adapters, and verification plan.

## Security remediation

```text
/snyk-ux-security apps/frontend
```

Expected: Snyk skill triages reachability, then asks `/upgrade-dependency` to remediate reachable package upgrades. Safe fixes apply; risky fixes become GitHub issues with advisory evidence.
