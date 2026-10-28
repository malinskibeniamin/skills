# Review and merge policy

## Owner merge policy

For **malinskibeniamin/skills only**, the repository owner chooses when to merge.
CI, security scans, review findings and approvals are advisory, not merge gates.
The hosted `main` policy and [saved payload](branch-protection.json) have no required
status checks, required PR reviews or conversation-resolution requirement. Admin
protection enforcement is off. Force pushes and branch deletion remain disabled.

Do not wait for CI, approvals or review-thread closure during PR, ship or `/go`
delivery here. An optional status snapshot must not start a wait/remediation loop.
Do not automatically restore blocking safeguards through consumer bootstrap.
Explicitly requested monitoring or feedback work remains separate. Agents still
need explicit permission to merge; this policy does not grant it.

This owner decision supersedes the earlier required-check policy. It accepts that
changes can merge while checks fail or findings remain open; it is not evidence
that a change passed verification. Run useful local verification and report limits.

Installed consumers retain the shared [review-enforcement contract](../shared/review-enforcement.md)
and their native policy. This exception neither changes their protections nor
allows their agents to skip required checks.

## Inspect before changing protection

```bash
gh api repos/malinskibeniamin/skills/branches/main/protection
gh api repos/malinskibeniamin/skills/rulesets
```

Re-read hosted policy after any write. Applying `branch-protection.json` replaces
settings; preserve unrelated rules. Only another explicit owner decision should
make checks, reviews or conversations blocking in this repository again.

[Security review](workflows/security-review.yml) still runs CodeQL and high/critical
dependency scanning. These diagnostics and the Linux/macOS/render workflows continue
without a merge requirement. Static scanning is not independent AI review; no
reviewer credential is checked in or inferred from a local CLI session.

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
  This repository explicitly opts out of required reviews; consumers keep their own policy.
- Reviewer-quality claims need human-validated incident/revert cases, executed model
  evaluations and finding dispositions. Activity metrics do not supply these guardrails.
- This repository requires neither a fresh base nor a merge queue. Flags, internal-first rollout, release channels,
  incident detection and operational rollback belong to each consuming product's owners.
  PR rollback instructions do not implement those systems.

Sources: [GitHub branch protection API](https://docs.github.com/en/rest/branches/branch-protection#update-branch-protection),
[CodeQL advanced setup](https://docs.github.com/en/code-security/code-scanning/creating-an-advanced-setup-for-code-scanning/configuring-advanced-setup-for-code-scanning),
[dependency review action](https://github.com/actions/dependency-review-action).
