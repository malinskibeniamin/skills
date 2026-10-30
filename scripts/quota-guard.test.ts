import { afterEach, expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const roots: string[] = [];
afterEach(() => {
  for (const root of roots.splice(0))
    rmSync(root, { recursive: true, force: true });
});

const window = (usedPercent = 20) => ({
  usedPercent,
  windowDurationMins: 300,
  resetsAt: Math.floor(Date.now() / 1000) + 3600,
});
const fixture = () => ({
  account: { type: "chatgpt", email: "operator@example.test" },
  config: { model_provider: "openai" },
  limits: { rateLimits: { primary: window(), secondary: window(30) } },
});

test("guard is registered in both generated host prompt and checkpoint paths", () => {
  for (const [file, script] of [
    ["../hooks/hooks.json", "quota-guard.sh"],
    ["../hooks/codex-hooks.json", "codex-quota-guard.sh"],
  ] as const) {
    const config = JSON.parse(
      readFileSync(new URL(file, import.meta.url), "utf8"),
    );
    for (const event of ["UserPromptSubmit", "PostToolUse", "PreToolUse"]) {
      const groups = config.hooks[event];
      expect(JSON.stringify(groups)).toContain(script);
    }
    expect(JSON.stringify(config.hooks.Stop)).not.toContain(script);
  }
});

test("launch matcher excludes read-only task management tools", () => {
  const config = JSON.parse(
    readFileSync(new URL("../hooks/codex-hooks.json", import.meta.url), "utf8"),
  );
  const group = config.hooks.PreToolUse.find(
    (g: { matcher?: string; hooks: unknown }) =>
      g.matcher && JSON.stringify(g.hooks).includes("codex-quota-guard.sh"),
  );
  const matcher = new RegExp(group.matcher);
  expect(matcher.test("mcp__t3_code__delegate_task")).toBe(true);
  expect(matcher.test("Agent")).toBe(true);
  expect(matcher.test("TaskGet")).toBe(false);
  expect(matcher.test("TaskList")).toBe(false);
});

function run(
  data: unknown = fixture(),
  env: Record<string, string> = {},
  event = "UserPromptSubmit",
  provider = "codex",
  input: Record<string, unknown> = {},
) {
  const root = mkdtempSync(join(tmpdir(), "quota-guard-"));
  roots.push(root);
  writeFileSync(join(root, "fixture.json"), JSON.stringify(data));
  if (env.QUOTA_TEST_PYTHON_FAILURE) {
    writeFileSync(
      join(root, "python3"),
      "#!/bin/sh\necho SECRET-runtime-error >&2\nexit 1\n",
      { mode: 0o755 },
    );
  }
  if (env.QUOTA_TEST_JQ_FAILURE) {
    writeFileSync(join(root, "jq"), "#!/bin/sh\nexit 127\n", { mode: 0o755 });
  }
  writeFileSync(
    join(root, "codex"),
    `#!/usr/bin/env python3
import json, os, sys, signal
from pathlib import Path
root=Path(os.environ['QUOTA_FIXTURE_ROOT'])
data=json.loads((root/'fixture.json').read_text())
count=0
for line in sys.stdin:
    q=json.loads(line)
    with (root/'calls').open('a') as f: f.write(q['method']+'\\n')
    if 'id' not in q: continue
    method=q['method']
    if method=='initialize': result={}
    elif method=='config/read': result={'config':data['config']}
    elif method=='account/read':
        count+=1
        result={'account':data.get('changedAccount',data['account']) if count>1 else data['account'], 'requiresOpenaiAuth':True}
    elif method=='account/rateLimits/read':
        if data.get('hang'): signal.pause()
        if data.get('rpcError'):
            print(json.dumps({'id':q['id'],'error':{'message':'SECRET-provider-error'}}),flush=True)
            continue
        result=data['limits']
    else:
        print(json.dumps({'id':q['id'],'error':{'message':'unexpected method'}}),flush=True)
        continue
    print(json.dumps({'id':q['id'],'result':result}),flush=True)
`,
    { mode: 0o755 },
  );
  const result = Bun.spawnSync(
    [
      "/bin/bash",
      new URL(
        `../.claude/hooks/${provider === "codex" ? "codex-quota-guard" : "quota-guard"}.sh`,
        import.meta.url,
      ).pathname,
    ],
    {
      env: {
        ...Bun.env,
        PATH: `${root}:${Bun.env.PATH}`,
        QUOTA_FIXTURE_ROOT: root,
        HARNESS_QUOTA_GUARD: "1",
        HARNESS_QUOTA_GUARD_ACCOUNT: "operator@example.test",
        HARNESS_QUOTA_GUARD_THRESHOLD: "90",
        HARNESS_QUOTA_GUARD_TIMEOUT: "2",
        OPENAI_API_KEY: "",
        CODEX_API_KEY: "",
        OPENAI_BASE_URL: "",
        CHATGPT_BASE_URL: "",
        ...env,
      },
      stdin: Buffer.from(
        JSON.stringify({
          hook_event_name: event,
          session_id: "fixture",
          ...input,
        }),
      ),
    },
  );
  let calls = "";
  try {
    calls = readFileSync(join(root, "calls"), "utf8");
  } catch (error) {
    if (!(error instanceof Error && "code" in error && error.code === "ENOENT"))
      throw error;
  }
  return {
    code: result.exitCode,
    out: result.stdout.toString(),
    err: result.stderr.toString(),
    calls,
  };
}

test("disabled guard is silent and never starts a collector", () => {
  expect(run(fixture(), { HARNESS_QUOTA_GUARD: "0" })).toMatchObject({
    code: 0,
    out: "",
    err: "",
    calls: "",
  });
});

test("fresh native quota below the threshold allows without model execution", () => {
  const r = run();
  expect(r).toMatchObject({ code: 0, out: "", err: "" });
  expect(r.calls.trim().split("\n")).toEqual([
    "initialize",
    "initialized",
    "config/read",
    "account/read",
    "account/rateLimits/read",
    "account/read",
  ]);
});

test("accepts Codex's materialized native ChatGPT base URL", () => {
  const data = {
    ...fixture(),
    config: {
      model_provider: "openai",
      chatgpt_base_url: "https://chatgpt.com/backend-api/",
    },
  };
  expect(run(data).out).toBe("");
});

for (const field of ["primary", "secondary"] as const) {
  test(`blocks a prompt at the ${field} threshold`, () => {
    const data = fixture();
    data.limits.rateLimits[field] = window(90);
    const r = run(data);
    expect(r.code).toBe(0);
    expect(r.out ? JSON.parse(r.out) : {}).toMatchObject({ decision: "block" });
    expect(r.out).toContain("90%");
  });
}

test("checks every reported model bucket, not only the legacy view", () => {
  const data = {
    ...fixture(),
    limits: {
      ...fixture().limits,
      rateLimitsByLimitId: { model: { primary: window(95), secondary: null } },
    },
  };
  expect(JSON.parse(run(data).out).decision).toBe("block");
});

test("uses host-specific blocking output at task and post-tool checkpoints", () => {
  const data = fixture();
  data.limits.rateLimits.primary = window(95);
  expect(JSON.parse(run(data, {}, "PreToolUse").out)).toMatchObject({
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
    },
  });
  expect(JSON.parse(run(data, {}, "PostToolUse").out)).toMatchObject({
    continue: false,
  });
});

test("does not invent a missing secondary window", () => {
  const data = {
    ...fixture(),
    limits: { rateLimits: { primary: window(), secondary: null } },
  };
  expect(run(data).out).toBe("");
});

for (const limits of [
  {},
  { rateLimits: { primary: null, secondary: null } },
  { rateLimits: { primary: { ...window(), usedPercent: "20" } } },
  { rateLimits: { primary: { ...window(), usedPercent: -1 } } },
  { rateLimits: { primary: { ...window(), resetsAt: 1 } } },
  { rateLimits: { primary: { ...window(), resetsAt: null } } },
  { rateLimits: { primary: window(), rateLimitReachedType: "primary" } },
  { ...fixture().limits, rateLimitsByLimitId: {} },
]) {
  test(`fails closed on missing, invalid, stale or reached quota: ${JSON.stringify(limits)}`, () => {
    expect(JSON.parse(run({ ...fixture(), limits }).out).decision).toBe(
      "block",
    );
  });
}

test("wrong accounts, account changes and API billing cannot pass", () => {
  for (const change of [
    { account: { type: "chatgpt", email: "other@example.test" } },
    { changedAccount: { type: "chatgpt", email: "other@example.test" } },
    { account: { type: "apiKey" } },
    { config: { model_provider: "proxy" } },
    {
      config: {
        model_provider: "openai",
        openai_base_url: "https://proxy.test",
      },
    },
  ]) {
    const result = run({ ...fixture(), ...change });
    expect(result.out ? JSON.parse(result.out) : {}).toMatchObject({
      decision: "block",
    });
  }
});

test("invalid configuration and unsupported Claude fail closed before collection", () => {
  for (const env of [
    { HARNESS_QUOTA_GUARD_ACCOUNT: "" },
    { HARNESS_QUOTA_GUARD_THRESHOLD: "100" },
    { HARNESS_QUOTA_GUARD_THRESHOLD: "NaN" },
    { HARNESS_QUOTA_GUARD: "yes" },
  ]) {
    const r = run(fixture(), env);
    expect(JSON.parse(r.out).decision).toBe("block");
    expect(r.calls).toBe("");
  }
  const r = run(fixture(), {}, "UserPromptSubmit", "claude");
  expect(JSON.parse(r.out).decision).toBe("block");
  expect(r.out).toContain("Claude");
  expect(r.calls).toBe("");
});

test("RPC failures and timeouts block without exposing provider output", () => {
  const failed = run({ ...fixture(), rpcError: true });
  expect(JSON.parse(failed.out).decision).toBe("block");
  expect(failed.out + failed.err).not.toContain("SECRET");
  const hung = run(
    { ...fixture(), hang: true },
    { HARNESS_QUOTA_GUARD_TIMEOUT: "0.2" },
  );
  expect(JSON.parse(hung.out).decision).toBe("block");
  expect(hung.out).toContain("unavailable");
});

test("collector crashes and oversized tool events stop instead of failing open", () => {
  const failed = run(
    fixture(),
    { QUOTA_TEST_PYTHON_FAILURE: "1" },
    "PostToolUse",
  );
  expect(failed.out ? JSON.parse(failed.out) : {}).toMatchObject({
    continue: false,
  });
  expect(failed.out + failed.err).not.toContain("SECRET");
  const large = run(fixture(), {}, "PostToolUse", "codex", {
    tool_response: "x".repeat(300000),
  });
  expect(JSON.parse(large.out)).toMatchObject({ continue: false });
  expect(large.calls).toBe("");
});

test("missing parser dependencies still emit a blocking checkpoint result", () => {
  const env = { QUOTA_TEST_PYTHON_FAILURE: "1", QUOTA_TEST_JQ_FAILURE: "1" };
  const stopped = run(fixture(), env, "PostToolUse");
  expect(stopped.out ? JSON.parse(stopped.out) : {}).toMatchObject({
    continue: false,
  });
  const denied = run(fixture(), env, "PreToolUse");
  expect(denied.out ? JSON.parse(denied.out) : {}).toMatchObject({
    hookSpecificOutput: { permissionDecision: "deny" },
  });
});
