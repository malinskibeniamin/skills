import type { ToolResultOf } from "claude-code";
import { describe, expect, test } from "claude-code/testing";
import { deskFixture, paneProps } from "./fixtures/desk";

describe("harness desk", () => {
  test("native proof command exposes missing evidence without a model turn", async ($, on) => {
    const { commands, opened } = deskFixture(on);
    on("ui.render", { component: "Pane" }, ($, e) =>
      $.ui.resolve(e).Text({ children: "Host pane" }),
    );
    await $.session.start({
      surface: "terminal",
      isInteractive: true,
      cwd: "/work",
    });
    expect(commands).toContain("harness");
    const result = await $.command.run({
      command: "harness",
      args: "proof",
      origin: { kind: "composer" },
      presentation: { isFullscreen: true, columns: 120 },
    });
    expect(result.text).toContain("Types: missing");
    expect(result.text).toContain("Visual: missing");
    expect(opened).toEqual(["harness"]);
    const ui = await $.ui.mount({
      plugin: "frontend-skills-mods",
      surface: "terminal",
      component: "Pane",
      requestId: "harness",
      props: paneProps,
    });
    expect(
      await ui.find({ type: "Text", text: /Types: missing/ }),
    ).toBeDefined();
    await ui.unmount();
  });
  test("proof receipts follow the observed outcome and become stale or unverified", async ($, on) => {
    const { git } = deskFixture(on);
    on("tool.call", { tool: "Bash" }, (_$, e) => {
      if (e.command === "bun run lint") return { deny: "" };
      if (e.command === "bun run test")
        return { isError: true, result: "tests failed" };
      return { result: { stdout: "ok", stderr: "", interrupted: false } };
    });
    const proof = () =>
      $.command.run({
        command: "harness",
        args: "proof",
        origin: { kind: "composer" },
        presentation: { isFullscreen: true, columns: 120 },
      });
    const passed = await $.tool.call({
      tool: "Bash",
      command: "bun run type:check",
    });
    expect(passed).toEqual({
      result: { stdout: "ok", stderr: "", interrupted: false },
    });
    expect((await proof()).text).toContain("Types: passed");
    git.hash = "b".repeat(40);
    expect((await proof()).text).toContain("Types: stale (passed)");
    git.available = false;
    expect((await proof()).text).toContain("Types: unverified (passed)");
    await $.tool.call({ tool: "Bash", command: "bun run lint" });
    await $.tool.call({ tool: "Bash", command: "bun run test" });
    await $.tool.call({
      tool: "Bash",
      command: "bun run test:mods && echo ok",
    });
    const text = (await proof()).text;
    expect(text).toContain("Lint: denied");
    expect(text).toContain("Tests: failed");
    expect(text).toContain("Mod tests: missing");
  });

  test("proof never reports a thrown or interrupted check as passed", async ($, on) => {
    const { git } = deskFixture(on);
    let mode = "throw";
    let incomplete: Partial<ToolResultOf<"Bash">> = {};
    on("tool.call", { tool: "Bash" }, () => {
      if (mode === "throw") throw new Error("check transport failed");
      if (mode === "changed") git.hash = "c".repeat(40);
      return {
        result: { stdout: "", stderr: "", interrupted: false, ...incomplete },
      };
    });
    const proof = () =>
      $.command.run({
        command: "harness",
        args: "proof",
        origin: { kind: "composer" },
        presentation: { isFullscreen: true, columns: 120 },
      });
    await expect(
      $.tool.call({ tool: "Bash", command: "bun run type:check" }),
    ).rejects.toThrow("no implementation for tool.call");
    expect((await proof()).text).toContain("Types: incomplete");
    mode = "incomplete";
    for (const flags of [
      { interrupted: true },
      { backgroundTaskId: "" },
      { backgroundedByUser: true },
      { backgroundedByTurnAbort: true },
      { backgroundedToDeliverMessage: true },
      { timedOutAfterMs: 0 },
      { returnCodeInterpretation: "" },
    ]) {
      incomplete = flags;
      await $.tool.call({ tool: "Bash", command: "bun run test" });
      expect((await proof()).text).toContain("Tests: incomplete");
    }
    mode = "changed";
    incomplete = {};
    await $.tool.call({ tool: "Bash", command: "bun run lint:fix" });
    expect((await proof()).text).toContain(
      "Lint: stale (passed; files changed during check)",
    );
  });

  test("latest started check wins when an older check finishes afterward", async ($, on) => {
    deskFixture(on);
    let release = () => {};
    let started = () => {};
    const pending = new Promise<void>((resolve) => {
      release = resolve;
    });
    const entered = new Promise<void>((resolve) => {
      started = resolve;
    });
    on("tool.call", { tool: "Bash" }, async (_$, e) => {
      if (e.tool_use_id === "older") {
        started();
        await pending;
      }
      if (e.tool_use_id === "newer") return { isError: true, result: "failed" };
      return { result: { stdout: "", stderr: "", interrupted: false } };
    });
    const older = $.tool.call({
      tool: "Bash",
      command: "bun run test",
      tool_use_id: "older",
    });
    await entered;
    await $.tool.call({
      tool: "Bash",
      command: "bun run test",
      tool_use_id: "newer",
    });
    release();
    await older;
    const proof = await $.command.run({
      command: "harness",
      args: "proof",
      origin: { kind: "composer" },
      presentation: { isFullscreen: true, columns: 120 },
    });
    expect(proof.text).toContain("Tests: failed");
  });
  test("proof fails visibly closed on unsafe or oversized comparison inputs", async ($, on) => {
    const { git } = deskFixture(on);
    on("tool.call", { tool: "Bash" }, () => ({
      result: { stdout: "ok", stderr: "", interrupted: false },
    }));
    await $.tool.call({ tool: "Bash", command: "bun run type:check" });
    const proof = () =>
      $.command.run({
        command: "harness",
        args: "proof",
        origin: { kind: "composer" },
        presentation: { isFullscreen: true, columns: 120 },
      });
    for (const invalid of [
      "truncated",
      "symlink",
      "oversized",
      "too-many-files",
    ]) {
      git.truncated = invalid === "truncated";
      git.isLink = invalid === "symlink";
      git.size = invalid === "oversized" ? 5 * 1024 * 1024 : 100;
      git.fileCount = invalid === "too-many-files" ? 201 : 1;
      expect((await proof()).text).toContain("Types: unverified (passed)");
    }
    git.fileCount = 1;
    expect((await proof()).text).toContain("Types: passed");
    git.untracked = true;
    expect((await proof()).text).toContain("Types: stale (passed)");
  });

  test("unknown tools invalidate comparison; background and agent checks cannot overwrite main evidence", async ($, on) => {
    deskFixture(on);
    on("tool.call", { tool: "Bash" }, (_$, e) =>
      e.agentId || e.run_in_background
        ? { isError: true, result: "not a main foreground check" }
        : { result: { stdout: "ok", stderr: "", interrupted: false } },
    );
    await $.tool.call({ tool: "Bash", command: "bun run type:check" });
    await $.command.run({
      command: "harness",
      args: "proof",
      origin: { kind: "composer" },
      presentation: { isFullscreen: true, columns: 120 },
    });
    const ui = await $.ui.mount({
      plugin: "frontend-skills-mods",
      surface: "desktop",
      component: "Pane",
      requestId: "harness",
      props: paneProps,
    });
    expect(
      await ui.find({ type: "Text", text: /Types: passed/ }),
    ).toBeDefined();
    await $.tool.call({ tool: "Bash", command: "git status" });
    expect(
      await ui.find({ type: "Text", text: /Types: unverified \(passed\)/ }),
    ).toBeDefined();
    await $.tool.call({
      tool: "Bash",
      command: "bun run type:check",
      run_in_background: true,
    });
    const worker: import("claude-code").ToolCallInput = {
      tool: "Bash",
      command: "bun run type:check",
      agentId: "worker",
      tool_use_id: "worker",
    };
    await $.tool.call(worker);
    await $.tool.call({ tool: "Bash", command: "__proto__" });
    await ui.press({ key: "refresh" });
    expect(
      await ui.find({ type: "Text", text: /Types: passed/ }),
    ).toBeDefined();
    await ui.unmount();
  });
});
