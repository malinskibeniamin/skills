import { readFileSync } from "node:fs";
import type { ExperimentConfig, Sandbox } from "@vercel/agent-eval";

type Variant = "baseline" | "selective";

const baselineExploration = `### Code exploration

- Use the TraceDecay graph before broad shell search or whole-file reads: start with context or symbol search, then use callers, callees, affected tests, or test maps for relationships.
- Use \`tracedecay tool\` as the CLI fallback when MCP is unavailable. Fall back to scoped \`rg\` and file reads only when the index is unavailable or stale, or when generated and ignored artifacts are outside the graph.
- Treat TraceDecay savings as local estimates, not Codex usage, quota, or billing evidence. In linked worktrees, confirm the active project and branch before relying on graph results.`;

const explorationSection =
  /### Code exploration\n[\s\S]*?(?=\n### Native delegation)/;

export function renderRetrievalContext(
  source: string,
  variant: Variant,
): string {
  if (!explorationSection.test(source)) {
    throw new Error("AGENTS.md has no code exploration section");
  }
  return variant === "baseline"
    ? source.replace(explorationSection, baselineExploration)
    : source;
}

export function createExperiment(variant: Variant): ExperimentConfig {
  const source = readFileSync("AGENTS.md", "utf8");
  const context = renderRetrievalContext(source, variant);

  return {
    agent: "codex",
    model: "gpt-6.1-sol?reasoningEffort=xhigh",
    evals: ["evergreen-project-recovery", "knowledge-system-audit"],
    runs: 3,
    earlyExit: false,
    timeout: 600,
    sandbox: "docker",
    copyFiles: "changed",
    setup: async (sandbox: Sandbox) => {
      await sandbox.writeFiles({ "AGENTS.md": context });
    },
  } satisfies ExperimentConfig;
}
