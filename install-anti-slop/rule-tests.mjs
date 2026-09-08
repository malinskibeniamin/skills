import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import {
  mkdirSync,
  mkdtempSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { installAntiSlop } from "./scripts/install.mjs";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const oxlint = join(repoRoot, "node_modules/.bin/oxlint");
const project = mkdtempSync(join(tmpdir(), "anti-slop-rules-"));

function runOxlint() {
  const result = spawnSync(
    oxlint,
    ["--format=json", "--config", "oxlint.config.ts", "src/input.ts"],
    {
      cwd: project,
      encoding: "utf8",
    },
  );
  return {
    exitCode: result.status,
    stderr: result.stderr,
    stdout: result.stdout,
  };
}

function parseOxlintReport(stdout) {
  const report = JSON.parse(stdout);
  assert.ok(Array.isArray(report.diagnostics), stdout);
  return report;
}

try {
  symlinkSync(join(repoRoot, "node_modules"), join(project, "node_modules"));
  installAntiSlop({ cwd: project });
  mkdirSync(join(project, "src"));
  writeFileSync(
    join(project, "oxlint.config.ts"),
    `import { defineConfig } from "oxlint";

export default defineConfig({
  ignorePatterns: ["tools/oxlint/anti-slop/**"],
  jsPlugins: [
    { name: "anti-slop", specifier: "./tools/oxlint/anti-slop/index.ts" },
  ],
  rules: {
    "anti-slop/no-chained-type-assertions": "error",
    "anti-slop/no-unknown-type-aliases": "error",
    "anti-slop/no-widen-then-assert": "error",
  },
});
`,
  );
  writeFileSync(
    join(project, "src/input.ts"),
    `type Hidden = unknown;
declare const input: unknown;
const user = input as unknown as { id: string };
const source = { id: "one" };
const widened: unknown = source;
const restored = widened as { id: string };
export { restored, user, type Hidden };
`,
  );

  const invalid = runOxlint();
  assert.equal(invalid.exitCode, 1, invalid.stderr);
  const invalidReport = parseOxlintReport(invalid.stdout);
  assert.deepEqual(
    invalidReport.diagnostics.map((diagnostic) => diagnostic.code).toSorted(),
    [
      "anti-slop(no-chained-type-assertions)",
      "anti-slop(no-unknown-type-aliases)",
      "anti-slop(no-widen-then-assert)",
    ],
  );

  writeFileSync(
    join(project, "src/input.ts"),
    `type User = { id: string };
declare const input: unknown;
const user = input as User;
export { user, type User };
`,
  );

  const valid = runOxlint();
  assert.equal(valid.exitCode, 0, valid.stderr);
  assert.deepEqual(parseOxlintReport(valid.stdout).diagnostics, []);
  console.log("anti-slop rule integration: pass");
} finally {
  rmSync(project, { recursive: true, force: true });
}
