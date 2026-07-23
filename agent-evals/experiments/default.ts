import type { ExperimentConfig, Sandbox } from "@vercel/agent-eval";

export default {
  agent: "claude-code",
  model: "sonnet",
  runs: 1,
  timeout: 300,
  sandbox: "docker",
  copyFiles: "changed",
  setup: async (sandbox: Sandbox) => {
    await sandbox.runCommand("npm", ["install", "-g", "typescript", "bun"]);
  },
} satisfies ExperimentConfig;
