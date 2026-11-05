import { lstatSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

export type ModelAgent = "claude-code" | "codex";
type ModelRoute = { model: string; effort: string };

function record(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function policy(path?: string) {
  const personal = join(
    homedir(),
    ".config/frontend-skills/model-routing.json",
  );
  const source =
    path ??
    (lstatSync(personal, { throwIfNoEntry: false })
      ? personal
      : process.env.MODEL_ROUTING_FILE);
  const data: unknown = JSON.parse(
    readFileSync(
      source ?? new URL("../config/model-routing.json", import.meta.url),
      "utf8",
    ),
  );
  if (
    !record(data) ||
    !record(data.selection) ||
    !record(data.models) ||
    !record(data.quality_first)
  ) {
    throw new Error(
      "Invalid model-routing policy: selection, models and quality_first are required",
    );
  }
  const allowed = data.selection.preferred_models;
  if (
    !Array.isArray(allowed) ||
    allowed.length === 0 ||
    !allowed.every(
      (model): model is string =>
        typeof model === "string" && model.trim() === model && model.length > 0,
    )
  ) {
    throw new Error(
      "Invalid model-routing policy: preferred_models must be a nonempty model allowlist",
    );
  }
  const models = data.models;
  if (
    new Set(allowed).size !== allowed.length ||
    !allowed.every(
      (model) =>
        record(models[model]) &&
        typeof models[model].status === "string" &&
        !["retired", "unsupported"].includes(models[model].status),
    )
  ) {
    throw new Error(
      "Invalid model-routing policy: preferred models must have supported catalog entries",
    );
  }
  return { allowed, routes: data.quality_first };
}

export function assertAllowedModel(model: string, path?: string): string {
  if (!policy(path).allowed.includes(model)) {
    throw new Error(
      `Model ${JSON.stringify(model)} is not allowed by the current model-routing policy; no request was started`,
    );
  }
  return model;
}

export function getModelRoute(
  agent: ModelAgent,
  requested?: string,
  path?: string,
): ModelRoute {
  const current = policy(path);
  const route =
    current.routes[agent === "claude-code" ? "default" : "secondary"];
  if (
    !record(route) ||
    typeof route.model !== "string" ||
    typeof route.effort !== "string" ||
    !current.allowed.includes(route.model)
  ) {
    throw new Error(
      `Invalid model-routing policy: missing allowed ${agent} route`,
    );
  }
  const model = requested === undefined ? route.model : requested;
  assertAllowedModel(model, path);
  if (!model.startsWith(agent === "claude-code" ? "claude-" : "gpt-")) {
    throw new Error(
      `Model ${JSON.stringify(model)} is not allowed for ${agent}; no request was started`,
    );
  }
  return { model, effort: route.effort };
}

function hookModels(input: Record<string, unknown>): string[] {
  if (input.hook_event_name === "PreModelSwitch") {
    const model = input.to_model ?? input.new_model ?? input.model;
    if (typeof model !== "string" || !model)
      throw new Error("Model switch has no target model");
    return [model];
  }
  if (
    input.hook_event_name !== "PreToolUse" ||
    typeof input.tool_name !== "string" ||
    !/(?:^|__|\.)(?:Agent|Task|spawn_agent|delegate_task|t3_thread_configure|t3_thread_launch|create_threads)$/.test(
      input.tool_name,
    )
  )
    return [];
  const args = input.tool_input;
  if (!record(args))
    throw new Error("Model-launch tool has no structured input");
  if (
    typeof args.subagent_type === "string" &&
    args.subagent_type !== "general-purpose"
  ) {
    throw new Error(
      `Subagent ${args.subagent_type} has no verified inherited model in the current allowlist`,
    );
  }
  if (
    typeof args.agent_type === "string" &&
    !["default", "worker", "explorer"].includes(args.agent_type)
  ) {
    throw new Error(
      `Specialist ${args.agent_type} has no verified model in the current allowlist`,
    );
  }
  function collect(value: unknown): string[] {
    if (Array.isArray(value)) return value.flatMap(collect);
    if (!record(value)) return [];
    return Object.entries(value).flatMap(([key, entry]) => {
      if (key !== "model") return collect(entry);
      if (typeof entry !== "string")
        throw new Error("Model selection must be a model ID");
      return [entry];
    });
  }
  return collect(args);
}

if (import.meta.main) {
  const [command, ...args] = process.argv.slice(2);
  if (command === "hook") {
    let event = "PreToolUse";
    try {
      const input: unknown = JSON.parse(await Bun.stdin.text());
      if (!record(input)) throw new Error("Invalid hook payload");
      if (input.hook_event_name === "PreModelSwitch") event = "PreModelSwitch";
      for (const model of hookModels(input)) assertAllowedModel(model);
    } catch (error) {
      console.log(
        JSON.stringify({
          hookSpecificOutput: {
            hookEventName: event,
            permissionDecision: "deny",
            permissionDecisionReason:
              error instanceof Error ? error.message : String(error),
          },
        }),
      );
    }
  } else {
    try {
      if (command === "check" && args.length > 0) {
        for (const model of args) assertAllowedModel(model);
      } else if (
        command === "route" &&
        (args[0] === "claude-code" || args[0] === "codex") &&
        args.length === 1
      ) {
        console.log(JSON.stringify(getModelRoute(args[0])));
      } else if (command === "claude-settings" && args.length === 0) {
        const route = getModelRoute("claude-code");
        console.log(
          JSON.stringify(
            {
              model: route.model,
              availableModels: [route.model],
              availableModelsMatch: "exact",
              enforceAvailableModels: true,
              requiredMinimumVersion: "2.1.283",
            },
            null,
            2,
          ),
        );
      } else
        throw new Error(
          "Usage: model-policy.ts check MODEL... | route claude-code|codex | claude-settings | hook",
        );
    } catch (error) {
      console.error(error instanceof Error ? error.message : String(error));
      process.exitCode = 1;
    }
  }
}
