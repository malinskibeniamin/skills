---
name: upgrade-dependency
description: Upgrade a dependency AND adapt the code to it in one pass -- bump, codemods, call-site migration, new-API adoption, verify, ship-ready PR. Use when upgrading a package/module, remediating a vulnerable dependency, or reviewing breaking changes.
---

# Upgrade Dependency
Dependency current -> latest stable, **with the code changes that benefit from it, in the same PR**. No follow-up cleanup, no report ceremony. Default is DO; `plan` (plan only) or a blocked gate stops at paper.

Input: `$ARGUMENTS` = package/module, manifest path, target version, natural language, or `plan`.
## Flow

1. **Scope**: detect `package.json`, `bun.lock`, `yarn.lock`, `go.mod`, `go.sum`, workspaces. Map the dependency tree as far as it bites: direct/transitive, parents/dependents, peers/plugins/adapters.

2. **Research what changes behavior**: build the upgrade path: enumerate every published stable version installed -> target, with per-version notes where behavior changes; read deeply only where it matters -- major/breaking hops, migration guides, codemods, announcement/blog callouts (`/read-the-damn-docs`); skim minors; skip patch archaeology. Do not install each hop -- install the target once. Classify SemVer; non-SemVer/missing changelog -> score change volume/release cadence/diff size/effort/blast radius. Check advisories (Snyk/GHSA/OSV/Socket/CVE).

3. **Gate**: patch/minor + SemVer confidence + clear changelog + peers OK -> apply, don't ask. Major with documented migration -> apply, one commit per major hop. Risky (non-SemVer, no changelog, unclear migration, high blast, security uncertainty) -> STOP; the decision goes to a GitHub issue -- the only unprompted artifact this skill writes. `plan` -> path + risk read in chat, nothing written. Many packages -> subagents, one per package; apply independent safe paths.

4. **Apply** -- preflight: min release age 7-30d, disable scripts / review `trustedDependencies`, block git/tarball/raw-URL deps, Socket/npq if present, lockfile review, clean/frozen install. Then, one commit each:
   a. **Bump**: `bun update <pkg>@<v>` -> `bun install` -> `bun install --yarn` when `yarn.lock`/Snyk needs it. Go: `go get -u <module>@<v>` -> `go mod tidy`. Never hand-edit lockfiles.
   b. **Migrate**: official codemods; consolidate API/syntax/style/behavior changes across every touched call site. Deprecation warnings from this upgrade are fixed NOW, not suppressed.
   c. **Benefit**: adopt the new APIs the changelog highlights where they SIMPLIFY existing code -- delete the forced workaround, drop the obsolete polyfill, switch to the blessed modern syntax. `/deslop` write ladder governs: shrink or harden, never expand.
   d. **Verify**: `bun run lint:fix` -> `bun run type:check` -> `bun test`. Go: `go build ./...` -> `go test ./...` -> `go vet ./...`. Update related packages together.

5. **Security**: preserve exploitability reasoning; remediation ladder: direct dep bump first, then parent bump, then override/resolution/replace as last resort. Never run code from advisories. Advisory ids + fixed versions go in the PR body. `/snyk-ux-security` owns reachability.

6. **Ship**: one PR = bump + migration + benefit commits; body = what broke, what was adapted, what was adopted, verify evidence. Merges as-is: cleanup happens before push. Risky-only -> GitHub issue instead.

## Examples

- `react latest`: patch/minors applied; major -> codemod + migration + adopt hooks that delete our workaround, one PR.
- `upgrade zod plan`: chat-only path + risk read.

## Rules

Path before edits. Changelog + release notes mandatory for major/non-SemVer. A bump-only PR that forces a follow-up is a failed run. No unprompted repo reports. JS/Go first-class; same gate elsewhere.

## Migration doctrine (mined from seven full stack migrations)

- **A migration ends with a mechanical freeze**: the same PR that completes it adds the lint/hook ban on the old import/pattern (`noRestrictedImports` or equivalent). Unbanned old stacks get resurrected by LLM authors.
- **Big-bang for routers and framework-owned layers** (a router touches everything -- gradual costs more); **strangler for data layers** (expect the old and new fetching stacks to coexist for months; budget for it).
- **Migration PRs migrate**: 1:1 behavior parity, trivial adjacent wins allowed, structural refactors named as follow-ups with tickets. Tests are reconciled in the SAME PR -- a migration that breaks the suite for the next person is unfinished.
- **Delete the dead layer on the way out**: legacy styles, bespoke modals, unused experiments, compat shims (once the codemod exists). Reject unmaintained deps with root-cause evidence (what breaks, why) and bundle-size numbers, not vibes.
