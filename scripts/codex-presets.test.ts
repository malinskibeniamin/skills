import { afterEach, expect, test } from "bun:test";
import {
  copyFileSync,
  mkdtempSync,
  mkdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const roots: string[] = [];
afterEach(() => {
  for (const root of roots.splice(0))
    rmSync(root, { recursive: true, force: true });
});

function run(args: readonly string[] = []) {
  const home = mkdtempSync(join(tmpdir(), "codex-presets-"));
  roots.push(home);
  const config = join(home, "config.toml");
  const original = '[tui.presets.7]\ninput = "My existing preset"\n';
  writeFileSync(config, original);
  const result = Bun.spawnSync(
    [
      process.execPath,
      new URL("./codex-presets.ts", import.meta.url).pathname,
      ...args,
    ],
    { env: { ...Bun.env, CODEX_HOME: home } },
  );
  expect(readFileSync(config, "utf8")).toBe(original);
  return {
    code: result.exitCode,
    out: result.stdout.toString(),
    err: result.stderr.toString(),
  };
}

test("exports native review, local fix, and model presets without modifying user config", () => {
  const result = run();
  expect(result.code).toBe(0);
  expect(result.err).toBe("");
  expect(Bun.TOML.parse(result.out)).toEqual({
    tui: {
      presets: {
        "7": {
          label: "Review",
          input: expect.stringContaining("frontend-skills review skill"),
        },
        "8": {
          label: "Fix locally",
          input: expect.stringContaining("failing public-contract test"),
        },
        "9": {
          label: "Review model",
          input: "/model gpt-6.1-sol --reasoning=xhigh",
        },
      },
    },
  });
  expect(result.out).toContain("do not edit");
  expect(result.out).toContain("do not commit, push");
  expect(result.out).toContain("or delegate");
});

test("lets the user choose three free native slots, including zero", () => {
  const result = run(["--slots", "0,2,5"]);
  expect(result.code).toBe(0);
  expect(Bun.TOML.parse(result.out)).toMatchObject({
    tui: {
      presets: {
        "0": { label: "Review" },
        "2": { label: "Fix locally" },
        "5": { label: "Review model" },
      },
    },
  });
});

test("uses the packaged review route instead of a separately maintained model", () => {
  const root = mkdtempSync(join(tmpdir(), "codex-presets-routing-"));
  roots.push(root);
  mkdirSync(join(root, "scripts"));
  mkdirSync(join(root, "config"));
  const entry = join(root, "scripts/codex-presets.ts");
  copyFileSync(new URL("./codex-presets.ts", import.meta.url), entry);
  writeFileSync(
    join(root, "config/model-routing.json"),
    JSON.stringify({
      quality_first: {
        review: { primary: { model: "fixture-review-model", effort: "high" } },
      },
    }),
  );
  const result = Bun.spawnSync([process.execPath, entry]);
  expect(result.exitCode).toBe(0);
  expect(Bun.TOML.parse(result.stdout.toString())).toMatchObject({
    tui: {
      presets: {
        "9": { input: "/model fixture-review-model --reasoning=high" },
      },
    },
  });
});

test.each([
  { args: ["--slots", "7,7,9"] },
  { args: ["--slots", "1,2"] },
  { args: ["--slots", "1,2,10"] },
  { args: ["--slots", "-1,2,3"] },
  { args: ["--slots", "a,2,3"] },
  { args: ["--slots"] },
  { args: ["--slots", "1,2,3", "extra"] },
  { args: ["--install"] },
])(
  "rejects invalid arguments without emitting a partial snippet: %j",
  ({ args }) => {
    const result = run(args);
    expect(result.code).not.toBe(0);
    expect(result.out).toBe("");
    expect(result.err).toContain("3 distinct slots from 0 to 9");
  },
);

test("prints usage without exporting presets", () => {
  const result = run(["--help"]);
  expect(result.code).toBe(0);
  expect(result.out).toContain("--slots");
  expect(result.out).not.toContain("[tui.presets.");
});
