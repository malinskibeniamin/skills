import type {
  RenderPropsOf,
  ToolCallInput,
  TurnCompleteInput,
} from "claude-code";
import { describe, expect, test } from "claude-code/testing";

const bandProps: RenderPropsOf["AbovePrompt"] = {
  hasSurvey: false,
  isWorking: false,
  maxRows: 10,
  bodyColumns: 120,
  scroll: { offset: 0, bodyRows: 10 },
  view: {},
};
const completed: TurnCompleteInput = {
  reason: "answer",
  answer: "ok",
  durationMs: 1,
  isAborted: false,
  turnId: "turn-1",
};

describe("harness lens", () => {
  test("context updates after a main-loop turn on both surfaces", async ($, on) => {
    let tokens = 36_000;
    on("session.start", (_$, e) => ({ cwd: e.cwd }));
    on("command.register", (_$, e) => ({ value: { command: e.name } }));
    on("session.usage", () => ({
      value: {
        startedAt: 0,
        context: { tokens, window: 200_000, percent: tokens / 2_000 },
        rateLimits: [],
      },
    }));
    on("turn.complete", () => ({ text: "answer" }));
    on("ui.render", { component: "AbovePrompt" }, ($, e) => {
      const { Text } = $.ui.resolve(e);
      return Text({ children: "Host band" });
    });

    await $.session.start({
      surface: "terminal",
      isInteractive: true,
      cwd: "/work",
    });
    for (const surface of ["terminal", "desktop"] as const) {
      tokens = 36_000;
      await $.turn.complete(completed);
      const ui = await $.ui.mount({
        plugin: "frontend-skills-mods",
        surface,
        component: "AbovePrompt",
        props: bandProps,
      });
      expect(
        await ui.find({ type: "Text", text: /Context 18%/ }),
      ).toBeDefined();
      expect(await ui.find({ type: "Text", text: "Host band" })).toBeDefined();
      expect(await ui.drawn()).toMatchObject({
        type: "Box",
        props: { flexDirection: "column" },
      });
      tokens = 134_000;
      const result = await $.turn.complete(completed);
      expect(result).toEqual({ text: "answer" });
      expect(
        await ui.find({ type: "Text", text: /Context 67%/ }),
      ).toBeDefined();
      await ui.unmount();
    }
  });
  test("only successful main-loop Skill calls change the readout", async ($, on) => {
    on("session.start", (_$, e) => ({ cwd: e.cwd }));
    on("command.register", (_$, e) => ({ value: { command: e.name } }));
    on("session.usage", () => ({
      value: {
        startedAt: 0,
        context: { tokens: 20_000, window: 200_000 },
        rateLimits: [],
      },
    }));
    on("tool.call", { tool: "Skill" }, (_$, e) => {
      if (e.skill === "denied") return { deny: "User declined" };
      if (e.skill === "errored")
        return {
          isError: true,
          result: { success: true, commandName: e.skill },
        };
      return {
        result: { success: e.skill !== "missing", commandName: e.skill },
      };
    });
    on("ui.render", { component: "AbovePrompt" }, ($, e) =>
      $.ui.resolve(e).Text({ children: "Host band" }),
    );

    await $.session.start({
      surface: "terminal",
      isInteractive: true,
      cwd: "/work",
    });
    const ui = await $.ui.mount({
      plugin: "frontend-skills-mods",
      surface: "terminal",
      component: "AbovePrompt",
      props: bandProps,
    });
    const passed = await $.tool.call({
      tool: "Skill",
      skill: "frontend-skills:tdd",
    });
    expect(passed).toEqual({
      result: { success: true, commandName: "frontend-skills:tdd" },
    });
    expect(
      await ui.find({ type: "Text", text: /Last skill frontend-skills:tdd/ }),
    ).toBeDefined();
    const denied = await $.tool.call({ tool: "Skill", skill: "denied" });
    expect(denied).toEqual({ deny: "User declined" });
    await $.tool.call({ tool: "Skill", skill: "missing" });
    await $.tool.call({ tool: "Skill", skill: "errored" });
    const subagentCall: ToolCallInput = {
      tool: "Skill",
      skill: "subagent-skill",
      tool_use_id: "tool-1",
      agentId: "worker",
    };
    await $.tool.call(subagentCall);
    expect(
      await ui.find({ type: "Text", text: /Last skill frontend-skills:tdd/ }),
    ).toBeDefined();
    // Repeated session.start must retain the observed skill in host-owned state.
    await $.session.start({
      surface: "terminal",
      isInteractive: true,
      cwd: "/work",
    });
    expect(
      await ui.find({ type: "Text", text: /Last skill frontend-skills:tdd/ }),
    ).toBeDefined();
    await ui.unmount();
  });

  test("unavailable usage replaces stale context and recovers", async ($, on) => {
    let available = true;
    let tokens: number | undefined = 40_000;
    on("session.start", (_$, e) => ({ cwd: e.cwd }));
    on("command.register", (_$, e) => ({ value: { command: e.name } }));
    on("session.usage", () =>
      available
        ? {
            value: {
              startedAt: 0,
              context: { tokens, window: 200_000 },
              rateLimits: [],
            },
          }
        : { deny: "Usage unavailable" },
    );
    on("turn.complete", () => ({ text: "answer" }));
    on("ui.render", { component: "AbovePrompt" }, ($, e) =>
      $.ui.resolve(e).Text({ children: "Host band" }),
    );
    await $.session.start({
      surface: "terminal",
      isInteractive: true,
      cwd: "/work",
    });
    const ui = await $.ui.mount({
      plugin: "frontend-skills-mods",
      surface: "terminal",
      component: "AbovePrompt",
      props: bandProps,
    });
    expect(await ui.find({ type: "Text", text: "Context 20%" })).toBeDefined();
    tokens = 160_000;
    await $.turn.complete({ ...completed, agentId: "worker" });
    expect(await ui.find({ type: "Text", text: "Context 20%" })).toBeDefined();
    available = false;
    expect(await $.turn.complete(completed)).toEqual({ text: "answer" });
    expect(
      await ui.find({ type: "Text", text: "Context unavailable" }),
    ).toBeDefined();
    available = true;
    tokens = undefined;
    await $.turn.complete(completed);
    expect(
      await ui.find({ type: "Text", text: "Context unavailable" }),
    ).toBeDefined();
    tokens = 160_000;
    await $.turn.complete(completed);
    expect(await ui.find({ type: "Text", text: "Context 80%" })).toBeDefined();
    await ui.unmount();
  });

  test("surveys, narrow bands and agent views keep the downstream drawing unchanged", async ($, on) => {
    on("ui.render", { component: "AbovePrompt" }, ($, e) =>
      $.ui.resolve(e).Text({ children: "Host band" }),
    );
    for (const props of [
      { ...bandProps, hasSurvey: true },
      { ...bandProps, bodyColumns: 31 },
      { ...bandProps, view: { agentId: "worker" } },
    ]) {
      const ui = await $.ui.mount({
        plugin: "frontend-skills-mods",
        surface: "terminal",
        component: "AbovePrompt",
        props,
      });
      expect(await ui.drawn()).toEqual({
        type: "Text",
        children: ["Host band"],
      });
      await ui.unmount();
    }
  });

  test("a context refresh retains skills observed while usage is pending", async ($, on) => {
    let releaseUsage: (() => void) | undefined;
    let usageRequested: (() => void) | undefined;
    const usagePending = new Promise<void>((resolve) => {
      releaseUsage = resolve;
    });
    const usageStarted = new Promise<void>((resolve) => {
      usageRequested = resolve;
    });
    on("session.usage", async () => {
      usageRequested?.();
      await usagePending;
      return {
        value: {
          startedAt: 0,
          context: { tokens: 40_000, window: 200_000 },
          rateLimits: [],
        },
      };
    });
    on("turn.complete", () => ({ text: "answer" }));
    on("tool.call", { tool: "Skill" }, (_$, e) => ({
      result: { success: true, commandName: e.skill },
    }));
    on("ui.render", { component: "AbovePrompt" }, ($, e) =>
      $.ui.resolve(e).Text({ children: "Host band" }),
    );
    const refresh = $.turn.complete(completed);
    await usageStarted;
    await $.tool.call({ tool: "Skill", skill: "frontend-skills:review" });
    releaseUsage?.();
    await refresh;
    const ui = await $.ui.mount({
      plugin: "frontend-skills-mods",
      surface: "terminal",
      component: "AbovePrompt",
      props: bandProps,
    });
    expect(
      await ui.find({
        type: "Text",
        text: "Context 20% · Last skill frontend-skills:review",
      }),
    ).toBeDefined();
    await ui.unmount();
  });
});
