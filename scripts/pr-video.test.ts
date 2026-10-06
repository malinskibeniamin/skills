import { afterEach, expect, test } from "bun:test";
import {
  copyFileSync,
  existsSync,
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

function composeFixture(version: string) {
  const root = mkdtempSync(join(tmpdir(), "pr-video-contract-"));
  directories.push(root);
  const scripts = join(root, "scripts");
  const bin = join(root, "bin");
  mkdirSync(scripts);
  mkdirSync(bin);
  for (const name of ["pr-video.sh", "pr-video-frame.html"]) {
    copyFileSync(new URL(name, import.meta.url), join(scripts, name));
  }
  writeFileSync(
    join(root, "package.json"),
    JSON.stringify({ devDependencies: { hyperframes: version } }),
  );
  for (const side of ["before", "after"]) {
    writeFileSync(join(root, `${side}.webm`), `${side} recording`);
    writeFileSync(
      join(root, `${side}.webm.steps.json`),
      JSON.stringify({
        title: "Save a name",
        steps: [{ at: 0, caption: "Save" }],
      }),
    );
  }
  // Only external tools are substituted. Exercise the real compose entrypoint.
  const fake = `#!${process.execPath}
import { appendFileSync, readFileSync, writeFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { basename } from "node:path";
const tool = basename(process.argv[1]);
const args = process.argv.slice(2);
if (tool === "ffprobe") console.log("2");
else if (tool === "ffmpeg") {
  if (args.includes("hash")) console.log("SHA256=" + createHash("sha256").update(readFileSync(args[args.indexOf("-i") + 1])).digest("hex"));
  else if (args.at(-1) === "-") console.error("frame= 12");
  else writeFileSync(args.at(-1), "video");
} else {
  appendFileSync(process.env.CALLS, JSON.stringify(args) + "\\n");
  if (process.env.FAIL_RENDER === "1" && args.includes("render")) process.exit(1);
  const output = args.indexOf("--output");
  if (output !== -1) writeFileSync(args[output + 1], "video");
}
`;
  for (const tool of ["ffmpeg", "ffprobe", "bunx"]) {
    writeFileSync(join(bin, tool), fake, { mode: 0o755 });
  }
  const calls = join(root, "calls.jsonl");
  const run = (failRender = false, overrides: Record<string, string> = {}) =>
    Bun.spawnSync(
      [
        "bash",
        join(scripts, "pr-video.sh"),
        "compose",
        join(root, "before.webm"),
        join(root, "after.webm"),
        join(root, "out"),
      ],
      {
        env: {
          ...Bun.env,
          PATH: `${bin}:${Bun.env.PATH}`,
          CALLS: calls,
          FAIL_RENDER: failRender ? "1" : "0",
          PR_VIDEO_RENDERER: "hyperframes",
          PR_VIDEO_BEFORE_LABEL: "Previous: save silently",
          PR_VIDEO_AFTER_LABEL: "New: confirmation shown",
          PR_VIDEO_FOCUS: "",
          ...overrides,
        },
      },
    );
  return { root, run, calls };
}

test("compose uses the manifest pin and delivery quality, returning MP4 first", () => {
  const { root, run, calls } = composeFixture("0.8.123");
  const result = run();
  expect(result.exitCode).toBe(0);
  expect(
    readFileSync(calls, "utf8")
      .trim()
      .split("\n")
      .map((line) => JSON.parse(line)),
  ).toEqual([
    ["hyperframes@0.8.123", "check"],
    [
      "hyperframes@0.8.123",
      "render",
      "--quality",
      "delivery",
      "--video-frame-format",
      "png",
      "--output",
      "../before-after.mp4",
    ],
  ]);
  expect(result.stdout.toString().trim().split("\n")).toEqual([
    join(root, "out/before-after.mp4"),
    join(root, "out/before-after.gif"),
  ]);
});

test("rejects duplicate recordings instead of presenting them as a change", () => {
  const { root, run } = composeFixture("0.8.123");
  copyFileSync(join(root, "before.webm"), join(root, "after.webm"));

  const result = run();

  expect(result.exitCode).not.toBe(0);
  expect(result.stderr.toString()).toContain("duplicate");
  expect(existsSync(join(root, "out/before-after.mp4"))).toBe(false);
});

test("frames the concrete previous and new behavior, safely escaping labels", () => {
  const { root, run } = composeFixture("0.8.123");
  const result = run(false, {
    PR_VIDEO_BEFORE_LABEL: "Previous: <silent> save",
    PR_VIDEO_AFTER_LABEL: "New: confirmation & retry",
  });

  expect(result.exitCode, result.stderr.toString()).toBe(0);
  const composition = readFileSync(
    join(root, "out/hyperframes/index.html"),
    "utf8",
  );
  expect(composition).toContain("Previous: &lt;silent&gt; save</div>");
  expect(composition).toContain("New: confirmation &amp; retry</div>");
});

test.each([
  { PR_VIDEO_BEFORE_LABEL: "" },
  { PR_VIDEO_AFTER_LABEL: "  " },
  { PR_VIDEO_BEFORE_LABEL: "Before", PR_VIDEO_AFTER_LABEL: "After" },
  { PR_VIDEO_BEFORE_LABEL: "Same", PR_VIDEO_AFTER_LABEL: "Same" },
  { PR_VIDEO_BEFORE_LABEL: " Same ", PR_VIDEO_AFTER_LABEL: "same" },
  { PR_VIDEO_BEFORE_LABEL: "Previous\nUnsafe line" },
  { PR_VIDEO_AFTER_LABEL: "W".repeat(61) },
])("requires distinct behavior labels before rendering: %j", (labels) => {
  const { root, run } = composeFixture("0.8.123");
  const result = run(false, labels);

  expect(result.exitCode).not.toBe(0);
  expect(result.stderr.toString()).toContain("behavior labels");
  expect(existsSync(join(root, "out/before-after.mp4"))).toBe(false);
});

test.each([
  "10:10:0:200",
  "10:10:201:100",
  "10:10:200:101",
  "-1:0:200:100",
  "0:0:200:100,scale=2:2",
])("rejects invalid focus geometry %j before rendering", (focus) => {
  const { root, run } = composeFixture("0.8.123");
  const result = run(false, { PR_VIDEO_FOCUS: focus });
  expect(result.exitCode).not.toBe(0);
  expect(result.stderr.toString()).toContain("PR_VIDEO_FOCUS");
  expect(existsSync(join(root, "out/before-after.mp4"))).toBe(false);
});

test.each(["^0.8.123", "latest", "0.8.123-beta.1", "01.8.123", ""])(
  "rejects the non-stable renderer pin %j before rendering",
  (version) => {
    const { run } = composeFixture(version);
    const result = run();
    expect(result.exitCode).not.toBe(0);
    expect(result.stderr.toString()).toContain("exact stable version");
  },
);

test("a forced HyperFrames failure never becomes an uncaptioned successful fallback", () => {
  const { root, run } = composeFixture("0.8.123");
  const result = run(true);
  expect(result.exitCode).not.toBe(0);
  expect(result.stdout.toString()).not.toContain("before-after.mp4");
  expect(() => readFileSync(join(root, "out/before-after.gif"))).toThrow();
});

test("uses the matching installed renderer without fetching another CLI", () => {
  const { root, run } = composeFixture("0.8.123");
  const modules = join(root, "node_modules");
  mkdirSync(join(modules, "hyperframes"), { recursive: true });
  mkdirSync(join(modules, ".bin"));
  writeFileSync(
    join(modules, "hyperframes/package.json"),
    '{"version":"0.8.123"}',
  );
  copyFileSync(join(root, "bin/bunx"), join(modules, ".bin/hyperframes"));
  const result = run();
  expect(result.exitCode, result.stderr.toString()).toBe(0);
  expect(
    readFileSync(join(root, "calls.jsonl"), "utf8")
      .trim()
      .split("\n")
      .map((line) => JSON.parse(line)),
  ).toEqual([
    ["check"],
    [
      "render",
      "--quality",
      "delivery",
      "--video-frame-format",
      "png",
      "--output",
      "../before-after.mp4",
    ],
  ]);
});
