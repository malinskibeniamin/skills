import { list, object, text } from "./github-evidence";
import { member, nonempty } from "./review-results";

/** Paginated, immutable-head CI evidence; never approve from a truncated rollup. */
export function prChecks(repo: string, head: string, cwd: string) {
  const pages = (path: string) => {
    const run = Bun.spawnSync(["gh", "api", path, "--paginate", "--slurp"], {
      cwd,
      timeout: 30_000,
    });
    if (run.exitCode !== 0)
      throw new Error(`CI unavailable: ${run.stderr.toString().trim()}`);
    return list(JSON.parse(run.stdout.toString()));
  };
  const checkPages = pages(
    `repos/${repo}/commits/${head}/check-runs?filter=latest&per_page=100`,
  ).map(object);
  if (!checkPages.length) throw new Error("Incomplete check-run pages");
  const runs = checkPages.flatMap((page) => list(page.check_runs));
  if (
    checkPages.some(
      (page) =>
        typeof page.total_count !== "number" ||
        page.total_count !== runs.length,
    )
  )
    throw new Error("Incomplete check-run inventory");
  const checks = runs.map((raw) => {
    const run = object(raw);
    if (text(run.head_sha) !== head)
      throw new Error("CI evidence belongs to a different head");
    const status = member(
      run.status,
      ["queued", "in_progress", "completed", "waiting", "requested", "pending"],
      "check status",
    );
    const conclusion =
      run.conclusion === null
        ? null
        : member(
            run.conclusion,
            [
              "success",
              "failure",
              "neutral",
              "cancelled",
              "skipped",
              "timed_out",
              "action_required",
              "startup_failure",
              "stale",
            ],
            "check conclusion",
          );
    return {
      name: nonempty(run.name, "check name"),
      bucket:
        status !== "completed"
          ? "pending"
          : conclusion === "success"
            ? "pass"
            : ["skipped", "neutral"].includes(conclusion ?? "")
              ? "skipping"
              : "fail",
      link: run.details_url == null ? "" : text(run.details_url),
    };
  });
  const seen = new Set<string>();
  for (const raw of pages(
    `repos/${repo}/commits/${head}/statuses?per_page=100`,
  ).flatMap(list)) {
    const item = object(raw);
    const name = nonempty(item.context, "status context");
    if (seen.has(name)) continue;
    seen.add(name);
    const status = member(
      item.state,
      ["success", "failure", "error", "pending"],
      "commit status",
    );
    checks.push({
      name,
      bucket:
        status === "success"
          ? "pass"
          : status === "pending"
            ? "pending"
            : "fail",
      link: item.target_url == null ? "" : text(item.target_url),
    });
  }
  return checks;
}
