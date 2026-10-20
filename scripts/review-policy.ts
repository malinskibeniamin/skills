import { count, flag, list, object, text } from "./github-evidence";

// A 404 here means no classic protection, not missing credentials or a green policy.
function read(path: string, pages = false, allowMissing = false): unknown {
  const result = Bun.spawnSync(
    [
      "gh",
      "api",
      path,
      "--hostname",
      "github.com",
      ...(pages ? ["--paginate", "--slurp"] : []),
    ],
    { timeout: 15_000 },
  );
  let value: unknown;
  try {
    value = JSON.parse(result.stdout.toString());
  } catch {
    throw new Error(`Review policy unavailable: ${path}`);
  }
  if (result.exitCode !== 0) {
    if (allowMissing && object(value).status === "404") return null;
    throw new Error(`Review policy unavailable: ${path}`);
  }
  return value;
}
function enabled(value: unknown) {
  return flag(object(value).enabled);
}
function context(value: unknown) {
  const name = text(value);
  if (!name.trim()) throw new Error("Missing required check context");
  return name;
}

/** Observe the consumer's actual base policy; never copy or mutate hosted settings. */
export function reviewPolicy(
  repo: string,
  branch: string,
  base: string,
  head: string,
) {
  const path = `repos/${repo}`;
  const raw = read(
    `${path}/branches/${encodeURIComponent(branch)}/protection`,
    false,
    true,
  );
  const classic = raw === null ? null : object(raw);
  const pages = list(
    read(
      `${path}/rules/branches/${encodeURIComponent(branch)}?per_page=100`,
      true,
    ),
  );
  if (!pages.length) throw new Error("Incomplete branch rules response");
  const active = pages.flatMap((page) =>
    list(page).map((value) => {
      const item = object(value);
      const id = count(item.ruleset_id);
      if (!id) throw new Error("Missing native ruleset identity");
      return { type: text(item.type), id, parameters: item.parameters };
    }),
  );
  const trusted: typeof active = [];
  for (const id of new Set(active.map((item) => item.id))) {
    const details = object(read(`${path}/rulesets/${id}`));
    const enforcement = text(details.enforcement);
    if (!["active", "evaluate", "disabled"].includes(enforcement))
      throw new Error("Unknown ruleset enforcement state");
    // Omitted without sufficient access: unknown is not an empty bypass list.
    const bypass = list(details.bypass_actors);
    if (enforcement === "active" && !bypass.length)
      trusted.push(...active.filter((item) => item.id === id));
  }
  const enforced = classic && enabled(classic.enforce_admins) ? classic : null;
  const checks = enforced?.required_status_checks
    ? object(enforced.required_status_checks)
    : null;
  const reviews = enforced?.required_pull_request_reviews
    ? object(enforced.required_pull_request_reviews)
    : null;
  const nativeReviews = classic?.required_pull_request_reviews
    ? object(classic.required_pull_request_reviews)
    : null;
  const requiredChecks = new Set(
    checks ? list(checks.contexts).map(context) : [],
  );
  let currentBase = checks ? flag(checks.strict) : false;
  let conversations = enforced?.required_conversation_resolution
    ? enabled(enforced.required_conversation_resolution)
    : false;
  let staleApprovals = reviews ? flag(reviews.dismiss_stale_reviews) : false;
  let pullRequests = Boolean(reviews);
  let forcePushBlocked = enforced?.allow_force_pushes
    ? !enabled(enforced.allow_force_pushes)
    : false;
  let deletionBlocked = enforced?.allow_deletions
    ? !enabled(enforced.allow_deletions)
    : false;
  let requiredApprovals = nativeReviews
    ? count(nativeReviews.required_approving_review_count)
    : 0;
  for (const item of trusted) {
    switch (item.type) {
      case "required_status_checks": {
        const params = object(item.parameters);
        for (const check of list(params.required_status_checks))
          requiredChecks.add(context(object(check).context));
        currentBase ||= flag(params.strict_required_status_checks_policy);
        break;
      }
      case "pull_request": {
        const params = object(item.parameters);
        pullRequests = true;
        requiredApprovals = Math.max(
          requiredApprovals,
          count(params.required_approving_review_count),
        );
        staleApprovals ||= flag(params.dismiss_stale_reviews_on_push);
        conversations ||= flag(params.required_review_thread_resolution);
        break;
      }
      case "merge_queue":
        currentBase = true;
        break;
      case "non_fast_forward":
        forcePushBlocked = true;
        break;
      case "deletion":
        deletionBlocked = true;
        break;
      // Other native rules remain enforced by GitHub; they do not establish these gates.
    }
  }
  const reasons = [
    ...(!requiredChecks.size ? ["review-policy:required-checks-missing"] : []),
    ...(!currentBase ? ["review-policy:strict-base-or-queue-missing"] : []),
    ...(!pullRequests ? ["review-policy:pull-requests-not-enforced"] : []),
    ...(!conversations ? ["review-policy:thread-resolution-not-enforced"] : []),
    ...(requiredApprovals > 0 && !staleApprovals
      ? ["review-policy:stale-approvals-not-dismissed"]
      : []),
    ...(!forcePushBlocked ? ["review-policy:force-pushes-not-blocked"] : []),
    ...(!deletionBlocked ? ["review-policy:branch-deletion-not-blocked"] : []),
  ];
  // Inspect direct uses in the consumer's committed workflows, not the plugin's .github.
  const workflow = Bun.spawnSync([
    "git",
    "grep",
    "-I",
    "-l",
    "-E",
    "^[[:space:]]*(-[[:space:]]*)?uses:[[:space:]]*[\"']?actions/dependency-review-action@",
    head,
    "--",
    ":(top).github/workflows",
  ]);
  if (![0, 1].includes(workflow.exitCode ?? -1))
    throw new Error("Cannot inspect candidate dependency-review workflows");
  const dependencyReview = workflow.exitCode === 0;
  if (dependencyReview) {
    // Replay the action's public seam: disabled graph, access and plan errors block.
    list(read(`${path}/dependency-graph/compare/${base}...${head}`));
  }
  return {
    requiredChecks: [...requiredChecks].sort(),
    requiredApprovals,
    dependencyReview: dependencyReview ? "verified" : "not-detected",
    reasons,
  };
}
