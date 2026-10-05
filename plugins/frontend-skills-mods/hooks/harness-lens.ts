import type { EngineInterface, Register } from "claude-code";
import type { ContextReading } from "../types";

const contextState = {
  plugin: "frontend-skills-mods",
  key: "context",
} as const;
const skillState = {
  plugin: "frontend-skills-mods",
  key: "lastSkill",
} as const;

export const register: Register = (on) => {
  on("session.start", async ($, e, next) => {
    const result = await next(e);
    await readContext($);
    return result;
  });

  on("turn.complete", async ($, e, next) => {
    const result = await next(e);
    if (!e.agentId) await readContext($);
    return result;
  });

  on("tool.call", { tool: "Skill" }, async ($, e, next) => {
    const result = await next(e);
    if (
      !e.agentId &&
      !result.deny &&
      !result.isError &&
      result.result?.success
    ) {
      await $.state.set(skillState, e.skill);
    }
    return result;
  });

  on("ui.render", { component: "AbovePrompt" }, async ($, e, next) => {
    if (e.props.hasSurvey || e.props.bodyColumns < 32 || e.props.view.agentId) {
      return next(e);
    }
    const { value: usage } = await $.state.get(contextState);
    const { value: lastSkill } = await $.state.get(skillState);
    const context = usage ? `Context ${usage.percent}%` : "Context unavailable";
    const skill = lastSkill ? ` · Last skill ${lastSkill}` : "";
    const { Box, Text } = $.ui.resolve(e);
    return Box({
      flexDirection: "column",
      children: [
        await next(e),
        Text({
          dimColor: true,
          children: `${context}${skill}`.slice(0, e.props.bodyColumns),
        }),
      ],
    });
  });
};

async function readContext($: EngineInterface): Promise<void> {
  let context: ContextReading = null;
  try {
    const { context: usage } = await $.session.usage();
    if (usage.window > 0 && usage.tokens !== undefined) {
      const percent = usage.percent ?? (usage.tokens / usage.window) * 100;
      if (Number.isFinite(percent)) {
        context = {
          tokens: usage.tokens,
          window: usage.window,
          percent: Math.round(percent),
        };
      }
    }
  } catch {
    // Visible unavailable state replaces stale numbers; no tool/turn is denied.
    context = null;
  }
  await $.state.set(contextState, context);
}
