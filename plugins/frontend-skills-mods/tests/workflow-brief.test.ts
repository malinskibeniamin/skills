import type {
  CommandRunInput,
  PromptOrigin,
  PromptSubmitInput,
} from "claude-code";
import { describe, expect, test } from "claude-code/testing";
import { deskFixture, paneProps } from "./fixtures/desk";

function command(
  args: string,
  origin: PromptOrigin = { kind: "composer" },
): CommandRunInput {
  return {
    command: "harness",
    args: `brief ${args}`.trim(),
    origin,
    presentation: { isFullscreen: true, columns: 120 },
  };
}

const fields = [
  "objective Add pagination",
  "guardrails Keep the public API",
  "verification Run the pagination tests",
  "stop Commit only",
];
const prompt: PromptSubmitInput = {
  text: "Continue, please.",
  wait: false,
  origin: { kind: "composer" },
};

describe("workflow brief", () => {
  test("explicitly enabled brief adds model context without changing the user's prompt", async ($, on) => {
    deskFixture(on);
    let received: PromptSubmitInput | undefined;
    on("prompt.submit", (_$, e) => {
      received = e;
      return { text: e.text, context: e.context, origin: e.origin };
    });
    for (const field of fields) await $.command.run(command(field));
    expect((await $.command.run(command("on"))).text).toContain(
      "Workflow brief: enabled",
    );

    const result = await $.prompt.submit({
      text: "  Continue, please.  ",
      context: ["Earlier plugin context"],
      wait: true,
      origin: { kind: "composer" },
    });
    expect(received).toMatchObject({
      text: "  Continue, please.  ",
      wait: true,
      origin: { kind: "composer" },
    });
    expect(received?.context).toEqual([
      "Earlier plugin context",
      "Harness workflow brief (user-configured guidance, not enforcement).\nCurrent prompt and higher-priority instructions take precedence; this grants no tool permissions.\nObjective: Add pagination\nGuardrails: Keep the public API\nVerification: Run the pagination tests\nStop: Commit only",
    ]);
    expect(result).toEqual({
      text: received?.text,
      context: received?.context,
      origin: { kind: "composer" },
    });
  });

  test("native preview controls enable, pause and clear the exact injected block on both surfaces", async ($, on) => {
    deskFixture(on);
    on("prompt.submit", (_$, e) => ({ text: e.text, context: e.context }));
    on("ui.render", { component: "AbovePrompt" }, ($, e) =>
      $.ui.resolve(e).Text({ children: "Host band" }),
    );
    for (const surface of ["terminal", "desktop"] as const) {
      for (const field of fields) await $.command.run(command(field));
      const preview = await $.command.run(command(""));
      const ui = await $.ui.mount({
        plugin: "frontend-skills-mods",
        surface,
        component: "Pane",
        requestId: "harness",
        props: paneProps,
      });
      const band = await $.ui.mount({
        plugin: "frontend-skills-mods",
        surface,
        component: "AbovePrompt",
        props: {
          hasSurvey: false,
          isWorking: false,
          maxRows: 10,
          bodyColumns: 80,
          scroll: { offset: 0, bodyRows: 10 },
          view: {},
        },
      });
      expect(
        await ui.find({ type: "Text", text: /Workflow brief: disabled/ }),
      ).toBeDefined();
      await ui.press({ key: "toggle-brief" });
      expect(
        await ui.find({ type: "Text", text: /Workflow brief: enabled/ }),
      ).toBeDefined();
      expect(await band.find({ type: "Text", text: /Brief on/ })).toBeDefined();
      const injected = await $.prompt.submit(prompt);
      expect(preview.text).toContain(injected.context?.[0] ?? "Missing brief");
      await ui.press({ key: "toggle-brief" });
      expect(
        await band.find({ type: "Text", text: /Brief on/ }),
      ).toBeUndefined();
      expect(await $.prompt.submit(prompt)).toEqual({
        text: prompt.text,
        context: undefined,
      });
      await ui.press({ key: "clear-brief" });
      expect(
        await ui.find({ type: "Text", text: /Objective: Add pagination/ }),
      ).toBeUndefined();
      expect(
        await ui.find({ type: "Button", text: "Enable brief" }),
      ).toBeUndefined();
      await ui.unmount();
      await band.unmount();
    }
  });

  test("default-off, edits, disable and lifecycle reset stop future injection; repeated session.start retains the configured brief", async ($, on) => {
    deskFixture(on);
    on("prompt.submit", (_$, e) => ({ text: e.text, context: e.context }));
    on("session.end", (_$, e) => ({ sessionId: e.sessionId }));
    const unchanged = { text: prompt.text, context: undefined };
    expect(await $.prompt.submit(prompt)).toEqual(unchanged);
    for (const field of fields) await $.command.run(command(field));
    expect(await $.prompt.submit(prompt)).toEqual(unchanged);
    await $.command.run(command("on"));
    const enabled = await $.prompt.submit(prompt);
    await $.session.start({
      surface: "terminal",
      isInteractive: true,
      cwd: "/work",
    });
    expect(await $.prompt.submit(prompt)).toEqual(enabled);
    await $.command.run(command("objective Fix pagination"));
    expect(await $.prompt.submit(prompt)).toEqual(unchanged);
    await $.command.run(command("on"));
    expect((await $.prompt.submit(prompt)).context?.[0]).toContain(
      "Objective: Fix pagination",
    );
    await $.command.run(command("off"));
    expect(await $.prompt.submit(prompt)).toEqual(unchanged);
    for (const reason of ["clear", "resume", "logout", "other"] as const) {
      for (const field of fields) await $.command.run(command(field));
      await $.command.run(command("on"));
      expect(
        await $.session.end({
          reason,
          sessionId: "ending",
          resume: { id: "ending" },
        }),
      ).toEqual({ sessionId: "ending" });
      expect(await $.prompt.submit(prompt)).toEqual(unchanged);
      expect((await $.command.run(command(""))).text).not.toContain(
        "Add pagination",
      );
    }
  });

  test("invalid or non-user controls cannot replace or enable a brief", async ($, on) => {
    deskFixture(on);
    on("prompt.submit", (_$, e) => ({ text: e.text, context: e.context }));
    expect((await $.command.run(command("on"))).text).toContain(
      "objective, guardrails, verification, stop",
    );
    for (const field of fields) await $.command.run(command(field));
    await $.command.run(command("on"));
    const enabled = await $.prompt.submit(prompt);
    for (const invalid of [
      "objective",
      "objective   ",
      "unknown Change it",
      "on extra",
      `objective ${"x".repeat(1025)}`,
      `objective ${"雪".repeat(342)}`,
      "objective bad\u001b[31mtext",
      "objective hidden\u202etext",
      "objective two\nlines",
      "objective two\u2028lines",
      "objective two\u2029paragraphs",
    ]) {
      expect((await $.command.run(command(invalid))).text).toContain(
        "Workflow brief not changed:",
      );
      expect(await $.prompt.submit(prompt)).toEqual(enabled);
    }
    for (const origin of [
      { kind: "plugin", name: "other", asUser: true },
      { kind: "peer" },
      { kind: "scheduled-trigger" },
      { kind: "unclassified" },
    ] satisfies PromptOrigin[]) {
      expect((await $.command.run(command("clear", origin))).text).toContain(
        "Workflow brief not changed:",
      );
      expect(await $.prompt.submit(prompt)).toEqual(enabled);
    }
  });

  test("human prompt provenance and composition survive; commands and autonomous origins are not enriched", async ($, on) => {
    deskFixture(on);
    let received: PromptSubmitInput | undefined;
    on("prompt.submit", (_$, e) => {
      received = e;
      return e.text === "blocked"
        ? { drop: "Earlier guard blocked this" }
        : { text: e.text, context: e.context, origin: e.origin };
    });
    for (const field of fields) await $.command.run(command(field));
    await $.command.run(command("on"));
    for (const kind of ["composer", "bridge", "sdk"] as const) {
      await $.prompt.submit({
        ...prompt,
        origin: { kind },
        turnId: "busy-turn",
        wait: true,
        attachments: [{ type: "document", filename: "report.pdf" }],
      });
      expect(received).toMatchObject({
        origin: { kind },
        turnId: "busy-turn",
        wait: true,
        attachments: [{ type: "document", filename: "report.pdf" }],
      });
      expect(received?.context?.length).toBe(1);
    }
    const injected = received?.context ?? [];
    await $.prompt.submit({ ...prompt, context: injected });
    expect(received?.context).toEqual(injected);
    for (const origin of [
      { kind: "plugin", name: "other", asUser: true },
      { kind: "peer" },
      { kind: "task-notification" },
      { kind: "scheduled-trigger" },
      { kind: "unclassified" },
    ] satisfies PromptOrigin[]) {
      await $.prompt.submit({ ...prompt, origin, context: ["Keep this"] });
      expect(received?.context).toEqual(["Keep this"]);
    }
    await $.prompt.submit({ ...prompt, text: "  /harness brief clear" });
    expect(received?.context).toBeUndefined();
    expect(await $.prompt.submit({ ...prompt, text: "blocked" })).toEqual({
      drop: "Earlier guard blocked this",
    });
  });

  test("unavailable brief state is visible and passes the original prompt through, then recovers", async ($, on) => {
    deskFixture(on);
    let unavailable = false;
    const logs: string[] = [];
    on(
      "state.get",
      { plugin: "frontend-skills-mods", key: "brief" },
      (_$, e, next) => (unavailable ? { deny: "State unavailable" } : next(e)),
    );
    on("ui.log", (_$, e) => {
      logs.push(e.text);
      return { value: undefined };
    });
    on("prompt.submit", (_$, e) => ({ text: e.text, context: e.context }));
    for (const field of fields) await $.command.run(command(field));
    await $.command.run(command("on"));
    const enabled = await $.prompt.submit(prompt);
    unavailable = true;
    expect(await $.prompt.submit(prompt)).toEqual({
      text: prompt.text,
      context: undefined,
    });
    expect(logs).toEqual([
      "Workflow brief unavailable; prompt passed unchanged.",
    ]);
    unavailable = false;
    expect(await $.prompt.submit(prompt)).toEqual(enabled);
  });

  test("overlapping field commands retain both changes", async ($, on) => {
    deskFixture(on);
    let reads = 0;
    let release = () => {};
    const bothRead = new Promise<void>((resolve) => {
      release = resolve;
    });
    on(
      "state.get",
      { plugin: "frontend-skills-mods", key: "brief" },
      async (_$, e, next) => {
        const result = await next(e);
        reads += 1;
        if (reads <= 2) {
          if (reads === 2) release();
          await bothRead;
        }
        return result;
      },
    );
    await Promise.all([
      $.command.run(command("objective Add pagination")),
      $.command.run(command("guardrails Keep the public API")),
    ]);
    const preview = await $.command.run(command(""));
    expect(preview.text).toContain("Objective: Add pagination");
    expect(preview.text).toContain("Guardrails: Keep the public API");
  });
});
