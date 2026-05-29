# Upgrade Dependency Reference

Templates/checklists for `/upgrade-dependency`.

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
- Target:
- Direct parents:
- Transitive children:
- Repo dependents:
- Peer deps:
- Plugins/adapters:

## Non-SemVer scale
- Release cadence:
- Change volume:
- Diff size:
- API churn:
- Effort:
- Danger/blast radius:

## Ecosystem impact
- Packages that move together:
- Runtime entrypoints touched:

## Security notes
| Advisory | Source | Reachability/exploitability | Fixed version | Decision |
|---|---|---|---|---|

## Risk gate
- Decision: apply now | create issue | plan only | ask user
- Reason:
- Explicit approval:

## Commands
```bash
# exact update + verify commands
```

## Verification
- Lint:
- Type check:
- Tests:
- Build/vet/security scan:
```

## GitHub issue template

Use for major, non-SemVer, missing changelog, unclear migration, peer risk, security uncertainty.

```md
Title: Plan dependency upgrade: <package> <from> -> <target>

## Goal
Upgrade <package> from <from> to <target> with verified path.

## Version path
<paste report table>

## Breaking changes/migrations
- <version>: <change, source, required code change>

## Codemods/scripts
- Available:
- Safe to auto-run: yes/no, reason

## Related deps
- Peers:
- Plugins/adapters:
- Parent deps if transitive:

## Security context
- Advisories:
- Reachability/exploitability:
- Fixed versions:

## Risk gate
Why not auto-applied:
- [ ] major
- [ ] non-SemVer / low SemVer confidence
- [ ] missing/unclear changelog
- [ ] peer ecosystem risk
- [ ] security uncertainty
- [ ] high effort migration

## Plan
1. <step>
2. <step>
3. Verify: <commands>

## Delegation plan
- One package per agent:
- Shared blockers:
- Merge order:

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
- Decision: applied automatically
- Why safe: patch/minor high SemVer confidence | explicit approval | security remediation

## Changes
- Manifest/lockfiles:
- Migrations:
- Related deps:

## Security
- Advisories fixed:
- Reachability/exploitability:
- Residual risk:

## Verification
- [ ] lint:fix
- [ ] type:check
- [ ] test
- [ ] build/vet/security scan if applicable
```

## Command notes

JS/Bun: `bun update <pkg>@<version>` -> `bun install`; add `bun install --yarn` when `yarn.lock` exists or Snyk needs mirror. No npm/yarn/pnpm runtime cmds in bun repos.

Go: `go get -u <module>@<version>` -> `go mod tidy`. Keep `go.mod` + `go.sum` together. Do not bump Go toolchain unless requested.

Security ladder: direct/top-level dep -> parent dep -> override/resolution/replace last, with removal follow-up.
