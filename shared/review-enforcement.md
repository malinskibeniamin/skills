# Review enforcement in consuming repositories

Installing this harness ships guidance and hooks, not this repository's `.github/`
workflows or hosted settings. Verify the consuming repository's `origin` and the PR's
actual base branch. Never copy this harness's CI names or overwrite a stricter policy.

## Generic delivery policy

CI, reviews and approvals do not block delivery, including ship and `/go`. Verify locally,
publish the requested scope, report one current snapshot and stop without waiting. Apply
this uniformly: no repository-name checks, allowlists or copied protection payloads.
Publication/ownership checks still apply. Monitoring and feedback resolution need explicit
scope; merging always needs explicit permission. Advisory or pending checks are not passing
evidence and must be reported accurately.

Delivery policy does not replace hosted merge policy. Preserve existing classic protection,
rulesets, required checks, approval counts and owner-approved admin bypasses. If the owner
chooses advisory checks or unrestricted admin merging, honor that decision without restoring
blocking gates. Never infer approval to weaken hosted rules merely from admin access, sole
contributor status or the no-wait delivery default.

## Automatic setup

Automatically set up missing **local** safeguards during authorized implementation/delivery:
reuse repository-native checks, short `REVIEW.md` guidance for real failure modes and a PR
template covering Testing, Risk and How to revert. Keep source changes on the owned feature
branch/PR. Respect read-only/local-only, commit-only and other narrower endpoints.
Installation/startup alone authorizes no writes. Hooks route guidance, not hosted mutations.

Changes to workflows, hosted requirements, approval/ownership policy, paid services or
credentials require explicit scope. When the owner requests protection setup:

1. Resolve origin, identity, permissions, actual PR base, workflows, classic protection,
   and active/inherited rulesets. Inspect before writing; preserve unrelated and stronger
   rules. Use the owner's intended policy, not a bundled protection template or check name.
2. Reuse native lint/types/tests/build and existing security/reviewer integrations. Verify
   current provider docs, language support and plan before adding a scanner. Keep unsupported
   or unavailable scanning fail-visible; new external reviewers and scheduling need their own
   authorization. For dependency review, use the prerequisite procedure below.
3. Require only observed native check/app identities when the requested policy calls for
   blocking checks. Preserve native approval counts, including 0, stale dismissal, admin
   bypass policy, force-push/deletion rules and any merge queue. Never invent owners,
   trusted authors or approval tiers. A disabled requirement/ruleset may be intentional.
4. Read back each hosted write and replay the failing API/check. Report pending evidence
   without waiting; neither installation, a saved file nor a cached marker proves readiness.
   Report missing administration or an owner-reserved decision, not a substitute identity.

Reconcile changes only within the requested policy scope. Repeated review failures should
improve the owning rule, skill or check rather than accumulate repository exceptions.

## Readiness contract

This read-only, conservative checkpoint diagnoses protected-consumer readiness, not delivery
completion or permission to merge. Run it only when that diagnostic is requested or needed
for a protected merge. Missing protections may reflect an intentional owner policy; a failed
diagnostic never authorizes restoring them or delaying ordinary delivery.

Before claiming a GitHub PR is ready for merge, run the read-only checkpoint from the
owned consuming checkout, using the installed plugin's script and observed full SHAs:

```sh
bun --no-install <plugin-root>/scripts/full-send-check.ts \
  --repo owner/repo --pr 42 --head <candidate-sha> --base <base-sha>
```

It verifies publication, the candidate, native checks, review decision, all unresolved
threads, and mergeability. It also reads classic protection and active inherited rulesets:

- Require the repository's own status checks, strict base freshness or a merge queue,
  pull requests, resolved conversations, and blocked force pushes/deletion.
- Count protection only when it applies without an administrator/actor bypass.
  Missing access to bypass policy is unknown, not an empty allowlist.
- Preserve the native human approval count, including 0. A zero-approval policy is
  not evidence of independent review; positive counts require fresh approval policy.
- For a consumer opted into [review gates](../review/GATES.md), or with an existing
  default gate plan, require current passing gate evidence on the same head/base.
  `--review-plan <file>` selects explicit evidence. Missing, stale, invalid and blocking
  results fail visibly; `not-configured` supplies no semantic-review evidence. Keep
  this opt-in separate from hosted approval policy and delegation authorization.
- For a committed workflow using `actions/dependency-review-action`, replay the
  dependency-graph comparison for the exact base/head. A disabled graph, unsupported
  plan, malformed response, or unavailable access cannot become a pass.
  This detects direct action references, not reusable-workflow internals or complete
  scanner coverage; `not-detected` supplies no dependency-security evidence.

The lifecycle Stop hook checks publication, not hosted readiness, in both supported hosts.
PR and ship endpoints stop without CI/review waiting; pending or missing protections are
reported, never described as hosted-gates-pass. Commit-only, push-only, local-only and
genuine blocked/awaiting-decision endpoints stay intact.

This is sampled evidence, not an atomic merge lock or a tamper-proof security boundary.
The authorized merge path must still use the expected-head guard and hosted base-race
protection or an explicit owner-approved override. Non-GitHub providers need equivalent
native verification; this helper does
not silently certify them. This checker neither configures nor requires an external AI
reviewer service; preserve any existing reviewer integrations.

For a read-only activity snapshot in any consumer, use the shipped `review-metrics.ts`
with its repository name. Activity is not accuracy, recall, or safety evidence; scheduling
recurring collection needs separate authorization.

## Dependency-graph prerequisite

A 403 alone does not prove the graph is disabled: inspect permissions and feature
support. For GitHub dependency review, enable Dependency graph in repository settings,
or use the documented admin endpoint below, which also enables Dependabot alerts:

```sh
gh api repos/OWNER/REPO/vulnerability-alerts
gh api --method PUT repos/OWNER/REPO/vulnerability-alerts
gh api repos/OWNER/REPO/vulnerability-alerts
```

Check identity and hosted state before the write; verify afterward, including the same
base/head dependency comparison. This does not enable automatic dependency-fix PRs.
Paid features, new credentials/services, approval tiers, and changes outside the owned
repository remain owner decisions. Unavailable administration is an explicit blocker.

Sources: [active branch rules](https://docs.github.com/en/rest/repos/rules#get-rules-for-a-branch),
[classic protection](https://docs.github.com/en/rest/branches/branch-protection#get-branch-protection),
[dependency graph prerequisite](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/secure-your-dependencies/enable-dependency-graph),
[enable graph and alerts](https://docs.github.com/en/rest/repos/repos#enable-vulnerability-alerts).
