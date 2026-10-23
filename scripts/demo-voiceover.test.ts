import { afterEach, expect, test } from "bun:test";
import {
  existsSync,
  mkdtempSync,
  readFileSync,
  readdirSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const entry = new URL("./demo-voiceover.sh", import.meta.url).pathname;
const directories: string[] = [];
// Bound a broken child process; not a synchronization or performance assertion.
const PROCESS_DEADLINE_MS = 10_000;

afterEach(() => {
  for (const directory of directories.splice(0)) {
    rmSync(directory, { recursive: true, force: true });
  }
});

function fixture() {
  const root = mkdtempSync(join(tmpdir(), "demo voiceover-"));
  directories.push(root);
  const video = join(root, "browser take.webm");
  const audio = join(root, "narration.wav");
  const out = join(root, "demo.mp4");
  const calls = join(root, "ffmpeg.json");
  writeFileSync(video, "real footage placeholder");
  writeFileSync(audio, "authored narration placeholder");
  // Substitute only media tools; exercise the public shell command and files.
  writeFileSync(
    join(root, "ffprobe"),
    `#!${process.execPath}
const video = process.argv.includes("v:0");
console.log(JSON.stringify({
  streams: process.env.MISSING_STREAM === (video ? "video" : "audio") ? [] : [{ codec_type: video ? "video" : "audio", duration: video ? process.env.VIDEO_STREAM_DURATION : undefined }],
  format: { duration: video ? "5" : process.env.AUDIO_DURATION },
}));
`,
    { mode: 0o755 },
  );
  writeFileSync(
    join(root, "ffmpeg"),
    `#!${process.execPath}
import { writeFileSync } from "node:fs";
const args = process.argv.slice(2);
writeFileSync(process.env.CALLS, JSON.stringify(args));
writeFileSync(args.at(-1), "encoded media");
process.exit(Number(process.env.ENCODE_EXIT ?? 0));
`,
    { mode: 0o755 },
  );
  const run = (overrides: Record<string, string> = {}) =>
    Bun.spawnSync(["bash", entry, video, audio, out], {
      env: {
        ...Bun.env,
        PATH: `${root}:${Bun.env.PATH}`,
        CALLS: calls,
        AUDIO_DURATION: "3",
        ...overrides,
      },
      timeout: PROCESS_DEADLINE_MS,
    });
  return { root, video, audio, out, calls, run };
}

test("muxes authored narration without keeping source audio or shortening the footage", () => {
  const { video, audio, out, calls, run } = fixture();
  const result = run();
  expect(result.exitCode, result.stderr.toString()).toBe(0);
  expect(result.stdout.toString().trim()).toBe(out);
  expect(readFileSync(out, "utf8")).toBe("encoded media");
  const args: string[] = JSON.parse(readFileSync(calls, "utf8"));
  const values = (flag: string) =>
    args.flatMap((arg, index) => (arg === flag ? [args[index + 1]] : []));
  expect(values("-i")).toEqual([video, audio]);
  expect(values("-map")).toEqual(["0:v:0", "1:a:0"]);
  expect(values("-af")).toEqual(["apad"]);
  expect(values("-t")).toEqual(["5"]);
  expect(values("-c:v")).toEqual(["libx264"]);
  expect(values("-c:a")).toEqual(["aac"]);
});

test.each([
  { env: { AUDIO_DURATION: "6" }, error: "longer than" },
  { env: { AUDIO_DURATION: "0" }, error: "positive duration" },
  { env: { AUDIO_DURATION: "N/A" }, error: "positive duration" },
  { env: { AUDIO_DURATION: "Infinity" }, error: "positive duration" },
  { env: { VIDEO_STREAM_DURATION: "2" }, error: "longer than" },
  { env: { MISSING_STREAM: "video" }, error: "video stream" },
  { env: { MISSING_STREAM: "audio" }, error: "audio stream" },
])("invalid media fails visibly before encoding: $env", ({ env, error }) => {
  const { out, calls, run } = fixture();
  const result = run(env);
  expect(result.exitCode).not.toBe(0);
  expect(result.stderr.toString()).toContain(error);
  expect(existsSync(calls)).toBe(false);
  expect(existsSync(out)).toBe(false);
});

test.each(["existing file", "dangling symlink"])(
  "preserves an output owned by someone else: %s",
  (kind) => {
    const { root, out, calls, run } = fixture();
    if (kind === "existing file") writeFileSync(out, "keep this");
    else symlinkSync(join(root, "absent.mp4"), out);
    const result = run();
    expect(result.exitCode).not.toBe(0);
    expect(result.stderr.toString()).toContain("already exists");
    expect(existsSync(calls)).toBe(false);
    expect(readdirSync(root)).toContain("demo.mp4");
    if (kind === "existing file") {
      expect(readFileSync(out, "utf8")).toBe("keep this");
    }
  },
);

test("a failed encode leaves no partial deliverable and can be retried", () => {
  const { root, out, run } = fixture();
  const failed = run({ ENCODE_EXIT: "1" });
  expect(failed.exitCode).not.toBe(0);
  expect(failed.stderr.toString()).toContain("encoding failed");
  expect(existsSync(out)).toBe(false);
  expect(readdirSync(root).some((name) => name.startsWith(".voiceover-"))).toBe(
    false,
  );
  expect(run().exitCode).toBe(0);
  expect(existsSync(out)).toBe(true);
});
