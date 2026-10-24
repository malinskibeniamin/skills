# Review gates

These settings belong to this repository. Installed consumers use the shared
[review-enforcement contract](../shared/review-enforcement.md) and shipped lifecycle
hook to verify their own hosted protections and security prerequisites. Installing
the plugin does not copy this workflow/payload or mutate another repository's policy.

The hosted `main` protection requires the existing Linux, macOS, and render checks
from GitHub Actions, an up-to-date branch, and resolved conversations. Admins have
an explicit merge-gate override by owner policy. Force-push and branch-deletion
settings remain disabled. Preserve this repository-specific admin override when
reconciling protection; it does not change the defaults for installed consumers.

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

[Security review](workflows/security-review.yml) adds CodeQL analysis and
high/critical dependency review. These are static checks, not independent AI
review. Require their exact observed check names only after the workflow lands
on `main` and produces green runs. Requiring undeployed checks can strand PRs.
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

Sources: [GitHub branch protection API](https://docs.github.com/en/rest/branches/branch-protection#update-branch-protection),
[CodeQL advanced setup](https://docs.github.com/en/code-security/code-scanning/creating-an-advanced-setup-for-code-scanning/configuring-advanced-setup-for-code-scanning),
[dependency review action](https://github.com/actions/dependency-review-action).
