# Review enforcement in consuming repositories

Installing this harness ships guidance and hooks, not this repository's `.github/`
workflows or hosted settings. Verify the consuming repository's `origin` and the PR's
actual base branch. Never copy this harness's CI names or overwrite a stricter policy.

## Automatic setup

On authorized build/fix or push/PR/ship work in **every consuming repository**, read
this workflow and reconcile missing safeguards automatically. Do not wait for a setup
command, ask whether to configure ordinary prerequisites, or only report repairable gaps.
This applies to plugin and skills-only installs; bootstrap is not exclusive to this repo
or `/frontend-starter-kit`. Resolve the harness root from the loaded skill/hook path,
then operate from the consumer's Git root, including in monorepos and linked worktrees.

Installation/startup alone, questions, reviews, plans, commit-only, and explicit
read-only/local-only/no-push tasks authorize no hosted changes. Hooks only route the
agent; they do not make network writes. During authorized delivery, use the current
account's existing access. Missing administration, paid features, new credentials or
services, and owner-reserved approval/ownership decisions are explicit blockers, not
reasons to switch accounts, weaken protection, or silently skip setup.

Reconcile in order; inspect before writing and read back afterward. Keep file changes
on the current owned feature branch/PR and use its requested delivery endpoint:

1. **Inspect the consumer.** Resolve `origin`, authenticated identity, permissions,
   actual PR base (default branch before a PR exists), workflows, classic protection,
   and active/inherited rulesets. Reuse complete existing pieces; no blanket settings
   replacement, unrelated repositories, generated-file edits, or installed-plugin edits.
2. **Prepare local safeguards.** Add missing `REVIEW.md` guidance for the consumer's
   real failure modes, evidence requirements, skipped/generated paths, and nit budget.
   Create/extend its PR template with Testing, Risk, and How to revert; retain existing
   content. Reuse repo-native lint/types/tests/build in blocking PR CI; add supported
   static/dependency security scanning when absent. Inspect current provider docs,
   language support, and plan first. Keep security separate and fail-visible; do not
   copy this harness's check names, package commands, Action versions, or paid services.
   If a merge queue exists, ensure required workflows support `merge_group`.
3. **Repair security prerequisites.** Follow the dependency-graph procedure below when
   the consumer uses dependency review. An unavailable/unsupported scanner needs a
   compatible native scanner or an explicit blocker, not a successful skipped job.
   Preserve existing reviewer integrations; external AI reviewer provisioning remains
   excluded. Do not activate automatic dependency-fix PRs or scheduled agents as a side effect.
4. **Establish native gates.** Once the consumer's checks have run successfully on the
   published candidate, require their observed native names/app identities. Add missing
   PR/thread-resolution, strict-base-or-queue, admin/no-bypass, force-push and deletion
   safeguards. Prefer a narrowly scoped additive ruleset to replacing existing policy;
   preserve every stronger/inherited rule and the native approval count, including 0.
   Positive human-approval policies need stale dismissal. Do not invent CODEOWNERS,
   trusted authors, or approval tiers: reuse verified owners/policy and report any
   reserved decision needed. New gates must never require an unobserved check.
5. **Prove the result.** Re-run the public API/check that failed, inspect saved files
   and hosted policy, then run the readiness checkpoint below on fresh head/base SHAs.
   Existing repair-round/thread hooks remain the owner of feedback convergence; do not
   duplicate them in the consumer. Record what was reused, created, verified, or blocked;
   installation, file presence, and a cached setup marker are not passing evidence.

Reconcile again when the origin/base, CI names, policy, or security prerequisites change.
PR-only still ends after one CI snapshot: checks not yet observed remain pending setup,
not merge-ready. Ship continues the repair/verification loop. No merge is authorized by
setup. Repeated review failures should improve the owning harness rule/skill/hook and
its regression test, not accumulate per-consumer exceptions.

## Readiness contract

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

The shipped lifecycle Stop hook runs this checkpoint for `ship` in both supported hook
hosts, even with a clean tree. An ordinary PR request still stops after one CI snapshot;
pending or missing protections are reported, never described as merge-ready. Commit-only,
push-only, local-only, and genuine blocked/awaiting-decision endpoints stay intact.

This is sampled evidence, not an atomic merge lock or a tamper-proof security boundary.
The authorized merge path must still use the expected-head guard and hosted base-race
protection. Non-GitHub providers need equivalent native verification; this helper does
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
