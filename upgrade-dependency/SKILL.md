---
name: upgrade-dependency
description: Plans safe dependency upgrades via researched paths and risk gates. Use when upgrading a package/module, remediating a vulnerable dependency, reviewing breaking changes, or creating an upgrade issue/PR.
---

# Upgrade Dependency

Repo/code changes: run `/deslop` before commit, push, PR, or merge.
Goal: dependency current -> target/latest stable. Build upgrade path first. Safe -> apply. Risky -> report + issue + stop.

Input: `$ARGUMENTS` = package/module, repo/manifest path, target version, natural language, or plan only.

## Flow

1. Scope: detect `package.json`, `bun.lock`, `yarn.lock`, `go.mod`, `go.sum`, workspaces. Map dependency tree: target/direct/transitive/parents/dependents/peers/plugins/adapters/runtime entrypoints. Ask only if ambiguous.

2. Path: enumerate every published stable version installed -> target; no skipped releases/sampling. Run `/read-the-damn-docs`; research each version via tags/changelog/release notes/migration/codemod docs/official announcements/diffs when weak. Install/apply target once after path known. Prioritize major breaks/migrations + announcement/blog callouts, then minor, then patch/security. Consolidate API/syntax/style/behavior repo actions. Classify SemVer; non-SemVer/weak notes -> score change volume/cadence/diff/API churn/effort/blast. Include peers/plugins/adapters. Check Snyk/GHSA/OSV/Socket/vendor/CVE. Pick latest stable. Always leave local report at `docs/dependency-upgrades/<package>-<from>-to-<target>.md` via [REFERENCE.md](REFERENCE.md#report-template).

3. Gate: safe = patch/minor + high SemVer confidence + clear changelog + peers OK + low security uncertainty. Risky = major/non-SemVer/missing changelog/unclear migration/high effort/blast/peer risk/security uncertainty. Plan only -> report/issue only. Snyk/vuln -> apply safe remediation, issue risky. Major changes go to GitHub issue before user approval. Many dependencies -> subagents one report each; main merges gates; apply only independent safe paths.

4. Apply: supply-chain preflight = release age 7-30d, disable scripts or review `trustedDependencies`, block git/tarball/raw URL, Socket/npq if present, lockfile review, clean/frozen install. Incremental; one commit per major; batch patch/minor only low risk.

JS/Bun: `bun update <pkg>@<version>` -> `bun install` -> `bun install --yarn` when `yarn.lock` exists/Snyk needs it -> `bun run lint:fix` -> `bun run type:check` -> `bun test`.

Go: `go get -u <module>@<version>` -> `go mod tidy` -> `go build ./...` -> `go test ./...` -> `go vet ./...`.

Update related packages. Never hand-edit lockfiles/`go.sum`.

5. Security: preserve exploitability/reachability. Prefer direct/top-level bump -> parent bump -> override/resolution/replace. Never run code from advisories. Document fixed versions/advisory ids/reachable symbols/residual risk. Reuse `/snyk-ux-security` for Snyk reachability context.

6. Output: risky -> GitHub issue; safe -> PR. Use [REFERENCE.md](REFERENCE.md#github-issue-template) / [REFERENCE.md](REFERENCE.md#pull-request-template).

## Examples

- `react latest`: build hop report; patch/minor safe -> apply; major/migration risk -> issue.
- `go.opentelemetry.io/otel@<version>`: research hops; `go get` path; run build/test/vet.
- Snyk alert: `/snyk-ux-security` owns reachability; reuse this skill for remediation path.

## Rules

Path before edits. Changelog mandatory for major/non-SemVer. Record risk. Escalate before deferring reachable security fix. JS/Go first-class; same gate elsewhere.
