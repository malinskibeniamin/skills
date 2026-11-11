import { afterAll, afterEach, beforeAll, expect, test } from "bun:test";
import {
  copyFileSync,
  mkdirSync,
  mkdtempSync,
  readdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";

const root = mkdtempSync(join(tmpdir(), "skill-model-policy-"));
const source = new URL("../", import.meta.url).pathname;
const skill = join(root, "resolve-pr-feedback/SKILL.md");
const agent = join(root, "agents/code-reviewer.md");
let agentSource = "";
const header =
  "---\nname: resolve-pr-feedback\ndescription: Check review feedback.\n";
const document = (metadata = "") => `${header}${metadata}---\nFixture skill.\n`;

function copy(path: string) {
  mkdirSync(dirname(join(root, path)), { recursive: true });
  copyFileSync(join(source, path), join(root, path));
}

function generate(mode?: "--check") {
  return Bun.spawnSync(
    [
      "bash",
      join(root, "scripts/generate-skill-catalog.sh"),
      ...(mode ? [mode] : []),
    ],
    { cwd: root },
  );
}

beforeAll(() => {
  for (const path of [
    "scripts/generate-skill-catalog.sh",
    ".claude-plugin/plugin.json",
    ".codex-plugin/plugin.json",
    "config/model-routing.json",
    "ask-ben/SKILL.md",
  ])
    copy(path);
  const manifest = JSON.parse(
    readFileSync(join(source, ".claude-plugin/plugin.json"), "utf8"),
  ) as { skills: string[] };
  for (const path of manifest.skills) copy(join(path, "SKILL.md"));
  for (const path of readdirSync(join(source, "vendor")))
    if (path.endsWith(".lock.json")) copy(join("vendor", path));
  for (const path of readdirSync(join(source, "agents")))
    if (path.endsWith(".md")) copy(join("agents", path));
  mkdirSync(join(root, "ask-ben/references"), { recursive: true });
  agentSource = readFileSync(agent, "utf8");
  writeFileSync(skill, document("model: inherit\neffort: xhigh\n"));
  const result = generate();
  if (result.exitCode !== 0) throw new Error(result.stderr.toString());
});

afterAll(() => rmSync(root, { recursive: true, force: true }));
afterEach(() => {
  writeFileSync(skill, document("model: inherit\neffort: xhigh\n"));
  writeFileSync(agent, agentSource);
});

test("publishes the complete registry with inherited models and the configured effort", () => {
  writeFileSync(skill, document("model: inherit\neffort: xhigh\n"));
  const applied = generate();
  expect(applied.exitCode).toBe(0);
  expect(generate("--check").exitCode).toBe(0);
});

test.each([
  "model: claude-sonnet-5\n",
  "model: opus\n",
  '"model": "claude-sonnet-5"\n',
  "effort: high\n",
  "context: fork\n",
  "hooks:\n  Stop:\n    - hooks:\n        - type: agent\n          model: claude-sonnet-5\n",
  "hooks:\n  Stop:\n    - hooks:\n        - type: prompt\n          prompt: Verify this work.\n",
  "hooks: {Stop: [{hooks: [{type: agent}]}]}\n",
])("rejects hidden execution metadata before publishing: %s", (metadata) => {
  writeFileSync(skill, document(metadata));
  const before = readFileSync(
    join(root, "codex-skills/resolve-pr-feedback/SKILL.md"),
    "utf8",
  );
  const result = generate();
  expect(result.exitCode).not.toBe(0);
  expect(result.stderr.toString()).toContain("MODEL POLICY");
  expect(result.stderr.toString()).toContain("resolve-pr-feedback");
  expect(
    readFileSync(
      join(root, "codex-skills/resolve-pr-feedback/SKILL.md"),
      "utf8",
    ),
  ).toBe(before);
});

test("checks registered agent definitions too without rejecting inherit", () => {
  writeFileSync(
    agent,
    agentSource.replace("model: inherit", "model: claude-sonnet-5"),
  );
  const result = generate();
  expect(result.exitCode).not.toBe(0);
  expect(result.stderr.toString()).toContain("MODEL POLICY");
  expect(result.stderr.toString()).toContain("agents/code-reviewer.md");
  writeFileSync(agent, agentSource);
  expect(generate("--check").exitCode).toBe(0);
});

test("keeps deterministic skill hooks publishable", () => {
  writeFileSync(
    skill,
    document(
      "hooks:\n  Stop:\n    - hooks:\n        - type: command\n          command: echo verified\n",
    ),
  );
  expect(generate().exitCode).toBe(0);
  expect(generate("--check").exitCode).toBe(0);
});
