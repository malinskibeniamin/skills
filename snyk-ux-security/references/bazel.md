# Bazel dependency branch

Read after [shared triage](triage.md) for `MODULE.bazel` or `bazel/repositories.bzl`.

## Bazel track

Use for Snyk findings in Bazel dependency manifests. This mode normally
starts from one pasted Snyk vulnerability summary, not a path sweep.

### Parse and gate

Extract from the pasted Snyk output:

- CVE, GHSA, or Snyk issue id.
- Vulnerable package, installed version, and fixed version.
- "Introduced via" dependency path.
- Remediation hint.

Only fix findings resolved by increasing a dependency version. If the
hint requires a code change, patch file, config change, or a product
mitigation, stop and tell the user which non-bump action is needed.

### Branch, ticket, and worktree

Before edits:

1. Show the current branch with `git branch --show-current`.
2. Ask the user to confirm the target branch. Use the repo default or
   mainline branch for primary fixes; release branches follow repo policy.
3. Ask whether there is a ticket key. If provided, append `FIXES=<key>`
   or the repo-specific tracker footer to every PR body so auto-linking
   works.
4. Fetch the confirmed branch and create a separate worktree. Branch
   naming: `snyk/<cve-id>-<package>-<version>`. Include the target
   branch in the worktree path so parallel backports do not collide.

Work only in the worktree. Never modify the user's current checkout for
Bazel CVE fixes.

### Manifest validation

Check both files on every target branch:

```bash
grep -n "<package>" bazel/repositories.bzl || true
grep -n "<package>" MODULE.bazel || true
```

- `bazel/repositories.bzl` manages `http_archive` style dependencies,
  including GitHub URLs and mirrored artifact URLs.
- `MODULE.bazel` manages BCR dependencies through `bazel_dep`.

A package may be in either file, and branch drift is common: the default
branch can use BCR while a release branch still uses a mirrored artifact.
If the package appears in neither file, stop and report that the Snyk
path does not match this branch.

### Update mechanism

| Manifest location | Action | Follow-up |
|---|---|---|
| `MODULE.bazel` `bazel_dep` | Bump the version field. | Run `bazel mod deps --lockfile_mode=update`. If BCR has not published the fix yet, still open a draft PR and let CI prove availability before inventing workarounds. |
| `bazel/repositories.bzl` GitHub URL | Update URL/tag, `sha256`, and `strip_prefix` when present. | Run `bazel mod deps --lockfile_mode=update`. |
| `bazel/repositories.bzl` mirrored artifact URL | Add the new upstream artifact to the repository's artifact mirror/tooling repo first, then point the Bazel manifest at the mirrored artifact. | Open the artifact tooling draft PR first; the target PR depends on it. Never change a mirrored artifact URL to `github.com` or any direct upstream host without asking the user. |
| Other URL source | Stop and ask. | Do not guess hosting policy. |

For direct URL updates, compute and record the new `sha256` from the
actual release artifact. Do not reuse checksums or hand-edit lockfiles.

### Artifact mirror dependency flow

When the current URL points at an organization-owned S3, GCS, or binary
artifact mirror:

1. Find the new upstream release artifact and checksum it.
2. Locate or clone the artifact tooling repository named in project docs.
3. Add the new artifact entry to the repo's dependency mirror manifest
   with mirror filename, source URL, and `sha256`.
4. Open an artifact tooling `--draft` PR from a branch named
   `snyk/<cve-id>-<package>-<version>`.
5. Update `bazel/repositories.bzl` in the target worktree only after
   the tooling PR exists; tell reviewers the target PR cannot land until
   the mirror update merges and uploads the artifact.

### OpenSSL and FIPS

OpenSSL findings need named-entry handling:

- Search `bazel/repositories.bzl` by `name =`, not only package text.
- Treat `@openssl` as the normal base OpenSSL build; update for routine
  CVEs when tests pass.
- Treat `@openssl-fips` as a CMVP-validated FIPS provider. Do not bump
  it unless the target version is CMVP validated for the required FIPS
  certificate path.

Decision tree for `@openssl-fips`:

1. Check whether a CMVP-validated fixed version exists.
2. If yes, bump like a normal dependency and document the validation
   source.
3. If no, decide reachability: is the vulnerable algorithm or code path
   used by the FIPS build? If not reachable, suppress through Snyk with
   a specific rationale and security approval. If reachable or unknown,
   escalate to security engineering for impact assessment; do not land a
   blind version bump that invalidates FIPS.

Useful sources to check during execution: NIST CMVP validated modules,
NIST modules in process, project FIPS docs, and upstream OpenSSL
security policy documents.

### Backport assessment

Before opening target PRs, inspect each affected branch, including the
default branch if the first target is a release branch:

```bash
git show origin/<branch>:bazel/repositories.bzl | grep -A6 "<package>" || true
git show origin/<branch>:MODULE.bazel | grep "<package>" || true
```

For every branch, record:

- current dependency version;
- correct fixed version for that branch line;
- mechanism: BCR, GitHub URL, mirrored artifact, or other;
- whether an artifact tooling PR is needed;
- expected PR base branch.

Present the backport plan to the user and ask which branches to proceed
with before opening PRs. Each confirmed branch gets its own worktree and
draft PR.

### Bazel PR format

Open all Bazel PRs as draft PRs with `gh pr create --draft` when the fix touches release/backport branches, mirrored artifacts, FIPS-sensitive dependencies, or uncertain BCR availability.

Target PR body:

1. Read `.github/pull_request_template.md` from the live target branch
   when present; otherwise use the standard skill PR body.
2. Preserve all HTML comments when a template exists.
3. Fill the top summary with the package bump, CVE/Snyk id, affected
   branches, and artifact-tooling dependency note if applicable.
4. Leave backport checkboxes unchecked; reviewers decide.
5. Fill release notes with a `### Bug Fixes` entry for the CVE fix.
6. Append `FIXES=<ticket-key>` at the end when a ticket key was provided.

Title and commit format for security bumps:

```text
build/deps: upgrade <package> to vX.Y.Z (<CVE-ID>)
```

If an artifact tooling PR exists, include its URL in the target PR body
and in the final report.

### Bazel report

Return:

- target branch and backport branches;
- manifest path touched (`MODULE.bazel` or `bazel/repositories.bzl`);
- old and new dependency versions;
- lockfile command result for `bazel mod deps --lockfile_mode=update`;
- artifact tooling draft PR URL, if any;
- target draft PR URL per branch;
- ticket key used or "none";
- FIPS decision, if OpenSSL-related.
