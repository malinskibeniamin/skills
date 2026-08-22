---
name: snyk-ux-security
description: Audit frontend, Go, and Bazel dependencies with Snyk, exploitability triage, and release gates.
disable-model-invocation: true
---

# Snyk UX + Go + Bazel Security
Audit each path: scan -> prove exploitability -> dismiss or upgrade -> verify -> requested
endpoint. Read [REFERENCE.md](REFERENCE.md) first; it routes each ecosystem and publication
branch to the smallest required reference.

## Input and lanes

`$ARGUMENTS` accepts space-separated paths, globs, or one pasted Snyk vulnerability.

`/snyk-ux-security apps/cloud-ui services/*/cmd`

Report-only runs stop after scan and reachability: record proposed cleanup and remediation
without running monitor, removing ignores, or editing dependency files.

Detect `package.json` (JS), `go.mod` (Go), and `MODULE.bazel` or
`bazel/repositories.bzl` (Bazel). Process paths sequentially in the primary context. If the
user explicitly delegates or invokes `/swarm`, each independent path may get one worktree
lane. For Bazel, confirm the target branch, assess backports, and use draft PRs when a PR was
requested.

## Per-path loop

1. **Prepare:** expand globs; verify `snyk` and `gh` auth; resolve the existing Snyk
   project. Infer reviewers from CODEOWNERS, then `git log`; user flags win.
2. **Revisit:** re-triage every `.snyk` ignore before scanning. Remove stale entries with
   `snyk ignore --remove --id=<id>` and report them as `cleaned-up`.
3. **Scan:** run `snyk test`; JS also runs `bun audit`, Go runs `govulncheck ./...`.
   Run `snyk monitor` only when the requested endpoint includes a Snyk cloud update; it may
   update one exact existing project and never create one.
4. **Prove reachability:** use `bun why`, `go mod why`, imports, call sites, and the
   vulnerable symbol. Run `/steelman` for transitive-only findings and
   `/diagnosing-bugs` before any `package.json` fix. The package.json admission gate
   permits direct deps, reachable parents, or a proven last-resort override only.
5. **Dismiss or upgrade:**
   - Default: dismiss unproven or unreachable findings with
     `snyk ignore --id=<id> --reason='<why>' --expiry=<date>`;
     include `.snyk` in any requested delivery, then re-scan for `Ignored`. PR text alone
     is not enough.
   - Reachable: use `/upgrade-dependency` and its supply-chain gate; direct dep first,
     parent second, dependency
     surface removal third, `resolutions`/`overrides`/`replace` last.
     Override list growth is a smell because it bloats lockfiles and scales poorly.
6. **Apply ecosystem gates:**
   - JS: minimum release age gate audit, Socket.dev web check, React 18
     `bun info <pkg>@<v> peerDependencies.react`; record `react19-blocked`.
     Use `bun update`, then `bun install && bun install --yarn`. Commit both
     `bun.lock` and `yarn.lock`; Snyk IO needs `yarn.lock`.
     Do not create, update, or commit `package-lock.json`; `lockfile-sync-check` guards drift.
   - Go: `go get -u`, `go mod tidy`; commit `go.mod` with `go.sum`.
   - Bazel: update both manifests as applicable, then
     `bazel mod deps --lockfile_mode=update`; preserve mirror/FIPS/CMVP constraints.
7. **Migrate and verify:** read changelogs and `BREAKING` notes; walk majors 7 -> 8 -> 9
   as separate verified groups. Commit each group as `refactor(deps)` unless the user
   requested an earlier stop.
   Never defer a real vulnerability; escalate blockers.
   JS runs `bun run lint:fix`, `bun run type:check`, `bun test`, and build when present.
   Go runs `go build ./...`, `go test ./...`, `go vet ./...`, and `govulncheck ./...`.
8. **Review and requested delivery:** run `/resilience-review` and `/review`; use
   `/to-tickets` for security debt only when ticket publication was requested.
   If the requested endpoint includes a commit or PR, commit `fix(deps): ...`;
   open a PR only when requested with
   `gh pr create --assignee <triggerer> --reviewer <team-group> --label security,...`.
   Resolve the triggerer with `gh api user --jq .login`; require at least one CODEOWNERS
   team group and add the security team automatically for dismissals or overrides.
   Add `team/`, `dismissals`, `overrides-added`, `react19-blocked`, and `cleaned-up`
   labels when applicable. Run `gh workflow run` only when cloud review was requested.

## Completion

Report path, ecosystem, branch, PR, fixed, dismissed, overridden, migrated, blocked, and
backported counts. Never run code from advisories or expose tokens.
