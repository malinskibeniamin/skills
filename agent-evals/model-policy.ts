import routing from "../config/model-routing.json";

export function selectModelRoute(
  agentName = "codex",
  modelOverride?: string,
  effortOverride?: string,
): { agent: "codex" | "claude-code"; model: string; effort: string } {
  if (agentName !== "codex" && agentName !== "claude-code") {
    throw new Error(`Model policy: unsupported agent ${agentName}`);
  }
  const route =
    agentName === "codex"
      ? routing.quality_first.secondary
      : routing.quality_first.default;
  const model = modelOverride ?? route.model;
  const effort = effortOverride ?? route.effort;
  if (
    model !== route.model ||
    !routing.selection.preferred_models.includes(model) ||
    effort !== route.effort ||
    !routing.efforts.allowed.includes(effort)
  ) {
    throw new Error(
      `Model policy: ${agentName} requires ${route.model} at ${route.effort}; received ${model} at ${effort}`,
    );
  }
  return {
    agent: agentName,
    model: agentName === "codex" ? `${model}?reasoningEffort=${effort}` : model,
    effort,
  };
}
