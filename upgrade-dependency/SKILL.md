---
name: upgrade-dependency
description: Upgrade a dependency and adapt every affected call site. Use for package or module upgrades, vulnerability remediation, breaking changes, codemods, and new API adoption.
---

# Upgrade Dependency
Move to requested stable version; use latest stable if omitted. Adapt calls.
Honor requested endpoint: `plan` reads only; build/fix verifies, commits, and pushes unless user says local,
no-commit, or no-push. PR only when requested.
Read [REFERENCE.md](REFERENCE.md) for supply-chain checks and issue/PR templates when those
branches fire.

Input: `$ARGUMENTS` = package/module, manifest path, target version, natural language, or `plan`.
## Flow

1. **Scope**: detect manifests/lockfiles (`package.json`, `bun.lock`, `go.mod`) and workspaces. Map the dependency tree: direct/transitive, parents/dependents, peers/plugins/adapters. Run `/quantify-impact` for a direct metric.

2. **Research what changes behavior**: build the upgrade path: every published stable version installed -> target with per-version behavior notes; read deeply only at major/breaking hops (migration guides, codemods, announcements, `/read-the-damn-docs`); skim minors, skip patch archaeology; install the target once, not each hop. Classify SemVer; non-SemVer/missing changelog -> score change volume/cadence/diff size/blast radius. Check advisories (Snyk/GHSA/OSV/Socket/CVE).

3. **Gate**: confident patch/minor -> apply. Documented major -> apply one major hop at a
   time. Non-SemVer, unclear migration, high blast, or security uncertainty -> stop with
   evidence and the required decision. `plan` -> report the path and risk in chat. Process
   packages sequentially; explicit delegation or `/swarm` may assign independent lanes.

4. **Apply** -- preflight: min release age 7-30d, disable scripts / review `trustedDependencies`, no git/tarball/raw-URL deps, Socket/npq if present, lockfile review, clean install. Keep separate verified commits unless the user requested an earlier stop:
   a. **Bump**: `bun update <pkg>@<v>` -> `bun install` -> `bun install --yarn` when `yarn.lock`/Snyk needs it. Go: `go get -u <module>@<v>` -> `go mod tidy`. Never hand-edit lockfiles.
   b. **Migrate**: official codemods; consolidate API/syntax/style/behavior changes across every touched call site. This upgrade's deprecation warnings are fixed NOW, not suppressed.
   c. **Benefit**: adopt changelog-highlighted APIs where they simplify existing code -- delete forced workarounds and obsolete polyfills; shrink or harden, never expand speculatively.
   d. **Verify**: `bun run lint:fix` -> `bun run type:check` -> `bun test`. Go: `go build ./...` -> `go test ./...` -> `go vet ./...`. Update related packages together.

5. **Security**: preserve exploitability reasoning; remediation ladder: direct dep bump > parent bump > override/resolution/replace. Never run code from advisories. Advisory ids + fixed versions in the PR body. `/snyk-ux-security` owns reachability.

6. **Requested delivery**: one PR contains bump + migration + benefit and records verification.
   A blocked risk gate creates an issue only when requested.

## Rules

Evidence belongs in chat or the requested PR; create local Markdown only when asked. State the
path before edits. Read changelog + release notes for major/non-SemVer changes. Completion
means every affected call site is adapted. JS and Go are first-class.

## Migration doctrine

Finish = freeze: the completing PR bans the old import/pattern (lint/hook) or LLM authors resurrect it. Big-bang for routers/framework layers; strangler for data layers (old+new coexist -- budget it). Migration PRs migrate: 1:1 parity, tests reconciled in the SAME PR, structural refactors ticketed. Delete the dead layer (legacy styles, shims, one-offs) on exit.
