import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { installAntiSlop } from "./scripts/install.mjs";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const biome = join(repoRoot, "node_modules/.bin/biome");
const project = mkdtempSync(join(tmpdir(), "anti-slop-biome-rules-"));

function runBiome() {
  const result = spawnSync(
    biome,
    ["lint", "--config-path", "biome.json", "src/input.ts"],
    { cwd: project, encoding: "utf8" },
  );
  return {
    exitCode: result.status,
    output: `${result.stdout}${result.stderr}`,
  };
}

try {
  installAntiSlop({ cwd: project, linter: "biome" });
  mkdirSync(join(project, "src"));
  writeFileSync(
    join(project, "biome.json"),
    `${JSON.stringify(
      {
        $schema: "https://biomejs.dev/schemas/2.5.9/schema.json",
        plugins: [
          {
            includes: ["**/*.ts", "**/*.tsx", "**/*.mts", "**/*.cts"],
            path: "./tools/biome/anti-slop/no-chained-type-assertions.grit",
          },
          {
            includes: ["**/*.ts", "**/*.tsx", "**/*.mts", "**/*.cts"],
            path: "./tools/biome/anti-slop/no-direct-unknown-type-aliases.grit",
          },
        ],
        linter: { rules: { recommended: false } },
      },
      null,
      2,
    )}\n`,
  );
  writeFileSync(
    join(project, "src/input.ts"),
    `type User = { id: string };
type Hidden = unknown;
type MaybeHidden = string | unknown;
type ParenthesizedHidden = (unknown);
type MaybeParenthesizedHidden = string | (unknown);
declare const input: unknown;
const direct = input as unknown as User;
const parenthesized = (input as unknown) as User;
const angle = <User>(<unknown>input);
const angleThenAs = (<unknown>input) as User;
const asThenAngle = <User>(input as unknown);
const triple = input as unknown as object as User;
export { angle, angleThenAs, asThenAngle, direct, parenthesized, triple, type Hidden, type MaybeHidden, type ParenthesizedHidden, type MaybeParenthesizedHidden };
`,
  );

  const invalid = runBiome();
  assert.equal(invalid.exitCode, 1, invalid.output);
  assert.equal(invalid.output.match(/anti-slop:/g)?.length, 10, invalid.output);

  writeFileSync(
    join(project, "src/input.ts"),
    `type User = { id: string };
type Box<T> = { value: T };
type BoxedUnknown = Box<unknown>;
type MaybeBoxedUnknown = string | Box<unknown>;
declare const input: unknown;
const parsed = input as User;
const literal = ({ id: "one" } as const) as const;
export { literal, parsed, type BoxedUnknown, type MaybeBoxedUnknown };
`,
  );

  const valid = runBiome();
  assert.equal(valid.exitCode, 0, valid.output);
  assert.doesNotMatch(valid.output, /anti-slop:/);
  console.log("anti-slop Biome rule integration: pass");
} finally {
  rmSync(project, { recursive: true, force: true });
}
