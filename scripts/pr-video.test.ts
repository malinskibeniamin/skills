import { afterEach, expect, test } from "bun:test";
import {
  mkdtempSync,
  mkdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const entry = new URL("./pr-video.sh", import.meta.url).pathname;
const directories: string[] = [];

afterEach(() => {
  for (const directory of directories.splice(0)) {
    rmSync(directory, { recursive: true, force: true });
  }
});

function fixture() {
  const root = mkdtempSync(join(tmpdir(), "pr-video-"));
  directories.push(root);
  const calls = join(root, "calls.jsonl");
  writeFileSync(calls, "");
  const video = join(root, "flow with spaces.mp4");
  writeFileSync(video, "media fixture");
  writeFileSync(
    join(root, "gh"),
    `#!${process.execPath}
import { appendFileSync } from "node:fs";
const args = process.argv.slice(2);
appendFileSync(process.env.CALLS, JSON.stringify(args) + "\\n");
if (args.includes("--help")) {
  console.log(process.env.GH_ATTACH_SUPPORTED === "0" ? "--body-file file" : "--attach file   Attach an image or video");
} else if (args[0] === "pr" && args[1] === "edit") {
  console.log("https://github.com/example/project/pull/42");
  if (process.env.GH_EDIT_EXIT) {
    console.error("one attachment failed to upload");
    process.exit(Number(process.env.GH_EDIT_EXIT));
  }
} else if (args[0] === "pr" && args[1] === "view") {
  console.log("https://github.com/example/project/pull/42");
} else {
  process.exit(2);
}
`,
    { mode: 0o755 },
  );
  writeFileSync(
    join(root, "agent-browser"),
    `#!${process.execPath}
import { appendFileSync } from "node:fs";
appendFileSync(process.env.CALLS, JSON.stringify(["browser"]) + "\\n");
process.exit(99);
`,
    { mode: 0o755 },
  );
  const run = (
    args: readonly string[],
    overrides: Record<string, string> = {},
  ) =>
    Bun.spawnSync(["/bin/bash", entry, "attach", ...args], {
      cwd: root,
      env: {
        ...Bun.env,
        PATH: `${root}:${Bun.env.PATH}`,
        CALLS: calls,
        PR_VIDEO_PR_URL: "",
        PR_VIDEO_PROFILE: join(root, "legacy-profile"),
        ...overrides,
      },
    });
  const commands = (): string[][] =>
    readFileSync(calls, "utf8")
      .trim()
      .split("\n")
      .filter(Boolean)
      .map((line) => JSON.parse(line));
  return { root, video, run, commands };
}

test("attaches media to the current PR without a browser or replacing its body", () => {
  const { video, run, commands } = fixture();
  const result = run([video]);

  expect(result.exitCode, result.stderr.toString()).toBe(0);
  expect(result.stdout.toString().trim()).toBe(
    "https://github.com/example/project/pull/42",
  );
  expect(commands()).toEqual([
    ["pr", "edit", "--help"],
    ["pr", "edit", "--attach", video],
  ]);
});

test("places multiple attachments through a body file on an explicitly selected PR", () => {
  const { root, video, run, commands } = fixture();
  const screenshot = join(root, "before.png");
  writeFileSync(screenshot, "image fixture");
  const body = join(root, "pr body.md");
  const markdown = `## Summary\nKeep reviewer notes.\n\n![](${video})\n\n![Before](${screenshot})\n`;
  writeFileSync(body, markdown);
  const url = "https://github.com/example/project/pull/42";

  const result = run(["--body-file", body, video, screenshot], {
    PR_VIDEO_PR_URL: url,
  });

  expect(result.exitCode, result.stderr.toString()).toBe(0);
  expect(commands()).toEqual([
    ["pr", "edit", "--help"],
    [
      "pr",
      "edit",
      url,
      "--body-file",
      body,
      "--attach",
      video,
      "--attach",
      screenshot,
    ],
  ]);
  expect(readFileSync(body, "utf8")).toBe(markdown);
});

test("older GitHub CLI fails with upgrade guidance, never browser fallback", () => {
  const { video, run, commands } = fixture();

  const result = run([video], { GH_ATTACH_SUPPORTED: "0" });

  expect(result.exitCode).toBe(3);
  expect(result.stderr.toString()).toContain("upgrade GitHub CLI");
  expect(commands()).toEqual([["pr", "edit", "--help"]]);
});

test("reports partial upload failures without retrying or masking gh's exit", () => {
  const { video, run, commands } = fixture();

  const result = run([video], { GH_EDIT_EXIT: "41" });

  expect(result.exitCode).toBe(41);
  expect(result.stderr.toString()).toContain("one attachment failed to upload");
  expect(result.stderr.toString()).toContain(
    "read the PR body before retrying",
  );
  expect(result.stdout.toString()).toContain(
    "https://github.com/example/project/pull/42",
  );
  expect(commands()).toHaveLength(2);
});

test.each(["missing", "empty", "directory"])(
  "rejects a %s attachment before any remote action",
  (kind) => {
    const { root, video, run, commands } = fixture();
    const invalid = join(root, "invalid.mp4");
    if (kind === "empty") writeFileSync(invalid, "");
    if (kind === "directory") mkdirSync(invalid);

    const result = run([video, invalid]);

    expect(result.exitCode).toBe(1);
    expect(result.stderr.toString()).toContain("missing or empty file");
    expect(commands()).toEqual([]);
  },
);

test.each([
  { label: "no media", args: [] },
  { label: "no body path", args: ["--body-file"] },
  { label: "no media after body", args: ["--body-file", "body.md"] },
])("rejects $label without remote actions", ({ args }) => {
  const { run, commands } = fixture();
  const result = run(args);

  expect(result.exitCode).toBe(2);
  expect(commands()).toEqual([]);
});
