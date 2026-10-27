# Review gates

These settings belong to this repository. Installed consumers use the shared
[review-enforcement contract](../shared/review-enforcement.md) and shipped lifecycle
hook to verify their own hosted protections and security prerequisites. Installing
the plugin does not copy this workflow/payload or mutate another repository's policy.

The hosted `main` protection requires Linux, macOS, render, CodeQL security, dependency
security, and the CodeQL analysis result, plus an up-to-date branch and resolved
conversations. The saved payload matches the observed administrator enforcement;
force pushes and branch deletion remain disabled. Recheck hosted state before changes.

The API payload lives in [branch-protection.json](branch-protection.json). It
preserves the previous approval count of 0; it does not authorize automatic
merging or claim an independent human approved a change. Sensitive-path owners
and approval tiers remain an owner policy decision.

## Inspect before changing protection

```bash
gh api repos/malinskibeniamin/skills/branches/main/protection
gh api repos/malinskibeniamin/skills/rulesets
```

Compare hosted policy before applying the JSON with `gh api --method PUT ...
--input .github/branch-protection.json`. The PUT replaces settings. Preserve
stricter existing policy and additional required checks. Re-read hosted policy
after a write or uncertain response before retrying.

Automation-created PR runs can require a maintainer to select **Approve workflows
to run**. Keep required checks in place while authorizing those runs through
[GitHub's supported flow](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow#triggering-a-workflow-from-a-workflow).

[Security review](workflows/security-review.yml) supplies required CodeQL analysis and
high/critical dependency review. The required contexts are `CodeQL security` and
`Dependency security` from GitHub Actions (app 15368), and `CodeQL` from GitHub Advanced
Security (app 57789). These exact identities passed on a deployed PR candidate before
being required. They are static checks, not independent AI review. New check identities
still need observed green runs before enforcement; undeployed checks can strand PRs.
No reviewer credential is checked in or inferred from a local CLI session.

## Observe review effort without claiming safety

```bash
bun run review:metrics malinskibeniamin/skills 30
```

The read-only command samples up to 100 latest-updated merged PRs. It reports
currently approved human review submissions per PR (including reapprovals, not
dismissed approvals), human discussion comments,
and elapsed minutes from PR creation to the first human review. This elapsed time
is not time waiting on a requested reviewer. Comments include post-merge
discussion. An incomplete nested history fails instead of silently truncating.
After these workflow changes land on `main`, the existing nightly and manual
eval runs publish this JSON in their job summary. No model is invoked.

Missing reviews produce unavailable latency, not a zero-minute success.
Incident rate, revert rate, reviewer recall, and false-positive rate stay unknown.
Do not lower human approval requirements from these activity metrics.

The manually invoked [review experiment](../agent-evals/experiments/review.ts)
includes defect scenarios and a clean negative control. Its fixture assertions
and deterministic CI checks do not measure model quality. Run model evaluations
only with explicit authorization and configured credentials. Record the model,
effort, prompt revision, case dispositions, and run evidence before claiming a
reviewer improvement. Human-validated incident cases remain a separate need.

## Remaining adoption boundaries

The [Claude Code review process](https://claude.dev/blog/solving-code-review-at-anthropic/)
informs this harness; its full operating model is not installed by these files.

- Candidate-bound [review gates](../review/GATES.md) remain opt-in. Independent AI
  review/verification needs explicit authorization and a configured reviewer; installing
  the harness neither provisions a service nor grants delegation permission.
- Risk-tier human counts, trusted authors and sensitive-path ownership need owner policy.
  The existing zero-approval count is preserved, not evidence that less review is safe.
- Reviewer-quality claims need human-validated incident/revert cases, executed model
  evaluations and finding dispositions. Activity metrics do not supply these guardrails.
- Strict-base checks are not a merge queue. Flags, internal-first rollout, release channels,
  incident detection and operational rollback belong to each consuming product's owners.
  PR rollback instructions do not implement those systems.

Sources: [GitHub branch protection API](https://docs.github.com/en/rest/branches/branch-protection#update-branch-protection),
[CodeQL advanced setup](https://docs.github.com/en/code-security/code-scanning/creating-an-advanced-setup-for-code-scanning/configuring-advanced-setup-for-code-scanning),
[dependency review action](https://github.com/actions/dependency-review-action).
