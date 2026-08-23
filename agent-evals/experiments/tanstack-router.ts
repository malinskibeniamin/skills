import { readFileSync } from "node:fs";
import type { ExperimentConfig, Sandbox } from "@vercel/agent-eval";

const routerSkill = readFileSync(
  new URL("../../tanstack-router/SKILL.md", import.meta.url),
  "utf8",
);
const routerReference = readFileSync(
  new URL("../../tanstack-router/REFERENCE.md", import.meta.url),
  "utf8",
);
const e2eSkill = readFileSync(
  new URL("../../e2e-testing/SKILL.md", import.meta.url),
  "utf8",
);
const intentSkill = readFileSync(
  new URL("../../tanstack-intent/SKILL.md", import.meta.url),
  "utf8",
);

export default {
  agent: "claude-code",
  model: "sonnet",
  runs: 3,
  earlyExit: false,
  timeout: 600,
  sandbox: "docker",
  copyFiles: "changed",
  evals: ["tanstack-router-navigation-lifetimes"],
  setup: async (sandbox: Sandbox) => {
    await sandbox.writeFiles({
      ".claude/skills/e2e-testing/SKILL.md": e2eSkill,
      ".claude/skills/tanstack-intent/SKILL.md": intentSkill,
      ".claude/skills/tanstack-router/SKILL.md": routerSkill,
      ".claude/skills/tanstack-router/REFERENCE.md": routerReference,
    });
    await sandbox.runCommand("npm", ["install", "-g", "bun"]);
    await sandbox.runCommand("bun", ["install"]);
  },
} satisfies ExperimentConfig;
