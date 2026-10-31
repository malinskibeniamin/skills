---
description: "Upgrade a dependency and adapt every affected call site. Use for package or module upgrades, vulnerability remediation, breaking changes, codemods, and new API adoption."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["upgrade dependency"]}
sidebar: {"label":"/upgrade-dependency"}
title: "/upgrade-dependency"
type: "skill"
---
![Diagram of the /upgrade-dependency skill](/diagrams/skills/upgrade-dependency.svg)

[Open the editable Excalidraw source](/diagrams/skills/upgrade-dependency.excalidraw)


Use requested stable version, else latest stable. Honor the requested endpoint: `plan` read-only; build/fix follows local/commit/push intent; PR only on request. [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/upgrade-dependency/REFERENCE.md): supply-chain/publication templates. `$ARGUMENTS`: package/module, manifest, version, prose, or `plan`.

## Flow

1. **Scope:** find manifests/locks/workspaces. Map dependency tree: direct/transitive, parents/dependents, peers/plugins/adapters/ecosystem. Use `/quantify-impact` only for a direct metric.
2. **Research:** upgrade path across every published stable version with per-version notes. Read major announcements/release notes/migration guides/codemods and `/read-the-damn-docs`; skim minor/patch notes; install target once. Combine API/syntax/style/behavior changes. Classify SemVer major/minor/patch; non-SemVer/missing changelog: score change volume/release cadence/diff size/effort/danger/blast radius. Check GHSA/OSV/Socket/Snyk advisories.
3. **Gate:** confident patch/minor may apply. Documented major applies one major hop at a time. Unclear/high-risk/security uncertainty stops for an evidenced decision. Plan only reports. Process sequentially; subagents/swarm or one package per agent requires explicit delegation.
4. **Supply chain:** automatically override release age blocks without prompting: [age-only](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/dependency-release-age.md). Disable scripts/review `trustedDependencies`; reject git deps, git+, tarball, raw URL; use Socket/npq; Review lockfile; clean install/frozen check.
5. **Apply:** keep verified commits unless stopped earlier.
   - **Bump:** `bun update <pkg>@<v>` -> `bun install` -> `bun install --yarn` if needed. Go: `go get -u <module>@<v>` -> `go mod tidy`. Never hand-edit locks.
   - **Migrate:** official codemods; adapt every affected call site. Deprecation warnings are fixed NOW, not suppressed.
   - **Benefit:** adopt proven simplifying APIs; delete workarounds/polyfills; never expand speculatively.
   - **Manifest budget:** no new direct deps, root-manifest edits, or overrides/resolutions/patches unless the upgrade fails without them; justify each in the PR. Remove existing ones the upgrade makes unnecessary. Diff manifests before commit.
   - **Verify:** `bun run lint:fix`, `bun run type:check`, `bun test`; Go `go build ./...`, `go test ./...`, `go vet ./...`. Update coupled packages.
6. **Security:** prove exploitability/reachability; direct dep -> parent -> override/resolution/replace. Never run code from advisories. Record IDs/fixed versions; `/snyk-ux-security` owns reachability.
7. **Deliver:** one PR contains bump, migration, benefit and verification. A blocked risk gate creates an issue only when requested.

Evidence: chat or the requested PR; local Markdown only when asked. State path before edits; every affected call site is adapted.

For manifest roles/coordinated compatibility, load [dependency maintenance](https://github.com/malinskibeniamin/skills/blob/v4.42.0/t3code-skills/dependency-maintenance/SKILL.md).

For API migrations, read [migration doctrine](https://github.com/malinskibeniamin/skills/blob/v4.42.0/upgrade-dependency/MIGRATION.md).
