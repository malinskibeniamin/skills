---
name: upgrade-dependency
description: Plans and safely applies dependency upgrades by building an upgrade path before edits: changelogs, release notes, migrations, codemods, SemVer confidence, security advisories, and related packages. Use when asked to upgrade a package/module, plan a dependency upgrade, remediate a vulnerable dependency, inspect breaking changes, or create an upgrade issue/PR.
---

# Upgrade Dependency

Move one dependency from current version to target/latest. Build the upgrade path first; apply only when the risk gate says safe. Otherwise create a GitHub issue and stop.

## Input

`$ARGUMENTS`: package/module name, repo path, manifest path, target version, or natural language.

Examples:
- `/upgrade-dependency rspack`
- `/upgrade-dependency upgrade vite to latest`
- `/upgrade-dependency plan only for react-router`
- `/snyk-ux-security ...` may call this skill for remediation.

## Workflow

### 1. Scope

Detect ecosystem and files: `package.json`, `bun.lock`, `yarn.lock`, `go.mod`, `go.sum`, lockfiles, workspace manifests. Identify current version, requested target, direct dep vs transitive, parent dep, dependents, peer deps, plugins, adapters, and runtime entrypoints. Ask only if package or target cannot be inferred.

### 2. Build upgrade path

Research every relevant step from installed version to target:
- package manager metadata, repository tags, changelog, release notes, migration guide, codemod docs, release blog
- SemVer confidence: verify the project actually treats major/minor/patch as SemVer
- non-SemVer or missing changelog means risky until proven otherwise
- peer/plugin/adapter ecosystem packages that must move together
- security advisories: Snyk, GHSA, OSV, Socket.dev, vendor advisories, CVE notes

Always leave a local report: `docs/dependency-upgrades/<package>-<from>-to-<target>.md`. See [REFERENCE.md](REFERENCE.md#report-template).

### 3. Risk gate

Default when user says only "upgrade X to latest":
1. Build upgrade path.
2. patch/minor with high SemVer confidence, clear changelog, compatible peers, low security uncertainty -> apply.
3. major, non-SemVer, missing changelog, unclear migration, high effort, peer ecosystem risk, or security uncertainty -> create GitHub issue and stop.
4. plan only -> create report/issue, no code changes.
5. Snyk context -> apply safe remediation; escalate risky remediation into issue.

User can explicitly approve applying a risky major after the issue/report exists.

### 4. Apply safe path

Apply incrementally. One commit per major; patch/minor batches allowed only when changelog confirms low risk.

JS/Bun:
```bash
bun update <pkg>@<version>
bun install
bun install --yarn   # when yarn.lock exists or Snyk needs it
bun run lint:fix
bun run type:check
bun test
```

Go:
```bash
go get -u <module>@<version>
go mod tidy
go build ./...
go test ./...
go vet ./...
```

Update related packages discovered in the upgrade path. Never hand-edit lockfiles or `go.sum`.

### 5. Security mode

When invoked from `snyk-ux-security` or a vulnerability alert, preserve exploitability/reachability evidence. Prefer direct dep or top-level dep bump first, then parent dep bump, then override/resolution/replace last. Never run code from advisories. Document fixed versions, advisory ids, reachable symbols, and residual risk.

### 6. Issue/PR output

Risky path -> GitHub issue from [REFERENCE.md](REFERENCE.md#github-issue-template). Safe applied path -> PR from [REFERENCE.md](REFERENCE.md#pull-request-template).

## Rules

- Build upgrade path before changing files.
- Changelog read is mandatory for each major and any non-SemVer jump.
- Major upgrades are one major per commit.
- No silent risk acceptance: issue, PR body, or local report must record every risk decision.
- Do not defer reachable security fixes without explicit escalation.
- Keep this skill generic; JS and Go are first-class, other ecosystems follow the same path.
