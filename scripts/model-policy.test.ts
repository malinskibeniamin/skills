import { afterEach, expect, test } from "bun:test";
import {
  readFileSync,
  mkdtempSync,
  mkdirSync,
  writeFileSync,
  rmSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import defaultExperiment from "../agent-evals/experiments/default";

const original = process.env.ABLATION_MODEL;
afterEach(() => {
  if (original === undefined) delete process.env.ABLATION_MODEL;
  else process.env.ABLATION_MODEL = original;
});

test("default evaluations use the current primary route, not the Sonnet alias", () => {
  const policy = JSON.parse(
    readFileSync(
      new URL("../config/model-routing.json", import.meta.url),
      "utf8",
    ),
  );
  expect(defaultExperiment.model).toBe(policy.quality_first.default.model);
});

test("ablation rejects a legacy model before returning a launchable experiment", async () => {
  const { createExperiment } = await import(
    "../agent-evals/context-ablation/create-experiment"
  );
  process.env.ABLATION_MODEL = "claude-sonnet-5";
  expect(() => createExperiment(null)).toThrow(/not allowed/i);
});

test("model switches reject unknown SDK-selected models before execution", () => {
  const result = Bun.spawnSync(
    ["bash", ".claude/hooks/model-switch-router.sh"],
    {
      stdin: Buffer.from(
        JSON.stringify({
          hook_event_name: "PreModelSwitch",
          session_id: "model-policy-test",
          to_model: "claude-sonnet-5",
          source: "sdk",
        }),
      ),
      env: {
        ...process.env,
        MODEL_ROUTING_FILE: new URL(
          "../config/model-routing.json",
          import.meta.url,
        ).pathname,
        HOOK_METRICS_DISABLED: "1",
      },
    },
  );
  const output = result.stdout.toString();
  expect(
    output
      ? JSON.parse(output).hookSpecificOutput?.permissionDecision
      : undefined,
  ).toBe("deny");
});

for (const model of [
  "sonnet",
  "claude-sonnet-5",
  "claude-haiku-4-5-20251001",
  "claude-opus-5",
  "gpt-6.1-sol?model=sonnet",
  "unknown-model",
]) {
  test(`rejects ${model} without invoking a provider`, async () => {
    const { assertAllowedModel } = await import("./model-policy");
    expect(() => assertAllowedModel(model)).toThrow(/not allowed/);
  });
}

test("accepts both owner-selected model IDs but not a cross-provider launch", async () => {
  const { assertAllowedModel, getModelRoute } = await import("./model-policy");
  expect(assertAllowedModel("claude-opus-5-5")).toBe("claude-opus-5-5");
  expect(assertAllowedModel("gpt-6.1-sol")).toBe("gpt-6.1-sol");
  expect(() => getModelRoute("claude-code", "gpt-6.1-sol")).toThrow(
    /not allowed for/,
  );
});

test("missing policy fails closed", async () => {
  const { assertAllowedModel } = await import("./model-policy");
  expect(() =>
    assertAllowedModel("claude-opus-5-5", "/nonexistent/model-routing.json"),
  ).toThrow();
});

test("direct delegated model selections receive a pre-tool denial", () => {
  const result = Bun.spawnSync(
    [process.execPath, "scripts/model-policy.ts", "hook"],
    {
      stdin: Buffer.from(
        JSON.stringify({
          hook_event_name: "PreToolUse",
          tool_name: "mcp__t3_code__delegate_task",
          tool_input: { target: { model: "claude-sonnet-5" } },
        }),
      ),
    },
  );
  expect(
    JSON.parse(result.stdout.toString()).hookSpecificOutput.permissionDecision,
  ).toBe("deny");
});

test("allowed direct selections pass while a missing policy blocks a model launch", () => {
  const payload = Buffer.from(
    JSON.stringify({
      hook_event_name: "PreToolUse",
      tool_name: "Agent",
      tool_input: { model: "claude-opus-5-5" },
    }),
  );
  const allowed = Bun.spawnSync(
    [process.execPath, "scripts/model-policy.ts", "hook"],
    { stdin: payload },
  );
  expect(allowed.exitCode).toBe(0);
  expect(allowed.stdout.toString()).toBe("");
  const missing = Bun.spawnSync(
    [process.execPath, "scripts/model-policy.ts", "hook"],
    {
      stdin: payload,
      env: {
        ...process.env,
        MODEL_ROUTING_FILE: "/nonexistent/model-routing.json",
        HOME: "/nonexistent/model-policy-home",
      },
    },
  );
  expect(
    JSON.parse(missing.stdout.toString()).hookSpecificOutput.permissionDecision,
  ).toBe("deny");
});

test("managed Claude settings enforce the current provider-specific allowlist", () => {
  const result = Bun.spawnSync([
    process.execPath,
    "scripts/model-policy.ts",
    "claude-settings",
  ]);
  expect(result.exitCode).toBe(0);
  expect(JSON.parse(result.stdout.toString())).toEqual({
    model: "claude-opus-5-5",
    availableModels: ["claude-opus-5-5"],
    availableModelsMatch: "exact",
    enforceAvailableModels: true,
    requiredMinimumVersion: "2.1.283",
  });
});

test("bulk thread model selections cannot hide an unapproved model", () => {
  const result = Bun.spawnSync(
    [process.execPath, "scripts/model-policy.ts", "hook"],
    {
      stdin: Buffer.from(
        JSON.stringify({
          hook_event_name: "PreToolUse",
          tool_name: "create_threads",
          tool_input: {
            threads: [{ modelSelection: { model: "claude-sonnet-5" } }],
          },
        }),
      ),
    },
  );
  const output = result.stdout.toString();
  expect(
    output
      ? JSON.parse(output).hookSpecificOutput?.permissionDecision
      : undefined,
  ).toBe("deny");
});

test("fixed-model specialist roles cannot bypass model selection checks", () => {
  const result = Bun.spawnSync(
    [process.execPath, "scripts/model-policy.ts", "hook"],
    {
      stdin: Buffer.from(
        JSON.stringify({
          hook_event_name: "PreToolUse",
          tool_name: "spawn_agent",
          tool_input: { agent_type: "quiet_mac_reviewer", message: "Review" },
        }),
      ),
    },
  );
  const output = result.stdout.toString();
  expect(
    output
      ? JSON.parse(output).hookSpecificOutput?.permissionDecision
      : undefined,
  ).toBe("deny");
});

test("built-in Claude explorers cannot select an implicit cheaper model", () => {
  const result = Bun.spawnSync(
    [process.execPath, "scripts/model-policy.ts", "hook"],
    {
      stdin: Buffer.from(
        JSON.stringify({
          hook_event_name: "PreToolUse",
          tool_name: "Agent",
          tool_input: { subagent_type: "Explore", prompt: "Inspect" },
        }),
      ),
    },
  );
  const output = result.stdout.toString();
  expect(
    output
      ? JSON.parse(output).hookSpecificOutput?.permissionDecision
      : undefined,
  ).toBe("deny");
});

test("a stale environment policy cannot override an installed personal allowlist", () => {
  const home = mkdtempSync(join(tmpdir(), "model-policy-owner-"));
  try {
    const folder = join(home, ".config/frontend-skills");
    mkdirSync(folder, { recursive: true });
    const fixture = (model: string) =>
      JSON.stringify({
        selection: { preferred_models: [model] },
        models: { [model]: { status: "primary" } },
        quality_first: { default: { model, effort: "xhigh" } },
      });
    writeFileSync(
      join(folder, "model-routing.json"),
      fixture("claude-opus-5-5"),
    );
    const stale = join(home, "stale.json");
    writeFileSync(stale, fixture("claude-sonnet-5"));
    const result = Bun.spawnSync(
      [process.execPath, "scripts/model-policy.ts", "check", "claude-sonnet-5"],
      { env: { HOME: home, MODEL_ROUTING_FILE: stale } },
    );
    expect(result.exitCode).toBe(1);
    expect(result.stderr.toString()).toContain("not allowed");
  } finally {
    rmSync(home, { recursive: true, force: true });
  }
});
