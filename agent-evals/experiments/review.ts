import { readFileSync } from "node:fs";
import type { ExperimentConfig, Sandbox } from "@vercel/agent-eval";

const skill = readFileSync(
  new URL("../../review/SKILL.md", import.meta.url),
  "utf8",
);
const reference = readFileSync(
  new URL("../../review/REFERENCE.md", import.meta.url),
  "utf8",
);
const deepAudit = readFileSync(
  new URL("../../review/DEEP-AUDIT.md", import.meta.url),
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
  evals: ["contract-tracing-review", "dogfood-review-live-data"],
  setup: async (sandbox: Sandbox) => {
    await sandbox.writeFiles({
      ".claude/skills/review/SKILL.md": skill,
      ".claude/skills/review/REFERENCE.md": reference,
      ".claude/skills/review/DEEP-AUDIT.md": deepAudit,
    });
    await sandbox.runCommand("npm", ["install", "-g", "bun"]);
  },
} satisfies ExperimentConfig;
