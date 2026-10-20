import { afterEach, expect, setDefaultTimeout, test } from "bun:test";
import {
  mkdtempSync,
  mkdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
  copyFileSync,
  existsSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

// Real git repos and CLI subprocesses: keep a bounded integration deadline under load.
setDefaultTimeout(15_000);

const entry = new URL("./full-send-check.ts", import.meta.url).pathname;
const directories: string[] = [];
afterEach(() => {
  for (const directory of directories.splice(0))
    rmSync(directory, { recursive: true, force: true });
});

function fixture(dependencyReview = false) {
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
  if (dependencyReview) {
    mkdirSync(join(worktree, ".github/workflows"), { recursive: true });
    writeFileSync(
      join(worktree, ".github/workflows/security.yml"),
      "name: Consumer dependencies\non: pull_request\njobs:\n  audit:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/dependency-review-action@v5\n",
    );
    git("add", ".github");
  }
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
    protection: {
      enforce_admins: { enabled: true },
      required_status_checks: { strict: true, contexts: ["test"] },
      required_pull_request_reviews: {
        required_approving_review_count: 1,
        dismiss_stale_reviews: true,
      },
      required_conversation_resolution: { enabled: true },
      allow_force_pushes: { enabled: false },
      allow_deletions: { enabled: false },
    } as Record<string, unknown> | null,
    rules: [] as Record<string, unknown>[],
    rulesets: {} as Record<string, Record<string, unknown>>,
    dependencyGraphUnavailable: false,
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
  console.log(args.includes("--jq") ? d.pr.baseRefOid : JSON.stringify(d.pr));
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
} else if (args[0] === "pr" && args[1] === "list") {
  console.log("42");
} else if (args[0] === "api" && args[1] === "graphql") {
  const cursor = args.find(a => a.startsWith("cursor="));
  const page = cursor ? d.pages[1] : d.pages[0];
  console.log(JSON.stringify({ data: { repository: { pullRequest: { reviewThreads: page } } } }));
} else if (args[0] === "api" && args[1].includes("/rules/branches/")) {
  console.log(JSON.stringify([d.rules]));
} else if (args[0] === "api" && args[1].includes("/rulesets/")) {
  console.log(JSON.stringify(d.rulesets[args[1].split("/").at(-1)]));
} else if (args[0] === "api" && args[1].endsWith("/protection")) {
  if (!d.protection) { console.log(JSON.stringify({ status: "404", message: "Branch not protected" })); process.exit(1); }
  console.log(JSON.stringify(d.protection));
} else if (args[0] === "api" && args[1].includes("/dependency-graph/compare/")) {
  if (d.dependencyGraphUnavailable) { console.log(JSON.stringify({ status: "403", message: "Forbidden" })); process.exit(1); }
  console.log("[]");
} else { process.exit(2); }
`,
    { mode: 0o755 },
  );
  const run = (checker = entry, cwd = worktree) => {
    const result = Bun.spawnSync(
      [
        process.execPath,
        "--no-install",
        checker,
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
        cwd,
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
      receipt: (result.stdout.length
        ? JSON.parse(result.stdout.toString())
        : {
            status: "unavailable",
            reasons: [result.stderr.toString()],
          }) as {
        status: string;
        reasons: string[];
        head?: string;
      },
    };
  };
  const runHook = (endpoint: string) => {
    const sid = `consumer-${root.split("/").at(-1)}`;
    const session = join("/tmp", `hook-session-${sid}`);
    directories.push(session);
    mkdirSync(session, { recursive: true });
    writeFileSync(join(session, "task-endpoint"), endpoint);
    const result = Bun.spawnSync(
      [
        "bash",
        new URL("../.claude/hooks/lifecycle-stop.sh", import.meta.url).pathname,
      ],
      {
        cwd: worktree,
        env: {
          ...Bun.env,
          PATH: `${bin}:${Bun.env.PATH}`,
          DATA: data,
          CALLS: calls,
          CLAUDE_SESSION_ID: sid,
          HOOK_METRICS_DISABLED: "1",
        },
        stdin: Buffer.from(
          JSON.stringify({
            session_id: sid,
            last_assistant_message:
              "Intent: deliver | Impact: tested\n🟢 done — checks pass",
          }),
        ),
      },
    );
    return { code: result.exitCode, error: result.stderr.toString() };
  };
  return { git, run, runHook, snapshot, save, calls, worktree, head };
}

test("startup routes both hosts to automatic setup in the installed harness without hosted writes", () => {
  const f = fixture();
  for (const provider of ["CLAUDE_SESSION_ID", "CODEX_SESSION_ID"]) {
    const sid = `bootstrap-${provider}-${f.head.slice(0, 12)}`;
    directories.push(join("/tmp", `hook-session-${sid}`));
    const result = Bun.spawnSync(
      [
        "bash",
        new URL("../.claude/hooks/session-env.sh", import.meta.url).pathname,
      ],
      {
        cwd: f.worktree,
        env: {
          ...Bun.env,
          PATH: `${join(f.worktree, "../bin")}:${Bun.env.PATH}`,
          DATA: join(f.worktree, "../github.json"),
          CALLS: f.calls,
          CLAUDE_SESSION_ID: "",
          CODEX_SESSION_ID: "",
          CLAUDE_ENV_FILE: join(f.worktree, "../session.env"),
          [provider]: sid,
          HOOK_SESSION_SWEEP_DISABLED: "1",
          HOOK_METRICS_DISABLED: "1",
        },
        stdin: Buffer.from(JSON.stringify({ session_id: sid })),
      },
    );
    expect(result.exitCode).toBe(0);
    const context = JSON.parse(result.stdout.toString()).hookSpecificOutput
      .additionalContext;
    expect(context).toContain("Automatically set up");
    expect(context).toContain(
      new URL("../shared/review-enforcement.md", import.meta.url).pathname,
    );
    expect(context).toContain("read-only/local-only");
    expect(existsSync(f.calls)).toBe(false);
  }
});

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
        (args[0] === "api" &&
          !args.includes("--method") &&
          !args.includes("-X")),
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

test("a green consuming PR cannot be ready without hosted review protections", () => {
  const f = fixture();
  f.snapshot.protection = null;
  f.save();
  expect(f.run()).toEqual({
    code: 2,
    receipt: expect.objectContaining({
      status: "blocked",
      reasons: expect.arrayContaining([
        "review-policy:required-checks-missing",
      ]),
    }),
  });
});

test("a declared required check absent from the observed checks cannot silently pass", () => {
  const f = fixture();
  if (!f.snapshot.protection) throw new Error("Missing fixture protection");
  f.snapshot.protection.required_status_checks = {
    strict: true,
    contexts: ["test", "consumer-build"],
  };
  f.save();
  expect(f.run()).toEqual({
    code: 1,
    receipt: expect.objectContaining({
      reasons: ["required-check-not-observed:consumer-build"],
    }),
  });
});

test("the shipped Stop hook rejects a green but unprotected consuming repo", () => {
  const f = fixture();
  f.snapshot.protection = null;
  f.save();
  const result = f.runHook("ship");
  expect(result.code).toBe(2);
  expect(result.error).toContain("review-policy:required-checks-missing");
  expect(result.error).toContain("automatic setup");
});

test("the shipped Stop hook allows protected consumers and preserves the PR-only endpoint", () => {
  const f = fixture();
  expect(f.runHook("ship").code).toBe(0);
  f.snapshot.protection = null;
  f.snapshot.checks = [{ name: "test", bucket: "pending", state: "PENDING" }];
  f.save();
  expect(f.runHook("ship").code).toBe(2);
  expect(f.runHook("pr").code).toBe(0);
});

test("zero required approvals does not invent an independent reviewer", () => {
  const f = fixture();
  if (!f.snapshot.protection) throw new Error("Missing fixture protection");
  f.snapshot.protection.required_pull_request_reviews = {
    required_approving_review_count: 0,
    dismiss_stale_reviews: false,
  };
  f.snapshot.pr.reviewDecision = "";
  f.save();
  expect(f.run().code).toBe(0);
  f.snapshot.protection.required_pull_request_reviews = {
    required_approving_review_count: 2,
    dismiss_stale_reviews: true,
  };
  f.save();
  expect(f.run()).toEqual({
    code: 1,
    receipt: expect.objectContaining({
      reasons: ["reviews-pending-or-policy-unknown"],
    }),
  });
});

for (const [field, value, reason] of [
  ["enforce_admins", { enabled: false }, "required-checks-missing"],
  [
    "required_status_checks",
    { strict: false, contexts: ["consumer-build"] },
    "strict-base-or-queue-missing",
  ],
  [
    "required_conversation_resolution",
    { enabled: false },
    "thread-resolution-not-enforced",
  ],
  [
    "required_pull_request_reviews",
    { required_approving_review_count: 2, dismiss_stale_reviews: false },
    "stale-approvals-not-dismissed",
  ],
  ["allow_force_pushes", { enabled: true }, "force-pushes-not-blocked"],
  ["allow_deletions", { enabled: true }, "branch-deletion-not-blocked"],
] as const) {
  test(`consumer policy blocks ${reason} without rewriting it`, () => {
    const f = fixture();
    if (!f.snapshot.protection) throw new Error("Missing fixture protection");
    f.snapshot.protection[field] = value;
    f.save();
    expect(f.run()).toEqual({
      code: 2,
      receipt: expect.objectContaining({
        reasons: expect.arrayContaining([`review-policy:${reason}`]),
      }),
    });
  });
}

test("native rulesets and merge queues satisfy the same consumer contract without classic protection", () => {
  const f = fixture();
  f.snapshot.protection = null;
  f.snapshot.rules = [
    {
      type: "required_status_checks",
      ruleset_id: 9,
      parameters: {
        strict_required_status_checks_policy: false,
        required_status_checks: [{ context: "test" }],
      },
    },
    {
      type: "pull_request",
      ruleset_id: 9,
      parameters: {
        required_approving_review_count: 1,
        dismiss_stale_reviews_on_push: true,
        required_review_thread_resolution: true,
      },
    },
    ...["merge_queue", "non_fast_forward", "deletion"].map((type) => ({
      type,
      ruleset_id: 9,
    })),
  ];
  f.snapshot.rulesets["9"] = { enforcement: "active", bypass_actors: [] };
  f.snapshot.pr.baseRefName = "release/stable";
  f.save();
  expect(f.run().code).toBe(0);
  const calls = readFileSync(f.calls, "utf8");
  expect(calls).toContain("rules/branches/release%2Fstable");
  f.snapshot.rulesets["9"] = {
    enforcement: "active",
    bypass_actors: [
      { actor_type: "RepositoryRole", actor_id: 5, bypass_mode: "always" },
    ],
  };
  f.save();
  expect(f.run().code).toBe(2);
  f.snapshot.rulesets["9"] = { enforcement: "active" };
  f.save();
  expect(f.run().code).toBe(2);
});

test("a consuming dependency-review workflow requires a working dependency-graph comparison", () => {
  const f = fixture(true);
  f.snapshot.dependencyGraphUnavailable = true;
  f.save();
  expect(f.run()).toEqual({
    code: 2,
    receipt: expect.objectContaining({
      reasons: [
        `Review policy unavailable: repos/example/project/dependency-graph/compare/${f.head}...${f.head}`,
      ],
    }),
  });
  f.snapshot.dependencyGraphUnavailable = false;
  f.save();
  expect(f.run().code).toBe(0);
});

test("an installed verifier runs without this repository's node_modules or automatic package installation", () => {
  const f = fixture();
  const plugin = join(f.worktree, "..", "installed-plugin");
  mkdirSync(plugin);
  for (const file of [
    "full-send-check.ts",
    "review-policy.ts",
    "github-evidence.ts",
  ]) {
    copyFileSync(new URL(`./${file}`, import.meta.url), join(plugin, file));
  }
  expect(f.run(join(plugin, "full-send-check.ts"))).toEqual({
    code: 0,
    receipt: expect.objectContaining({ status: "hosted-gates-pass" }),
  });
});

test("consumer security prerequisites are checked from worktree subdirectories", () => {
  const f = fixture(true);
  const nested = join(f.worktree, "packages");
  mkdirSync(nested);
  f.snapshot.dependencyGraphUnavailable = true;
  f.save();
  expect(f.run(entry, nested).code).toBe(2);
});
