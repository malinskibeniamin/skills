import { readFileSync } from "node:fs";
import type { ExperimentConfig, Sandbox } from "@vercel/agent-eval";

const skill = readFileSync(
  new URL("../../aip/SKILL.md", import.meta.url),
  "utf8",
);
const reference = readFileSync(
  new URL("../../aip/REFERENCE.md", import.meta.url),
  "utf8",
);

export default {
  agent: "claude-code",
  model: "sonnet",
  runs: 3,
  earlyExit: false,
  timeout: 900,
  sandbox: "docker",
  copyFiles: "changed",
  evals: ["aip-design-review"],
  setup: async (sandbox: Sandbox) => {
    await sandbox.writeFiles({
      ".claude/skills/aip/SKILL.md": skill,
      ".claude/skills/aip/REFERENCE.md": reference,
    });
    await sandbox.runCommand("chmod", ["+x", "tools/api-linter"]);
  },
} satisfies ExperimentConfig;
