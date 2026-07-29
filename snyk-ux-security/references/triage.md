# Shared vulnerability triage

Read this branch for every ecosystem before choosing dismissal or remediation.

## Arg inference rules

From the user message, infer per path:

- **reviewers**: CODEOWNERS of the path; fall back to
  `git log --format='%an' -n 20 <path> | sort -u` top contributors.
- **team**: match path prefix -> team slug via `.github/CODEOWNERS`
  team entries. `apps/*-ui`, `ui-registry/*`, `console/frontend` ->
  UX team. `services/*`, `cmd/*`, paths with `go.mod` -> backend
  team.
- **labels**: always `security`, `dependencies`, `snyk`. Add a domain
  label if inferable from path (e.g. `cloud-ui` -> `area/cloud`;
  `services/ingest` -> `area/ingest`). Add `lang/go` on Go paths,
  `lang/ts` on JS paths.
- **cloud review workflow**: look for
  `.github/workflows/*cloud*review*.yml` or equivalent; skip the
  trigger step if none found.
- **PR title/body**: generate per path. Mention ecosystem.

User can override any of these in the prompt:
`/snyk-ux-security apps/cloud-ui --reviewer @alice --label area/cloud`.

## Per-path detail

Reachable remediation uses `/upgrade-dependency` as the upgrade primitive. This skill owns vulnerability triage and Snyk IO state; `/upgrade-dependency` owns the version path, SemVer confidence, changelog/migration/codemod research, related dependency checks, and apply-vs-issue risk gate.

Bazel remediation is intentionally separate from `/upgrade-dependency`:
the risk is usually in Bazel manifest semantics, release/backport branch
differences, S3-hosted artifacts, and FIPS validation. Use the
[Bazel branch](bazel.md) when the finding maps to
`MODULE.bazel` or `bazel/repositories.bzl`.

### 2a. Existing `.snyk` revisit (every run, before scan)

Run this before `snyk test` so the rescan reflects cleanup. Goal:
never let the `.snyk` policy file accumulate stale dismissals. Each
sweep should leave `.snyk` **shorter** than it started, unless the
codebase genuinely needs new ignores.

For every entry in the repo-root `.snyk` (if any):

1. **Still in the dep graph?**
   ```bash
   # JS
   bun why <pkg>
   # Go
   go mod why <module>
   ```
   No results / "not a dependency" -> the transitive was bumped out
   by a prior sweep. Remove the ignore:
   ```bash
   snyk ignore --remove --id=<issue-id>
   # or edit .snyk directly; publish only through the existing-project
   # monitor gate in 2a.1
   ```
   Log under PR `Dismissed (cleaned up)` section.

2. **Still not reachable?** If the transitive is present, re-run the
   exploitability check from 2b. If reachable now (new caller, new
   entrypoint, code moved), remove the ignore and proceed to 2c to
   upgrade/fix properly.

3. **Expiry passed?** If `expiry` is before today, the CLI already
   stops honoring it -- remove the entry so `.snyk` stays clean.

4. **Reason still valid?** Skim the reason; if the advisory surface
   changed (new CVE on same pkg, patch landed upstream), re-triage.

Report: include a `Revisited .snyk` count (existing entries
inspected) and a `Cleaned up` count (entries removed) in the PR
body + subagent 2k report. Cleanup trims long-term override debt.

### 2a.1 Scan + existing Snyk project preflight

`snyk monitor` creates a project in Snyk IO when the supplied identity
does not already exist. In this skill, audits must **not** create new
Snyk projects, targets, apps, or resources. The default audit signal is
`snyk test`; `monitor` is a gated publish step that reuses exactly one
existing Snyk project.

Resolve local context once:
```bash
audit_branch=$(git rev-parse --abbrev-ref HEAD)   # PR/git only
repo_slug=$(basename "$(git rev-parse --show-toplevel)" .git)
remote_url=$(git config --get remote.origin.url || true)
snyk_org="${SNYK_CFG_ORG:-$(snyk config get org 2>/dev/null || true)}"
```

The audit branch (often `chore/snyk-sweep-YYYY-MM-DD`) is **never** a
Snyk identity. Do not derive `--target-reference`, `--project-name`,
target names, app names, or resource names from the audit branch,
sweep branch, worktree path, PR number, date, or timestamp.

Preflight existing projects before any monitor call:
```bash
# Requires Snyk Projects API read permission (`org.project.read`).
# Query `/orgs/{org_id}/projects` and filter by stable Snyk identity:
# `names_start_with`, `target_file`, and existing `target_reference`.
: "${SNYK_ORG_ID:?Set SNYK_ORG_ID to the existing Snyk org UUID}"
: "${SNYK_TOKEN:?Set SNYK_TOKEN for read-only project preflight}"
curl -fsS \
  -H "Authorization: Token ${SNYK_TOKEN}" \
  -H "Accept: application/vnd.api+json" \
  "https://api.snyk.io/rest/orgs/${SNYK_ORG_ID}/projects?version=2025-11-05&names_start_with=${repo_slug}" \
  > .snyk-projects.json
```

Match rules:

1. Match by existing org, project `name`, `target_file`
   (`package.json`, workspace manifest path, `go.mod`, and so on), and
   `target_reference` if the existing project has one.
2. Exactly one match per target file -> monitor may run using that
   exact identity.
3. Zero matches -> **skip monitor**. Do not run `snyk monitor`; do not
   create a project. Record `monitor: skipped (no existing project)`.
4. More than one match -> **skip monitor** and ask the Snyk/security
   owner to disambiguate. Do not guess.
5. Do not run `snyk monitor --all-projects`; the PreToolUse guard
   blocks it. Use per-file monitor calls only after exact preflight.

JS path:
```bash
snyk test --all-projects --json > .snyk-findings.json
bun audit --json > .bun-audit.json

# Existing-project publish only, after the API preflight found one
# exact project for this target_file.
SNYK_ALLOW_EXISTING_PROJECT_MONITOR=1 \
SNYK_EXISTING_PROJECT_ID="$existing_project_id" \
snyk monitor \
  --file="$existing_target_file" \
  --org="$snyk_org" \
  --project-name="$existing_project_name" \
  ${existing_target_reference:+--target-reference="$existing_target_reference"}
```

Go path:
```bash
snyk test --file=go.mod --json > .snyk-findings.json
govulncheck -json ./... > .govulncheck.json

# Existing-project publish only, after the API preflight found one
# exact go.mod project.
SNYK_ALLOW_EXISTING_PROJECT_MONITOR=1 \
SNYK_EXISTING_PROJECT_ID="$existing_project_id" \
snyk monitor \
  --file="$existing_target_file" \
  --org="$snyk_org" \
  --project-name="$existing_project_name" \
  ${existing_target_reference:+--target-reference="$existing_target_reference"}
```

If the existing project has no `target_reference`, omit
`--target-reference`; adding a new branch/reference would create
another project. If the existing project uses a stable reference such
as `main`, `master`, or a release line, reuse that exact value. Never
use the audit branch.

Snyk IO reads `yarn.lock`, not `bun.lock`. If JS repo has no
`yarn.lock`, generate first: `bun install --yarn`.


### 2b. Exploitability triage

For every finding, decide REACHABLE vs NOT-REACHABLE **before any
bump**. This is the most important gate -- skipping it leads to
reflex `resolutions`/`overrides` that bloat `node_modules` and force
more upgrades later.

Default stance for npm/Node.js packages: Snyk output is an allegation,
not proof. Many findings are false positives for browser/UI repos,
dev-only tools, optional server plugins, and packages present only in
lockfiles. Dismiss with `.snyk` when no repo code path reaches the
vulnerable behavior and Socket.dev does not show credible
install-time/build-time risk.

Inputs:
- Advisory attack vector: read the CVE / GHSA description. Which
  function / endpoint / input surface is the exploit? Server-side
  parser? Client-side SSR? CLI arg? Build-time plugin?
- Import graph:
  - JS: `bun why <pkg>` -- why it's included, which parent(s).
    `grep -rn "from '<pkg>'"` to see if we import it directly.
  - Go: `go mod why <mod>` + `grep -rn '"<mod>"' --include='*.go'`
    for direct imports.
- Our usage: do we call the vulnerable function / hit the vulnerable
  code path? Example: `hono-server` ships as a transitive of the MCP
  SDK protocol package, but we may only use the client half. Server
  feature never imported -> NOT-REACHABLE.

### /steelman transitive bump gate

Invoke `/steelman` before any JS transitive-only bump, parent bump, or
override/resolution when the vulnerable package is absent from
`package.json`.

Goal: prevent "fixes" that merely grow `package.json` or lockfile debt
when the app does not use the vulnerable package.

Required output in PR evidence:

1. **Claim to challenge:** "We need to bump or override `<pkg>`."
2. **Strongest case to dismiss:** argue the strongest case for
   dismissal first, using repo evidence:
   - package absent from `package.json`;
   - `bun why <pkg>` shows only deep transitive path;
   - no direct imports;
   - parent feature/code path unused by shipped UI;
   - vulnerable symbol not called;
   - Socket.dev shows no install-time/build-time credible vector.
3. **Contradicting evidence:** direct import, reachable parent call,
   vulnerable symbol usage, install script, build-time execution, or
   critical Socket.dev supply-chain alert.
4. **Verdict:**
   - `dismiss`: strongest dismissal case survives -> `snyk ignore`
     with parent chain + symbol evidence.
   - `fix-parent`: vulnerable path reachable only through parent ->
     bump parent, not transitive.
   - `override-last-resort`: direct + parent blocked, vector credible,
     and policy cannot dismiss.

If the evidence cannot prove direct use, parent reachability, or
vulnerable symbol usage, the bump makes no sense. Dismiss with expiry
instead of growing the dependency surface.

### /diagnosing-bugs reachability loop

Invoke `/diagnosing-bugs` before any `package.json` change that claims to fix
a JS security finding. Treat the Snyk finding as a bug report and build
a fast feedback loop that can prove the vulnerable surface is relevant
to this repo.

Acceptable loops:

- `grep` / import graph proves app code imports the vulnerable package
  or the direct parent feature that calls it.
- A unit or integration harness calls the same parent API and reaches
  the vulnerable symbol / file.
- A bundler or build script path proves the vulnerable package executes
  during build, install, or CI.
- Socket.dev shows a critical install-time or build-time supply-chain
  vector: known malware, install script payload, shell access,
  environment variable access, typosquat, or unstable ownership plus a
  newly introduced version.

Not enough:

- Snyk says "introduced via" without evidence the parent path is used.
- The package exists somewhere in `node_modules`.
- The package name appears only in lockfiles.
- "Fix available" exists but the package is several layers deep and no
  vulnerable symbol is reachable.

Verdict rule:

- Proven reachable / credible install-time vector -> proceed to the
  [Package.json admission gate](#packagejson-admission-gate).
- Unproven or uncertain transitive finding -> **DEFAULT: dismiss** with
  `snyk ignore`, expiry, parent chain, and diagnostic evidence.

The PR must call this a **real potential vulnerability** before any
package manifest change is allowed.

### Package.json admission gate

`package.json` is not a suppression ledger. It is the public dependency
surface. A Snyk fix may mutate `package.json` only when one of these
admission reasons is true:

1. **Already-direct vulnerable dependency.** The vulnerable package is
   already declared in `dependencies` / `devDependencies`, and
   `/diagnosing-bugs` proves direct use or install/build-time execution.
2. **Reachable direct parent.** The vulnerable package is transitive,
   but the direct parent is already declared and `/diagnosing-bugs` proves the
   parent path reaches the vulnerable behavior. Bump the parent, not the
   transitive.
3. **Last-resort override.** Direct and parent fixes are blocked,
   the vulnerability is a real potential vulnerability, security policy
   cannot dismiss it, and the PR includes a removal tracking issue.

Anything else stays out of `package.json`. Use `.snyk` dismissal with a
90-day expiry and precise reason. This makes the skill more likely to
ignore/suppress noisy deep transitives than to create dependency debt.

Treat every new `resolutions` / `overrides` entry as a code smell and
every existing long override list as a burn-down queue. The safest
dependency is the one absent from the graph: before adding an override,
ask whether the direct parent can be deleted, whether the feature is
unused, or whether native/in-house code can replace the third-party
dependency with less total surface area. Lower third-party surface area
means fewer future advisories, fewer transitive surprises, and less
lockfile churn.

### Transitive-only dismissal checklist

Use this checklist before adding any override/resolution for a finding
several layers deep in `node_modules`.

1. **Direct dependency absence is evidence.** If the vulnerable package
   is not listed in `package.json`, that supports a dismissal path; it
   does not justify adding the transitive as a new top-level dependency.
2. Identify the parent chain with `bun why <pkg>` and record the first
   direct parent that introduced it.
3. Grep imports for both package names:
   ```bash
   grep -rn "from ['\"]<pkg>['\"]\\|require(['\"]<pkg>['\"])" .
   grep -rn "from ['\"]<parent>['\"]\\|require(['\"]<parent>['\"])" .
   ```
4. Map the advisory to a vulnerable symbol / file / runtime behavior.
   A CVE on a server parser, CLI, dev-only loader, or optional plugin
   is not automatically reachable from a browser UI bundle.
5. If the parent code path is unused, optional, SSR-only, build-only, or
   outside shipped UI code, dismiss with `snyk ignore` and a precise
   reason. Include the parent chain + symbol proof.
6. If the parent code path is reachable, first ask whether the parent
   dependency or feature can be removed entirely. Prefer deletion,
   native platform behavior, or small in-house code when that lowers
   total dependency surface area.
7. If removal is not viable, fix the parent before any override. Do
   not add the vulnerable transitive to `package.json` just to make a
   suppression-only override easier.
8. Override/resolution only when direct + parent remediation and
   dependency removal are all blocked, and the vulnerability is still
   reachable or Snyk cannot be ignored for policy reasons. Add a
   removal issue and a burn-down note.
9. In short: do not add a transitive package to `package.json` just to
   suppress a nested finding.

Anti-pattern to reject in review:

```diff
+ "vulnerable-transitive": "x.y.z"
+ "resolutions": { "vulnerable-transitive": "x.y.z" }
```

If we do not use the library directly, this grows the public dependency
surface just to silence a nested finding. Prefer `.snyk` dismissal with
expiry when not reachable, or parent bump when reachable.

Decision:

- **NOT-REACHABLE** -- dismiss **via the Snyk CLI, not via PR
  description alone**. PR text is not an audit artifact; `.snyk` +
  Snyk IO project state are. Do this per finding, in order:

  1. Run the dismiss now:
     ```bash
     snyk ignore --id=<issue-id> \
       --reason='Not reachable: <specific pkg path + why we do not hit it>' \
       --expiry=$(date -u -v+90d +%Y-%m-%dT%H:%M:%SZ)
     ```
     This writes a policy entry to the `.snyk` file at repo root
     (creates the file if absent). Run from the repo root so the
     policy applies project-wide.
  2. Stage + commit `.snyk` as part of the sweep PR. The dismissal
     must land in git alongside the bumps. A dismissal that only
     lives in the PR description is invisible to CI, auditors, and
     the next sweep.
  3. Publish dismissals to Snyk IO only if an existing project match
     was verified in 2a.1:
     ```bash
     # Use the exact existing Snyk project identity from 2a.1.
     SNYK_ALLOW_EXISTING_PROJECT_MONITOR=1 \
     SNYK_EXISTING_PROJECT_ID="$existing_project_id" \
     snyk monitor --file="$existing_target_file" \
       --org="$snyk_org" \
       --project-name="$existing_project_name" \
       ${existing_target_reference:+--target-reference="$existing_target_reference"}
     ```
     Monitor applies the `.snyk` policy to the existing IO project, so
     the dashboard shows the issue as `Ignored` with the reason +
     expiry. If there is no exact existing project match, **skip
     monitor** and record that IO will update after merge through the
     normal Snyk integration or after a security owner links the
     existing resource. Re-run `snyk test` locally to confirm the issue
     is listed under `Ignored issues` before opening the PR.
  4. **Do not** add the package to `resolutions` / `overrides` /
     `replace`. Dismissal replaces the bump, it does not accompany
     one.

  Record the dismissal in the PR body under `Dismissed (not
  exploitable)`. Include CVE, vulnerable symbol, usage check,
  `snyk ignore` issue id used, reason, expiry date, and a link to
  the IO issue. Expiry forces re-triage so dismissals do not rot.

  If `snyk ignore` errors (e.g. the issue is already ignored,
  auth missing, wrong org context), fix the CLI state before
  opening the PR. Do not fall back to "note in the description"
  -- escalate instead.

- **REACHABLE** (or exploit vector credible and reachability cannot
  be proved false) -- proceed to 2c.

### 2c. Upgrade priority (top-level first, override last)

Always try these in order. Document the order actually taken in the
PR body.

1. **Direct dep bump.** The package is already in our `package.json`
   / `go.mod`. Bump it to a fixing version. This is the default path.
   ```bash
   # JS
   bun update <pkg>@<fixed-version>
   # Go
   go get -u <module>@<fixed-version>
   ```
2. **Parent dep bump.** The vuln is in a transitive. Look up which of
   our direct deps pulls it. Bump that direct dep to a version whose
   transitives pin the fixed version. Prefer this over override --
   one bump, upstream-maintained.
3. **Dependency surface removal.** If the parent dependency exists only
   for a small/unused feature, remove it or replace it with native or
   in-house code before accepting more third-party surface area. This
   is often safer than pinning nested packages forever.
4. **Override / resolution / replace (last resort).** Only when
   direct + parent bump and dependency removal are all blocked
   (upstream has no fix; fixing version needs React 19 and our React
   18 pin stands; etc).
   - JS: `package.json` `"resolutions"` (bun/yarn-compatible) or
     `"overrides"` (npm-compatible). We use `resolutions` under bun.
   - Go: `replace` directive in `go.mod`.
   - Add a follow-up TODO: **Remove this override once upstream
     ships a fix**. Include the override in a dedicated PR section
     (`Overrides added -- follow-up to remove`).
   - Explain in the PR body why steps 1 and 2 were blocked.

**Why this order matters:** every added override is tomorrow's forced
upgrade and a smell that the dependency graph is taking control of the
app. Overrides accumulate, node_modules bloats, maintenance compounds
weekly, and each nested pin can pull in more packages with their own
advisories. Lower third-party surface area is the durable win.
