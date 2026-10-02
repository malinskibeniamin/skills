// Approves bot image-bump, ADP release, ui-registry version, and UI
// main -> preprod promotion PRs as the gh-authenticated user. A bump is approved only when
// every changed line fits its rule, a promotion only when its head is already
// on main; anything else is logged and raised as a macOS notification once
// per head.
//
//   bun scripts/auto-approve-bumps.ts            # dry run
//   bun scripts/auto-approve-bumps.ts --approve  # approve matches
//
// scripts/install-auto-approve-bumps.sh schedules it every 30 seconds. Each
// run is one 1-point GraphQL search; a PR costs REST calls only when its head
// is new, because decisions are cached per head.

import {
  existsSync,
  mkdirSync,
  readFileSync,
  renameSync,
  writeFileSync,
} from "node:fs";
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
  // Lines an additive file may still drop, such as a reformatted array.
  removable?: RegExp;
  // The file must be deleted outright, such as a consumed changeset.
  deleted?: boolean;
  // Captures a version that every added match must equal the branch's.
  version?: RegExp;
};

// PRs and commits default to vbotbuildovich.
type Authors = { author?: string; committer?: string };

type DiffRule = Authors & {
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
type PromotionRule = Authors & {
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
    // Changesets "version packages" PRs, built from already-merged changesets.
    kind: "diff",
    repo: "redpanda-data/ui-registry",
    author: "app/github-actions",
    committer: "github-actions[bot]",
    branch: /^changeset-release\/main$/,
    files: [
      {
        path: /^\.changeset\/(?!README\.md$)[\w-]+\.md$/,
        line: /^/,
        deleted: true,
      },
      {
        path: /^(?:packages\/[\w-]+\/)?CHANGELOG\.md$/,
        line: /^/,
        additive: true,
      },
      { path: /^packages\/[\w-]+\/package\.json$/, line: PACKAGE_VERSION },
      { path: "bun.lock", line: new RegExp(`^ {6}"version": "${SEMVER}",$`) },
      {
        // JSON data rendered by the docs site; only the components arrays
        // are reflowed from one line to many.
        path: "packages/docs/data/changelog.json",
        line: /^/,
        additive: true,
        removable: /^ {6}"components": \[(?:"[\w*-]+"(?:, "[\w*-]+")*)?\],$/,
      },
    ],
    approval: "Auto-approved: Changesets version bump from merged changesets.",
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
  deleted: boolean;
  removed: string[];
  added: string[];
};

type Verdict = { ok: true } | { ok: false; reason: string };

const STRUCTURAL =
  /^(new file mode|rename from|copy from|old mode|Binary files|GIT binary patch)/;

export function parseDiff(diff: string): FileDiff[] {
  const files: FileDiff[] = [];
  let current: FileDiff | undefined;
  // Only lines inside a hunk are content; before it, "--- a/x" is a header.
  let inHunk = false;
  for (const line of diff.split("\n")) {
    const header = /^diff --git a\/(.+) b\/(.+)$/.exec(line);
    if (header) {
      current = {
        path: header[2] ?? "",
        structural: header[1] !== header[2],
        deleted: false,
        removed: [],
        added: [],
      };
      files.push(current);
      inHunk = false;
    } else if (!current) {
    } else if (line.startsWith("@@")) {
      inHunk = true;
    } else if (!inHunk) {
      if (line.startsWith("deleted file mode")) current.deleted = true;
      if (STRUCTURAL.test(line)) current.structural = true;
    } else if (line.startsWith("-")) {
      current.removed.push(line.slice(1));
    } else if (line.startsWith("+")) {
      current.added.push(line.slice(1));
    }
  }
  return files;
}

function checkOpener(pr: BumpPr, rule: Rule, base: string): Verdict {
  if (pr.author !== (rule.author ?? BOT)) {
    return { ok: false, reason: `author ${pr.author}` };
  }
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
  const opener = checkOpener(pr, rule, rule.base);
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
  const opener = checkOpener(pr, rule, "main");
  if (!opener.ok) return opener;
  if (
    pr.commitAuthors.length === 0 ||
    pr.commitAuthors.some((a) => a !== (rule.committer ?? BOT))
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
    if (file.deleted !== Boolean(fileRule.deleted)) {
      return {
        ok: false,
        reason: file.deleted
          ? `deleted ${file.path}`
          : `expected ${file.path} to be deleted`,
      };
    }
    if (file.deleted) continue;
    const removable = fileRule.removable;
    if (
      fileRule.additive &&
      file.removed.some((line) => !removable?.test(line))
    ) {
      return { ok: false, reason: `removed lines in ${file.path}` };
    }
    const checked = fileRule.additive
      ? file.added
      : [...file.removed, ...file.added];
    const unexpected = checked.find((line) => !fileRule.line.test(line));
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

const PR_FIELDS =
  "number url isDraft baseRefName headRefName headRefOid author { __typename login } repository { nameWithOwner }";

// One search per PR author across its repos, sent as a single query.
export function searchQuery(): string {
  const reposByAuthor = new Map<string, string[]>();
  for (const rule of RULES) {
    const author = rule.author ?? BOT;
    const repos = reposByAuthor.get(author) ?? [];
    if (!repos.includes(rule.repo)) repos.push(rule.repo);
    reposByAuthor.set(author, repos);
  }
  const searches = [...reposByAuthor].map(([author, repos], i) => {
    const query = [
      "is:pr is:open",
      `author:${author}`,
      ...repos.map((repo) => `repo:${repo}`),
    ].join(" ");
    return `s${i}: search(query: ${JSON.stringify(query)}, type: ISSUE, first: 100) { nodes { ... on PullRequest { ${PR_FIELDS} } } }`;
  });
  return `query { ${searches.join(" ")} }`;
}

// Decisions are keyed by head, so a PR is evaluated again only after a push.
export function pendingPrs<T extends { key: string; head: string }>(
  open: readonly T[],
  decided: Readonly<Record<string, string>>,
): { pending: T[]; decided: Record<string, string> } {
  const kept: Record<string, string> = {};
  for (const pr of open) {
    const head = decided[pr.key];
    if (head !== undefined) kept[pr.key] = head;
  }
  return {
    pending: open.filter((pr) => decided[pr.key] !== pr.head),
    decided: kept,
  };
}

const SearchResults = z.object({
  data: z.record(
    z.object({
      nodes: z.array(
        z.object({
          number: z.number(),
          url: z.string(),
          isDraft: z.boolean(),
          baseRefName: z.string(),
          headRefName: z.string(),
          headRefOid: z.string().regex(/^[0-9a-f]{40}$/),
          // gh shows GitHub App authors as app/<login>; match that.
          author: z
            .object({ __typename: z.string(), login: z.string() })
            .nullable()
            .transform((a) =>
              a?.__typename === "Bot" ? `app/${a.login}` : (a?.login ?? ""),
            ),
          repository: z.object({ nameWithOwner: z.string() }),
        }),
      ),
    }),
  ),
});
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
const STATE_FILE = join(STATE_DIR, "state.json");
// decided maps "<repo>#<number>" to the head already approved, rejected, or
// left to a human.
const State = z.object({
  viewer: z.string().optional(),
  decided: z.record(z.string()),
});
type State = z.infer<typeof State>;

function loadState(): State {
  if (!existsSync(STATE_FILE)) return { decided: {} };
  return State.parse(JSON.parse(readFileSync(STATE_FILE, "utf8")));
}

function saveState(state: State): void {
  mkdirSync(STATE_DIR, { recursive: true });
  const temp = `${STATE_FILE}.tmp`;
  writeFileSync(temp, `${JSON.stringify(state, null, 2)}\n`);
  renameSync(temp, STATE_FILE);
}

function notify(message: string): void {
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

// A dry run reads state but never writes it, so it cannot hide a real run.
function run(approve: boolean): void {
  const state = loadState();
  state.viewer ??= gh(["api", "user", "--jq", ".login"]).trim();
  const viewer = state.viewer;
  const results = SearchResults.parse(
    ghJson(["api", "graphql", "-f", `query=${searchQuery()}`]),
  );
  const open = Object.values(results.data)
    .flatMap((search) => search.nodes)
    .flatMap((node) => {
      const repo = node.repository.nameWithOwner;
      const rule = findRule(repo, node.headRefName);
      return rule
        ? [
            {
              key: `${repo}#${node.number}`,
              head: node.headRefOid,
              repo,
              rule,
              node,
            },
          ]
        : [];
    });
  const { pending, decided } = pendingPrs(open, state.decided);
  state.decided = decided;
  if (approve) saveState(state);

  for (const { key: pr, head, repo, rule, node } of pending) {
    const decide = () => {
      if (!approve) return;
      state.decided[pr] = head;
      saveState(state);
    };
    const mine = Reviews.parse(
      ghJson([
        "api",
        `repos/${repo}/pulls/${node.number}/reviews?per_page=100`,
      ]),
    ).flatMap((r) =>
      r.user?.login === viewer
        ? [{ state: r.state, commitId: r.commit_id ?? "" }]
        : [],
    );
    const action = reviewAction(mine, head);
    if (action === "skip") {
      decide();
      continue;
    }

    const facts: BumpPr = {
      repo,
      number: node.number,
      author: node.author,
      baseRefName: node.baseRefName,
      headRefName: node.headRefName,
      isDraft: node.isDraft,
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
          `repos/${repo}/pulls/${node.number}/commits?per_page=100`,
        ]),
      ).map((c) => c.author?.login ?? "");
      const diff = gh([
        "api",
        "-H",
        "Accept: application/vnd.github.diff",
        `repos/${repo}/compare/${node.baseRefName}...${head}`,
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
      if (approve) notify(`${pr}: ${verdict.reason}${stale} — ${node.url}`);
      decide();
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
      `repos/${repo}/pulls/${node.number}/reviews`,
      "-f",
      `commit_id=${head}`,
      "-f",
      "event=APPROVE",
      "-f",
      `body=${rule.approval}`,
    ]);
    log("info", { pr, head, approved: true });
    decide();
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
