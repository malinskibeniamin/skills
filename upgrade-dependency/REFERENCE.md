# Upgrade Dependency Reference


## Harness integration protocol

- Manual: `/upgrade-dependency <pkg>`.
- `/snyk-ux-security`: owns reachability/Snyk state; calls this for remediation path.
- `/go`: dependency files changed -> require upgrade evidence in the PR body (what broke/adapted/adopted + verify) or skip reason.
- `/commit-push-pr`: dependency diff -> add `Dependency upgrade path` PR section.
- `file-changed-deps`: nudge only; run `/upgrade-dependency` (upgrade+adapt) or record a skip reason.

## PR/issue evidence

Use in the PR body or one umbrella GitHub issue. No local Markdown report unless explicitly requested.

```md
# Dependency upgrade: <package> <from> -> <target>

## Summary
- Ecosystem:
- Manifest/lockfiles:
- Direct dep, parent dep, or transitive:
- Requested by:

## Version path
Every published stable version from current exclusive to target inclusive; research every row; do not install every version.

| Step | From | To | SemVer class or non-SemVer scale | Source | Migration/breakage | Action |
|---|---:|---:|---|---|---|---|

## Consolidated upgrade actions
Priority: majors + announcements/blogs/migrations/codemods, then minors, then patches/security.

API changes:
Syntax/style-guide changes:
Behavior/config changes:
Repo actions before target install:

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

Use for major, non-SemVer, missing changelog, unclear migration, or peer/security risk.

```md
Title: Plan dependency upgrade: <package> <from> -> <target>

## Version path
<version-hop table: version | breaking | action>

## Breaking changes/migrations
- <version>: <change, source, required code change>

Codemods/scripts: available, safe to auto-run yes/no + reason

Related deps: peers, plugins/adapters, parent deps if transitive

Security context: advisories, reachability/exploitability, fixed versions

## Risk gate
Why not auto-applied: major | non-SemVer/low SemVer confidence | missing/unclear changelog | peer risk | security uncertainty | high effort migration

## Plan
1. <step>
2. <step>
3. Verify: <commands>

Delegation plan: one package per agent, blockers, merge order

## Acceptance
- [ ] Manifest + lockfiles updated together
- [ ] Migration landed
- [ ] Related deps compatible
- [ ] Lint/type/test/build/security scan clean or documented
```

## Pull request template

```md
## Summary
- Upgraded <package> <from> -> <target>
- Upgrade path: <installed -> target hops>

## Risk gate
Decision: applied automatically
Why safe: patch/minor high SemVer confidence | explicit approval | security remediation

Changes: manifests/lockfiles, migrations, related deps
Security: advisories fixed, reachability/exploitability, residual risk

## Verification
- [ ] lint:fix
- [ ] type:check
- [ ] test
- [ ] build/vet/security scan
```

## Command notes

JS/Bun: `bun update <pkg>@<version>` -> `bun install`; `bun install --yarn` when needed.

Go: `go get -u <module>@<version>` -> `go mod tidy`; keep `go.mod` + `go.sum`.

Security ladder: direct/top-level dep -> parent dep -> override/resolution/replace last, with removal follow-up.

## Examples

- Safe minor: `/upgrade-dependency vite to latest` -> path, SemVer, changelog, peers, locks, PR.
- Risky major: `/upgrade-dependency react-router to latest` -> GitHub issue; apply after approval.
- Plan only: `plan only for rspack` -> path + risk in chat; nothing written.
- Security: `/snyk-ux-security apps/frontend` -> triage reachability, then use this skill for remediation.
- Many packages: `/upgrade-dependency modernize frontend dependencies to latest stable` -> one package per subagent, merge gates, apply safe bumps.

## Supply-chain gate

Before apply, check:
- Min release age: npm `min-release-age`, pnpm/Yarn/Bun `minimumReleaseAge` where supported; default 7-30d unless security fix overrides.
- Disable scripts: no lifecycle scripts. Bun disables postinstall by default; review `trustedDependencies`.
- Block git deps: fail on `git+`, tarball, raw URL deps in manifest/lock.
- Scan deps: Snyk + `bun audit`; optional `npq`/Socket Firewall (`sfw`) if installed.
- Review lockfile: new names, resolved URLs, integrity, scripts/trusted deps, git/tarball sources.
- Clean install: frozen/clean command, not dirty incremental only.
