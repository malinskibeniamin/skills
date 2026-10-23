// Real media and browser checks for the demo stack; fixtures are not product evidence.
import { strict as assert } from "node:assert";
import {
  copyFileSync,
  mkdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { join } from "node:path";
import { type Browser, expect } from "@playwright/test";

export async function verifyDemoMedia(
  root: string,
  out: string,
  browser: Browser,
) {
  await verifyVoiceover(root, out);
  await verifyWalkthrough(root, out, browser);
  console.log(
    "PASS: narration mux, full frame count, audio then silence, overlong rejection; walkthrough playback, seeking, layouts, failure/recovery",
  );
}

async function command(args: string[]) {
  const process = Bun.spawn(args, { stdout: "pipe", stderr: "inherit" });
  const [stdout, exit] = await Promise.all([
    new Response(process.stdout).text(),
    process.exited,
  ]);
  assert.equal(exit, 0, `Failed: ${args.join(" ")}`);
  return stdout;
}

async function verifyVoiceover(root: string, out: string) {
  // Synthetic media checks the muxer, not any product or spoken-content claim.
  const input = join(out, "voiceover-fixture.webm");
  const audio = join(out, "voiceover-fixture.wav");
  const output = join(out, "voiceover-fixture.mp4");
  await command([
    "ffmpeg",
    "-v",
    "error",
    "-y",
    "-f",
    "lavfi",
    "-i",
    "testsrc2=size=320x180:rate=20:duration=3",
    "-f",
    "lavfi",
    "-i",
    "sine=frequency=220:duration=3",
    "-c:v",
    "libvpx",
    "-c:a",
    "libopus",
    input,
  ]);
  await command([
    "ffmpeg",
    "-v",
    "error",
    "-y",
    "-f",
    "lavfi",
    "-i",
    "sine=frequency=880:duration=1",
    audio,
  ]);
  rmSync(output, { force: true });
  await command([
    "bash",
    join(root, "scripts/demo-voiceover.sh"),
    input,
    audio,
    output,
  ]);
  const codec = async (stream: string) =>
    (
      await command([
        "ffprobe",
        "-v",
        "error",
        "-select_streams",
        stream,
        "-show_entries",
        "stream=codec_name",
        "-of",
        "csv=p=0",
        output,
      ])
    ).trim();
  assert.equal(await codec("v:0"), "h264");
  assert.equal(await codec("a:0"), "aac");
  assert.equal(
    Number(
      await command([
        "ffprobe",
        "-v",
        "error",
        "-select_streams",
        "v:0",
        "-count_frames",
        "-show_entries",
        "stream=nb_read_frames",
        "-of",
        "csv=p=0",
        output,
      ]),
    ),
    60,
    "Narration must not shorten the 60-frame fixture",
  );
  for (const [at, audible] of [
    [0.3, true],
    [2.5, false],
  ] as const) {
    const decode = Bun.spawn(
      [
        "ffmpeg",
        "-v",
        "error",
        "-i",
        output,
        "-ss",
        String(at),
        "-t",
        "0.1",
        "-ac",
        "1",
        "-ar",
        "8000",
        "-f",
        "s16le",
        "-",
      ],
      { stdout: "pipe", stderr: "inherit" },
    );
    const samples = new DataView(
      await new Response(decode.stdout).arrayBuffer(),
    );
    assert.equal(await decode.exited, 0);
    assert(samples.byteLength > 0, "Audio sample missing");
    let peak = 0;
    for (let i = 0; i < samples.byteLength; i += 2)
      peak = Math.max(peak, Math.abs(samples.getInt16(i, true)));
    assert.equal(
      peak > 100,
      audible,
      "Expect the fixture tone first, then padded silence",
    );
  }
  const overlong = join(out, "voiceover-overlong.wav");
  await command([
    "ffmpeg",
    "-v",
    "error",
    "-y",
    "-f",
    "lavfi",
    "-i",
    "sine=frequency=880:duration=4",
    overlong,
  ]);
  const rejectedOutput = join(out, `rejected-${crypto.randomUUID()}.mp4`);
  const rejected = Bun.spawn(
    [
      "bash",
      join(root, "scripts/demo-voiceover.sh"),
      input,
      overlong,
      rejectedOutput,
    ],
    { stdout: "pipe", stderr: "pipe" },
  );
  const error = await new Response(rejected.stderr).text();
  assert.notEqual(await rejected.exited, 0);
  assert.match(error, /longer than/);
  assert.equal(await Bun.file(rejectedOutput).exists(), false);
}

async function verifyWalkthrough(root: string, out: string, browser: Browser) {
  const directory = join(out, "walkthrough");
  mkdirSync(join(directory, "player"), { recursive: true });
  const files = [
    "index.html",
    "demo.mp4",
    "browser.vtt",
    "terminal.cast",
    "terminal-narration.mp3",
    "player/asciinema-player.min.js",
    "player/asciinema-player.css",
    "player/LICENSE",
  ];
  const html = readFileSync(
    join(root, "demo/templates/walkthrough.html"),
    "utf8",
  ).replaceAll("Product walkthrough", "Pipeline fixture walkthrough");
  writeFileSync(join(directory, "index.html"), html);
  copyFileSync(join(out, "voiceover-fixture.mp4"), join(directory, "demo.mp4"));
  writeFileSync(
    join(directory, "browser.vtt"),
    "WEBVTT\n\n00:00.000 --> 00:02.000\nSynthetic playback fixture.\n",
  );
  writeFileSync(
    join(directory, "terminal.cast"),
    `${[
      { version: 2, width: 60, height: 8, title: "Simulated terminal fixture" },
      [0, "o", "$ printf 'Ready\\n'\r\n"],
      [1, "o", "Ready\r\n"],
      [4, "o", "$ "],
    ]
      .map((value) => JSON.stringify(value))
      .join("\n")}\n`,
  );
  await command([
    "ffmpeg",
    "-v",
    "error",
    "-y",
    "-i",
    join(out, "voiceover-overlong.wav"),
    join(directory, "terminal-narration.mp3"),
  ]);
  for (const name of ["asciinema-player.min.js", "asciinema-player.css"]) {
    copyFileSync(
      join(root, "node_modules/asciinema-player/dist/bundle", name),
      join(directory, "player", name),
    );
  }
  copyFileSync(
    join(root, "node_modules/asciinema-player/LICENSE"),
    join(directory, "player/LICENSE"),
  );
  const routes = Object.fromEntries(
    files.map((name) => [
      `/${name}`,
      new Response(Bun.file(join(directory, name))),
    ]),
  );
  routes["/"] = new Response(Bun.file(join(directory, "index.html")));
  const server = Bun.serve({
    hostname: "127.0.0.1",
    port: 0,
    routes,
    fetch: () => new Response("Missing", { status: 404 }),
  });
  const page = await browser.newPage({
    viewport: { width: 1280, height: 1000 },
  });
  const errors: string[] = [];
  page.on("pageerror", (error) => errors.push(error.message));
  try {
    const range = await fetch(new URL("terminal-narration.mp3", server.url), {
      headers: { Range: "bytes=0-99" },
    });
    assert.equal(range.status, 206, "Audio host must support seeking");
    await range.arrayBuffer();
    // Observe the real narration element without adding a test-only production API.
    await page.addInitScript(() => {
      const play = HTMLMediaElement.prototype.play;
      HTMLMediaElement.prototype.play = function observeNarration() {
        if (
          this instanceof HTMLAudioElement &&
          this.src.endsWith("terminal-narration.mp3")
        ) {
          this.id = "observed-narration";
          this.hidden = true;
          document.body.append(this);
        }
        return play.call(this);
      };
    });
    await page.goto(server.url.href);
    await expect(page.locator("#terminal-status")).toBeHidden();
    await expect(page.locator("#terminal-error")).toBeHidden();
    await page.locator("#browser").evaluate(async (video: HTMLVideoElement) => {
      await video.play();
      video.pause();
      video.currentTime = 1;
    });
    await expect
      .poll(() =>
        page
          .locator("#browser")
          .evaluate((v: HTMLVideoElement) => v.readyState),
      )
      .toBeGreaterThan(1);
    await expect(page.locator("#browser-error")).toBeHidden();
    const terminal = page.locator("#terminal");
    await terminal.getByRole("button", { name: "Play", exact: true }).click();
    const audio = page.locator("#observed-narration");
    await expect
      .poll(() => audio.evaluate((a: HTMLAudioElement) => a.currentTime))
      .toBeGreaterThan(0);
    await terminal.getByRole("button", { name: "Pause", exact: true }).click();
    await expect
      .poll(() => audio.evaluate((a: HTMLAudioElement) => a.paused))
      .toBe(true);
    await page.keyboard.press("5");
    await expect
      .poll(() =>
        audio.evaluate((a: HTMLAudioElement) => Math.abs(a.currentTime - 2)),
      )
      .toBeLessThan(0.15);
    await page.getByText("Read the terminal transcript").click();
    for (const [name, width] of [
      ["desktop", 1280],
      ["mobile", 390],
    ] as const) {
      await page.setViewportSize({ width, height: 1000 });
      assert(
        await page.evaluate(
          () => document.documentElement.scrollWidth <= innerWidth,
        ),
        "Walkthrough overflows viewport",
      );
      await page.screenshot({
        path: join(directory, `${name}.png`),
        fullPage: true,
      });
    }
    assert.deepEqual(errors, []);
    await page.route("**/terminal-narration.mp3", (route) =>
      route.fulfill({ status: 404, body: "Missing" }),
    );
    await page.reload();
    await expect(page.locator("#terminal-error")).toBeVisible();
    await page.unroute("**/terminal-narration.mp3");
    await page.reload();
    await expect(
      page
        .locator("#terminal")
        .getByRole("button", { name: "Play", exact: true }),
    ).toBeVisible();
    await expect(page.locator("#terminal-error")).toBeHidden();
  } finally {
    await page.close();
    server.stop(true);
  }
}
