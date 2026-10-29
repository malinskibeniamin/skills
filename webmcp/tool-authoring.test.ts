import { expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { runInNewContext } from "node:vm";
import { z } from "zod";

const errorResult = z.object({
  isError: z.literal(true),
  content: z.array(z.object({ type: z.literal("text"), text: z.string() })),
});

interface Wall {
  id: string;
}

interface Execution {
  signal: AbortSignal;
}

interface WallTool {
  name: string;
  execute: (args: { metres: number }, context: Execution) => Promise<unknown>;
}

interface Registry {
  registerTool: (tool: WallTool, options: Execution) => Promise<void>;
}

interface Examples {
  ToolFailure: new (
    code: string,
    message: string,
    details?: Record<string, unknown>,
  ) => Error;
  safeExecute: (
    run: (args: unknown, context: Execution) => unknown,
  ) => (args: unknown, context: Execution) => Promise<unknown>;
  registerSelectedWall: (
    context: Registry,
    state: { getSelectedWall: () => Wall | null },
    extendWall: (id: string, metres: number, context: Execution) => unknown,
  ) => Promise<() => void>;
}

function examples(): Examples {
  const reference = readFileSync(
    new URL("./references/tool-authoring.md", import.meta.url),
    "utf8",
  );
  const snippets = [...reference.matchAll(/```js\n([\s\S]*?)\n```/g)].map(
    (match) => match[1],
  );
  return runInNewContext(
    `${snippets.join("\n")}\n({ ToolFailure, safeExecute, registerSelectedWall })`,
    { AbortController, Error, Number },
  );
}

const execution = { signal: new AbortController().signal };

function payload(result: unknown): unknown {
  const parsed = errorResult.parse(result);
  expect(parsed.content).toHaveLength(1);
  return JSON.parse(parsed.content[0]?.text ?? "null");
}

test("native failures resolve with a code and corrective context", async () => {
  const { safeExecute, ToolFailure } = examples();
  const run = safeExecute(() => {
    throw new ToolFailure(
      "STALE_CELL",
      "Read the new revision before editing.",
      {
        revision: 8,
        content: "Updated by the user",
      },
    );
  });
  expect(payload(await run({}, execution))).toEqual({
    code: "STALE_CELL",
    message: "Read the new revision before editing.",
    details: { revision: 8, content: "Updated by the user" },
  });
});

for (const failure of [new Error("secret token"), "private data", null]) {
  test(`unexpected ${typeof failure} failures resolve without leaking internals`, async () => {
    const { safeExecute } = examples();
    const run = safeExecute(async () => {
      throw failure;
    });
    expect(payload(await run({}, execution))).toEqual({
      code: "INTERNAL_ERROR",
      message: "The tool failed. Check the current state before trying again.",
      details: {},
    });
  });
}

test("the wrapper preserves success and forwards the execution signal", async () => {
  const { safeExecute } = examples();
  const output = { wallId: "wall-1", lengthMetres: 3 };
  const run = safeExecute((args, context) => {
    expect(args).toEqual({ metres: 2 });
    expect(context.signal).toBe(execution.signal);
    return output;
  });
  expect(await run({ metres: 2 }, execution)).toBe(output);
});

test("cancellation is resolved as an actionable failure, without running work", async () => {
  const { safeExecute } = examples();
  const controller = new AbortController();
  controller.abort();
  let calls = 0;
  const run = safeExecute(() => calls++);
  expect(payload(await run({}, { signal: controller.signal }))).toEqual({
    code: "CANCELLED",
    message: "The call was cancelled. Check the current state before retrying.",
    details: {},
  });
  expect(calls).toBe(0);
});

test("error detail serialization cannot escape as another native rejection", async () => {
  const { safeExecute, ToolFailure } = examples();
  const circular: Record<string, unknown> = {};
  circular.self = circular;
  const run = safeExecute(() => {
    throw new ToolFailure("BAD_INPUT", "A public message", circular);
  });
  await expect(run({}, execution)).resolves.toMatchObject({ isError: true });
  expect(payload(await run({}, execution))).toMatchObject({
    code: "INTERNAL_ERROR",
  });
});

test("unserializable success is reported as failure rather than a browser rejection", async () => {
  const { safeExecute } = examples();
  const run = safeExecute(() => ({ invalid: 1n }));
  expect(payload(await run({}, execution))).toMatchObject({
    code: "INTERNAL_ERROR",
  });
});

test("an interrupted running call resolves as cancelled", async () => {
  const { safeExecute } = examples();
  const controller = new AbortController();
  const run = safeExecute(async () => {
    controller.abort();
    throw new Error("Fetch aborted");
  });
  expect(payload(await run({}, { signal: controller.signal }))).toMatchObject({
    code: "CANCELLED",
  });
});

function fixture() {
  let selected: Wall | null = null;
  const tools = new Map<string, WallTool>();
  const writes: unknown[] = [];
  const context: Registry = {
    registerTool: async (tool, { signal }) => {
      tools.set(tool.name, tool);
      signal.addEventListener("abort", () => tools.delete(tool.name), {
        once: true,
      });
    },
  };
  return {
    tools,
    writes,
    select: (wall: Wall | null) => {
      selected = wall;
    },
    register: () =>
      examples().registerSelectedWall(
        context,
        { getSelectedWall: () => selected },
        (id, metres, context) => {
          writes.push({ id, metres, signal: context.signal });
          return { id, lengthMetres: metres };
        },
      ),
  };
}

test("a selected-wall tool exists only during its selection scope", async () => {
  const f = fixture();
  const noop = await f.register();
  expect(f.tools.size).toBe(0);
  noop();
  f.select({ id: "wall-1" });
  const dispose = await f.register();
  const tool = f.tools.get("extend_selected_wall");
  expect(tool).toBeDefined();
  expect(await tool?.execute({ metres: 2 }, execution)).toEqual({
    id: "wall-1",
    lengthMetres: 2,
  });
  expect(f.writes).toEqual([
    { id: "wall-1", metres: 2, signal: execution.signal },
  ]);
  f.select(null);
  dispose();
  expect(f.tools.size).toBe(0);
  expect(execution.signal.aborted).toBe(false);
});

test("a stale descriptor cannot mutate a different selected wall", async () => {
  const f = fixture();
  f.select({ id: "wall-1" });
  await f.register();
  const tool = f.tools.get("extend_selected_wall");
  f.select({ id: "wall-2" });
  const result = await tool?.execute({ metres: 2 }, execution);
  expect(result).toMatchObject({ isError: true });
  expect(JSON.stringify(result)).toContain("STALE_SELECTION");
  expect(JSON.stringify(result)).toContain("wall-2");
  expect(f.writes).toEqual([]);
});

for (const metres of [0, -1, Number.NaN, Number.POSITIVE_INFINITY]) {
  test(`invalid length ${metres} resolves without mutating the wall`, async () => {
    const f = fixture();
    f.select({ id: "wall-1" });
    await f.register();
    const result = await f.tools
      .get("extend_selected_wall")
      ?.execute({ metres }, execution);
    expect(JSON.stringify(result)).toContain("INVALID_LENGTH");
    expect(f.writes).toEqual([]);
  });
}
