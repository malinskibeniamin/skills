# Publication branch

Read only when the requested endpoint includes a commit, pull request, cloud review, or aggregate report.

### 2i. Open PR

```bash
# Resolve metadata
triggerer=$(gh api user --jq .login)
team_reviewers=$(bash "$SKILL_DIR/scripts/codeowners-teams.sh" "<path>")
# team_reviewers must be non-empty; if empty, fall back to path-prefix
# -> team map (documented below). Never open a PR with only individual
# reviewers -- require >=1 team group.
labels="security,dependencies,snyk,lang/<ts|go>"
# Add team-domain labels resolved from CODEOWNERS (e.g. team/ux,
# team/ai, team/console-ui). Add status labels based on state.
[ -s .snyk_diff ]            && labels="$labels,dismissals"
[ -s .overrides-added ]      && labels="$labels,overrides-added"
[ -s .react19-blocked ]      && labels="$labels,react19-blocked"

# Always add security team group when .snyk touched or overrides added.
security_team="@<org>/security"

gh pr create \
  --title "fix(deps): snyk sweep <path> -- $(date +%Y-%m-%d)" \
  --body-file .pr-body.md \
  --reviewer "$team_reviewers,$security_team" \
  --label "$labels,team/<slug>" \
  --assignee "$triggerer"
```

**Assignee rule**: one assignee per PR, = the user who triggered
the sweep. Resolve via `gh api user --jq .login` (the authenticated
gh user). Gives clear accountability: anyone scanning open PRs sees
who ran the audit.

**Reviewer rule**: at least one **team group** (`@<org>/<team>`)
resolved from CODEOWNERS entries for the path. Falls back to
path-prefix inference only if CODEOWNERS has no team owner (edit
CODEOWNERS rather than leaving the PR without a team). Individual
committers from `git log` may be added *in addition*, but a PR
with only individual reviewers is rejected (opens a follow-up note
asking the user to update CODEOWNERS). Security team group is
added automatically whenever the PR touches `.snyk` (dismissals)
or adds an `overrides` entry -- they need visibility on every
dismissal + override.

**Label rule**: always `security`, `dependencies`, `snyk`,
`lang/ts` or `lang/go`. Plus team-domain label derived from
CODEOWNERS team slug (examples from Redpanda monorepo: UX team
paths, AI team paths, Console UI team paths -- resolved by path,
not hardcoded). Plus status labels: `dismissals` (on any `.snyk`
add or remove), `overrides-added`, `react19-blocked`, `cleaned-up`
(when `.snyk` entries removed). Labels give one-click filters for
dashboards and oncall sweeps.

### PR body template (`.pr-body.md`)

```markdown
## Summary
Snyk sweep for `<path>` (ecosystem: <js|go|both>) -- <n> CVEs
addressed, <m> newly dismissed, <k> existing `.snyk` entries
revisited, <c> cleaned up (transitive gone / reachable now /
expired). Triggered by @<triggerer>.

## Bumped (top-level direct first, parent dep second)
| Package | From | To | CVE | Severity | Priority path | Major hops |
|---|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | direct / parent / override | 7->8->9 |

## Reachability diagnosis (`/diagnosing-bugs`)
| Package | Finding | Feedback loop | Real potential vulnerability? | Decision |
|---|---|---|---|---|
| <pkg> | <CVE/GHSA> | grep/import graph / harness / Socket.dev critical vector | yes/no | bump parent / direct bump / dismiss to `.snyk` |

## Package.json admission gate
| Package | Admission reason | Why `.snyk` dismissal is not enough | Removal issue if override |
|---|---|---|---|
| <pkg> | already-direct / reachable parent / override-last-resort | <proof> | #NN or none |

## Internal skill gates
- `/resilience-review`: PASS / NEEDS_GUARDS / BLOCKED -- <summary>
- `/to-tickets`: <n> issue(s) created or drafted for missing release age gate / overrides / React 19 / upstream no fix / Snyk project ambiguity / Socket.dev critical vector
- `/review`: PASS / BLOCKED -- package.json admission gate, `/steelman`, `/diagnosing-bugs`, and `.snyk` evidence checked

## Supply-chain gate warnings
- WARN: release age gate missing for `<package-manager>` (if absent).
  Follow-up: configure the package-manager-native minimum release age
  gate (`bunfig.toml`, `.npmrc`, `pnpm-workspace.yaml`, or
  `.yarnrc.yml`) before broad dependency churn.

## Socket.dev web check
No Socket CLI was installed or required.

| Package | Socket URL | Highest alert | Attack vector | Decision impact |
|---|---|---|---|---|
| <pkg> | https://socket.dev/npm/package/<pkg> | <alert> | install script / typosquat / unstable ownership / native code / shell access / environment variable access / none | bumped / dismissed / escalated |

## Dismissed (not exploitable)

All entries below were applied via `snyk ignore` (Snyk CLI writes to
`.snyk` policy file, committed in this PR). If the existing-project
preflight found an exact match, `snyk monitor` pushed them to that
existing Snyk IO project. If no exact match existed, monitor was
skipped rather than creating a new project; the committed `.snyk` file
is still the audit artifact. PR-description text alone is not an audit
artifact.

| Package | CVE | Vulnerable symbol | Our usage check | Reason | Snyk ignore id | Expiry | IO link |
|---|---|---|---|---|---|---|---|
| hono-server | CVE-XXXX-YYYY | server.listen | grep -rn "hono-server": only client-side import via MCP SDK protocol; server feature never called | Server feature not imported -- attack surface zero in this repo | 12345 | 2026-07-22 | [IO](https://app.snyk.io/...) |

Verify: `snyk test` shows each row as `Ignored` before PR open.

## Dismissed (cleaned up)

Existing `.snyk` entries removed this sweep -- transitive gone,
reachability changed, or expiry passed. Existing-project `snyk monitor`
pushed the cleanup to IO when the project match was exact; otherwise
monitor was skipped to avoid project churn.

| Package | Original CVE | Original ignore id | Reason removed | Proof |
|---|---|---|---|---|
| <pkg> | CVE-... | <id> | Transitive bumped out / reachable now / expired | `bun why <pkg>` -> no results |

## Overrides added (follow-up to remove)
| Package | CVE | Why direct + parent bump blocked | Tracking issue |
|---|---|---|---|
| ... | ... | upstream has no fix yet; filed #NN | #NN |

## Migration notes (per major hop)
- `pkg 7 -> 8`: <breaking changes handled, code locations>
- `pkg 8 -> 9`: <breaking changes handled, code locations>

## Skipped (React 19 peer only)
- `pkg` -- requires React 19, frozen on React 18, tracked as follow-up

## Lockfiles
JS: both regenerated via `bun i && bun i --yarn`. Snyk IO scans
yarn.lock; runtime uses bun.lock.
No npm commands ran, and no `package-lock.json` was created or
updated. If `package-lock.json` already existed in a bun repo, it was
reported as supply-chain drift instead of being used.
Go: `go mod tidy` ran; `go.mod` + `go.sum` committed together.

## Changelog review
<link per bumped pkg>

## Verify
JS:
- [x] `bun run lint:fix`
- [x] `bun run type:check`
- [x] `bun test`
- [x] Minimum release age gate audit completed; warnings recorded if missing
- [x] Socket.dev web check completed for JS packages; no Socket CLI used
- [x] Snyk rescan clean for addressed CVEs
- [x] `.snyk` committed with <n> new ignore entries
- [x] Existing-project `snyk monitor` pushed ignores to IO, or skipped
      with reason and no new project created
- [x] `snyk test` confirms all dismissed items show as `Ignored`
Go:
- [x] `go build ./...`
- [x] `go test ./...`
- [x] `go vet ./...`
- [x] `govulncheck ./...` clean for addressed CVEs

## Cloud review
Triggered via `<workflow>`.
```

### 2j. Trigger cloud review
```bash
gh workflow run <inferred_workflow> --ref <branch>
```

Skip silently if no cloud-review workflow detected.

### 2k. Report
Subagent returns: path, ecosystem (js/go/both), branch, PR URL,
triggerer (assignee), team reviewers (resolved from CODEOWNERS),
labels applied, `.snyk` revisited count, `.snyk` cleaned-up count
(transitive gone / reachable now / expired), newly-dismissed list
(CVE + reason + snyk ignore id + expiry), existing-project
`snyk monitor` status (pushed/skipped + reason), bumped list,
overrides-added list (CVE + blocker), JS release-age gate status
(configured/missing + package manager), Socket.dev findings
(package + highest alert + decision impact),
skipped list (reason), CI status.

## Aggregate

Main agent gathers reports. Summary table:

| Path | Ecosystem | PR | Fixed (direct) | Fixed (parent) | Overrides added | Dismissed | Major migrations | React19-blocked |
|---|---|---|---|---|---|---|---|---|

Show React-19-blocked pkgs -- candidates for the React 18 -> 19
migration plan. Show overrides-added as a follow-up backlog --
remove each once upstream ships a fix. Show release-age gate missing
warnings and Socket.dev high/critical alerts as supply-chain follow-up
items.
