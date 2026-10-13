import { readFileSync } from "node:fs";
import type { ExperimentConfig } from "@vercel/agent-eval";
import { createExperiment as createAblation } from "../context-ablation/create-experiment.ts";

export function createExperiment(
  variant: "bare" | "current",
): ExperimentConfig {
  const config = createAblation(
    variant === "bare"
      ? null
      : {
          claudeCode: "CLAUDE.md",
          codex: "AGENTS.md",
        },
  );
  const setup = readFileSync(
    "agent-evals/restraint-composition/setup.sh",
    "utf8",
  );
  // Both arms get the same readable reference files; only ambient instructions vary.
  const references = Object.fromEntries(
    [
      "shared/communication.md",
      "shared/intent-map.md",
      "shared/remote-completion.md",
      "shared/ldcli.md",
      "config/model-routing.json",
    ].map((path) => [path, readFileSync(path, "utf8")]),
  );

  return {
    ...config,
    evals: [
      "restraint-local-edit",
      "restraint-verification-report",
      "restraint-delivery-followup",
    ],
    setup: async (sandbox) => {
      await config.setup?.(sandbox);
      await sandbox.writeFiles({
        ...references,
        ".verification/setup.sh": setup,
      });
      const result = await sandbox.runCommand("bash", [
        ".verification/setup.sh",
      ]);
      if (result.exitCode !== 0) {
        throw new Error(
          `Fixture setup failed: ${result.stdout}\n${result.stderr}`,
        );
      }
    },
  };
}
