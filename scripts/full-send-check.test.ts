import { afterEach, expect, test } from "bun:test";
import {
  mkdtempSync,
  mkdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const entry = new URL("./full-send-check.ts", import.meta.url).pathname;
const directories: string[] = [];
afterEach(() => {
  for (const directory of directories.splice(0))
    rmSync(directory, { recursive: true, force: true });
});

function fixture() {
  const root = mkdtempSync(join(tmpdir(), "full-send-check-"));
  directories.push(root);
  const worktree = join(root, "worktree");
  const bin = join(root, "bin");
  mkdirSync(worktree);
  mkdirSync(bin);
  const git = (...args: string[]) => {
    const result = Bun.spawnSync(["git", ...args], { cwd: worktree });
    expect(result.exitCode).toBe(0);
    return result.stdout.toString().trim();
  };
  git("init", "-b", "ben-malinski/T-1/feature");
  git("config", "user.name", "Fixture");
  git("config", "user.email", "fixture@example.com");
  git("commit", "--allow-empty", "-m", "feat(test): initial");
  git("init", "--bare", join(root, "remote.git"));
  git(
    "config",
    `url.${join(root, "remote.git")}.insteadOf`,
    "https://github.com/example/project.git",
  );
  git("remote", "add", "origin", "https://github.com/example/project.git");
  git("push", "origin", "HEAD");
  const head = git("rev-parse", "HEAD");
  const snapshot = {
    pr: {
      state: "OPEN",
      isDraft: false,
      isCrossRepository: false,
      headRefName: "ben-malinski/T-1/feature",
      baseRefName: "main",
      headRefOid: head,
      baseRefOid: head,
      reviewDecision: "APPROVED",
      mergeable: "MERGEABLE",
      mergeStateStatus: "CLEAN",
    },
    checks: [{ name: "test", bucket: "pass", state: "SUCCESS" }],
    required: [{ name: "test", bucket: "pass", state: "SUCCESS" }],
    pages: [
      {
        nodes: [] as { id: string; isResolved: boolean; isOutdated: boolean }[],
        pageInfo: { hasNextPage: false, endCursor: "last" },
      },
    ],
    failGh: false,
    absentChecks: false,
    changeOnRead: "",
    detachOnRead: 0,
    viewReads: 0,
  };
  const data = join(root, "github.json");
  const calls = join(root, "calls.jsonl");
  const save = () => writeFileSync(data, JSON.stringify(snapshot));
  save();
  writeFileSync(
    join(bin, "gh"),
    `#!${process.execPath}
import { appendFileSync, readFileSync, writeFileSync } from "node:fs";
const args = process.argv.slice(2);
appendFileSync(process.env.CALLS, JSON.stringify(args) + "\\n");
const d = JSON.parse(readFileSync(process.env.DATA, "utf8"));
if (d.failGh) process.exit(1);
if (args[0] === "pr" && args[1] === "view") {
  console.log(JSON.stringify(d.pr));
  d.viewReads += 1;
  if (d.detachOnRead === d.viewReads) Bun.spawnSync(["git", "switch", "--detach"]);
  writeFileSync(process.env.DATA, JSON.stringify(d));
  if (d.changeOnRead) { d.pr[d.changeOnRead] = "a".repeat(40); d.changeOnRead = ""; writeFileSync(process.env.DATA, JSON.stringify(d)); }
} else if (args[0] === "pr" && args[1] === "checks") {
  if (d.absentChecks && args.includes("--required")) { console.error("no required checks reported on the fixture branch"); process.exit(1); }
  const checks = args.includes("--required") ? d.required : d.checks;
  console.log(JSON.stringify(checks));
  if (checks.some(c => c.bucket === "fail")) process.exit(1);
  if (checks.some(c => c.bucket === "pending")) process.exit(8);
} else if (args[0] === "api" && args[1] === "graphql") {
  const cursor = args.find(a => a.startsWith("cursor="));
  const page = cursor ? d.pages[1] : d.pages[0];
  console.log(JSON.stringify({ data: { repository: { pullRequest: { reviewThreads: page } } } }));
} else { process.exit(2); }
`,
    { mode: 0o755 },
  );
  const run = () => {
    const result = Bun.spawnSync(
      [
        process.execPath,
        entry,
        "--repo",
        "example/project",
        "--pr",
        "42",
        "--head",
        head,
        "--base",
        head,
      ],
      {
        cwd: worktree,
        env: {
          ...Bun.env,
          PATH: `${bin}:${Bun.env.PATH}`,
          DATA: data,
          CALLS: calls,
        },
      },
    );
    return {
      code: result.exitCode,
      receipt: JSON.parse(result.stdout.toString()) as {
        status: string;
        reasons: string[];
        head?: string;
      },
    };
  };
  return { git, run, snapshot, save, calls, worktree, head };
}

test("observes a published candidate without performing any hosted mutation", () => {
  const f = fixture();
  expect(f.run()).toEqual({
    code: 0,
    receipt: expect.objectContaining({
      status: "hosted-gates-pass",
      head: f.head,
    }),
  });
  const calls: string[][] = readFileSync(f.calls, "utf8")
    .trim()
    .split("\n")
    .map((line) => JSON.parse(line));
  expect(
    calls.every(
      (args) =>
        (args[0] === "pr" && ["view", "checks"].includes(args[1] ?? "")) ||
        (args[0] === "api" && args[1] === "graphql"),
    ),
  ).toBe(true);
});

test("pins all hosted reads to the same GitHub host as origin", () => {
  const f = fixture();
  expect(f.run().code).toBe(0);
  const calls: string[][] = readFileSync(f.calls, "utf8")
    .trim()
    .split("\n")
    .map((line) => JSON.parse(line));
  for (const args of calls) {
    const selector = args[0] === "pr" ? "--repo" : "--hostname";
    expect(args[args.indexOf(selector) + 1]).toBe(
      args[0] === "pr" ? "github.com/example/project" : "github.com",
    );
  }
});

test("invalidates evidence when the checkout detaches during hosted observation", () => {
  const f = fixture();
  f.snapshot.detachOnRead = 2;
  f.save();
  expect(f.run()).toEqual({
    code: 3,
    receipt: expect.objectContaining({
      status: "stale",
      reasons: expect.arrayContaining(["evidence-invalidated-during-read"]),
    }),
  });
});

test("a failed push leaves a local fix unpublished regardless of a claimed success file", () => {
  const f = fixture();
  f.git("commit", "--allow-empty", "-m", "fix(test): local fix");
  writeFileSync(
    join(f.worktree, "success.json"),
    '{"ready":true,"pushed":true}',
  );
  f.git("add", "success.json");
  f.git("commit", "-m", "docs(test): claimed success");
  // Independent remote rejects every write; the checker must observe actual remote HEAD.
  const remote = f.git("remote", "get-url", "origin");
  writeFileSync(join(remote, "hooks/pre-receive"), "#!/bin/sh\nexit 1\n", {
    mode: 0o755,
  });
  const push = Bun.spawnSync(["git", "push", "origin", "HEAD"], {
    cwd: f.worktree,
  });
  expect(push.exitCode).not.toBe(0);
  expect(f.run()).toEqual({
    code: 3,
    receipt: expect.objectContaining({
      reasons: expect.arrayContaining(["unpublished-or-stale-head"]),
    }),
  });
});

for (const [bucket, code] of [
  ["pending", 1],
  ["fail", 2],
  ["cancel", 2],
  ["skipping", 2],
] as const) {
  test(`${bucket} CI never passes, including gh's nonzero JSON responses`, () => {
    const f = fixture();
    f.snapshot.checks = [{ name: "test", bucket, state: "FIXTURE" }];
    f.snapshot.required = [{ name: "test", bucket, state: "FIXTURE" }];
    f.save();
    expect(f.run()).toEqual({
      code,
      receipt: expect.objectContaining({
        reasons: expect.arrayContaining([`check-${bucket}:test`]),
      }),
    });
  });
}

test("missing required policy is not green even with a passing bot", () => {
  const f = fixture();
  f.snapshot.required = [];
  f.save();
  expect(f.run()).toEqual({
    code: 1,
    receipt: expect.objectContaining({
      reasons: ["required-checks-missing-or-policy-unknown"],
    }),
  });
});

test("handles gh's empty no-required-checks response as missing policy", () => {
  const f = fixture();
  f.snapshot.absentChecks = true;
  f.save();
  expect(f.run()).toEqual({
    code: 1,
    receipt: expect.objectContaining({
      reasons: ["required-checks-missing-or-policy-unknown"],
    }),
  });
});

test("reads later-page outdated feedback and observes its resolution, not bot praise", () => {
  const f = fixture();
  f.snapshot.pages = [
    { nodes: [], pageInfo: { hasNextPage: true, endCursor: "more" } },
    {
      nodes: [{ id: "thread-7", isResolved: false, isOutdated: true }],
      pageInfo: { hasNextPage: false, endCursor: "last" },
    },
  ];
  f.save();
  expect(f.run()).toEqual({
    code: 1,
    receipt: expect.objectContaining({
      reasons: ["unresolved-review-threads"],
    }),
  });
  const laterPage = f.snapshot.pages[1];
  const finding = laterPage?.nodes[0];
  if (!laterPage || !finding) throw new Error("Missing test fixture");
  finding.isResolved = true;
  f.save();
  expect(f.run().code).toBe(0);
  // A new finding arrives after the successful observation; no cached pass survives it.
  laterPage.nodes.push({
    id: "thread-8",
    isResolved: false,
    isOutdated: false,
  });
  f.save();
  expect(f.run().code).toBe(1);
});

for (const field of ["headRefOid", "baseRefOid"]) {
  test(`${field} movement invalidates sampled evidence`, () => {
    const f = fixture();
    f.snapshot.changeOnRead = field;
    f.save();
    expect(f.run()).toEqual({
      code: 3,
      receipt: expect.objectContaining({
        reasons: expect.arrayContaining(["evidence-invalidated-during-read"]),
      }),
    });
  });
}

test("draft and change-request boundaries survive repeated snapshots", () => {
  const f = fixture();
  f.snapshot.pr.isDraft = true;
  f.snapshot.pr.reviewDecision = "CHANGES_REQUESTED";
  f.save();
  expect(f.run()).toEqual({
    code: 2,
    receipt: expect.objectContaining({
      reasons: expect.arrayContaining(["draft-boundary", "changes-requested"]),
    }),
  });
  f.snapshot.pr.isDraft = false;
  f.save();
  expect(f.run().code).toBe(1);
});

test("unavailable identity/service is an explicit blocker, with no fallback account", () => {
  const f = fixture();
  f.snapshot.failGh = true;
  f.save();
  expect(f.run()).toEqual({
    code: 2,
    receipt: expect.objectContaining({
      status: "blocked",
      reasons: ["gh pr unavailable (exit 1)"],
    }),
  });
});

test("incomplete or cyclic pagination cannot produce a green receipt", () => {
  const f = fixture();
  f.snapshot.pages = [
    { nodes: [], pageInfo: { hasNextPage: true, endCursor: "same" } },
    { nodes: [], pageInfo: { hasNextPage: true, endCursor: "same" } },
  ];
  f.save();
  expect(f.run()).toEqual({
    code: 2,
    receipt: expect.objectContaining({
      reasons: ["Incomplete thread pagination"],
    }),
  });
});
