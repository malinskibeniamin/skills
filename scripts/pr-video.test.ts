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
  for (const name of [
    "pr-video.sh",
    "pr-video-frame.html",
    "pr-video-demo.html",
  ]) {
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
        steps: [
          { at: 0, caption: "Type a name" },
          { at: 0.8, caption: "Save" },
        ],
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
if (tool === "ffprobe") console.log(args.at(-1).endsWith("before.webm") ? process.env.BEFORE_DURATION : process.env.AFTER_DURATION);
else if (tool === "ffmpeg") {
  if (args.includes("hash")) console.log("SHA256=" + createHash("sha256").update(readFileSync(args[args.indexOf("-i") + 1])).digest("hex"));
  else if (args.some((arg) => arg.includes("freezedetect"))) console.error(process.env.FREEZE_LOG || "");
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
  const run = (
    failRender = false,
    overrides: Record<string, string> = {},
    demo = false,
  ) =>
    Bun.spawnSync(
      [
        "bash",
        join(scripts, "pr-video.sh"),
        ...(demo ? ["demo"] : ["compose", join(root, "before.webm")]),
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
          BEFORE_DURATION: "2",
          AFTER_DURATION: "2",
          ...overrides,
        },
      },
    );
  return {
    root,
    run,
    calls,
    demo: (overrides: Record<string, string> = {}) =>
      run(false, overrides, true),
  };
}

function recordFixture(flowText: string) {
  const { root, commands } = fixture();
  writeFileSync(
    join(root, "agent-browser"),
    `#!${process.execPath}
import { appendFileSync } from "node:fs";
appendFileSync(process.env.CALLS, JSON.stringify(process.argv.slice(2)) + "\\n");
`,
    { mode: 0o755 },
  );
  const flow = join(root, "flow.txt");
  writeFileSync(flow, flowText);
  const run = (step = "") =>
    Bun.spawnSync(
      [
        "bash",
        entry,
        "record",
        "http://localhost:3000",
        flow,
        join(root, "take.webm"),
      ],
      {
        env: {
          ...Bun.env,
          PATH: `${root}:${Bun.env.PATH}`,
          CALLS: join(root, "calls.jsonl"),
          PR_VIDEO_STEP_MS: step,
        },
      },
    );
  return { root, run, commands };
}

test.each([
  { step: "", expected: 1500 },
  { step: "1000", expected: 1000 },
  { step: "5000", expected: 5000 },
  { step: "700", expected: null },
  { step: "no", expected: null },
])(
  "record uses readable subtitle holds and rejects unsafe pacing: $step",
  ({ step, expected }) => {
    const { run, commands } = recordFixture(
      '# Save a name\n## Type a name\n  \ntype "#name" "Ada"\n## Save\nclick "#save"\n',
    );
    const result = run(step);
    if (expected === null) {
      expect(result.exitCode).not.toBe(0);
      expect(result.stderr.toString()).toContain("PR_VIDEO_STEP_MS");
      expect(commands()).toEqual([]);
    } else {
      expect(result.exitCode, result.stderr.toString()).toBe(0);
      expect(
        commands()
          .filter((args) => args[2] === "wait")
          .map((args) => Number(args[3])),
      ).toEqual([expected, Math.max(expected, 2000), Math.max(expected, 2000)]);
    }
  },
);

test("silent narration preserves authored text and gets enough reading time", () => {
  const { root, run, commands } = recordFixture(
    '# Save a name\n## We enter a task name so the viewer can follow.\ntype "#name" "Ada"\n## We save the task.\nclick "#save"\n',
  );
  const result = run();
  expect(result.exitCode, result.stderr.toString()).toBe(0);
  expect(
    commands()
      .filter((args) => args[2] === "wait")
      .map((args) => Number(args[3])),
  ).toEqual([1500, 4000, 2200]);
  expect(
    JSON.parse(readFileSync(join(root, "take.webm.steps.json"), "utf8"))
      .steps[0].at,
  ).toBe(0);
  expect(
    JSON.parse(
      readFileSync(join(root, "take.webm.steps.json"), "utf8"),
    ).steps.map((step: { caption: string }) => step.caption),
  ).toEqual([
    "We enter a task name so the viewer can follow.",
    "We save the task.",
  ]);
});

test.each([
  'type "#name" "Ada"\n## We save the task.\nclick "#save"\n',
  '##   \ntype "#name" "Ada"\n## We save the task.\nclick "#save"\n',
  '## We enter a name.\ntype "#name" "Ada"\nclick "#save"\n',
  '## We enter a name.\ntype "#name" "Ada"\n## We save the task.\nclick "#save"\n  click "#retry"\n',
])("missing action narration fails before opening a browser: %j", (flow) => {
  const { run, commands } = recordFixture(flow);
  const result = run();
  expect(result.exitCode).toBe(2);
  expect(result.stderr.toString()).toContain("## narration");
  expect(commands()).toEqual([]);
});

test.each([
  {
    before: "2",
    after: "2",
    duration: 5,
    beforeCaption: [2, 3],
    afterCaption: [2, 3],
  },
  {
    before: "1",
    after: "2",
    duration: 5,
    beforeCaption: [4, 1],
    afterCaption: [2, 3],
  },
  {
    before: "6",
    after: "8",
    duration: 8,
    beforeCaption: [0.8, 7.2],
    afterCaption: [0.8, 7.2],
  },
  {
    before: "35",
    after: "39",
    duration: 39,
    beforeCaption: [0.8, 38.2],
    afterCaption: [0.8, 38.2],
  },
])(
  "compose keeps readable duration and synchronized captions: $before/$after seconds",
  ({ before, after, duration, beforeCaption, afterCaption }) => {
    const { root, run } = composeFixture("0.8.123");
    const result = run(false, {
      BEFORE_DURATION: before,
      AFTER_DURATION: after,
    });
    expect(result.exitCode, result.stderr.toString()).toBe(0);
    // The composition is a public output consumed by HyperFrames.
    const composition = readFileSync(
      join(root, "out/hyperframes/index.html"),
      "utf8",
    );
    expect(
      Number(
        composition.match(
          /data-composition-id="main"[^>]*data-duration="?([\d.]+)/,
        )?.[1],
      ),
    ).toBe(duration);
    for (const [side, expected] of [
      ["before", beforeCaption],
      ["after", afterCaption],
    ] as const) {
      expect(
        composition
          .match(
            new RegExp(
              `id="${side}-cap-1"[^>]*data-start="([^"]+)" data-duration="([^"]+)"`,
            ),
          )
          ?.slice(1)
          .map(Number),
      ).toEqual([...expected]);
    }
  },
);

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

test("rejects long idle stretches even when a take has enough distinct frames", () => {
  const { root, run, calls } = composeFixture("0.8.123");
  const result = run(false, {
    FREEZE_LOG: "[freezedetect] lavfi.freezedetect.freeze_start: 2.4",
  });
  expect(result.exitCode).not.toBe(0);
  expect(result.stderr.toString()).toContain("idle from 2.4s");
  expect(existsSync(join(root, "out/before-after.mp4"))).toBe(false);
  expect(existsSync(calls)).toBe(false);
});

function demoFixture() {
  const fixture = composeFixture("0.8.123");
  writeFileSync(
    join(fixture.root, "after.webm.steps.json"),
    JSON.stringify({
      title: "Analyze a draft",
      diagram: ["CLI <input>", "RPC & handler", "Result"],
      steps: [
        { at: 0, caption: "Run the command.", active: 0 },
        { at: 3, caption: "Inspect the result.", active: 2 },
      ],
    }),
  );
  return {
    ...fixture,
    demo: (overrides: Record<string, string> = {}) =>
      fixture.demo({ AFTER_DURATION: "6", ...overrides }),
  };
}

test("renders one real CLI or UI take with timed subtitles and an escaped execution model", () => {
  const { root, demo } = demoFixture();
  const result = demo();
  expect(result.exitCode, result.stderr.toString()).toBe(0);
  expect(result.stdout.toString().trim().split("\n")).toEqual([
    join(root, "out/demo.mp4"),
    join(root, "out/demo.gif"),
  ]);
  const html = readFileSync(join(root, "out/hyperframes/index.html"), "utf8");
  expect(html).toContain("CLI &lt;input&gt;");
  expect(html).toContain("RPC &amp; handler");
  expect(html).toContain("Execution model");
  expect(html).toContain('data-start="3" data-duration="3"');
  expect(html).toContain("Inspect the result.");
  expect(html).toContain('class="node active">Result');
});

test.each([
  null,
  { title: "No steps", steps: [] },
  { steps: [{ at: 1, caption: "Late start" }] },
  { steps: [{ at: 0, caption: " " }] },
  {
    steps: [
      { at: 0, caption: "Run" },
      { at: 0, caption: "Repeat" },
    ],
  },
  {
    steps: [
      { at: 0, caption: "Run" },
      { at: 6, caption: "Too late" },
    ],
  },
  {
    steps: [
      { at: 0, caption: "Too fast" },
      { at: 0.2, caption: "Result" },
    ],
  },
  { diagram: ["CLI", "RPC"], steps: [{ at: 0, caption: "Run", active: 2 }] },
])(
  "demo rejects missing or invalid narration before rendering: %j",
  (sidecar) => {
    const { root, demo, calls } = demoFixture();
    const path = join(root, "after.webm.steps.json");
    if (sidecar === null) rmSync(path);
    else
      writeFileSync(
        path,
        JSON.stringify({ title: "Analyze a draft", ...sidecar }),
      );
    const result = demo();
    expect(result.exitCode).not.toBe(0);
    expect(result.stderr.toString()).toContain("steps.json");
    expect(existsSync(calls)).toBe(false);
  },
);

test("auto renderer fails closed instead of silently dropping subtitles", () => {
  const { run } = composeFixture("0.8.123");
  const result = run(true, { PR_VIDEO_RENDERER: "auto" });
  expect(result.exitCode).not.toBe(0);
  expect(result.stdout.toString()).not.toContain("before-after.mp4");
});

test("comparison refuses to manufacture a long frozen tail on the shorter side", () => {
  const { root, run, calls } = composeFixture("0.8.123");
  const result = run(false, { BEFORE_DURATION: "6", AFTER_DURATION: "20" });
  expect(result.exitCode).not.toBe(0);
  expect(result.stderr.toString()).toContain("freeze the shorter take");
  expect(existsSync(join(root, "out/before-after.mp4"))).toBe(false);
  expect(existsSync(calls)).toBe(false);
});

test("records a narrated hover when the actual change is a tooltip", () => {
  const { run, commands } = recordFixture(
    '# Disabled send reason\n## Hover reveals why Send is disabled.\nhover "#send"\n',
  );
  const result = run();
  expect(result.exitCode, result.stderr.toString()).toBe(0);
  expect(commands()).toContainEqual(expect.arrayContaining(["hover", "#send"]));
});

test("demo without a diagram keeps the recording full-width", () => {
  const { root, demo } = demoFixture();
  writeFileSync(
    join(root, "after.webm.steps.json"),
    JSON.stringify({
      title: "Save a name",
      steps: [{ at: 0, caption: "Type and save a name." }],
    }),
  );
  const result = demo();
  expect(result.exitCode, result.stderr.toString()).toBe(0);
  const html = readFileSync(join(root, "out/hyperframes/index.html"), "utf8");
  expect(html).toContain('class="full"');
  expect(html).not.toContain("<aside>");
});

test("captioned comparison refuses a take without narration", () => {
  const { root, run, calls } = composeFixture("0.8.123");
  rmSync(join(root, "after.webm.steps.json"));
  const result = run();
  expect(result.exitCode).not.toBe(0);
  expect(result.stderr.toString()).toContain("steps.json");
  expect(existsSync(calls)).toBe(false);
});

test("record gives a verified result one reading hold, without stacking idle pauses", () => {
  const { run, commands } = recordFixture(
    '# Save a name\n## Save the name.\nclick "#save"\nwait --text "Saved"\n',
  );
  const result = run();
  expect(result.exitCode, result.stderr.toString()).toBe(0);
  expect(
    commands()
      .filter((args) => args[2] === "wait")
      .map((args) => args.slice(3)),
  ).toEqual([["1500"], ["2000"], ["--text", "Saved"], ["2000"]]);
});
