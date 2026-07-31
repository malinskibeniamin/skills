import { readFileSync } from "node:fs";
import type { ExperimentConfig } from "@vercel/agent-eval";

type ContextSource =
  | { claudeCode: string; codex: string }
  | { shared: string }
  | null;

const manifest = JSON.parse(
  readFileSync("agent-evals/context-ablation/manifest.json", "utf8"),
) as { tasks: string[]; runs_per_cell: number };

export const createExperiment = (source: ContextSource): ExperimentConfig => {
  const agent =
    process.env.ABLATION_AGENT === "claude-code" ? "claude-code" : "codex";
  const effort =
    process.env.ABLATION_EFFORT ?? (agent === "codex" ? "xhigh" : "high");
  const model =
    agent === "codex"
      ? `gpt-5.6-sol?reasoningEffort=${effort}`
      : (process.env.ABLATION_CLAUDE_MODEL ?? "fable");
  const instructionFile = agent === "codex" ? "AGENTS.md" : "CLAUDE.md";
  const contextPath =
    source === null
      ? null
      : "shared" in source
        ? source.shared
        : agent === "codex"
          ? source.codex
          : source.claudeCode;
  const context =
    contextPath === null ? null : readFileSync(contextPath, "utf8");
  const runtimeContext = context ?? "";

  return {
    agent,
    model,
    evals: manifest.tasks,
    runs: manifest.runs_per_cell,
    earlyExit: false,
    timeout: 600,
    sandbox: "docker",
    copyFiles: "changed",
    ...(agent === "claude-code" ? { agentOptions: { effort } } : {}),
    setup: async (sandbox) => {
      // copyFiles may carry changed ambient instructions into every cell. Always
      // overwrite the runtime-native file so the bare cell is actually bare.
      await sandbox.writeFiles({ [instructionFile]: runtimeContext });
    },
  } satisfies ExperimentConfig;
};
