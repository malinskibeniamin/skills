---
name: upgrade-dependency
description: Plans safe dependency upgrades. Use when asked to upgrade package/module, plan dependency upgrade, remediate vulnerable dependency, inspect breaking changes, or create upgrade issue/PR.
---

# Upgrade Dependency

Move dependency current -> target/latest stable. Build upgrade path first. Apply only if risk gate safe; else GitHub issue + stop.

## Input

`$ARGUMENTS`: package/module, repo path, manifest path, target version, natural language.

## Workflow

### 1. Scope

Detect files: `package.json`, `bun.lock`, `yarn.lock`, `go.mod`, `go.sum`, workspaces. Walk dependency tree: target, direct/transitive, parents, dependents, peers, plugins, adapters, runtime entrypoints. Ask only if ambiguous.

### 2. Build upgrade path

Research per-version hops installed -> target:
- metadata, tags, changelog, release notes, migration guide, codemod docs, release blog
- SemVer confidence: verify project honors major/minor/patch; classify each hop patch, minor, or major
- non-SemVer/missing changelog -> risky; score change volume, release cadence, diff size, API churn, effort, danger/blast radius
- peer/plugin/adapter packages that move together
- security advisories: Snyk, GHSA, OSV, Socket.dev, vendor, CVE notes
- target latest stable, not blind latest; migrate to modern supported syntax/patterns

Always leave local report: `docs/dependency-upgrades/<package>-<from>-to-<target>.md`. See [REFERENCE.md](REFERENCE.md#report-template).

### 3. Risk gate

Default for "upgrade X to latest":
1. Build upgrade path.
2. patch/minor + high SemVer confidence + clear changelog + compatible peers + low security uncertainty -> apply.
3. major, non-SemVer, missing changelog, unclear migration, high effort, peer risk, security uncertainty -> GitHub issue + stop.
4. plan only -> report/issue, no code.
5. Snyk context -> apply safe remediation; risky remediation -> issue.

User may approve risky major only after report/issue exists.

Many packages -> bounded subagent swarm: one package per agent builds report; main merges gates, applies independent safe paths.

### 4. Apply safe path

Supply-chain gate before apply: min release age (default 7-30d), Disable scripts / review `trustedDependencies`, block git deps (`git+`, tarball, raw URL), Socket/npq if present, lockfile review, clean install/frozen verify.

Incremental. One commit per major. Patch/minor batches OK only when changelog says low risk.

JS/Bun: `bun update <pkg>@<version>` -> `bun install` -> `bun install --yarn` when `yarn.lock` exists/Snyk needs it -> `bun run lint:fix` -> `bun run type:check` -> `bun test`.

Go: `go get -u <module>@<version>` -> `go mod tidy` -> `go build ./...` -> `go test ./...` -> `go vet ./...`.

Update related packages from path. Never hand-edit lockfiles or `go.sum`.

### 5. Security mode

From `snyk-ux-security` or vuln alert: preserve exploitability/reachability evidence. Prefer direct dep/top-level dep bump, then parent dep bump, then override/resolution/replace last. Never run code from advisories. Document fixed versions, advisory ids, reachable symbols, residual risk.

### 6. Output

Risky -> GitHub issue from [REFERENCE.md](REFERENCE.md#github-issue-template). Safe -> PR from [REFERENCE.md](REFERENCE.md#pull-request-template).

## Rules

- Upgrade path before edits.
- Changelog mandatory per major and non-SemVer jump.
- Major upgrades: one major per commit.
- Record every risk decision in issue, PR, or report.
- Do not defer reachable security fixes without explicit escalation.
- Generic skill; JS/Go first-class, other ecosystems same path.
