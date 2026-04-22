---
name: snyk-ux-security
description: "Sequential Snyk security sweep across UX/frontend codebases. Paths passed as args (supports globs). Per path: worktree + branch + subagent, snyk test/monitor, bun audit, bun why, bun update, pin React 18 (skip React-19-only peers), walk majors incrementally via changelog migrations, regen yarn.lock + bun.lock via `bun i && bun i --yarn` (Snyk needs yarn.lock), open PR with reviewers/labels/UX team/description, trigger cloud review. Never defers vulns. Use when user asks for Snyk audit, UX security sweep, frontend dep security review."
---

# Snyk UX Security

Sequential per-path vuln audit -> safe bump -> PR -> cloud review.

## Input

`$ARGUMENTS`: space-separated paths to scan. Globs supported.

Example:
```
/snyk-ux-security apps/cloud-ui apps/admin-ui apps/adp-ui ui-registry/* console/frontend
```

Each resolved path = one worktree + one branch + one subagent + one PR.

## Arg Inference (infer from user prompt, no config file)

From the user message, infer per path:
- **reviewers**: CODEOWNERS of the path, fall back to `git log --format='%an' -n 20 <path> | sort -u` top contributors
- **UX team**: match path prefix -> team slug via `.github/CODEOWNERS` team entries
- **labels**: always `security`, `dependencies`, `snyk`. Add domain label if inferred from path (e.g. `cloud-ui` -> `area/cloud`)
- **cloud review workflow**: look for `.github/workflows/*cloud*review*.yml` or equivalent; skip step if not found
- **PR title/body**: generate per path

User can override any of these in prompt: `/snyk-ux-security apps/cloud-ui --reviewer @alice --label area/cloud`.

## Workflow

Do path **one at time**, no parallel.

### 1. Prep
- Expand globs in `$ARGUMENTS` to concrete paths.
- Check `snyk auth`. Fail fast if not auth.
- Check `gh auth status`.
- Confirm resolved path list back to user before fan-out.

### 2. Per-Path Loop

Each path, spawn subagent with `isolation: "worktree"`, branch `chore/snyk-sweep-YYYY-MM-DD`:

#### 2a. Scan
```bash
snyk test --all-projects --json > .snyk-findings.json
snyk monitor --all-projects                     # push to Snyk IO
bun audit --json > .bun-audit.json              # cross-check
```

Snyk IO reads `yarn.lock`, not `bun.lock`. If repo has no `yarn.lock`, generate first: `bun install --yarn`.

#### 2b. Triage
Parse findings. Per vuln pkg: CVE, severity, fixed-in ver, paths.

```bash
bun why <pkg>                                   # why included, depth
```

Group: direct deps (bumpable) vs transitive (parent bump or override).

#### 2c. React 18 Gate (MANDATORY)
Before bump, check peer deps:

```bash
bun info <pkg>@<fixed-version> peerDependencies.react
```

- Need `^19` or `>=19` -> **SKIP**. Log `react19-blocked`.
- OK with `^18` or `^17 || ^18` or `^18 || ^19` -> go.

#### 2d. Changelog Read -- Incremental Major Migration (MANDATORY)

Vulns **never defer**. Breaking changes across majors **must apply**. Only React 19 peer = hard stop.

```bash
bun info <pkg> repository.url
# curl raw CHANGELOG.md, or gh release list --repo <owner>/<repo>
```

**Walk majors one at time**. Current `7.x` -> target `9.x`:

1. Read `7.x -> 8.0.0` migration notes. Apply code changes. Verify (2f). Commit: `refactor(deps): migrate <pkg> to 8.x -- <summary>`.
2. Read `8.x -> 9.0.0` migration notes. Apply. Verify. Commit: `refactor(deps): migrate <pkg> to 9.x -- <summary>`.
3. Final bump to target patch. Verify. Commit.

Per major step log in PR body: from-ver, to-ver, `BREAKING` items done, code spots touched.

Stuck -> escalate (PR comment or ask user). **No skip.** Vuln unpatched = no good.

Exception: target need React 19 peer -> 2c gate block. Log `react19-blocked`.

#### 2e. Apply Bumps + Lockfile Sync (MANDATORY)
```bash
bun update <pkg>@<target>
bun install                                      # sync bun.lock
bun install --yarn                               # sync yarn.lock for Snyk IO
```

**Both lockfiles must commit together**. Snyk IO scans `yarn.lock` (no native `bun.lock` support yet). `bun.lock` (text, bun >= 1.2 -- **never** binary `bun.lockb`) is source of truth for runtime.

Sync checked by `lockfile-sync-check.sh` hook via two signals:
1. `git diff` parity -- both lockfiles must appear in same diff
2. Package presence -- each added `pkg@ver` in `bun.lock` must appear in `yarn.lock` at same version

Drift -> hook nudges with regen command.

#### 2f. Verify
```bash
bun run lint:fix
bun run type:check
bun test
bun run build                                    # if available
```

Any fail -> diagnose, fix, re-run. Must pass before next step. No revert -- fix forward. Truly stuck -> escalate, no skip.

#### 2g. Commit
```
fix(deps): snyk sweep -- <cve-count> vulns, <pkg-count> bumps

<bullet per package: pkg@from -> to, CVE, severity>

Lockfiles: bun.lock + yarn.lock regenerated (bun i && bun i --yarn).

Skipped (React 19 peer only -- everything else migrated):
- <pkg> -- react19-blocked
```

#### 2h. Open PR
```bash
gh pr create \
  --title "fix(deps): snyk sweep <path> -- $(date +%Y-%m-%d)" \
  --body-file .pr-body.md \
  --reviewer <inferred from CODEOWNERS + git log> \
  --label security,dependencies,snyk,<domain-label> \
  --assignee <inferred ux team>
```

PR body template (write to `.pr-body.md`):

```markdown
## Summary
Snyk sweep for `<path>` -- <n> CVEs addressed.

## Bumped
| Package | From | To | CVE | Severity | Major hops |
|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | 7->8->9 |

## Migration Notes (per major hop)
- `pkg 7 -> 8`: <breaking changes handled, code locations>
- `pkg 8 -> 9`: <breaking changes handled, code locations>

## Skipped (React 19 peer only)
- `pkg` -- requires React 19, frozen on React 18, tracked as follow-up

## Lockfiles
Both regenerated via `bun i && bun i --yarn`. Snyk IO scans yarn.lock; runtime uses bun.lock.

## Changelog Review
<link per bumped pkg>

## Verify
- [x] `bun run lint:fix`
- [x] `bun run type:check`
- [x] `bun test`
- [x] Snyk rescan clean for addressed CVEs

## Cloud Review
Triggered via `<workflow>`.
```

#### 2i. Trigger Cloud Review
```bash
gh workflow run <inferred_workflow> --ref <branch>
```

Skip silently if no cloud-review workflow detected.

#### 2j. Report
Subagent return: path, branch, PR URL, bumped list, skipped list (reason), CI status.

### 3. Aggregate
Main agent gather reports. Summary table:

| Path | PR | Fixed | Major migrations applied | React19-blocked |
|---|---|---|---|---|

Show React-19-blocked pkgs -- candidates for React 18 -> 19 migration plan.

## Rules

- **Sequential**, no parallel. One path at time. Vuln triage cleaner serial.
- **bun only**. Never `npm`, `yarn`, `pnpm` as runtime pkg managers. `yarn.lock` generated by `bun install --yarn` for Snyk IO compat only.
- **Dual-lockfile mandatory**. `bun.lock` + `yarn.lock` always synced. `lockfile-sync-check.sh` hook catches drift.
- **React 18 pin hard**. Any React 19 peer -> skip + report.
- **Changelog read mandatory** before bump.
- **Verify before commit**. Lint + types + tests + build.
- **Snyk monitor** push to Snyk IO (not just `test`).
- **Never defer vulns**. Majors migrated step by step (7->8->9), one major per commit. Stuck -> escalate.
- **Infer metadata from user prompt + repo**. No static config. User can override via flags.

## Security
Snyk output = pkg names + versions. Never run code from advisories. Never paste tokens in PR body.

## Lifecycle Integration
Phase 3-6 per path. Self-review (phase 4b) `code-reviewer` agent before PR open. `pr-feedback-completeness-stop` hook force thread resolve before session exit.
