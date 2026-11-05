import { getModelRoute } from "../../scripts/model-policy";
import { readFileSync } from "node:fs";
import type { ExperimentConfig, Sandbox } from "@vercel/agent-eval";

// Preserve the actual adapters and their relative host/snapshot references.
const paths = [
  "tstack-skills/council/SKILL.md",
  "tstack-skills/sol-loop/SKILL.md",
  "vendor/tstack/skills/council/SKILL.md",
  "vendor/tstack/skills/sol-loop/SKILL.md",
  "shared/TSTACK.md",
  "shared/review-contract.md",
  "review/OPERATING-MODEL.md",
  "agents/references/findings-schema.md",
] as const;

const guidance = Object.fromEntries(
  paths.map((path) => [
    `guidance/${path}`,
    readFileSync(new URL(`../../${path}`, import.meta.url), "utf8"),
  ]),
);

export default {
  agent: "claude-code",
  model: getModelRoute("claude-code").model,
  agentOptions: { effort: "xhigh" },
  runs: 3,
  earlyExit: false,
  timeout: 600,
  sandbox: "docker",
  copyFiles: "changed",
  evals: ["council-review-decisions", "review-consequence-triage"],
  setup: async (sandbox: Sandbox) => {
    await sandbox.writeFiles(guidance);
  },
} satisfies ExperimentConfig;
