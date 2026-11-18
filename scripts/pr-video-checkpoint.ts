// Media-canary support: resolve checkpoints in encoded footage, not host wall time.
import { strict as assert } from "node:assert";

const fps = 25;
async function ffmpeg(args: string[]) {
  const child = Bun.spawn(["ffmpeg", "-v", "error", ...args], {
    stdout: "pipe",
    stderr: "pipe",
  });
  const [stdout, stderr, exit] = await Promise.all([
    new Response(child.stdout).arrayBuffer(),
    new Response(child.stderr).text(),
    child.exited,
  ]);
  assert.equal(exit, 0, `Cannot decode recorded checkpoint: ${stderr}`);
  return new Uint8Array(stdout);
}

export async function recordedCheckpoint(video: string, reference: string) {
  const stats = new TextDecoder().decode(
    await ffmpeg([
      "-i",
      video,
      "-loop",
      "1",
      "-i",
      reference,
      "-filter_complex",
      `[0:v]fps=${fps},setpts=PTS-STARTPTS[v];[v][1:v]ssim=stats_file=-:shortest=1`,
      "-an",
      "-f",
      "null",
      "-",
    ]),
  );
  let best = { at: 0, similarity: 0 };
  for (const line of stats.split("\n")) {
    const match = /n:(\d+).*All:([\d.]+)/.exec(line);
    if (match && Number(match[2]) > best.similarity)
      best = { at: (Number(match[1]) - 1) / fps, similarity: Number(match[2]) };
  }
  assert(
    best.similarity > 0.99,
    `UI checkpoint not found: ${reference} (${best.similarity})`,
  );
  return best;
}

export async function recordedClick(
  video: string,
  target: { x: number; y: number; width: number; height: number },
  from: number,
  until: number,
) {
  // Observe the pulse's left arc: separate from the arrow, border and text.
  // Stable UI checkpoints bound this search so a later click cannot stand in.
  const x = Math.floor(target.x + target.width / 2 - 42);
  const y = Math.floor(target.y + target.height / 2 - 10);
  const pixels = await ffmpeg([
    "-i",
    video,
    "-vf",
    `fps=${fps},format=rgb24,crop=30:20:${x}:${y}`,
    "-an",
    "-pix_fmt",
    "rgb24",
    "-f",
    "rawvideo",
    "-",
  ]);
  const bytesPerFrame = 30 * 20 * 3;
  let best = { at: 0, pulsePixels: 0 };
  for (
    let offset = 0;
    offset + bytesPerFrame <= pixels.length;
    offset += bytesPerFrame
  ) {
    const at = offset / bytesPerFrame / fps;
    if (at <= from || at >= until) continue;
    let pulsePixels = 0;
    for (let i = offset; i < offset + bytesPerFrame; i += 3)
      if (
        (pixels[i] ?? 0) >= 180 &&
        (pixels[i + 1] ?? 255) <= 110 &&
        (pixels[i + 2] ?? 255) <= 110
      )
        pulsePixels++;
    if (pulsePixels > best.pulsePixels) best = { at, pulsePixels };
  }
  assert(
    best.pulsePixels > 15,
    "Readable click pulse not found in recorded state interval",
  );
  return best;
}
