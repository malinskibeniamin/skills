import { afterEach, expect, test, setDefaultTimeout } from "bun:test";
import {
  mkdtempSync,
  mkdirSync,
  writeFileSync,
  readFileSync,
  rmSync,
  existsSync,
  realpathSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

setDefaultTimeout(20_000);
const entry = new URL("./pr-review-auto.ts", import.meta.url).pathname;
const dirs: string[] = [];
afterEach(() => {
  for (const dir of dirs.splice(0))
    rmSync(dir, { recursive: true, force: true });
});

function fixture() {
  const root = mkdtempSync(join(tmpdir(), "review-policy-"));
  dirs.push(root);
  const bin = join(root, "bin");
  mkdirSync(bin);
  const git = (...args: string[]) => {
    const result = Bun.spawnSync(["git", ...args], { cwd: root });
    expect(result.exitCode).toBe(0);
    return result.stdout.toString().trim();
  };
  git("init", "-b", "feature");
  git("config", "user.name", "Test");
  git("config", "user.email", "test@example.com");
  writeFileSync(join(root, "README.md"), "base\n");
  git("add", "README.md");
  git("commit", "-m", "feat(test): base");
  const base = git("rev-parse", "HEAD");
  mkdirSync(join(root, "ui"));
  writeFileSync(join(root, "ui/screen.tsx"), "export const screen = 'new';\n");
  git("add", "ui");
  git("commit", "-m", "feat(test): screen");
  git("remote", "add", "origin", "git@github.com:example/project.git");
  const dispositions: {
    id: string;
    status: "fixed" | "refuted";
    reason: string;
    evidence: string;
  }[] = [];
  const data = {
    pr: {
      number: 42,
      state: "open",
      draft: false,
      changed_files: 1,
      user: { login: "alice", id: 123 },
      head: {
        sha: git("rev-parse", "HEAD"),
        ref: "feature",
        repo: { full_name: "example/project" },
      },
      base: { sha: base, ref: "main", repo: { full_name: "example/project" } },
    },
    files: [{ filename: "ui/screen.tsx" }],
    checks: [
      {
        name: "types",
        bucket: "pass",
        link: "https://github.com/example/project/actions/runs/1",
      },
    ],
    result: {
      schema_version: 2,
      reviewer: "automatic-review",
      dispositions,
      challenges: [
        {
          hypothesis: "The screen export does not match the requested value.",
          scenario: "A caller imports screen from the changed UI module.",
          method: "source-trace",
          check: "Read ui/screen.tsx:1 in the pinned fixture snapshot.",
          expected: "The module exports screen with the new value.",
          observation: "The fixture module exports screen = 'new'.",
          outcome: "refuted",
          finding_ids: [],
          execution_limits:
            "The fixture checks orchestration, not a running frontend.",
        },
      ],
      status: "APPROVED",
      findings: [] as Record<string, unknown>[],
      testing_gaps: [],
      simplification_opportunities: [],
      sufficiency:
        "Inspected the full diff, callers, states and available checks.",
    },
    coverage: [] as Record<string, unknown>[],
    posted: [] as {
      id: number;
      body: string;
      state: string;
      commit_id: string;
    }[],
    specialistUnresolved: false,
    guardStartupRoot: false,
    failedCliEnvelope: false,
    spoofRecovery: false,
    failCiRead: false,
    fencedResult: false,
    laterCheckFailure: false,
    disableDuringReview: false,
    overlapDuringReview: false,
    moveDuringReview: false,
    failPublish: false,
    failWorker: false,
    failDiscovery: false,
    spoofAuthor: false,
    secondPr: false,
  };
  const store = join(root, "github.json");
  writeFileSync(store, JSON.stringify(data));
  const save = () =>
    writeFileSync(
      store,
      JSON.stringify({
        ...data,
        posted: JSON.parse(readFileSync(store, "utf8")).posted,
      }),
    );
  const calls = join(root, "calls.jsonl");
  const fake = `#!${process.execPath}
import { appendFileSync, readFileSync, writeFileSync, existsSync } from 'node:fs';
import { basename } from 'node:path';
const tool = basename(process.argv[1]);
const args = process.argv.slice(2);
const input = tool === 'gh' ? '' : readFileSync(0, 'utf8');
appendFileSync(process.env.CALLS, JSON.stringify({tool,args,input,cwd:process.cwd()})+'\\n');
const data = JSON.parse(readFileSync(process.env.DATA,'utf8'));
if(tool==='codex' && args[0]==='exec' && args[1]==='resume') process.exit(0);
if(tool!=='gh'&&data.guardStartupRoot){const project=Bun.spawnSync(['git','rev-parse','--show-toplevel']).stdout.toString().trim();if(!project||existsSync(project+'/.claude/settings.json')||existsSync(project+'/.mcp.json')){console.error('Candidate startup configuration would be loaded');process.exit(91);}}
if (tool !== 'gh') {
  if (data.failWorker) process.exit(1);
  const catalogue = JSON.parse(readFileSync(process.env.CATALOGUE,'utf8'));
  const role = input.match(/Dispatched reviewer identity: ([a-z-]+)/)?.[1] ?? 'automatic-review';
  const assigned = input.match(/Assigned gate ids: ([a-z,-]+)/)?.[1]?.split(',');
  const coverage = data.coverage.length ? data.coverage : catalogue.gates.filter(g=>!assigned||assigned.includes(g.id)).map(g => ({gate:g.id,status:g.always||data.files.some(f=>g.globs.some(glob=>new Bun.Glob(glob).match(f.filename)))?'reviewed':'not-applicable',reason:'Inspected this responsibility against the complete change.'}));
  if (data.disableDuringReview) Bun.spawnSync([process.env.BUN,process.env.ENTRY,'policy','disable','--id','ui-alice'],{env:process.env});
  if (data.overlapDuringReview) {
    const file=process.env.DATA+'.policy.json';
    writeFileSync(file,JSON.stringify({...JSON.parse(readFileSync(process.env.POLICY,'utf8')),id:'ui-overlap'}));
    const changed=Bun.spawnSync([process.env.BUN,process.env.ENTRY,'policy','set','--file',file],{env:{...process.env,PR_REVIEW_AUTO_RUN:'0'}});
    if(changed.exitCode!==0){console.error(changed.stderr.toString());process.exit(92);}
  }
  if (data.moveDuringReview) data.pr.head.sha = 'a'.repeat(40);
  writeFileSync(process.env.DATA,JSON.stringify(data));
  const report = {...data.result,reviewer:role,coverage};
  if(data.specialistUnresolved&&role!=='automatic-review'){report.status='NEEDS_CHANGES';report.challenges=[{...data.result.challenges[0],hypothesis:'Specialist cannot establish the changed contract.',outcome:'unresolved',finding_ids:[]}];}
  const result = JSON.stringify(report);
  if(tool==='claude'){const model=args[args.indexOf('--model')+1];console.log(JSON.stringify({type:'result',subtype:data.failedCliEnvelope?'error_during_execution':'success',is_error:data.failedCliEnvelope,result,modelUsage:{[model]:{}}}));process.exit(0);}
  const output = args[args.indexOf('--output-last-message')+1];
  writeFileSync(output,data.fencedResult?String.fromCharCode(96).repeat(3)+'json\\n'+result+'\\n'+String.fromCharCode(96).repeat(3):result);
  console.log(JSON.stringify({type:'thread.started',thread_id:'review-fixture'}));
  process.exit(0);
}
if(args[0]==='repo'){console.log(JSON.stringify({nameWithOwner:'example/project',defaultBranchRef:{name:'main'}}));process.exit(0);}
if(args[0]==='pr'&&args[1]==='view'){console.log(JSON.stringify({number:data.pr.number,url:'https://github.com/example/project/pull/42',state:'OPEN',headRefName:data.pr.head.ref,baseRefName:data.pr.base.ref,headRefOid:data.pr.head.sha,baseRefOid:data.pr.base.sha,isCrossRepository:false}));process.exit(0);}
if(args[0]==='pr' && args[1]==='checks') { console.log(JSON.stringify(data.checks)); process.exit(data.checks.some(c=>c.bucket==='fail')?1:0); }
if(args[0]==='api') {
 const endpoint=args[1];
 if(endpoint.includes('/compare/')){const [base,head]=endpoint.split('/compare/')[1].split('?')[0].split('...');const r=Bun.spawnSync(['git','rev-list','--count',head+'..'+base]);console.log(JSON.stringify({behind_by:Number(r.stdout.toString().trim())}));process.exit(0);}
 if(endpoint.endsWith('/comments')){console.log('[[]]');process.exit(0);}
 if(endpoint.includes('/check-runs')) {
   if(data.failCiRead)process.exit(1);
   const checks=data.checks.map((c,i)=>({id:i+1,name:c.name,head_sha:data.pr.head.sha,completed_at:'2026-11-05T00:00:00Z',status:c.bucket==='pending'?'in_progress':'completed',conclusion:c.bucket==='pass'?'success':c.bucket==='skipping'?'skipped':c.bucket==='pending'?null:'failure',details_url:c.link}));
   const later=data.laterCheckFailure?[{id:999,name:'security',head_sha:data.pr.head.sha,status:'completed',conclusion:'failure',details_url:''}]:[];
   console.log(JSON.stringify([{total_count:checks.length+later.length,check_runs:checks},...(later.length?[{total_count:checks.length+later.length,check_runs:later}]:[])]));process.exit(0);
 }
 if(endpoint.includes('/statuses')){console.log('[[]]');process.exit(0);}
 if(endpoint==='users/alice') { console.log(JSON.stringify({login:'alice',id:123})); process.exit(0); }
 if(endpoint==='user') { console.log(args.includes('--jq')?'review-bot':JSON.stringify({login:'review-bot',id:999})); process.exit(0); }
 if(endpoint.split('?')[0].endsWith('/reviews')) {
   if(args.includes('POST')) {
     const fields = Object.fromEntries(args.filter((v,i)=>args[i-1]==='-f').map(v=>{const i=v.indexOf('=');return [v.slice(0,i),v.slice(i+1)];}));
     const result={id:data.posted.length+1,body:fields.body,state:fields.event,commit_id:fields.commit_id,user:{login:'review-bot',id:999}};
     data.posted.push(result);writeFileSync(process.env.DATA,JSON.stringify(data));
     if(data.failPublish) process.exit(1);
     console.log(JSON.stringify(result));
   } else console.log(JSON.stringify([data.posted.map(review=>({...review,user:{login:'review-bot',id:data.spoofRecovery?1337:999},author_association:'MEMBER'}))]));
 } else if(endpoint.includes('/files')) console.log(JSON.stringify([data.files]));
 else if(endpoint.includes('/pulls?')) {if(data.failDiscovery)process.exit(1);console.log(JSON.stringify([[data.pr,...(data.secondPr?[{...data.pr,number:43}]:[])]]));}
 else if(endpoint.endsWith('/pulls/42')||endpoint.endsWith('/pulls/43')) console.log(JSON.stringify({...data.pr,number:Number(endpoint.split('/').at(-1))}));
 else process.exit(2);
} else process.exit(2);
`;
  for (const tool of ["gh", "codex", "claude"])
    writeFileSync(join(bin, tool), fake, { mode: 0o755 });
  writeFileSync(
    join(root, ".git/info/exclude"),
    "bin/\nstate/\ngithub.json\ncalls.jsonl\npolicy.json\nworker-preload.ts\n",
  );
  const home = join(root, "state");
  const config = join(root, "policy.json");
  const policy = {
    version: 1,
    id: "ui-alice",
    repo: "example/project",
    author: "alice",
    worktree: root,
    paths: ["ui/**"],
    publish: ["P0", "P1"],
    autoApprove: true,
    model: "gpt-6.1-sol",
    effort: "xhigh",
    enabled: true,
  };
  // Even a broken preload cannot reach a real authenticated model.
  const blockedAuth = join(home, "blocked-test-auth");
  mkdirSync(blockedAuth, { recursive: true });
  writeFileSync(
    join(blockedAuth, "config.toml"),
    "intentionally invalid test configuration",
  );
  const env = {
    ...Bun.env,
    PR_REVIEW_CODEX_HOME: blockedAuth,
    PATH: `${bin}:${Bun.env.PATH}`,
    PR_REVIEW_AUTO_HOME: home,
    CALLS: calls,
    DATA: store,
    BUN: process.execPath,
    ENTRY: entry,
    CATALOGUE: new URL("../config/review-gates.json", import.meta.url).pathname,
    POLICY: config,
  };
  // Mock the provider module at the process boundary, never the real absolute Codex binary.
  const preload = join(root, "worker-preload.ts");
  writeFileSync(
    preload,
    `
import { mock } from "bun:test";
import { dirname } from "node:path";
mock.module(${JSON.stringify(new URL("./pr-review-worker.ts", import.meta.url).pathname)}, () => ({
  runIsolatedReview(input) {
    if (!input.model.startsWith("gpt-")) throw new Error("Unsupported isolated review provider");
    if (!input.guidanceRoots.length || !input.publisherRoots.length) throw new Error("Missing isolated scope");
    const run = Bun.spawnSync([${JSON.stringify(join(bin, "codex"))}, "exec", "--model", input.model, "--output-last-message", input.output, "-"], {
      cwd: dirname(input.output), stdin: Buffer.from(input.prompt), env: process.env,
    });
    return { stdout: run.stdout.toString(), stderr: run.stderr.toString(), exitCode: run.exitCode,
      isolation: { version: "codex-seatbelt-review-v1", codexVersion: "mock", permissionProfile: "fixture", networkPolicy: "disabled", ambientMcpServers: 0 } };
  }
}));
`,
  );
  const run = (...args: string[]) => {
    const r = Bun.spawnSync(
      [process.execPath, "--preload", preload, entry, ...args],
      {
        cwd: root,
        env,
      },
    );
    return {
      code: r.exitCode,
      out: r.stdout.toString(),
      err: r.stderr.toString(),
    };
  };
  const set = () => {
    writeFileSync(config, JSON.stringify(policy));
    return run("policy", "set", "--file", config);
  };
  const posted = () => JSON.parse(readFileSync(store, "utf8")).posted;
  const recorded = () =>
    existsSync(calls)
      ? readFileSync(calls, "utf8")
          .trim()
          .split("\n")
          .map((l) => JSON.parse(l))
      : [];
  return { root, home, data, save, policy, set, run, posted, recorded, git };
}

test("policy set stores an inspectable, resolved author scope without starting reviews", () => {
  const f = fixture();
  expect(f.set().code).toBe(0);
  const result = f.run("policy", "list");
  expect(result.code).toBe(0);
  const state = JSON.parse(result.out);
  expect(state.policies[0]).toMatchObject({
    id: "ui-alice",
    authorId: 123,
    repo: "example/project",
    paths: ["ui/**"],
    publish: ["P0", "P1"],
  });
  expect(f.recorded().some((c) => c.tool === "codex")).toBe(false);
  expect(f.posted()).toEqual([]);
});

test("five-minute sweeps review an eligible PR once and re-review every new candidate", () => {
  const f = fixture();
  expect(f.set().code).toBe(0);
  expect(f.run("configure", "--reviewer", "reviewer[bot]").code).toBe(0);
  expect(f.run("tick", "--dry-run").out).toContain(
    "Would review example/project#42",
  );
  expect(f.posted()).toHaveLength(0);
  const first = f.run("tick");
  expect(first.err).toBe("");
  expect(first.code).toBe(0);
  expect(f.posted()).toHaveLength(1);
  expect(f.posted()[0]).toMatchObject({
    state: "APPROVE",
    commit_id: f.data.pr.head.sha,
  });
  expect(f.run("tick").code).toBe(0);
  expect(
    f
      .recorded()
      .filter(
        (c) =>
          c.tool === "codex" &&
          c.input.includes("Dispatched reviewer identity: automatic-review"),
      ),
  ).toHaveLength(1);
  expect(f.posted()).toHaveLength(1);
  writeFileSync(
    join(f.root, "ui/screen.tsx"),
    "export const screen = 'updated';\n",
  );
  f.git("add", "ui");
  f.git("commit", "-m", "fix(test): repair");
  f.data.pr.head.sha = f.git("rev-parse", "HEAD");
  f.save();
  expect(f.run("tick").code).toBe(0);
  expect(f.posted()).toHaveLength(2);
  expect(f.posted()[1].commit_id).toBe(f.data.pr.head.sha);
  const workers = f
    .recorded()
    .filter(
      (c) =>
        c.tool === "codex" &&
        c.input.includes("Dispatched reviewer identity: automatic-review"),
    );
  expect(workers).toHaveLength(2);
  expect(workers[1].input).toContain("Prior review");
  expect(workers[1].cwd).not.toBe(f.root);
  expect(workers[0].args).toContain("--output-last-message");
  const state = JSON.parse(f.run("policy", "list").out);
  expect(state.runs).toHaveLength(2);
  expect(state.runs[1]).toMatchObject({
    status: "published",
    requestedModel: "gpt-6.1-sol",
    actualModel: null,
    nextCheckSeconds: 300,
  });
});

test("PRs sharing the same head and base each receive one review and publication", () => {
  const f = fixture();
  f.data.secondPr = true;
  f.save();
  expect(f.set().code).toBe(0);
  expect(f.run("configure", "--reviewer", "reviewer[bot]").code).toBe(0);
  const tick = f.run("tick");
  expect(tick.err).toBe("");
  expect(tick.code).toBe(0);
  expect(f.run("tick").code).toBe(0);
  const runs = JSON.parse(f.run("policy", "list").out).runs;
  expect(runs.map((run: { pr: number }) => run.pr).sort()).toEqual([42, 43]);
  expect(new Set(runs.map((run: { key: string }) => run.key)).size).toBe(2);
  for (const number of [42, 43]) {
    expect(
      f
        .recorded()
        .filter((call) =>
          call.input.includes(
            `Review https://github.com/example/project/pull/${number},`,
          ),
        ),
    ).toHaveLength(1);
    expect(
      f
        .recorded()
        .filter(
          (call) =>
            call.tool === "gh" &&
            call.args[1] === `repos/example/project/pulls/${number}/reviews` &&
            call.args.includes("POST"),
        ),
    ).toHaveLength(1);
  }
  expect(f.posted()).toHaveLength(2);
});

test("a clean candidate gains approval when pending CI passes without another paid review", () => {
  const f = fixture();
  f.data.checks[0] = {
    name: "types",
    bucket: "pending",
    link: "https://github.com/example/project/actions/runs/1",
  };
  f.save();
  expect(f.set().code).toBe(0);
  expect(f.run("configure", "--reviewer", "reviewer[bot]").code).toBe(0);
  expect(f.run("tick").code).toBe(0);
  expect(f.posted()[0].state).toBe("COMMENT");
  const initialWorkers = f.recorded().filter((c) => c.tool === "codex").length;
  f.data.checks[0] = {
    name: "types",
    bucket: "pass",
    link: "https://github.com/example/project/actions/runs/1",
  };
  f.save();
  expect(f.run("tick").code).toBe(0);
  expect(f.posted().map((review: { state: string }) => review.state)).toEqual([
    "COMMENT",
    "APPROVE",
  ]);
  expect(f.recorded().filter((c) => c.tool === "codex").length).toBe(
    initialWorkers,
  );
  expect(f.run("tick").code).toBe(0);
  expect(f.posted()).toHaveLength(2);
});

test.each([
  { bucket: "skipping", checks: true },
  { bucket: "pass", checks: false },
])(
  "CI without an observed passing check cannot auto-approve ($bucket, $checks)",
  ({ bucket, checks }) => {
    const f = fixture();
    f.data.checks = checks
      ? [
          {
            name: "types",
            bucket,
            link: "https://github.com/example/project/actions/runs/1",
          },
        ]
      : [];
    f.save();
    expect(f.set().code).toBe(0);
    f.run("configure", "--reviewer", "reviewer[bot]");
    expect(f.run("tick").code).toBe(0);
    expect(f.posted()[0].state).toBe("COMMENT");
  },
);

test.each([
  "empty coverage",
  "missing required gate",
  "policy",
  "repo",
  "pr",
  "head",
  "base",
  "requestedModel",
  "effort",
] as const)(
  "cached receipts reject %s before pending CI can unlock approval",
  (fault) => {
    const f = fixture();
    f.data.checks = f.data.checks.map((check) => ({
      ...check,
      bucket: "pending",
    }));
    f.save();
    expect(f.set().code).toBe(0);
    expect(f.run("configure", "--reviewer", "reviewer[bot]").code).toBe(0);
    expect(f.run("tick").code).toBe(0);
    expect(f.posted().map((review: { state: string }) => review.state)).toEqual(
      ["COMMENT"],
    );
    const paid = f.recorded().filter((call) => call.tool === "codex").length;
    const file = join(f.home, "policies.json");
    const state = JSON.parse(readFileSync(file, "utf8"));
    const receipt = state.runs[0];
    if (fault === "empty coverage") receipt.coverage = [];
    else if (fault === "missing required gate") {
      expect(
        receipt.coverage.some(
          (item: { gate: string }) => item.gate === "correctness",
        ),
      ).toBe(true);
      receipt.coverage = receipt.coverage.filter(
        (item: { gate: string }) => item.gate !== "correctness",
      );
    } else
      receipt[fault] = {
        policy: "another-policy",
        repo: "other/project",
        pr: 43,
        head: "a".repeat(40),
        base: "b".repeat(40),
        requestedModel: "claude-opus-5-5",
        effort: "high",
      }[fault];
    writeFileSync(file, JSON.stringify(state));
    f.data.checks = f.data.checks.map((check) => ({
      ...check,
      bucket: "pass",
    }));
    f.save();
    const tick = f.run("tick");
    expect(tick.code).toBe(1);
    expect(tick.err).toContain("Cached review receipt");
    expect(f.posted().map((review: { state: string }) => review.state)).toEqual(
      ["COMMENT"],
    );
    const rejected = JSON.parse(f.run("policy", "list").out).runs[0];
    expect(rejected.status).toBe("failed");
    expect(rejected.reason).toContain("Cached review receipt");
    expect(f.run("tick").code).toBe(0);
    expect(f.recorded().filter((call) => call.tool === "codex").length).toBe(
      paid,
    );
    expect(f.posted()).toHaveLength(1);
  },
);

const defect = {
  id: "missing-null",
  title: "Missing value crashes screen",
  severity: "P2",
  file: "ui/screen.tsx",
  line: 1,
  category: "correctness",
  why_it_matters: "The screen crashes for an empty response.",
  scenario: "The API returns null.",
  evidence: "The caller dereferences the missing value.",
  verification: "Render a null response without crashing.",
  autofix_class: "manual",
  suggested_fix: null,
  pre_existing: false,
  confidence: 0.9,
};

test.each(["P0", "P1", "P2", "P3"])(
  "publication filtering never turns an unresolved %s into approval",
  (severity) => {
    const f = fixture();
    f.data.result = {
      ...f.data.result,
      status:
        severity === "P0" || severity === "P1" ? "NEEDS_CHANGES" : "CONCERNS",
      findings: [{ ...defect, severity }],
    };
    f.save();
    expect(f.set().code).toBe(0);
    f.run("configure", "--reviewer", "reviewer[bot]");
    expect(f.run("tick").code).toBe(0);
    expect(f.posted()[0].state).toBe("COMMENT");
    expect(f.posted()[0].body.includes("Missing value crashes screen")).toBe(
      severity === "P0" || severity === "P1",
    );
    expect(
      JSON.parse(f.run("policy", "list").out).runs[0].result.findings[0]
        .severity,
    ).toBe(severity);
  },
);

test.each([
  "disableDuringReview",
  "moveDuringReview",
  "overlapDuringReview",
] as const)("%s prevents stale or revoked publication", (fault) => {
  const f = fixture();
  f.data[fault] = true;
  f.save();
  expect(f.set().code).toBe(0);
  f.run("configure", "--reviewer", "reviewer[bot]");
  expect(f.run("tick").code).toBe(0);
  expect(f.posted()).toEqual([]);
  expect(JSON.parse(f.run("policy", "list").out).runs[0].status).toBe(
    fault === "moveDuringReview" ? "stale" : "revoked",
  );
});

test("uncertain publication reconciles its marker instead of duplicating the review", () => {
  const f = fixture();
  f.data.failPublish = true;
  f.save();
  expect(f.set().code).toBe(0);
  f.run("configure", "--reviewer", "reviewer[bot]");
  expect(f.run("tick").code).toBe(1);
  expect(f.posted()).toHaveLength(1);
  expect(JSON.parse(f.run("policy", "list").out).runs[0].status).toBe(
    "publication-unknown",
  );
  const file = join(f.home, "policies.json");
  const original = readFileSync(file, "utf8");
  const tampered = JSON.parse(original);
  tampered.runs[0].coverage = [];
  writeFileSync(file, JSON.stringify(tampered));
  expect(f.run("tick").code).toBe(1);
  expect(JSON.parse(f.run("policy", "list").out).runs[0]).toMatchObject({
    status: "publication-unknown",
    reason: expect.stringContaining("Cached review receipt"),
  });
  expect(f.run("policy", "retry", "--id", "ui-alice").code).toBe(1);
  expect(f.posted()).toHaveLength(1);
  writeFileSync(file, original);
  expect(f.run("tick").code).toBe(0);
  expect(f.posted()).toHaveLength(1);
  expect(
    f
      .recorded()
      .filter(
        (c) =>
          c.tool === "codex" &&
          c.input.includes("Dispatched reviewer identity: automatic-review"),
      ),
  ).toHaveLength(1);
  expect(JSON.parse(f.run("policy", "list").out).runs[0].status).toBe(
    "published",
  );
});

test.each(["author", "path", "draft", "fork"])(
  "noneligible %s changes never launch reviewers",
  (fault) => {
    const f = fixture();
    if (fault === "author") f.data.pr.user.id = 456;
    if (fault === "path") f.data.files = [{ filename: "backend/main.go" }];
    if (fault === "draft") f.data.pr.draft = true;
    if (fault === "fork") f.data.pr.head.repo.full_name = "other/fork";
    f.save();
    expect(f.set().code).toBe(0);
    f.run("configure", "--reviewer", "reviewer[bot]");
    expect(f.run("tick").code).toBe(0);
    expect(f.posted()).toEqual([]);
    expect(f.recorded().some((c) => c.tool === "codex")).toBe(false);
  },
);

test("missing coverage and failed workers remain incomplete without paid retry loops", () => {
  for (const fault of ["coverage", "worker"]) {
    const f = fixture();
    if (fault === "coverage")
      f.data.coverage = [
        {
          gate: "correctness",
          status: "reviewed",
          reason: "Only one lane inspected",
        },
      ];
    else f.data.failWorker = true;
    f.save();
    expect(f.set().code).toBe(0);
    f.run("configure", "--reviewer", "reviewer[bot]");
    expect(f.run("tick").code).toBe(1);
    expect(f.posted()).toEqual([]);
    expect(f.run("tick").code).toBe(0);
    expect(
      f
        .recorded()
        .filter(
          (c) =>
            c.tool === "codex" &&
            c.input.includes("Dispatched reviewer identity: automatic-review"),
        ),
    ).toHaveLength(1);
    expect(JSON.parse(f.run("policy", "list").out).runs[0].status).toBe(
      "failed",
    );
  }
});

test("mixed-area changes automatically run applicable specialist workers without becoming repair owners", () => {
  const f = fixture();
  mkdirSync(join(f.root, ".github/workflows"), { recursive: true });
  writeFileSync(
    join(f.root, ".github/workflows/ci.yml"),
    "name: ci\non: push\njobs: {}\n",
  );
  f.git("add", ".github");
  f.git("commit", "-m", "ci(test): workflow");
  f.data.pr.head.sha = f.git("rev-parse", "HEAD");
  f.data.pr.changed_files = 2;
  f.data.files.push({ filename: ".github/workflows/ci.yml" });
  f.save();
  expect(f.set().code).toBe(0);
  f.run("configure", "--reviewer", "reviewer[bot]");
  expect(f.run("tick").code).toBe(0);
  const state = JSON.parse(f.run("policy", "list").out);
  expect(
    state.runs[0].workers.map((worker: { role: string }) => worker.role),
  ).toContain("adversarial-reviewer");
  expect(
    state.runs[0].workers.map((worker: { role: string }) => worker.role),
  ).toContain("interface-reviewer");
  expect(f.recorded().filter((c) => c.tool === "codex").length).toBeGreaterThan(
    1,
  );
  expect(JSON.parse(f.run("status").out).bindings).toEqual([]);
  expect(f.git("branch", "--show-current")).toBe("feature");
});

test("later-page CI failures prevent approval even when the first page passes", () => {
  const f = fixture();
  f.data.laterCheckFailure = true;
  f.save();
  expect(f.set().code).toBe(0);
  f.run("configure", "--reviewer", "reviewer[bot]");
  expect(f.run("tick").code).toBe(0);
  expect(f.posted()[0].state).toBe("COMMENT");
});

test("a concerns verdict without finding details cannot become an approval during synthesis", () => {
  const f = fixture();
  f.data.result.status = "CONCERNS";
  f.save();
  expect(f.set().code).toBe(0);
  f.run("configure", "--reviewer", "reviewer[bot]");
  expect(f.run("tick").code).toBe(0);
  expect(f.posted()[0].state).toBe("COMMENT");
});

test("unchanged unresolved findings stay in the ledger without duplicate comments on new revisions", () => {
  const f = fixture();
  f.data.result = {
    ...f.data.result,
    status: "NEEDS_CHANGES",
    findings: [{ ...defect, severity: "P1" }],
  };
  f.save();
  expect(f.set().code).toBe(0);
  f.run("configure", "--reviewer", "reviewer[bot]");
  expect(f.run("tick").code).toBe(0);
  expect(f.posted()[0].body).toContain(defect.title);
  writeFileSync(
    join(f.root, "ui/screen.tsx"),
    "export const screen = 'another revision';\n",
  );
  f.git("add", "ui");
  f.git("commit", "-m", "fix(test): another revision");
  f.data.pr.head.sha = f.git("rev-parse", "HEAD");
  f.save();
  expect(f.run("tick").code).toBe(0);
  expect(f.posted()).toHaveLength(2);
  expect(f.posted()[1].body).not.toContain(defect.title);
  expect(
    JSON.parse(f.run("policy", "list").out).runs[1].result.findings,
  ).toHaveLength(1);
});

test("explanation and dry-run expose eligibility without modifying policy state or launching workers", () => {
  const f = fixture();
  expect(f.set().code).toBe(0);
  f.run("configure", "--reviewer", "reviewer[bot]");
  const before = readFileSync(join(f.home, "policies.json"), "utf8");
  const explained = f.run(
    "policy",
    "explain",
    "--id",
    "ui-alice",
    "--pr",
    "42",
  );
  expect(explained.code).toBe(0);
  expect(JSON.parse(explained.out)).toMatchObject({
    eligible: true,
    pollSeconds: 300,
    model: "gpt-6.1-sol",
  });
  expect(f.run("tick", "--dry-run").code).toBe(0);
  expect(readFileSync(join(f.home, "policies.json"), "utf8")).toBe(before);
  expect(f.recorded().some((c) => c.tool === "codex")).toBe(false);
  expect(f.posted()).toEqual([]);
});

test("the documented fenced JSON report is accepted and the retained diff remains an applicable patch", () => {
  const f = fixture();
  f.data.fencedResult = true;
  f.save();
  expect(f.set().code).toBe(0);
  f.run("configure", "--reviewer", "reviewer[bot]");
  const tick = f.run("tick");
  expect(tick.err).toBe("");
  expect(tick.code).toBe(0);
  expect(f.posted()).toHaveLength(1);
  const receipt = JSON.parse(f.run("policy", "list").out).runs[0];
  const patch = Bun.spawnSync(
    [
      "git",
      "apply",
      "--reverse",
      "--check",
      join(receipt.directory, "change.diff"),
    ],
    { cwd: f.root },
  );
  expect(patch.stderr.toString()).toBe("");
  expect(patch.exitCode).toBe(0);
  expect(existsSync(join(receipt.directory, "checkout"))).toBe(false);
});

test("transient CI read outages retry publication without another model review", () => {
  const f = fixture();
  f.data.failCiRead = true;
  f.save();
  expect(f.set().code).toBe(0);
  f.run("configure", "--reviewer", "reviewer[bot]");
  expect(f.run("tick").code).toBe(1);
  expect(f.posted()).toEqual([]);
  const paid = f.recorded().filter((c) => c.tool === "codex").length;
  expect(JSON.parse(f.run("policy", "list").out).runs[0].status).toBe(
    "reviewed",
  );
  f.data.failCiRead = false;
  f.save();
  expect(f.run("tick").code).toBe(0);
  expect(f.posted()[0].state).toBe("APPROVE");
  expect(f.recorded().filter((c) => c.tool === "codex").length).toBe(paid);
});

test("a prior unresolved finding cannot silently disappear into approval on an unrelated update", () => {
  const f = fixture();
  f.data.result = {
    ...f.data.result,
    status: "NEEDS_CHANGES",
    findings: [{ ...defect, severity: "P1" }],
  };
  f.save();
  expect(f.set().code).toBe(0);
  f.run("configure", "--reviewer", "reviewer[bot]");
  expect(f.run("tick").code).toBe(0);
  writeFileSync(join(f.root, "README.md"), "Unrelated documentation update\n");
  f.git("add", "README.md");
  f.git("commit", "-m", "docs(test): unrelated update");
  f.data.pr.head.sha = f.git("rev-parse", "HEAD");
  f.data.pr.changed_files = 2;
  f.data.files.push({ filename: "README.md" });
  f.data.result = { ...f.data.result, status: "APPROVED", findings: [] };
  f.save();
  expect(f.run("tick").code).toBe(0);
  expect(f.posted()[1].state).toBe("COMMENT");
  writeFileSync(
    join(f.root, "README.md"),
    "Another unrelated documentation update\n",
  );
  f.git("add", "README.md");
  f.git("commit", "-m", "docs(test): another update");
  f.data.pr.head.sha = f.git("rev-parse", "HEAD");
  f.save();
  expect(f.run("tick").code).toBe(0);
  expect(f.posted()[2].state).toBe("COMMENT");
  expect(
    JSON.parse(f.run("policy", "list").out).runs[1].result.testing_gaps.join(
      " ",
    ),
  ).toContain(defect.id);
  writeFileSync(
    join(f.root, "ui/screen.tsx"),
    "export const screen = 'repaired';\n",
  );
  f.git("add", "ui");
  f.git("commit", "-m", "fix(test): verified repair");
  f.data.pr.head.sha = f.git("rev-parse", "HEAD");
  f.data.result.dispositions = [
    {
      id: defect.id,
      status: "fixed",
      reason: "The affected response path is repaired",
      evidence: "ui/screen.tsx now handles the tested response",
    },
  ];
  f.save();
  expect(f.run("tick").code).toBe(0);
  expect(f.posted().at(-1).state).toBe("APPROVE");
});

test("controller findings wake the bound original owner even when published by the dispatcher's account", () => {
  const f = fixture();
  f.data.result = {
    ...f.data.result,
    status: "NEEDS_CHANGES",
    findings: [{ ...defect, severity: "P1" }],
  };
  f.save();
  expect(f.set().code).toBe(0);
  expect(f.run("configure", "--reviewer", "reviewer[bot]").code).toBe(0);
  expect(
    f.run(
      "bind",
      "--agent",
      "codex",
      "--session",
      "11111111-1111-4111-8111-111111111111",
    ).code,
  ).toBe(0);
  expect(f.run("tick").code).toBe(0);
  expect(f.posted()).toHaveLength(1);
  expect(f.run("tick").code).toBe(0);
  const owner = f
    .recorded()
    .filter((c) => c.tool === "codex" && c.args[1] === "resume");
  expect(owner).toHaveLength(1);
  expect(owner[0].args).toEqual([
    "exec",
    "resume",
    "11111111-1111-4111-8111-111111111111",
    "-",
  ]);
  expect(owner[0].cwd).toBe(realpathSync(f.root));
  expect(owner[0].input).toContain("policies.json");
  expect(f.run("tick").code).toBe(0);
  expect(
    f.recorded().filter((c) => c.tool === "codex" && c.args[1] === "resume"),
  ).toHaveLength(1);
});

test("consumer-specific gates are never silently bypassed by automatic approval", () => {
  const f = fixture();
  writeFileSync(
    join(f.root, ".review-gates.json"),
    JSON.stringify({
      version: 1,
      gates: [
        {
          id: "domain-contract",
          always: true,
          globs: [],
          skills: [],
          title: "Domain contract",
          lens: "Check the application's domain-specific invariant",
        },
      ],
    }),
  );
  f.git("add", ".review-gates.json");
  f.git("commit", "-m", "test(review): consumer gate");
  f.data.pr.head.sha = f.git("rev-parse", "HEAD");
  f.data.pr.changed_files = 2;
  f.data.files.push({ filename: ".review-gates.json" });
  f.save();
  expect(f.set().code).toBe(0);
  f.run("configure", "--reviewer", "reviewer[bot]");
  expect(f.run("tick").code).toBe(1);
  expect(f.posted()).toEqual([]);
  expect(f.recorded().some((c) => c.tool === "codex")).toBe(false);
  expect(JSON.parse(f.run("policy", "list").out).runs[0].reason).toContain(
    "consumer-specific",
  );
});

test("a copied recovery marker from another publisher cannot acknowledge our approval", () => {
  const f = fixture();
  f.data.failPublish = true;
  f.save();
  expect(f.set().code).toBe(0);
  f.run("configure", "--reviewer", "reviewer[bot]");
  expect(f.run("tick").code).toBe(1);
  f.data.spoofRecovery = true;
  f.save();
  expect(f.run("tick").code).toBe(1);
  expect(JSON.parse(f.run("policy", "list").out).runs[0].status).toBe(
    "publication-unknown",
  );
  f.data.spoofRecovery = false;
  f.save();
  expect(f.run("tick").code).toBe(0);
  expect(f.posted()).toHaveLength(1);
  expect(JSON.parse(f.run("policy", "list").out).runs[0]).toMatchObject({
    status: "published",
    publisherId: 999,
  });
});

test("repository aliases compile to one case-insensitive scope", () => {
  const f = fixture();
  f.policy.repo = "EXAMPLE/PROJECT";
  expect(f.set().code).toBe(0);
  expect(JSON.parse(f.run("policy", "list").out).policies[0].repo).toBe(
    "example/project",
  );
});

test("unsupported review providers are rejected without changing authority or launching a model", () => {
  const f = fixture();
  f.policy.model = "claude-opus-5-5";
  const result = f.set();
  expect(result.code).not.toBe(0);
  expect(result.err).toContain("Unsupported isolated review provider");
  expect(JSON.parse(f.run("policy", "list").out).policies).toEqual([]);
  expect(
    f
      .recorded()
      .some((call) => call.tool === "codex" || call.tool === "claude"),
  ).toBe(false);
});

test("review workers launch in a private Git root, never the candidate's startup configuration", () => {
  const f = fixture();
  mkdirSync(join(f.root, ".claude"));
  writeFileSync(
    join(f.root, ".claude/settings.json"),
    JSON.stringify({
      hooks: {
        SessionStart: [{ hooks: [{ type: "command", command: "exit 1" }] }],
      },
    }),
  );
  writeFileSync(join(f.root, ".mcp.json"), JSON.stringify({ mcpServers: {} }));
  f.git("add", ".claude", ".mcp.json");
  f.git("commit", "-m", "test(review): candidate startup configuration");
  f.data.pr.head.sha = f.git("rev-parse", "HEAD");
  f.data.pr.changed_files = 3;
  f.data.files.push(
    { filename: ".claude/settings.json" },
    { filename: ".mcp.json" },
  );
  f.data.guardStartupRoot = true;
  f.save();
  expect(f.set().code).toBe(0);
  f.run("configure", "--reviewer", "reviewer[bot]");
  const result = f.run("tick");
  expect(result.err).toBe("");
  expect(result.code).toBe(0);
  expect(f.posted()).toHaveLength(1);
  const receipt = JSON.parse(f.run("policy", "list").out).runs[0];
  const worker = f.recorded().find((c) => c.tool === "codex");
  expect(realpathSync(worker.cwd)).toBe(realpathSync(receipt.directory));
  expect(worker.input).toContain(join(receipt.directory, "checkout"));
});

test("specialist falsification evidence survives synthesis and unresolved challenges withhold approval", () => {
  const f = fixture();
  f.data.specialistUnresolved = true;
  f.save();
  expect(f.set().code).toBe(0);
  expect(f.run("configure", "--reviewer", "reviewer[bot]").code).toBe(0);
  const tick = f.run("tick");
  expect(tick.err).toBe("");
  expect(tick.code).toBe(0);
  expect(f.posted()[0].state).toBe("COMMENT");
  const receipt = JSON.parse(f.run("policy", "list").out).runs[0];
  expect(receipt.result.schema_version).toBe(2);
  expect(receipt.result.status).toBe("NEEDS_CHANGES");
  expect(receipt.result.challenges).toContainEqual(
    expect.objectContaining({
      hypothesis: "Specialist cannot establish the changed contract.",
      outcome: "unresolved",
    }),
  );
});

test.each(["head", "policy"])(
  "historical uncertain publication is acknowledged without reusing approval after %s changes",
  (change) => {
    const f = fixture();
    f.data.failPublish = true;
    f.save();
    expect(f.set().code).toBe(0);
    expect(f.run("configure", "--reviewer", "reviewer[bot]").code).toBe(0);
    expect(f.run("tick").code).toBe(1);
    expect(f.posted()).toHaveLength(1);
    const old = JSON.parse(f.run("policy", "list").out).runs[0];
    if (change === "head") {
      writeFileSync(
        join(f.root, "ui/screen.tsx"),
        "export const screen = 'updated';\n",
      );
      f.git("add", "ui/screen.tsx");
      f.git("commit", "-m", "fix(test): update screen");
      f.data.pr.head.sha = f.git("rev-parse", "HEAD");
    } else {
      f.policy.autoApprove = false;
      expect(f.set().code).toBe(0);
    }
    f.data.failPublish = false;
    f.save();
    // Historical coverage remains binding even when current authority changes.
    const file = join(f.home, "policies.json");
    const saved = readFileSync(file, "utf8");
    const tampered = JSON.parse(saved);
    tampered.runs[0].coverage = [];
    writeFileSync(file, JSON.stringify(tampered));
    expect(f.run("tick").code).toBe(1);
    expect(f.posted()).toHaveLength(1);
    writeFileSync(file, saved);
    expect(f.run("tick").code).toBe(0);
    expect(f.posted()).toHaveLength(2);
    const runs = JSON.parse(f.run("policy", "list").out).runs;
    expect(runs).toHaveLength(2);
    expect(
      runs.find((run: { key: string }) => run.key === old.key),
    ).toMatchObject({
      status: "published",
      head: old.head,
      reason: expect.stringContaining("historical"),
    });
    expect(runs[1].key).not.toBe(old.key);
    expect(f.posted()[1]).toMatchObject({
      commit_id: f.data.pr.head.sha,
      state: change === "policy" ? "COMMENT" : "APPROVE",
    });
    const paid = f.recorded().filter((call) => call.tool === "codex").length;
    expect(f.run("tick").code).toBe(0);
    expect(f.posted()).toHaveLength(2);
    expect(f.recorded().filter((call) => call.tool === "codex")).toHaveLength(
      paid,
    );
  },
);
