import { readFileSync } from "node:fs";
import type { ExperimentConfig } from "@vercel/agent-eval";

const agent =
  process.env.ABLATION_AGENT === "claude-code" ? "claude-code" : "codex";
const effort =
  process.env.ABLATION_EFFORT ?? (agent === "codex" ? "xhigh" : "high");
const model =
  agent === "codex"
    ? `gpt-5.6-sol?reasoningEffort=${effort}`
    : (process.env.ABLATION_CLAUDE_MODEL ?? "fable");
const context = readFileSync("CLAUDE.md", "utf8");

export default {
  agent,
  model,
  evals: JSON.parse(
    readFileSync("agent-evals/context-ablation/manifest.json", "utf8"),
  ).tasks,
  runs: 3,
  earlyExit: false,
  timeout: 600,
  sandbox: "docker",
  copyFiles: "changed",
  ...(agent === "claude-code" ? { agentOptions: { effort } } : {}),
  editPrompt: (prompt) =>
    `${prompt}\n\nRepository context under test:\n${context}`,
} satisfies ExperimentConfig;
