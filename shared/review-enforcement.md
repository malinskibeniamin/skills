# Review enforcement in consuming repositories

Installing this harness ships guidance and hooks, not this repository's `.github/`
workflows or hosted settings. Verify the consuming repository's `origin` and the PR's
actual base branch. Never copy this harness's CI names or overwrite a stricter policy.

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

## Establish missing prerequisites

1. Inspect the consuming repository's workflows, native branch protection/rulesets,
   permissions, and existing requirements. Use its normal CI and security scanners.
2. Within the authorized task, repair failed workflows or missing prerequisites. A 403
   alone does not prove the graph is disabled: inspect permissions and feature support.
   For GitHub dependency review, enable Dependency graph in repository settings, or use
   the documented admin endpoint below, which also enables Dependabot alerts:

   ```sh
   gh api repos/OWNER/REPO/vulnerability-alerts
   gh api --method PUT repos/OWNER/REPO/vulnerability-alerts
   gh api repos/OWNER/REPO/vulnerability-alerts
   ```

   Check identity and hosted state before the write; verify afterward. This does not
   enable automatic dependency-fix PRs. Paid features, new credentials/services, approval
   tiers, and changes outside the owned repository require the owner's decision.
3. Deploy and observe checks before requiring their exact native names/app identities.
   Preserve stronger rules, inherited protections, and existing approval counts. Never
   lower a gate, enable a bypass, or replace the entire policy with a generic payload.
4. Re-run the same failing public API/check, then refresh the readiness checkpoint.
   If administration is unavailable, report the exact missing capability; do not claim
   success or automatically mutate other consuming repositories.

Sources: [active branch rules](https://docs.github.com/en/rest/repos/rules#get-rules-for-a-branch),
[classic protection](https://docs.github.com/en/rest/branches/branch-protection#get-branch-protection),
[dependency graph prerequisite](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/secure-your-dependencies/enable-dependency-graph),
[enable graph and alerts](https://docs.github.com/en/rest/repos/repos#enable-vulnerability-alerts).
