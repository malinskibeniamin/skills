// Media-only checks: short ffmpeg takes and real browser recordings -> compose
// CLI -> decoded pixels. The canary job installs ffmpeg/ffprobe; protocol CI does not.
// This fixture checks the pipeline, never replaces product-specific evidence.
import { strict as assert } from "node:assert";
import { mkdirSync, readFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { chromium, expect, type Locator, type Page } from "@playwright/test";
import { z } from "zod";

const root = resolve(import.meta.dir, "..");
const out = resolve(Bun.argv[2] ?? join(root, ".context/pr-video-canary"));
mkdirSync(out, { recursive: true });

async function command(args: string[], env: Record<string, string> = {}) {
  const process = Bun.spawn(args, {
    cwd: root,
    env: { ...Bun.env, ...env },
    stdout: "pipe",
    stderr: "inherit",
  });
  const [stdout, exit] = await Promise.all([
    new Response(process.stdout).text(),
    process.exited,
  ]);
  assert.equal(exit, 0, `Failed: ${args.join(" ")}`);
  return stdout;
}

const server = Bun.serve({
  hostname: "127.0.0.1",
  port: 0,
  async fetch(request) {
    if (new URL(request.url).pathname === "/save") {
      const data: unknown = await request.json();
      const failed =
        typeof data === "object" &&
        data !== null &&
        "fail" in data &&
        data.fail === true;
      return new Response(failed ? "Unavailable" : "Saved", {
        status: failed ? 503 : 200,
      });
    }
    return new Response(
      Bun.file(join(root, "scripts/fixtures/pr-video-canary.html")),
    );
  },
});

type Box = { x: number; y: number; width: number; height: number };
type Sample = { state: string; at: number; target: Box; pulse?: boolean };
const focus = { x: 184, y: 128, width: 912, height: 392 };
const samples: Record<string, Sample[]> = {};
const browser = await chromium.launch().catch((cause: unknown) => {
  server.stop(true);
  throw cause;
});
try {
  await verifyIdleRejection();
  const shortTakePacing = await verifyShortTakePacing();
  for (const side of ["before", "after"]) {
    const context = await browser.newContext({
      viewport: { width: 1280, height: 720 },
      recordVideo: { dir: out, size: { width: 1280, height: 720 } },
    });
    try {
      await context.addInitScript({
        path: join(root, "scripts/pr-video-cursor.js"),
      });
      const page = await context.newPage();
      const started = performance.now();
      const steps = [{ at: 0, caption: "We enter a task name." }];
      const states: Sample[] = [];
      const mark = (caption: string) =>
        steps.push({ at: (performance.now() - started) / 1000, caption });
      const clickSample = async (state: string) => {
        const target = await page
          .getByRole("button", { name: "Save task" })
          .boundingBox();
        assert(target, `${state}: clicked control missing`);
        states.push({
          state: `${state}-click`,
          at: (performance.now() - started) / 1000 + 0.2,
          target,
          pulse: true,
        });
      };
      const capture = async (
        state: string,
        control: Locator = page.getByRole("button", { name: "Save task" }),
      ) => {
        // Assert readiness before holding readable evidence; not a test wait.
        await Bun.sleep(3000);
        const target = await control.boundingBox();
        assert(target, `${state}: action target missing`);
        states.push({
          state,
          at: (performance.now() - started) / 1000 - 0.3,
          target,
        });
        await page.screenshot({ path: join(out, `${side}-${state}-ui.png`) });
      };
      await page.goto(server.url.href);
      await page
        .getByLabel("Task name")
        .pressSequentially("Review demo", { delay: 90 });
      await capture("typing", page.getByLabel("Task name"));
      if (side === "before") {
        mark("Save confirms the task.");
        await page.getByRole("button", { name: "Save task" }).click();
        await clickSample("success");
        await expect(page.getByRole("status")).toHaveText("Saved: Review demo");
        await capture("success");
      } else {
        mark("Save fails; the draft stays intact.");
        await page.getByLabel("Simulate unavailable service").check();
        await page.getByRole("button", { name: "Save task" }).click();
        await clickSample("error");
        await expect(page.getByRole("alert")).toHaveText(
          "Service unavailable. Try again.",
        );
        await expect(page.getByLabel("Task name")).toHaveValue("Review demo");
        await capture("error");
        mark("Retry saves the task.");
        await page.getByLabel("Simulate unavailable service").uncheck();
        await page.getByRole("button", { name: "Save task" }).click();
        await clickSample("recovery");
        await expect(page.getByRole("status")).toHaveText("Saved: Review demo");
        await capture("recovery");
      }
      const video = page.video();
      assert(video, "Browser recording missing");
      await context.close();
      await video.saveAs(join(out, `${side}.webm`));
      await video.delete();
      await Bun.write(
        join(out, `${side}.webm.steps.json`),
        JSON.stringify({ title: "Save, fail, and recover", steps }),
      );
      samples[side] = states;
    } finally {
      await context.close();
    }
  }

  await command(
    [
      "bash",
      join(root, "scripts/pr-video.sh"),
      "compose",
      join(out, "before.webm"),
      join(out, "after.webm"),
      out,
    ],
    {
      PR_VIDEO_RENDERER: "hyperframes",
      PR_VIDEO_TITLE: "Render canary: save vs failure and recovery",
      PR_VIDEO_BEFORE_LABEL: "Success path (fixture): saved task",
      PR_VIDEO_AFTER_LABEL: "Recovery path (fixture): error then retry",
      PR_VIDEO_FOCUS: `${focus.x}:${focus.y}:${focus.width}:${focus.height}`,
    },
  );
  const metadata = JSON.parse(
    await command([
      "ffprobe",
      "-v",
      "error",
      "-show_entries",
      "stream=width,height:format=duration",
      "-of",
      "json",
      join(out, "before-after.mp4"),
    ]),
  );
  assert.equal(metadata.streams[0].width, 1920);
  assert.equal(metadata.streams[0].height, 880);
  const durations = await Promise.all(
    ["before", "after"].map(async (side) =>
      Number(
        await command([
          "ffprobe",
          "-v",
          "error",
          "-show_entries",
          "format=duration",
          "-of",
          "csv=p=0",
          join(out, `${side}.webm`),
        ]),
      ),
    ),
  );
  assert(
    Math.abs(Number(metadata.format.duration) - Math.max(5, ...durations)) <
      0.15,
    "Rendered duration must be at least 5 seconds and preserve longer recordings",
  );

  const page = await browser.newPage();
  const demo = await verifyDemo(page);
  // Exercise the allowed 60-character labels against the real output layout.
  await page.setContent(
    readFileSync(join(out, "hyperframes/index.html"), "utf8").replace(
      /<script[\s\S]*?<\/script>/g,
      "",
    ),
  );
  for (const [id, text] of [
    ["before-chip", `Previous: ${"W".repeat(50)}`],
    ["after-chip", `New: ${"W".repeat(55)}`],
  ]) {
    assert(id && text);
    const layout = await page.locator(`#${id}`).evaluate((element, text) => {
      element.textContent = text;
      return {
        bottom: element.getBoundingClientRect().bottom,
        width: element.clientWidth,
        scrollWidth: element.scrollWidth,
      };
    }, text);
    assert(layout.bottom <= 190, `${id}: label overlaps the recorded UI`);
    assert(layout.scrollWidth <= layout.width, `${id}: label overflows`);
  }
  const subtitleLayout = await page
    .locator(".caption")
    .first()
    .evaluate((element) => {
      const text = element.querySelector("span");
      if (!text) throw new Error("Subtitle text missing");
      text.textContent =
        "We save this task, then check the confirmation without losing the text we entered.";
      const box = element.getBoundingClientRect();
      const content = text.getBoundingClientRect();
      return {
        inset: content.left - box.left,
        bottom: content.bottom,
        top: content.top,
        height: content.height,
        lineHeight: Number.parseFloat(getComputedStyle(text).lineHeight),
        boxTop: box.top,
        boxBottom: box.bottom,
      };
    });
  assert(
    subtitleLayout.inset >= 24,
    "Narration subtitles need horizontal padding",
  );
  assert(
    subtitleLayout.top >= subtitleLayout.boxTop &&
      subtitleLayout.bottom <= subtitleLayout.boxBottom,
    "Narration subtitle overflows its background",
  );
  assert(
    subtitleLayout.height <= subtitleLayout.lineHeight * 2 + 1,
    "Keep narration readable within 2 lines",
  );
  const metrics = [];
  for (const [side, states] of Object.entries(samples)) {
    const duration = durations[side === "before" ? 0 : 1];
    assert(duration && duration > 0, `${side}: recording duration missing`);
    for (const { state, at, target, pulse } of states) {
      const renderedAt = at * Math.max(1, 5 / duration);
      const frame = join(out, `${side}-${state}-frame.png`);
      const source = join(out, `${side}-${state}-source.png`);
      await extract(join(out, "before-after.mp4"), renderedAt, frame);
      await extract(join(out, `${side}.webm`), at, source);
      const metric = await compare(
        page,
        frame,
        source,
        side === "before" ? 40 : 980,
        focus,
        target,
      );
      // Raw recording is the independent oracle. Blank video and plain ffmpeg
      // fallback cannot satisfy both the panel and visible-text checks.
      assert(
        metric.panelError < 12,
        `${side}/${state}: recorded UI changed or disappeared (${metric.panelError})`,
      );
      assert(metric.title > 500, `${side}/${state}: title missing`);
      assert(metric.label > 100, `${side}/${state}: side label missing`);
      assert(metric.caption > 100, `${side}/${state}: step caption missing`);
      assert(
        metric.targetOutline > 200,
        `${side}/${state}: action target highlight missing (${metric.targetOutline})`,
      );
      assert(
        metric.cursor > 40,
        `${side}/${state}: visible cursor missing (${metric.cursor})`,
      );
      if (pulse)
        assert(
          metric.clickRing > 15,
          `${side}/${state}: readable click ring missing (${metric.clickRing})`,
        );
      metrics.push({ side, state, at, renderedAt, ...metric });
    }
  }
  await page.close();
  await Bun.write(
    join(out, "receipt.json"),
    JSON.stringify(
      {
        renderer: JSON.parse(readFileSync(join(root, "package.json"), "utf8"))
          .devDependencies.hyperframes,
        metadata,
        focus,
        metrics,
        shortTakePacing,
        demo,
      },
      null,
      2,
    ),
  );
  console.log(
    `PASS: ${metrics.length} decoded-frame checks (focused UI, title, labels, captions, cursor, action target); typing/success/error/recovery; short-take MP4/GIF timing and motion; idle/crop rejection; single-take subtitles and execution model; ${out}`,
  );
} finally {
  try {
    await browser.close();
  } finally {
    server.stop(true);
  }
}

async function verifyIdleRejection() {
  const directory = join(out, "idle-rejection");
  mkdirSync(directory, { recursive: true });
  for (const scenario of [
    {
      name: "burst-then-idle",
      duration: 1,
      filter: "tpad=stop_mode=clone:stop_duration=9",
      focus: "",
      error: /idle from .* for at least 5s/,
    },
    {
      name: "activity-outside-focus",
      duration: 2,
      filter: "drawbox=x=0:y=0:w=160:h=90:color=white:t=fill",
      focus: "0:0:160:90",
      error: /is static/,
    },
  ]) {
    const video = join(directory, `${scenario.name}.mp4`);
    await command([
      "ffmpeg",
      "-v",
      "error",
      "-y",
      "-f",
      "lavfi",
      "-i",
      `testsrc2=size=320x180:rate=30:duration=${scenario.duration}`,
      "-vf",
      scenario.filter,
      "-c:v",
      "libx264",
      video,
    ]);
    const child = Bun.spawn(
      [
        "bash",
        join(root, "scripts/pr-video.sh"),
        "compose",
        video,
        video,
        directory,
      ],
      {
        env: {
          ...Bun.env,
          PR_VIDEO_BEFORE_LABEL: "Previous: source fixture",
          PR_VIDEO_AFTER_LABEL: "New: source fixture",
          PR_VIDEO_FOCUS: scenario.focus,
        },
        stdout: "pipe",
        stderr: "pipe",
      },
    );
    const [stderr, stdout, exit] = await Promise.all([
      new Response(child.stderr).text(),
      new Response(child.stdout).text(),
      child.exited,
    ]);
    assert.notEqual(
      exit,
      0,
      `${scenario.name}: source quality check must fail`,
    );
    assert.match(
      stderr,
      scenario.error,
      "Reject the source, not just duplicate files",
    );
    assert.equal(stdout, "", "Failed quality checks must not publish paths");
  }
}

async function verifyDemo(page: Page) {
  const directory = join(out, "single-take");
  const input = join(directory, "flow.webm");
  mkdirSync(directory, { recursive: true });
  await Bun.write(input, Bun.file(join(out, "after.webm")));
  const sidecar = z
    .object({
      title: z.string(),
      steps: z.array(z.object({ at: z.number(), caption: z.string() })),
    })
    .parse(
      JSON.parse(readFileSync(join(out, "after.webm.steps.json"), "utf8")),
    );
  await Bun.write(
    `${input}.steps.json`,
    JSON.stringify({
      ...sidecar,
      diagram: [
        "Browser form",
        "POST /save",
        "503: input retained",
        "Retry → saved task",
      ],
      steps: sidecar.steps.map(
        (step: { at: number; caption: string }, i: number) => ({
          ...step,
          active: [0, 2, 3][i],
        }),
      ),
    }),
  );
  await command([
    "bash",
    join(root, "scripts/pr-video.sh"),
    "demo",
    input,
    directory,
  ]);
  await page.setContent(
    readFileSync(join(directory, "hyperframes/index.html"), "utf8"),
  );
  const checks = [];
  for (const [i, step] of sidecar.steps.entries()) {
    const frame = join(directory, `step-${i}.png`);
    const source = join(directory, `source-${i}.png`);
    await extract(join(directory, "demo.mp4"), step.at + 1, frame);
    await extract(input, step.at + 1, source);
    const activeIndex = [0, 2, 3][i];
    assert(activeIndex !== undefined);
    const active = await page
      .locator(`#step-${i} .node`)
      .nth(activeIndex)
      .boundingBox();
    assert(active, "Expected execution node missing");
    const counts = await page.evaluate(
      async ({ base64, source, active }) => {
        const image = new Image();
        image.src = `data:image/png;base64,${base64}`;
        await image.decode();
        const canvas = document.createElement("canvas");
        canvas.width = image.width;
        canvas.height = image.height;
        const context = canvas.getContext("2d");
        if (!context) throw new Error("Canvas unavailable");
        context.drawImage(image, 0, 0);
        const count = (
          x: number,
          y: number,
          width: number,
          height: number,
          blue = false,
        ) => {
          const data = context.getImageData(x, y, width, height).data;
          let pixels = 0;
          for (let j = 0; j < data.length; j += 4) {
            const r = data[j] ?? 0,
              g = data[j + 1] ?? 0,
              b = data[j + 2] ?? 0;
            if (blue ? b > 160 && b > r * 1.4 : r > 200 && g > 200 && b > 200)
              pixels++;
          }
          return pixels;
        };
        const counts = {
          footage: count(96, 220, 1160, 600),
          subtitle: count(192, 900, 1536, 100),
          diagram: count(1300, 160, 524, 720),
          active: count(active.x, active.y, active.width, active.height, true),
        };
        // Compare the recorded pixels, not just a nonempty/white video rectangle.
        const actual = context.getImageData(96, 194, 1160, 652).data;
        const original = new Image();
        original.src = `data:image/png;base64,${source}`;
        await original.decode();
        context.clearRect(0, 0, canvas.width, canvas.height);
        context.drawImage(original, 96, 193.75, 1160, 652.5);
        const expected = context.getImageData(96, 194, 1160, 652).data;
        let difference = 0;
        for (let j = 0; j < actual.length; j += 4) {
          for (let c = 0; c < 3; c++)
            difference += Math.abs(
              (actual[j + c] ?? 0) - (expected[j + c] ?? 0),
            );
        }
        return { ...counts, panelError: difference / (1160 * 652 * 3) };
      },
      {
        base64: readFileSync(frame).toString("base64"),
        source: readFileSync(source).toString("base64"),
        active,
      },
    );
    assert(counts.footage > 10000, "Demo lost its real footage");
    assert(
      counts.panelError < 12,
      `Demo changed its recording (${counts.panelError})`,
    );
    assert(counts.subtitle > 100, "Demo subtitle missing");
    assert(
      counts.diagram > 500 && counts.active > 100,
      "Execution model or active step missing",
    );
    checks.push(counts);
  }
  // Stress the published limits without hiding or truncating user text.
  await page.locator("h1").evaluate((element) => {
    element.textContent = "W".repeat(80);
  });
  await page
    .locator(".caption")
    .first()
    .evaluate((element) => {
      element.textContent = "W".repeat(80);
    });
  const aside = page.locator("aside").first();
  await aside.evaluate((element) => {
    const node = element.querySelector(".node");
    if (!node) throw new Error("Diagram node missing");
    for (const old of element.querySelectorAll(".node, .arrow")) old.remove();
    for (let i = 0; i < 6; i++) {
      const next = node.cloneNode(true);
      next.textContent = "W".repeat(60);
      element.append(next);
      if (i < 5) {
        const arrow = document.createElement("div");
        arrow.className = "arrow";
        arrow.textContent = "↓";
        element.append(arrow);
      }
    }
  });
  for (const element of [aside, page.locator(".caption").first()]) {
    assert(
      await element.evaluate(
        (element) =>
          element.scrollHeight <= element.clientHeight &&
          element.scrollWidth <= element.clientWidth,
      ),
      "Max-length explanation overflows",
    );
  }
  // Wider fallback metrics reproduce the Linux overflow on macOS too.
  for (const family of ["system-ui, sans-serif", "serif"]) {
    const title = await page.locator("h1").evaluate((element, family) => {
      element.style.fontFamily = family;
      const { height, bottom } = element.getBoundingClientRect();
      return { height, bottom };
    }, family);
    assert(
      title.height > 0 && title.bottom <= 160,
      `Title overlaps footage (${family}, bottom=${title.bottom})`,
    );
  }
  return checks;
}

async function verifyShortTakePacing() {
  const directory = join(out, "short-take-pacing");
  mkdirSync(directory, { recursive: true });
  for (const side of ["before", "after"]) {
    await command([
      "ffmpeg",
      "-v",
      "error",
      "-y",
      "-f",
      "lavfi",
      "-i",
      "testsrc2=size=160x90:rate=30:duration=2",
      "-vf",
      `drawbox=x=0:y=0:w=40:h=40:color=${side === "before" ? "red" : "green"}:t=fill:enable='lt(t,1)',drawbox=x=0:y=0:w=40:h=40:color=blue:t=fill:enable='gte(t,1)'`,
      "-c:v",
      "libvpx",
      join(directory, `${side}.webm`),
    ]);
  }
  await command(
    [
      "bash",
      join(root, "scripts/pr-video.sh"),
      "compose",
      join(directory, "before.webm"),
      join(directory, "after.webm"),
      directory,
    ],
    {
      PR_VIDEO_RENDERER: "ffmpeg",
      PR_VIDEO_BEFORE_LABEL: "Fixture: red then blue",
      PR_VIDEO_AFTER_LABEL: "Fixture: green then blue",
      PR_VIDEO_FOCUS: "",
    },
  );
  const durations: Record<string, number> = {};
  for (const extension of ["mp4", "gif"]) {
    const duration = Number(
      await command([
        "ffprobe",
        "-v",
        "error",
        "-show_entries",
        "format=duration",
        "-of",
        "csv=p=0",
        join(directory, `before-after.${extension}`),
      ]),
    );
    assert(
      Math.abs(duration - 5) < 0.05,
      `${extension}: short take must last 5s, got ${duration}`,
    );
    durations[extension] = duration;
  }
  const frame = async (at: number) => {
    const path = join(directory, `${at}.rgb`);
    await command([
      "ffmpeg",
      "-v",
      "error",
      "-y",
      "-ss",
      String(at),
      "-i",
      join(directory, "before-after.mp4"),
      "-vf",
      "crop=2:2:20:20",
      "-frames:v",
      "1",
      "-pix_fmt",
      "rgb24",
      "-f",
      "rawvideo",
      path,
    ]);
    const pixels = readFileSync(path);
    return { red: pixels.readUInt8(0), blue: pixels.readUInt8(2) };
  };
  const early = await frame(1.5);
  const late = await frame(3.5);
  assert(
    early.red > 200 && early.blue < 40,
    "Action must still show red at 1.5s; padding alone is not slowdown",
  );
  assert(
    late.red < 40 && late.blue > 200,
    "Action must progress to blue by 3.5s",
  );
  return { durations, early, late };
}

async function extract(video: string, at: number, output: string) {
  await command([
    "ffmpeg",
    "-v",
    "error",
    "-y",
    "-ss",
    String(at),
    "-i",
    video,
    "-frames:v",
    "1",
    output,
  ]);
}

async function compare(
  page: Page,
  frame: string,
  source: string,
  left: number,
  focus: { x: number; y: number; width: number; height: number },
  target: Box,
) {
  const image = (path: string) =>
    `data:image/png;base64,${readFileSync(path).toString("base64")}`;
  return page.evaluate(
    async ({ frame, source, left, focus, target }) => {
      const decode = async (url: string) => {
        const img = new Image();
        img.src = url;
        await img.decode();
        return img;
      };
      const canvas = document.createElement("canvas");
      canvas.width = 1920;
      canvas.height = 880;
      const context = canvas.getContext("2d");
      if (!context) throw new Error("Canvas unavailable");
      context.drawImage(await decode(frame), 0, 0);
      const actual = context.getImageData(left + 8, 198, 884, 490).data;
      const lightPixels = (
        x: number,
        y: number,
        width: number,
        height: number,
      ) => {
        const pixels = context.getImageData(x, y, width, height).data;
        let count = 0;
        for (let i = 0; i < pixels.length; i += 4) {
          if (
            (pixels[i] ?? 0) > 200 &&
            (pixels[i + 1] ?? 0) > 200 &&
            (pixels[i + 2] ?? 0) > 200
          )
            count++;
        }
        return count;
      };
      const text = {
        title: lightPixels(40, 36, 1800, 60),
        label: lightPixels(left, 116, 900, 64),
        caption: lightPixels(left, 720, 900, 96),
      };
      const scale = Math.min(900 / focus.width, 506 / focus.height);
      const origin = {
        x: left + (900 - focus.width * scale) / 2,
        y: 190 + (506 - focus.height * scale) / 2,
      };
      const bounds = {
        x: origin.x + (target.x - focus.x) * scale,
        y: origin.y + (target.y - focus.y) * scale,
        width: target.width * scale,
        height: target.height * scale,
      };
      const pixels = context.getImageData(0, 0, 1920, 880).data;
      let targetOutline = 0;
      let cursor = 0;
      let clickRing = 0;
      for (
        let y = Math.floor(bounds.y - 10);
        y < bounds.y + bounds.height + 10;
        y++
      ) {
        for (
          let x = Math.floor(bounds.x - 10);
          x < bounds.x + bounds.width + 10;
          x++
        ) {
          const i = (y * 1920 + x) * 4;
          if (
            (pixels[i] ?? 0) < 180 ||
            (pixels[i + 1] ?? 255) > 110 ||
            (pixels[i + 2] ?? 255) > 110
          )
            continue;
          const inside =
            x > bounds.x + 4 &&
            x < bounds.x + bounds.width - 4 &&
            y > bounds.y + 4 &&
            y < bounds.y + bounds.height - 4;
          if (inside) cursor++;
          else targetOutline++;
          // The left arc is separate from the arrow, control border, and text.
          if (
            x > bounds.x + bounds.width / 2 - 42 &&
            x < bounds.x + bounds.width / 2 - 12 &&
            Math.abs(y - bounds.y - bounds.height / 2) < 10
          )
            clickRing++;
        }
      }
      context.clearRect(0, 0, 1920, 880);
      context.fillStyle = "white";
      context.fillRect(left, 190, 900, 506);
      const width = focus.width * scale;
      const height = focus.height * scale;
      context.drawImage(
        await decode(source),
        focus.x,
        focus.y,
        focus.width,
        focus.height,
        left + (900 - width) / 2,
        190 + (506 - height) / 2,
        width,
        height,
      );
      const expected = context.getImageData(left + 8, 198, 884, 490).data;
      let difference = 0;
      for (let i = 0; i < actual.length; i += 4) {
        for (let channel = 0; channel < 3; channel++)
          difference += Math.abs(
            (actual[i + channel] ?? 0) - (expected[i + channel] ?? 0),
          );
      }
      return {
        panelError: difference / (884 * 490 * 3),
        targetOutline,
        cursor,
        clickRing,
        ...text,
      };
    },
    { frame: image(frame), source: image(source), left, focus, target },
  );
}
