---
name: upgrade-dependency
description: Upgrade a dependency and adapt every affected call site. Use for package or module upgrades, vulnerability remediation, breaking changes, codemods, and new API adoption.
---

# Upgrade Dependency
Dependency current -> latest stable, **with beneficial code changes in the same PR**. Default is DO; `plan` (plan only) or a blocked gate stops at paper.
Read [REFERENCE.md](REFERENCE.md) for supply-chain checks and issue/PR templates when those
branches fire.

Input: `$ARGUMENTS` = package/module, manifest path, target version, natural language, or `plan`.
## Flow

1. **Scope**: detect manifests/lockfiles (`package.json`, `bun.lock`, `go.mod`) and workspaces. Map the dependency tree: direct/transitive, parents/dependents, peers/plugins/adapters. Run `/quantify-impact` for a direct metric.

2. **Research what changes behavior**: build the upgrade path: every published stable version installed -> target with per-version behavior notes; read deeply only at major/breaking hops (migration guides, codemods, announcements, `/read-the-damn-docs`); skim minors, skip patch archaeology; install the target once, not each hop. Classify SemVer; non-SemVer/missing changelog -> score change volume/cadence/diff size/blast radius. Check advisories (Snyk/GHSA/OSV/Socket/CVE).

3. **Gate**: patch/minor + SemVer confidence + clear changelog + peers OK -> apply, don't ask. Major with documented migration -> apply, one commit per major hop. Risky (non-SemVer, no changelog, unclear migration, high blast, security uncertainty) -> STOP; one umbrella GitHub issue per blocked batch. `plan` -> path + risk read in chat, nothing written. Many packages -> subagents, one per package; apply independent safe paths.

4. **Apply** -- preflight: min release age 7-30d, disable scripts / review `trustedDependencies`, no git/tarball/raw-URL deps, Socket/npq if present, lockfile review, clean install. Then, one commit each:
   a. **Bump**: `bun update <pkg>@<v>` -> `bun install` -> `bun install --yarn` when `yarn.lock`/Snyk needs it. Go: `go get -u <module>@<v>` -> `go mod tidy`. Never hand-edit lockfiles.
   b. **Migrate**: official codemods; consolidate API/syntax/style/behavior changes across every touched call site. This upgrade's deprecation warnings are fixed NOW, not suppressed.
   c. **Benefit**: adopt changelog-highlighted APIs where they simplify existing code -- delete forced workarounds and obsolete polyfills; shrink or harden, never expand speculatively.
   d. **Verify**: `bun run lint:fix` -> `bun run type:check` -> `bun test`. Go: `go build ./...` -> `go test ./...` -> `go vet ./...`. Update related packages together.

5. **Security**: preserve exploitability reasoning; remediation ladder: direct dep bump > parent bump > override/resolution/replace. Never run code from advisories. Advisory ids + fixed versions in the PR body. `/snyk-ux-security` owns reachability.

6. **Ship**: one PR = bump + migration + benefit commits; body = what broke/adapted/adopted + verify evidence. Merges as-is: cleanup before push. Risky-only -> GitHub issue instead.

## Rules

Evidence: PR body or chat; never local Markdown reports. Reports only by explicit request. Path before edits. Changelog + release notes for major/non-SemVer. A bump-only PR is a failed run. JS/Go first-class.

## Migration doctrine

Finish = freeze: the completing PR bans the old import/pattern (lint/hook) or LLM authors resurrect it. Big-bang for routers/framework layers; strangler for data layers (old+new coexist -- budget it). Migration PRs migrate: 1:1 parity, tests reconciled in the SAME PR, structural refactors ticketed. Delete the dead layer (legacy styles, shims, one-offs) on exit.
