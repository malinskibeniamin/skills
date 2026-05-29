# Upgrade Dependency Reference

Detailed templates and checklists for `/upgrade-dependency`.

## Report template

Write to `docs/dependency-upgrades/<package>-<from>-to-<target>.md`.

```md
# Dependency upgrade: <package> <from> -> <target>

## Summary
- Ecosystem:
- Manifest/lockfiles:
- Direct dep, parent dep, or transitive:
- Requested by:

## Version path
| Step | From | To | SemVer confidence | Changelog/release note | Breaking or migration notes | Action |
|---|---:|---:|---|---|---|---|

## Ecosystem impact
- Peer deps:
- Plugins/adapters:
- Packages that must move together:
- Runtime entrypoints touched:

## Security notes
| Advisory | Source | Reachability or exploitability | Fixed version | Decision |
|---|---|---|---|---|

## Risk gate
- Decision: apply now | create issue | plan only | ask user
- Reason:
- Explicit approval, if any:

## Commands
```bash
# exact package-manager and verify commands used or recommended
```

## Verification
- Lint:
- Type check:
- Tests:
- Build/vet/security scan:
```

## GitHub issue template

Use for major, non-SemVer, missing changelog, uncertain migration, peer ecosystem risk, or security uncertainty.

```md
Title: Plan dependency upgrade: <package> <from> -> <target>

## Goal
Upgrade <package> from <from> to <target> with a verified upgrade path.

## Version path
<paste table from report>

## Breaking changes and migrations
- <version>: <change, source, required code change>

## Codemods or scripts
- Available:
- Safe to run automatically: yes/no, reason

## Related dependencies
- Peer deps:
- Plugins/adapters:
- Parent deps if transitive:

## Security context
- Advisories:
- Reachability/exploitability:
- Fixed versions:

## Risk gate
Why this is not auto-applied:
- [ ] major upgrade
- [ ] non-SemVer or low SemVer confidence
- [ ] missing or unclear changelog
- [ ] peer ecosystem risk
- [ ] security uncertainty
- [ ] high effort migration

## Proposed implementation plan
1. <step>
2. <step>
3. Verify: <commands>

## Acceptance criteria
- [ ] Manifest and lockfiles updated together
- [ ] Migration changes landed
- [ ] Related deps compatible
- [ ] Lint/type/test/build clean
- [ ] Security scan clean or explicitly documented
```

## Pull request template

Use after applying safe upgrades.

```md
## Summary
- Upgraded <package> from <from> to <target>
- Upgrade path: <report path>

## Risk gate
- Decision: applied automatically
- Why safe: patch/minor with high SemVer confidence | explicit approval | security remediation

## Changes
- Manifest/lockfiles:
- Code migrations:
- Related deps:

## Security
- Advisories fixed:
- Reachability/exploitability notes:
- Residual risk:

## Verification
- [ ] lint:fix
- [ ] type:check
- [ ] test
- [ ] build/vet/security scan, if applicable
```

## Command notes

JS/Bun:
- Use `bun update <pkg>@<version>` for a single package.
- Run `bun install` after edits so `bun.lock` matches the manifest.
- Run `bun install --yarn` when `yarn.lock` exists or Snyk IO needs a yarn mirror.
- Do not use npm, yarn, or pnpm runtime commands in bun repositories.

Go:
- Use `go get -u <module>@<version>` for module bumps.
- Run `go mod tidy` so `go.mod` and `go.sum` move together.
- Do not bump the Go toolchain directive as part of a dependency upgrade unless explicitly requested.

Security remediation ladder:
1. Direct dep or top-level dep bump.
2. Parent dep bump when the vulnerable package is transitive.
3. Override/resolution/replace only as last resort, with a follow-up removal note.
