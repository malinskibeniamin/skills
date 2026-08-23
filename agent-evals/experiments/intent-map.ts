import { readFileSync } from "node:fs";
import type { ExperimentConfig, Sandbox } from "@vercel/agent-eval";

const instructions = readFileSync(
  new URL("../../CLAUDE.md", import.meta.url),
  "utf8",
);
const contract = readFileSync(
  new URL("../../shared/intent-map.md", import.meta.url),
  "utf8",
);

export default {
  agent: "claude-code",
  model: "opus",
  agentOptions: { effort: "xhigh" },
  runs: 3,
  earlyExit: false,
  timeout: 600,
  sandbox: "docker",
  copyFiles: "changed",
  evals: ["intent-map-explanation"],
  setup: async (sandbox: Sandbox) => {
    await sandbox.writeFiles({
      "CLAUDE.md": instructions,
      "shared/intent-map.md": contract,
    });
  },
} satisfies ExperimentConfig;
