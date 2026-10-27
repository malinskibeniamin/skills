import { expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { runInNewContext } from "node:vm";

interface Tool {
  name: string;
  origin: string;
  window?: string;
}

const origin = "https://shop.example";
const ownTool = { name: "update-note", origin };

// Exercise the copyable example agents actually read: the adapter's override,
// or its required upstream instructions before the override was introduced.
function example() {
  const adapter = readFileSync(new URL("./SKILL.md", import.meta.url), "utf8");
  const upstream = readFileSync(
    new URL("../vendor/builder-webmcp/skills/webmcp/SKILL.md", import.meta.url),
    "utf8",
  );
  const native = adapter.match(/```js\n([\s\S]*?)\n```/)?.[1];
  if (native) return native;
  const legacy = upstream.match(/```js\n([\s\S]*?)\n```/)?.[1];
  if (!legacy) throw new Error("The page-tool example is missing");
  return `(async () => { ${legacy}\nreturn raw; })()`;
}

function fixture(tools: Tool[] = [ownTool], response: unknown = "saved") {
  const calls: { tool: Tool; input: unknown }[] = [];
  const context = {
    getTools: async () => tools,
    executeTool: async (tool: Tool, input: unknown) => {
      calls.push({ tool, input });
      if (typeof input !== "object" || input === null) {
        throw new TypeError("Chrome object input required");
      }
      if (!tools.includes(tool)) throw new Error("Live descriptor required");
      if (response instanceof Error) throw response;
      return response;
    },
  };
  return { calls, context };
}

function invoke(context: unknown, args: unknown = { text: "Hello" }) {
  const result: unknown = runInNewContext(example(), {
    document: { modelContext: context },
    NAME: ownTool.name,
    ORIGIN: origin,
    ARGS: args,
  });
  return Promise.resolve(result);
}

test("the native Chrome example passes an object and a live descriptor", async () => {
  const { calls, context } = fixture();
  await expect(invoke(context)).resolves.toBe("saved");
  expect(calls).toEqual([{ tool: ownTool, input: { text: "Hello" } }]);
});

test("same-name tools are selected by the task origin", async () => {
  const foreign = { name: ownTool.name, origin: "https://other.example" };
  const { calls, context } = fixture([foreign, ownTool]);
  await invoke(context);
  expect(calls[0]?.tool).toBe(ownTool);
});

for (const { name, tools } of [
  { name: "absent", tools: [] },
  {
    name: "different origin",
    tools: [{ ...ownTool, origin: "https://other.example" }],
  },
  {
    name: "ambiguous frames",
    tools: [
      { ...ownTool, window: "first" },
      { ...ownTool, window: "second" },
    ],
  },
]) {
  test(`task tools stop before execution when ${name}`, async () => {
    const { calls, context } = fixture(tools);
    await expect(invoke(context)).rejects.toThrow(
      "Expected exactly 1 matching WebMCP tool",
    );
    expect(calls).toHaveLength(0);
  });
}

test("missing browser capabilities report an unavailable page API", async () => {
  await expect(invoke(undefined)).rejects.toThrow(
    "WebMCP page API unavailable",
  );
});

test("a navigation result remains null, not a fabricated success receipt", async () => {
  const { context } = fixture([ownTool], null);
  await expect(invoke(context)).resolves.toBeNull();
});

test("a failed invocation is propagated without an input-format retry", async () => {
  const { calls, context } = fixture(
    [ownTool],
    new Error("transport interrupted"),
  );
  await expect(invoke(context)).rejects.toThrow("transport interrupted");
  expect(calls).toHaveLength(1);
});
