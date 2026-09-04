import { readFileSync } from "node:fs";
import type { ExperimentConfig } from "@vercel/agent-eval";
import { z } from "zod";

const ManifestSchema = z.object({
  automated_tasks: z.array(z.string().min(1)).min(1),
  runs_per_cell: z.number().int().positive(),
});

const manifest = ManifestSchema.parse(
  JSON.parse(
    readFileSync("agent-evals/capability-probes/manifest.json", "utf8"),
  ),
);
const agent =
  process.env.CAPABILITY_AGENT === "claude-code" ? "claude-code" : "codex";
const effort = process.env.CAPABILITY_EFFORT ?? "max";
const baseModel =
  process.env.CAPABILITY_MODEL ??
  (agent === "codex" ? "gpt-6-astra" : "claude-fable-5-1");
const model =
  agent === "codex" ? `${baseModel}?reasoningEffort=${effort}` : baseModel;

export default {
  agent,
  model,
  evals: manifest.automated_tasks,
  runs: manifest.runs_per_cell,
  earlyExit: false,
  timeout: 900,
  sandbox: "docker",
  copyFiles: "changed",
  ...(agent === "claude-code" ? { agentOptions: { effort } } : {}),
} satisfies ExperimentConfig;
