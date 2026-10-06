import type { ToolCallInput, ToolCallResult } from "claude-code";
import { describe, expect, test } from "claude-code/testing";
import { deskFixture, paneProps } from "./fixtures/desk";

const patch = [
  {
    oldStart: 1,
    oldLines: 1,
    newStart: 1,
    newLines: 1,
    lines: ["-before", "+owner accepted"],
  },
];

describe("edit replay", () => {
  test("replays returned successful patches, not attempted, denied, failed or staged edits", async ($, on) => {
    deskFixture(on);
    on("turn.start", (_$, e) => ({ turnId: e.turnId }));
    on("tool.call", { tool: "Edit" }, (_$, e): ToolCallResult<"Edit"> => {
      if (e.file_path === "/work/denied.ts") return { deny: "owner declined" };
      if (e.file_path === "/work/failed.ts")
        return { isError: true, result: "failed" };
      return {
        result: {
          filePath: e.file_path,
          oldString: "before",
          newString: "owner accepted",
          originalFile: "do not retain original",
          structuredPatch: patch,
          userModified: true,
          replaceAll: false,
          staged: e.file_path === "/work/staged.ts",
        },
      };
    });
    on("tool.call", { tool: "Write" }, (_$, e) => ({
      result: {
        type: "create",
        filePath: e.file_path,
        content: "never retain full content",
        originalFile: null,
        structuredPatch: [],
      },
    }));
    await $.turn.start({ turnId: "turn-1", text: "never retain user prompt" });
    for (const name of ["accepted", "denied", "failed", "staged"])
      await $.tool.call({
        tool: "Edit",
        file_path: `/work/${name}.ts`,
        old_string: "before",
        new_string: "attempted change",
      });
    const writer: ToolCallInput = {
      tool: "Write",
      file_path: "/work/worker.ts",
      content: "attempted content",
      tool_use_id: "write-1",
      agentId: "worker",
    };
    await $.tool.call(writer);
    const result = await $.command.run({
      command: "harness",
      args: "replay",
      origin: { kind: "composer" },
      presentation: { isFullscreen: true, columns: 120 },
    });
    expect(result.text).toContain("Edit 2/2");
    expect(result.text).toContain("agent worker");
    expect(result.text).toContain("turn turn-1");
    expect(result.text).toContain("Diff unavailable");
    expect(result.text).not.toContain("attempted");
    const ui = await $.ui.mount({
      plugin: "frontend-skills-mods",
      surface: "terminal",
      component: "Pane",
      requestId: "harness",
      props: paneProps,
    });
    await ui.press({ key: "previous" });
    expect(
      await ui.find({
        type: "Text",
        text: /Edit 1\/2.*accepted\.ts[\s\S]*\+owner accepted/,
      }),
    ).toBeDefined();
    expect(
      await ui.find({
        type: "Text",
        text: /never retain|do not retain|attempted change/,
      }),
    ).toBeUndefined();
    await ui.press({ key: "next" });
    expect(await ui.find({ type: "Text", text: /Edit 2\/2/ })).toBeDefined();
    await ui.press({ key: "clear-replay" });
    expect(
      await ui.find({ type: "Text", text: /No successful edits observed/ }),
    ).toBeDefined();
    await ui.unmount();
  });
  test("excludes sensitive paths and recognizable secrets without retaining their details", async ($, on) => {
    deskFixture(on);
    on("tool.call", { tool: "Write" }, (_$, e) => ({
      result: {
        type: "create",
        filePath: e.file_path,
        content: e.content,
        originalFile: null,
        structuredPatch: [
          {
            oldStart: 0,
            oldLines: 0,
            newStart: 1,
            newLines: 1,
            lines: [`+${e.content}`],
          },
        ],
      },
    }));
    for (const file_path of [
      "/work/.env.local",
      "/work/.ssh/id_ed25519",
      "/work/credentials.json",
      "/work/server.pem",
    ]) {
      await $.tool.call({ tool: "Write", file_path, content: "private value" });
    }
    await $.tool.call({
      tool: "Write",
      file_path: "/work/app.ts",
      content: 'api_key = "example-sensitive-key"',
    });
    const result = await $.command.run({
      command: "harness",
      args: "replay",
      origin: { kind: "composer" },
      presentation: { isFullscreen: true, columns: 120 },
    });
    expect(result.text).toContain("Excluded sensitive edits: 5");
    expect(result.text).not.toContain("private value");
    expect(result.text).not.toContain("example-sensitive-key");
    expect(result.text).not.toContain(".env.local");
  });

  test("bounds replay count and UTF-8 retention, labels truncated patches", async ($, on) => {
    deskFixture(on);
    on("tool.call", { tool: "Write" }, (_$, e) => ({
      result: {
        type: "create",
        filePath: e.file_path,
        content: e.content,
        originalFile: null,
        structuredPatch: [
          {
            oldStart: 0,
            oldLines: 0,
            newStart: 1,
            newLines: 1,
            lines: [`+${e.content}`],
          },
        ],
      },
    }));
    const replay = () =>
      $.command.run({
        command: "harness",
        args: "replay",
        origin: { kind: "composer" },
        presentation: { isFullscreen: true, columns: 120 },
      });
    for (let i = 0; i < 21; i++)
      await $.tool.call({
        tool: "Write",
        file_path: `/work/file-${i}.ts`,
        content: "small",
      });
    expect((await replay()).text).toContain("Edit 20/20");
    const ui = await $.ui.mount({
      plugin: "frontend-skills-mods",
      surface: "terminal",
      component: "Pane",
      requestId: "harness",
      props: paneProps,
    });
    await ui.press({ key: "clear-replay" });
    await $.tool.call({
      tool: "Write",
      file_path: "/work/large.ts",
      content: "界".repeat(20_000),
    });
    expect((await replay()).text).toContain("Patch truncated");
    expect(new TextEncoder().encode((await replay()).text).length).toBeLessThan(
      9000,
    );
    for (let i = 0; i < 10; i++)
      await $.tool.call({
        tool: "Write",
        file_path: `/work/big-${i}.ts`,
        content: "x".repeat(10_000),
      });
    // Count is below 20: aggregate byte cap, not merely count cap, evicts oldest diffs.
    const count = Number(
      ((await replay()).text ?? "").match(/^Edit (\d+)\//)?.[1],
    );
    expect(count).toBeLessThan(9);
    expect(count).toBeGreaterThan(1);
    await ui.unmount();
  });

  test("clear cancels in-flight retention; overlapping completions preserve both edits and their starting turn", async ($, on) => {
    deskFixture(on);
    on("turn.start", (_$, e) => ({ turnId: e.turnId }));
    let release = () => {};
    let entered = () => {};
    let pending = Promise.resolve();
    let started = Promise.resolve();
    const delay = () => {
      pending = new Promise<void>((resolve) => {
        release = resolve;
      });
      started = new Promise<void>((resolve) => {
        entered = resolve;
      });
    };
    on("tool.call", { tool: "Write" }, async (_$, e) => {
      if (e.file_path === "/work/delayed.ts") {
        entered();
        await pending;
      }
      return {
        result: {
          type: "create",
          filePath: e.file_path,
          content: e.content,
          originalFile: null,
          structuredPatch: patch,
        },
      };
    });
    const replay = () =>
      $.command.run({
        command: "harness",
        args: "replay",
        origin: { kind: "composer" },
        presentation: { isFullscreen: true, columns: 120 },
      });
    await replay();
    const ui = await $.ui.mount({
      plugin: "frontend-skills-mods",
      surface: "desktop",
      component: "Pane",
      requestId: "harness",
      props: paneProps,
    });
    delay();
    const cleared = $.tool.call({
      tool: "Write",
      file_path: "/work/delayed.ts",
      content: "x",
    });
    await started;
    await ui.press({ key: "clear-replay" });
    release();
    await cleared;
    expect((await replay()).text).toContain("No successful edits observed");
    delay();
    await $.turn.start({ turnId: "turn-before", text: "private prompt" });
    const delayed = $.tool.call({
      tool: "Write",
      file_path: "/work/delayed.ts",
      content: "x",
    });
    await started;
    await $.turn.start({ turnId: "turn-after", text: "private prompt" });
    await $.tool.call({
      tool: "Write",
      file_path: "/work/fast.ts",
      content: "x",
    });
    release();
    await delayed;
    expect((await replay()).text).toContain("Edit 2/2");
    expect((await replay()).text).toContain("turn turn-before");
    await ui.press({ key: "previous" });
    expect(
      await ui.find({ type: "Text", text: /fast\.ts[\s\S]*turn turn-after/ }),
    ).toBeDefined();
    await ui.unmount();
  });
});
