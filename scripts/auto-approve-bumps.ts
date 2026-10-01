// Approves vbotbuildovich image-bump, ADP release, and UI main -> preprod
// promotion PRs as the gh-authenticated user. A bump is approved only when
// every changed line fits its rule, a promotion only when its head is already
// on main; anything else is logged and raised as a macOS notification once
// per head.
//
//   bun scripts/auto-approve-bumps.ts            # dry run
//   bun scripts/auto-approve-bumps.ts --approve  # approve matches
//
// scripts/install-auto-approve-bumps.sh schedules it every 2 minutes.

import { appendFileSync, mkdirSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { z } from "zod";

const BOT = "vbotbuildovich";
const INSTALL_PACK = /^install-pack\/[\w.-]+\.yml$/;
const SHA = "[0-9a-f]{7,40}";
const SEMVER = String.raw`\d+\.\d+\.\d+`;
// A single-quoted TypeScript literal; escapes cannot end it early.
const STRING = String.raw`'(?:[^'\\]|\\.)*'`;
const PACKAGE_VERSION = new RegExp(`^  "version": "(${SEMVER})",$`);

type FileRule = {
  path: string | RegExp;
  line: RegExp;
  // Additive files only gain lines; others swap each line one for one.
  additive?: boolean;
  // Captures a version that every added match must equal the branch's.
  version?: RegExp;
};

type DiffRule = {
  kind: "diff";
  repo: string;
  // A capture group, when present, is the release version.
  branch: RegExp;
  files: readonly FileRule[];
  // Every file rule must appear in the diff.
  exact?: boolean;
  approval: string;
};

// Promotes already-reviewed commits, so the head must be on the source branch.
type PromotionRule = {
  kind: "promotion";
  repo: string;
  branch: RegExp;
  base: string;
  source: string;
  approval: string;
};

type Rule = DiffRule | PromotionRule;

const IMAGE_TAG_APPROVAL = "Auto-approved: only the image tag changed.";

const RULES: readonly Rule[] = [
  {
    kind: "diff",
    repo: "redpanda-data/cloudv2",
    branch: /^auto\/bump-console-image$/,
    files: [
      {
        path: INSTALL_PACK,
        line: new RegExp(`^\\s*console_image_tag: master-${SHA}$`),
      },
    ],
    approval: IMAGE_TAG_APPROVAL,
  },
  {
    kind: "diff",
    repo: "redpanda-data/cloudv2",
    branch: /^auto\/bump-ai-gateway-version$/,
    files: [
      {
        path: INSTALL_PACK,
        line: new RegExp(`^\\s*ai_gateway_version: nightly-\\d{8}-${SHA}$`),
      },
    ],
    approval: IMAGE_TAG_APPROVAL,
  },
  {
    kind: "diff",
    repo: "redpanda-data/serverless",
    branch: /^auto\/bump-console-image$/,
    files: [
      {
        path: /^infra\/terraform\/config\/[\w-]+\/[\w-]+\/tags\.yaml$/,
        line: new RegExp(`^\\s*console_image_tag: "master-${SHA}"$`),
      },
    ],
    approval: IMAGE_TAG_APPROVAL,
  },
  {
    kind: "diff",
    repo: "redpanda-data/cloudv2",
    branch: new RegExp(`^adp-release/v(${SEMVER})$`),
    exact: true,
    files: [
      {
        path: "apps/adp-ui/package.json",
        line: PACKAGE_VERSION,
        version: PACKAGE_VERSION,
      },
      {
        path: "adp/RELEASE_NOTES.md",
        line: /^/,
        additive: true,
        version: new RegExp(`^## v(${SEMVER})\\b`),
      },
      {
        // Generated data only, so no added line can smuggle in code.
        path: "apps/adp-ui/src/lib/release-notes.generated.ts",
        line: new RegExp(
          `^(?:${[
            " {2}\\{",
            " {2}\\},",
            ` {4}version: '${SEMVER}',`,
            " {4}date: '\\d{4}-\\d{2}-\\d{2}',",
            " {4}sections: \\[",
            " {4}\\],",
            " {6}\\{",
            " {6}\\},",
            " {8}kind: '(?:feature|improvement|fix)',",
            " {8}items: \\[",
            " {8}\\],",
            ` {10}\\{ headline: ${STRING}, (?:tag: '(?:UI|CLI)', )?body: ${STRING} \\},`,
          ].join("|")})$`,
        ),
        additive: true,
        version: new RegExp(`^ {4}version: '(${SEMVER})',$`),
      },
    ],
    approval: "Auto-approved: version bump and additive release notes only.",
  },
  {
    // Opened by cloudv2 release-promotion.yml for the Cloud and Admin UIs.
    kind: "promotion",
    repo: "redpanda-data/cloudv2",
    branch: /^ux\/\d+-main-to-preprod$/,
    base: "preprod",
    source: "main",
    approval: "Auto-approved: every commit is already on main.",
  },
];

function matches(pattern: string | RegExp, path: string): boolean {
  return typeof pattern === "string" ? pattern === path : pattern.test(path);
}

function findRule(repo: string, branch: string): Rule | undefined {
  return RULES.find((r) => r.repo === repo && r.branch.test(branch));
}

export type BumpPr = {
  repo: string;
  number: number;
  author: string;
  baseRefName: string;
  headRefName: string;
  isDraft: boolean;
  commitAuthors: string[];
};

type FileDiff = {
  path: string;
  structural: boolean;
  removed: string[];
  added: string[];
};

type Verdict = { ok: true } | { ok: false; reason: string };

const STRUCTURAL =
  /^(new file mode|deleted file mode|rename from|copy from|old mode|Binary files|GIT binary patch)/;

export function parseDiff(diff: string): FileDiff[] {
  const files: FileDiff[] = [];
  let current: FileDiff | undefined;
  for (const line of diff.split("\n")) {
    const header = /^diff --git a\/(.+) b\/(.+)$/.exec(line);
    if (header) {
      current = {
        path: header[2] ?? "",
        structural: header[1] !== header[2],
        removed: [],
        added: [],
      };
      files.push(current);
    } else if (!current || line.startsWith("+++ ") || line.startsWith("--- ")) {
    } else if (STRUCTURAL.test(line)) {
      current.structural = true;
    } else if (line.startsWith("-")) {
      current.removed.push(line.slice(1));
    } else if (line.startsWith("+")) {
      current.added.push(line.slice(1));
    }
  }
  return files;
}

function checkOpener(pr: BumpPr, base: string): Verdict {
  if (pr.author !== BOT) return { ok: false, reason: `author ${pr.author}` };
  if (pr.isDraft) return { ok: false, reason: "draft" };
  if (pr.baseRefName !== base) {
    return { ok: false, reason: `base ${pr.baseRefName}` };
  }
  return { ok: true };
}

// `status` is GitHub's compare status of source...head.
export function checkPromotion(pr: BumpPr, status: string): Verdict {
  const rule = findRule(pr.repo, pr.headRefName);
  if (rule?.kind !== "promotion") {
    return { ok: false, reason: `unknown branch ${pr.headRefName}` };
  }
  const opener = checkOpener(pr, rule.base);
  if (!opener.ok) return opener;
  if (status !== "behind" && status !== "identical") {
    return {
      ok: false,
      reason: `head is ${status} ${rule.source}, so it has commits not on ${rule.source}`,
    };
  }
  return { ok: true };
}

export function checkBump(pr: BumpPr, diff: string): Verdict {
  const rule = findRule(pr.repo, pr.headRefName);
  if (rule?.kind !== "diff") {
    return { ok: false, reason: `unknown branch ${pr.headRefName}` };
  }
  const opener = checkOpener(pr, "main");
  if (!opener.ok) return opener;
  if (
    pr.commitAuthors.length === 0 ||
    pr.commitAuthors.some((a) => a !== BOT)
  ) {
    return { ok: false, reason: "commit not authored by the bot" };
  }

  const version = rule.branch.exec(pr.headRefName)?.[1];
  const files = parseDiff(diff);
  if (files.length === 0) return { ok: false, reason: "empty diff" };
  for (const file of files) {
    const fileRule = rule.files.find((f) => matches(f.path, file.path));
    if (!fileRule) {
      return { ok: false, reason: `unexpected file ${file.path}` };
    }
    if (file.structural) {
      return { ok: false, reason: `structural change in ${file.path}` };
    }
    if (fileRule.additive && file.removed.length > 0) {
      return { ok: false, reason: `removed lines in ${file.path}` };
    }
    const unexpected = [...file.removed, ...file.added].find(
      (line) => !fileRule.line.test(line),
    );
    if (unexpected !== undefined) {
      return {
        ok: false,
        reason: `unexpected change in ${file.path}: ${unexpected.trim()}`,
      };
    }
    if (
      file.added.length === 0 ||
      (!fileRule.additive && file.added.length !== file.removed.length)
    ) {
      return { ok: false, reason: `unbalanced change in ${file.path}` };
    }
    if (fileRule.version) {
      const pattern = fileRule.version;
      const found = file.added.flatMap((line) => pattern.exec(line)?.[1] ?? []);
      const wrong = found.find((v) => v !== version);
      if (found.length === 0 || wrong !== undefined) {
        return {
          ok: false,
          reason: `version ${wrong ?? "missing"} in ${file.path}, expected ${version}`,
        };
      }
    }
  }
  const missing = rule.exact
    ? rule.files.find((f) => !files.some((file) => matches(f.path, file.path)))
    : undefined;
  if (missing) return { ok: false, reason: `missing file ${missing.path}` };
  return { ok: true };
}

export type Review = { state: string; commitId: string };

// GitHub counts a reviewer's latest approval or change request; comments
// leave it unchanged. Once you comment or object, the PR stays yours.
export function reviewAction(
  mine: readonly Review[],
  head: string,
): "check" | "recheck" | "skip" {
  const standing = mine.findLast(
    (r) => r.state !== "COMMENTED" && r.state !== "PENDING",
  );
  if (standing?.state === "APPROVED") {
    return standing.commitId === head ? "skip" : "recheck";
  }
  if (standing?.state === "CHANGES_REQUESTED") return "skip";
  return mine.some((r) => r.state === "COMMENTED") ? "skip" : "check";
}

const ListedPrs = z.array(
  z.object({
    number: z.number(),
    author: z.object({ login: z.string() }),
    baseRefName: z.string(),
    headRefName: z.string(),
    headRefOid: z.string().regex(/^[0-9a-f]{40}$/),
    isDraft: z.boolean(),
    url: z.string(),
  }),
);
const Reviews = z.array(
  z.object({
    user: z.object({ login: z.string() }).nullable(),
    state: z.string(),
    commit_id: z.string().nullable(),
  }),
);
const Commits = z.array(
  z.object({ author: z.object({ login: z.string() }).nullable() }),
);

function ghJson(args: string[]): unknown {
  return JSON.parse(gh(args));
}

function gh(args: string[]): string {
  const result = Bun.spawnSync(["gh", ...args], { stderr: "pipe" });
  if (result.exitCode !== 0) {
    throw new Error(`gh ${args[0]} failed: ${result.stderr.toString().trim()}`);
  }
  return result.stdout.toString();
}

function log(level: "info" | "warn" | "error", fields: object): void {
  console.log(
    JSON.stringify({ time: new Date().toISOString(), level, ...fields }),
  );
}

const STATE_DIR = join(homedir(), ".local", "state", "auto-approve-bumps");
const NOTIFIED = join(STATE_DIR, "notified");

function notifyOnce(key: string, message: string): void {
  mkdirSync(STATE_DIR, { recursive: true });
  let seen = "";
  try {
    seen = readFileSync(NOTIFIED, "utf8");
  } catch {}
  if (seen.split("\n").includes(key)) return;
  appendFileSync(NOTIFIED, `${key}\n`);
  Bun.spawnSync([
    "osascript",
    "-e",
    "on run argv",
    "-e",
    'display notification (item 1 of argv) with title "Bot PR needs a human"',
    "-e",
    "end run",
    message,
  ]);
}

function run(approve: boolean): void {
  const viewer = gh(["api", "user", "--jq", ".login"]).trim();
  for (const repo of new Set(RULES.map((r) => r.repo))) {
    const listed = ListedPrs.parse(
      ghJson([
        "pr",
        "list",
        "-R",
        repo,
        "--author",
        BOT,
        "--state",
        "open",
        "--json",
        "number,author,baseRefName,headRefName,headRefOid,isDraft,url",
      ]),
    );
    for (const item of listed) {
      const rule = findRule(repo, item.headRefName);
      if (!rule) continue;
      const pr = `${repo}#${item.number}`;
      const head = item.headRefOid;
      const mine = Reviews.parse(
        ghJson([
          "api",
          `repos/${repo}/pulls/${item.number}/reviews?per_page=100`,
        ]),
      ).flatMap((r) =>
        r.user?.login === viewer
          ? [{ state: r.state, commitId: r.commit_id ?? "" }]
          : [],
      );
      const action = reviewAction(mine, head);
      if (action === "skip") continue;

      const facts: BumpPr = {
        repo,
        number: item.number,
        author: item.author.login,
        baseRefName: item.baseRefName,
        headRefName: item.headRefName,
        isDraft: item.isDraft,
        commitAuthors: [],
      };
      // Pin the check and the approval to the same head so a later push is
      // never approved unseen.
      let verdict: Verdict;
      if (rule.kind === "promotion") {
        const status = gh([
          "api",
          `repos/${repo}/compare/${rule.source}...${head}`,
          "--jq",
          ".status",
        ]).trim();
        verdict = checkPromotion(facts, status);
      } else {
        facts.commitAuthors = Commits.parse(
          ghJson([
            "api",
            `repos/${repo}/pulls/${item.number}/commits?per_page=100`,
          ]),
        ).map((c) => c.author?.login ?? "");
        const diff = gh([
          "api",
          "-H",
          "Accept: application/vnd.github.diff",
          `repos/${repo}/compare/${item.baseRefName}...${head}`,
        ]);
        verdict = checkBump(facts, diff);
      }
      if (!verdict.ok) {
        const stale =
          action === "recheck"
            ? " (your approval of an older commit still counts)"
            : "";
        log("warn", {
          pr,
          head,
          skipped: verdict.reason,
          staleApproval: stale !== "",
        });
        notifyOnce(
          `${pr}@${head}`,
          `${pr}: ${verdict.reason}${stale} — ${item.url}`,
        );
        continue;
      }
      if (!approve) {
        log("info", { pr, head, wouldApprove: true });
        continue;
      }
      gh([
        "api",
        "--method",
        "POST",
        `repos/${repo}/pulls/${item.number}/reviews`,
        "-f",
        `commit_id=${head}`,
        "-f",
        "event=APPROVE",
        "-f",
        `body=${rule.approval}`,
      ]);
      log("info", { pr, head, approved: true });
    }
  }
}

if (import.meta.main) {
  try {
    run(process.argv.includes("--approve"));
  } catch (error) {
    log("error", { error: String(error) });
    process.exit(1);
  }
}
