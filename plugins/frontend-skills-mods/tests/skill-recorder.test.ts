import type { ToolCallInput, ToolCallResult } from "claude-code";
import { describe, expect, test } from "claude-code/testing";
import { deskFixture, paneProps } from "./fixtures/desk";

describe("skill flight recorder", () => {
  test("records actual Skill outcomes and provenance without arguments or result text", async ($, on) => {
    deskFixture(on);
    on("tool.call", { tool: "Skill" }, (_$, e): ToolCallResult<"Skill"> => {
      if (e.skill === "denied") return { deny: "secret denial" };
      if (e.skill === "failed")
        return { isError: true, result: "secret error" };
      if (e.skill === "fork")
        return {
          result: {
            success: true,
            commandName: "resolved-fork",
            status: "forked",
            agentId: "child",
            result: "secret result",
            background: true,
          },
        };
      return {
        result: {
          success: e.skill !== "invalid",
          commandName: e.skill,
          readOnly: e.skill === "read-only",
        },
      };
    });
    const fork = await $.tool.call({
      tool: "Skill",
      skill: "fork",
      args: "secret args",
    });
    expect(fork).toMatchObject({
      result: { commandName: "resolved-fork", background: true },
    });
    for (const skill of ["denied", "failed", "invalid", "read-only"]) {
      await $.tool.call({ tool: "Skill", skill });
    }
    const worker: ToolCallInput = {
      tool: "Skill",
      skill: "worker-skill",
      tool_use_id: "worker-call",
      agentId: "worker",
    };
    await $.tool.call(worker);
    const result = await $.command.run({
      command: "harness",
      args: "skills",
      origin: { kind: "composer" },
      presentation: { isFullscreen: true, columns: 120 },
    });
    expect(result.text).toContain(
      "resolved-fork · forked (launched; outcome unknown) · main",
    );
    expect(result.text).toContain("denied · denied");
    expect(result.text).toContain("failed · failed");
    expect(result.text).toContain("invalid · failed");
    expect(result.text).toContain("read-only · loaded read-only");
    expect(result.text).toContain("worker-skill · succeeded · agent worker");
    expect(result.text).not.toContain("secret");
    const ui = await $.ui.mount({
      plugin: "frontend-skills-mods",
      surface: "desktop",
      component: "Pane",
      requestId: "harness",
      props: paneProps,
    });
    await ui.press({ key: "clear-skills" });
    expect(
      await ui.find({ type: "Text", text: /No Skill calls observed/ }),
    ).toBeDefined();
    await ui.unmount();
  });

  test("retains only the latest 24 completions and concurrent calls do not erase each other", async ($, on) => {
    deskFixture(on);
    let release = () => {};
    let entered = () => {};
    const pending = new Promise<void>((resolve) => {
      release = resolve;
    });
    const started = new Promise<void>((resolve) => {
      entered = resolve;
    });
    on("tool.call", { tool: "Skill" }, async (_$, e) => {
      if (e.skill === "delayed") {
        entered();
        await pending;
      }
      return { result: { success: true, commandName: e.skill } };
    });
    const delayed = $.tool.call({ tool: "Skill", skill: "delayed" });
    await started;
    await $.tool.call({ tool: "Skill", skill: "fast" });
    release();
    await delayed;
    const skills = () =>
      $.command.run({
        command: "harness",
        args: "skills",
        origin: { kind: "composer" },
        presentation: { isFullscreen: true, columns: 120 },
      });
    const both = (await skills()).text;
    expect(both).toContain("fast · succeeded");
    expect(both).toContain("delayed · succeeded");
    for (let i = 0; i < 24; i++)
      await $.tool.call({ tool: "Skill", skill: `skill-${i}` });
    const bounded = (await skills()).text;
    expect(bounded).not.toContain("fast ·");
    expect(bounded).not.toContain("delayed ·");
    expect(bounded).toContain("skill-0 · succeeded");
    expect(bounded).toContain("skill-23 · succeeded");
  });
  test("clearing history prevents an earlier in-flight call repopulating it", async ($, on) => {
    deskFixture(on);
    let entered = () => {};
    let release = () => {};
    const started = new Promise<void>((resolve) => {
      entered = resolve;
    });
    const pending = new Promise<void>((resolve) => {
      release = resolve;
    });
    on("tool.call", { tool: "Skill" }, async (_$, e) => {
      entered();
      await pending;
      return { result: { success: true, commandName: e.skill } };
    });
    await $.command.run({
      command: "harness",
      args: "skills",
      origin: { kind: "composer" },
      presentation: { isFullscreen: true, columns: 120 },
    });
    const ui = await $.ui.mount({
      plugin: "frontend-skills-mods",
      surface: "terminal",
      component: "Pane",
      requestId: "harness",
      props: paneProps,
    });
    const flight = $.tool.call({ tool: "Skill", skill: "slow" });
    await started;
    await ui.press({ key: "clear-skills" });
    release();
    await flight;
    expect(
      await ui.find({ type: "Text", text: /No Skill calls observed/ }),
    ).toBeDefined();
    await ui.unmount();
  });
});
