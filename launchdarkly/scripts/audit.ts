import { execFileSync } from "node:child_process";

const DAY = 86_400_000;
const ENVIRONMENTS = ["integration", "production"];
type ObjectValue = Record<string, unknown>;
type Cli = (args: string[]) => unknown;
type Finding = {
  key: string;
  status: "candidate" | "excluded" | "unknown";
  reason: string;
  createdAt?: string;
  lastTargetingChangeAt?: string;
};

function isObject(value: unknown): value is ObjectValue {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function object(value: unknown): ObjectValue {
  if (!isObject(value)) {
    throw new Error("Expected a JSON object; evidence unavailable");
  }
  return value;
}

function array(value: unknown): unknown[] {
  if (!Array.isArray(value)) throw new Error("Missing full array evidence");
  return value;
}

function key(value: unknown): string {
  if (typeof value !== "string" || !/^[\w.-]+$/.test(value)) {
    throw new Error("Missing or invalid resource key");
  }
  return value;
}

function timestamp(value: unknown, at: number): number {
  const number =
    typeof value === "string" && /^\d+$/.test(value) ? Number(value) : value;
  if (
    typeof number !== "number" ||
    !Number.isSafeInteger(number) ||
    number <= 0 ||
    number > at
  ) {
    throw new Error("Missing, invalid, or future timestamp");
  }
  return number;
}

// Read each next offset through ldcli, never follow server URLs with HTTP.
function inventory(cli: Cli, args: string[]): Map<string, ObjectValue> {
  const items = new Map<string, ObjectValue>();
  let offset = 0;
  let total: number | undefined;
  for (;;) {
    const page = object(
      cli([...args, "--limit", "20", "--offset", String(offset)]),
    );
    const batch = array(page.items);
    for (const value of batch) {
      const item = object(value);
      const id = key(item.key);
      if (items.has(id))
        throw new Error("Duplicate inventory key; rerun audit");
      items.set(id, item);
    }
    if (page.totalCount !== undefined) {
      if (
        typeof page.totalCount !== "number" ||
        !Number.isSafeInteger(page.totalCount) ||
        page.totalCount < 0 ||
        (total !== undefined && total !== page.totalCount)
      ) {
        throw new Error("Invalid or changing inventory total; rerun audit");
      }
      total = page.totalCount;
    }
    const next = object(page._links).next;
    if (next === undefined || next === null) break;
    const href = object(next).href;
    if (typeof href !== "string") throw new Error("Invalid pagination link");
    const value = new URL(href, "https://pagination.invalid").searchParams.get(
      "offset",
    );
    const nextOffset =
      value !== null && /^\d+$/.test(value) ? Number(value) : NaN;
    if (
      batch.length === 0 ||
      !Number.isSafeInteger(nextOffset) ||
      nextOffset !== offset + batch.length
    ) {
      throw new Error("Incomplete or non-advancing pagination");
    }
    offset = nextOffset;
  }
  if (total !== undefined && total !== items.size) {
    throw new Error(
      "Incomplete inventory; total does not match collected keys",
    );
  }
  return items;
}

function servesTrue(outcome: ObjectValue, variations: unknown[]): boolean {
  const variationIsTrue = (value: unknown) => {
    if (
      typeof value !== "number" ||
      !Number.isInteger(value) ||
      value < 0 ||
      value >= variations.length
    ) {
      throw new Error("Missing or invalid variation index");
    }
    return object(variations[value]).value === true;
  };
  if (outcome.rollout !== undefined && outcome.rollout !== null) {
    if (outcome.variation !== undefined && outcome.variation !== null) {
      throw new Error("Ambiguous variation and rollout");
    }
    const rollout = object(outcome.rollout);
    if (rollout.kind !== undefined && rollout.kind !== "rollout") {
      throw new Error("Experiment rollout needs manual review");
    }
    let weight = 0;
    let allTrue = true;
    for (const value of array(rollout.variations)) {
      const bucket = object(value);
      if (
        typeof bucket.weight !== "number" ||
        !Number.isInteger(bucket.weight) ||
        bucket.weight < 0 ||
        bucket.weight > 100_000
      ) {
        throw new Error("Invalid rollout weight");
      }
      weight += bucket.weight;
      if (bucket.weight > 0 && !variationIsTrue(bucket.variation))
        allTrue = false;
    }
    if (weight !== 100_000) throw new Error("Incomplete rollout weights");
    return allTrue;
  }
  return variationIsTrue(outcome.variation);
}

function checkEnvironment(env: ObjectValue, variations: unknown[]) {
  if (env.on === false) return false;
  if (env.on !== true) throw new Error("Missing targeting on/off state");
  if (array(env.prerequisites).length > 0) {
    throw new Error("Prerequisite targeting needs manual review");
  }
  let allTrue = servesTrue(object(env.fallthrough), variations);
  for (const target of [...array(env.targets), ...array(env.contextTargets)]) {
    const value = object(target);
    if (array(value.values).length > 0 && !servesTrue(value, variations)) {
      allTrue = false;
    }
  }
  for (const rule of array(env.rules)) {
    if (!servesTrue(object(rule), variations)) allTrue = false;
  }
  return allTrue;
}

/** Read-only Integration and Production retirement report via ldcli. */
export function auditProject(project: string, cli: Cli, at = Date.now()) {
  key(project);
  timestamp(at, Date.now());
  const cutoff = at - 14 * DAY;
  const environments = inventory(cli, [
    "environments",
    "list",
    "--project",
    project,
  ]);
  for (const env of ENVIRONMENTS) {
    if (!environments.has(env))
      throw new Error(`Required environment ${env} is missing or inaccessible`);
  }
  const flags = inventory(cli, [
    "flags",
    "list",
    "--project",
    project,
    "--sort",
    "key",
  ]);
  const snapshots = new Map<string, Map<string, ObjectValue>>();
  for (const env of ENVIRONMENTS) {
    const snapshot = inventory(cli, [
      "flags",
      "list",
      "--project",
      project,
      "--env",
      env,
      "--summary",
      "0",
      "--sort",
      "key",
    ]);
    if (
      snapshot.size !== flags.size ||
      [...snapshot.keys()].some((id) => !flags.has(id))
    ) {
      throw new Error(
        "Flag inventory differs across environments; access incomplete or inventory changed",
      );
    }
    snapshots.set(env, snapshot);
  }
  const findings: Finding[] = [];
  for (const [id, flag] of flags) {
    const finding: Finding = {
      key: id,
      status: "unknown",
      reason: "Evidence unavailable",
    };
    findings.push(finding);
    try {
      if (typeof flag.archived !== "boolean")
        throw new Error("Missing archive state");
      if (flag.archived) {
        finding.status = "excluded";
        finding.reason = "Already archived";
        continue;
      }
      const created = timestamp(flag.creationDate, at);
      finding.createdAt = new Date(created).toISOString();
      if (created >= at - 30 * DAY) {
        finding.status = "excluded";
        finding.reason = "Not created more than 30 days ago";
        continue;
      }
      const configurations = [...snapshots].map(([env, snapshot]) =>
        object(object(object(snapshot.get(id)).environments)[env]),
      );
      if (configurations.some((config) => config.on === false)) {
        finding.status = "excluded";
        finding.reason = "Targeting is off in a selected environment";
        continue;
      }
      if (flag.kind !== "boolean")
        throw new Error("Non-boolean enabled value needs manual review");
      const variations = array(flag.variations);
      if (
        variations.length === 0 ||
        variations.some((value) => typeof object(value).value !== "boolean")
      ) {
        throw new Error("Invalid boolean variations");
      }
      let enabled = true;
      let modified = created;
      for (const [env, snapshot] of snapshots) {
        const item = snapshot.get(id);
        if (!item) throw new Error(`Missing flag in ${env}`);
        for (const field of [
          "creationDate",
          "variations",
          "archived",
          "kind",
          "_version",
        ]) {
          if (JSON.stringify(item[field]) !== JSON.stringify(flag[field])) {
            throw new Error("Flag metadata changed during audit; rerun");
          }
        }
        const config = object(object(item.environments)[env]);
        if (!checkEnvironment(config, variations)) enabled = false;
        modified = Math.max(modified, timestamp(config.lastModified, at));
      }
      finding.lastTargetingChangeAt = new Date(modified).toISOString();
      if (!enabled || modified >= cutoff) {
        finding.status = "excluded";
        finding.reason = !enabled
          ? "Not enabled for everyone in every environment"
          : "Targeting changed within 14 days";
        continue;
      }
      let changed = false;
      for (const env of ENVIRONMENTS) {
        const history = object(
          cli([
            "audit-log",
            "list",
            "--spec",
            `proj/${project}:env/${env}:flag/${id}`,
            "--after",
            String(cutoff - 1),
            "--limit",
            "1",
          ]),
        );
        const changes = array(history.items);
        // One hit disproves quietness. Empty results must have no next page.
        if (changes.length === 0 && object(history._links).next != null) {
          throw new Error("Incomplete change history");
        }
        if (changes.length > 0) changed = true;
      }
      finding.status = changed ? "excluded" : "candidate";
      finding.reason = changed
        ? "Flag changed within 14 days in the selected scope"
        : "Created over 30 days ago; universally true in selected environments; no changes in 14 days";
    } catch (error) {
      finding.status = "unknown";
      finding.reason =
        error instanceof Error ? error.message : "Evidence unavailable";
    }
  }
  const candidateCount = findings.filter(
    (item) => item.status === "candidate",
  ).length;
  const unknownCount = findings.filter(
    (item) => item.status === "unknown",
  ).length;
  return {
    project,
    auditedAt: new Date(at).toISOString(),
    quietSince: new Date(cutoff).toISOString(),
    scope:
      "Integration and Production only; resources visible to the configured ldcli token",
    environmentKeys: ENVIRONMENTS,
    ignoredEnvironmentKeys: [...environments.keys()].filter(
      (env) => !ENVIRONMENTS.includes(env),
    ),
    scannedCount: findings.length,
    candidateCount,
    unknownCount,
    excludedCount: findings.length - candidateCount - unknownCount,
    exactCount: unknownCount === 0 ? candidateCount : null,
    flags: findings,
  };
}

function ldcli(args: string[]): unknown {
  let stdout: string;
  try {
    stdout = execFileSync("ldcli", [...args, "--output", "json"], {
      encoding: "utf8",
      timeout: 60_000,
      maxBuffer: 32 * 1024 * 1024,
      stdio: ["ignore", "pipe", "pipe"],
    });
  } catch {
    throw new Error(
      `ldcli ${args[0]} ${args[1]} failed; check login, permissions, rate limits, and installed --help`,
    );
  }
  try {
    return JSON.parse(stdout);
  } catch {
    throw new Error("ldcli returned invalid JSON; no count is proven");
  }
}

if (import.meta.main) {
  const args = Bun.argv.slice(2);
  if (args.length === 1 && args[0] === "--help") {
    console.log(
      "Usage: bun run launchdarkly/scripts/audit.ts --project <key>\nRead-only Integration and Production 30-day age / 14-day quiet audit. JSON output; exit 2 means unknown evidence.\nRequires bun and authenticated ldcli. Never archives or deletes flags.",
    );
  } else {
    try {
      if (args.length !== 2 || args[0] !== "--project" || !args[1]) {
        throw new Error("Expected --project <key>; use --help");
      }
      const report = auditProject(args[1], ldcli);
      console.log(JSON.stringify(report, null, 2));
      if (report.unknownCount > 0) process.exitCode = 2;
    } catch (error) {
      console.error(error instanceof Error ? error.message : "Audit failed");
      process.exitCode = 1;
    }
  }
}
