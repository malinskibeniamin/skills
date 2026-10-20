#!/usr/bin/env bun
// Read-only observations, never merge authorization or proof of product correctness.
import { reviewPolicy } from "./review-policy";
import { object, text, flag, list } from "./github-evidence";
function command(args: string[], allowed = [0]): string {
  const result = Bun.spawnSync(args, { timeout: 30_000 });
  if (!allowed.includes(result.exitCode ?? -1))
    throw new Error(
      `${args.slice(0, 2).join(" ")} unavailable (exit ${result.exitCode})`,
    );
  const output = result.stdout.toString().trim();
  // gh emits no JSON for an absent check list, unlike pending/failing checks.
  if (
    result.exitCode === 1 &&
    !output &&
    args[0] === "gh" &&
    args[1] === "pr" &&
    args[2] === "checks" &&
    /^no (?:required )?checks reported on /i.test(
      result.stderr.toString().trim(),
    )
  )
    return "[]";
  return output;
}
function json(args: string[], allowed = [0]): unknown {
  return JSON.parse(command(args, allowed));
}
const sha = /^[a-f0-9]{40}$/;
const prFields =
  "state,isDraft,isCrossRepository,headRefName,baseRefName,headRefOid,baseRefOid,reviewDecision,mergeable,mergeStateStatus";
function candidate(repo: string, pr: string) {
  const value = object(
    json([
      "gh",
      "pr",
      "view",
      pr,
      "--repo",
      `github.com/${repo}`,
      "--json",
      prFields,
    ]),
  );
  const head = text(value.headRefOid);
  const base = text(value.baseRefOid);
  if (!sha.test(head) || !sha.test(base))
    throw new Error("Malformed candidate SHA");
  return {
    head,
    base,
    branch: text(value.headRefName),
    baseBranch: text(value.baseRefName),
    state: text(value.state),
    draft: flag(value.isDraft),
    fork: flag(value.isCrossRepository),
    review: text(value.reviewDecision),
    mergeable: text(value.mergeable),
    mergeState: text(value.mergeStateStatus),
  };
}
function checks(repo: string, pr: string, required: boolean) {
  return list(
    json(
      [
        "gh",
        "pr",
        "checks",
        pr,
        "--repo",
        `github.com/${repo}`,
        "--json",
        "name,bucket,state",
        ...(required ? ["--required"] : []),
      ],
      [0, 1, 8],
    ),
  ).map((value) => {
    const item = object(value);
    const bucket = text(item.bucket);
    if (!["pass", "fail", "pending", "skipping", "cancel"].includes(bucket))
      throw new Error("Unknown check bucket");
    return { name: text(item.name), bucket, state: text(item.state) };
  });
}
function threads(repo: string, pr: string): string[] {
  const [owner, name] = repo.split("/");
  const query = `query($owner:String!,$name:String!,$number:Int!,$cursor:String) {
    repository(owner:$owner,name:$name) { pullRequest(number:$number) {
      reviewThreads(first:100,after:$cursor) { nodes { id isResolved isOutdated }
        pageInfo { hasNextPage endCursor } }
    } }
  }`;
  const unresolved: string[] = [];
  const cursors = new Set<string>();
  let cursor: string | undefined;
  do {
    const response = object(
      json([
        "gh",
        "api",
        "graphql",
        "--hostname",
        "github.com",
        "-f",
        `query=${query}`,
        "-f",
        `owner=${owner}`,
        "-f",
        `name=${name}`,
        "-F",
        `number=${pr}`,
        ...(cursor ? ["-f", `cursor=${cursor}`] : []),
      ]),
    );
    if (response.errors !== undefined)
      throw new Error("Incomplete GitHub thread response");
    const page = object(
      object(object(object(response.data).repository).pullRequest)
        .reviewThreads,
    );
    for (const value of list(page.nodes)) {
      const item = object(value);
      // Outdated is not addressed; classification/rebuttal belongs to the feature owner.
      flag(item.isOutdated);
      if (!flag(item.isResolved)) unresolved.push(text(item.id));
    }
    const info = object(page.pageInfo);
    if (!flag(info.hasNextPage)) break;
    cursor = text(info.endCursor);
    if (!cursor || cursors.has(cursor))
      throw new Error("Incomplete thread pagination");
    cursors.add(cursor);
  } while (cursor);
  return unresolved;
}
function localHead() {
  return command(["git", "rev-parse", "HEAD"]);
}
function publishedHead(branch: string) {
  const rows = command([
    "git",
    "ls-remote",
    "--exit-code",
    "origin",
    `refs/heads/${branch}`,
  ]).split("\n");
  if (rows.length !== 1) throw new Error("Ambiguous published branch");
  const [head, ref] = rows[0]?.split(/\s+/) ?? [];
  if (!head || !sha.test(head) || ref !== `refs/heads/${branch}`)
    throw new Error("Missing published HEAD");
  return head;
}

try {
  const args = process.argv.slice(2);
  const options = new Map<string, string>();
  for (let index = 0; index < args.length; index += 2) {
    const key = args[index];
    const value = args[index + 1];
    if (
      !key ||
      !value ||
      !["--repo", "--pr", "--head", "--base"].includes(key) ||
      options.has(key)
    )
      throw new Error(
        "Usage: full-send-check.ts --repo owner/repo --pr number --head SHA --base SHA",
      );
    options.set(key, value);
  }
  const repo = options.get("--repo") ?? "";
  const pr = options.get("--pr") ?? "";
  const head = options.get("--head") ?? "";
  const base = options.get("--base") ?? "";
  if (
    !/^[\w.-]+\/[\w.-]+$/.test(repo) ||
    !/^[1-9]\d*$/.test(pr) ||
    !sha.test(head) ||
    !sha.test(base)
  )
    throw new Error("Explicit repository, PR and full head/base SHAs required");
  const origin = command(["git", "config", "--get", "remote.origin.url"]);
  const remoteRepo = origin.match(
    /^(?:https:\/\/github\.com\/|git@github\.com:)([^\s]+?)(?:\.git)?$/,
  )?.[1];
  if (remoteRepo?.toLowerCase() !== repo.toLowerCase())
    throw new Error("origin does not identify the requested GitHub repository");
  const before = candidate(repo, pr);
  const reasons: string[] = [];
  let status = "hosted-gates-pass";
  let code = 0;
  const note = (reason: string, severity: number) => {
    reasons.push(reason);
    if (severity > code) {
      code = severity;
      status =
        severity === 3 ? "stale" : severity === 2 ? "blocked" : "pending";
    }
  };
  if (before.head !== head || before.base !== base)
    note("candidate-changed", 3);
  if (before.fork || before.state !== "OPEN") note("not-owned-open-pr", 2);
  if (before.draft) note("draft-boundary", 2);
  if (command(["git", "branch", "--show-current"]) !== before.branch)
    note("branch-mismatch", 3);
  if (command(["git", "status", "--porcelain"])) note("uncommitted-work", 3);
  if (localHead() !== head || publishedHead(before.branch) !== head)
    note("unpublished-or-stale-head", 3);
  const policy = reviewPolicy(repo, before.baseBranch, base, head);
  for (const reason of policy.reasons) note(reason, 2);
  const allChecks = checks(repo, pr, false);
  const requiredChecks = checks(repo, pr, true);
  for (const name of policy.requiredChecks) {
    if (
      requiredChecks.length &&
      !requiredChecks.some((check) => check.name === name)
    )
      note(`required-check-not-observed:${name}`, 1);
  }
  if (!allChecks.length || !requiredChecks.length)
    note("required-checks-missing-or-policy-unknown", 1);
  for (const check of [...allChecks, ...requiredChecks]) {
    if (check.bucket !== "pass")
      note(
        `check-${check.bucket}:${check.name}`,
        check.bucket === "pending" ? 1 : 2,
      );
  }
  if (
    !["", "APPROVED", "CHANGES_REQUESTED", "REVIEW_REQUIRED"].includes(
      before.review,
    )
  )
    throw new Error("Unknown provider review decision");
  if (
    before.review !== "APPROVED" &&
    (policy.requiredApprovals > 0 || before.review !== "")
  )
    note(
      before.review === "CHANGES_REQUESTED"
        ? "changes-requested"
        : "reviews-pending-or-policy-unknown",
      1,
    );
  const unresolved = threads(repo, pr);
  if (unresolved.length) note("unresolved-review-threads", 1);
  if (before.mergeable !== "MERGEABLE" || before.mergeState !== "CLEAN")
    note("mergeability-not-clean", 1);
  const after = candidate(repo, pr);
  if (
    JSON.stringify(before) !== JSON.stringify(after) ||
    command(["git", "branch", "--show-current"]) !== before.branch ||
    localHead() !== head ||
    publishedHead(before.branch) !== head ||
    command(["git", "status", "--porcelain"])
  )
    note("evidence-invalidated-during-read", 3);
  console.log(
    JSON.stringify({
      status,
      repo,
      pr: Number(pr),
      head,
      base,
      reasons: [...new Set(reasons)],
      checks: allChecks,
      requiredChecks,
      policy,
      unresolvedThreads: unresolved,
      next:
        code === 3
          ? "Refresh identity and replay affected verification."
          : code
            ? "Resolve named gates; notify the owner only for a genuine reserved decision or external blocker."
            : "Verify acceptance and all feedback, then use the separately authorized protected merge path.",
      limits:
        "Sampled read-only hosted gates, not product verification, complete semantic feedback triage, merge authorization, or atomic readiness.",
    }),
  );
  process.exitCode = code;
} catch (error) {
  console.log(
    JSON.stringify({
      status: "blocked",
      reasons: [error instanceof Error ? error.message : "Observation failed"],
      next: "Restore the missing prerequisite; do not substitute identity, credentials or permission.",
    }),
  );
  process.exitCode = 2;
}
