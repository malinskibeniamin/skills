#!/usr/bin/env bun
import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { PNG } from "pngjs";
import { z } from "zod";

const artifactSchema = z
  .object({
    id: z.string().min(1),
    path: z.string().min(1),
    sha256: z.string().regex(/^[a-f0-9]{64}$/),
  })
  .strict();
const manifestSchema = z
  .object({
    schema_version: z.literal(1),
    artifacts: z.array(artifactSchema).min(1),
    comparisons: z
      .array(
        z
          .object({
            baseline: z.string().min(1),
            candidate: z.string().min(1),
            expect: z.enum(["changed", "unchanged"]),
            changed_pixels: z.number().int().nonnegative().optional(),
          })
          .strict(),
      )
      .default([]),
  })
  .strict();

try {
  const [path, ...extra] = process.argv.slice(2);
  if (!path || extra.length)
    throw new Error("Usage: check-evidence.ts <manifest.json>");
  const raw: unknown = JSON.parse(readFileSync(path, "utf8"));
  const manifest = manifestSchema.parse(raw);
  const files = new Map<string, Buffer>();
  const artifacts = manifest.artifacts.map((artifact) => {
    if (files.has(artifact.id))
      throw new Error(`Duplicate artifact id: ${artifact.id}`);
    const bytes = readFileSync(resolve(dirname(path), artifact.path));
    const sha256 = createHash("sha256").update(bytes).digest("hex");
    if (sha256 !== artifact.sha256)
      throw new Error(`${artifact.id}: sha256 mismatch`);
    files.set(artifact.id, bytes);
    return { id: artifact.id, sha256 };
  });
  const comparisons = manifest.comparisons.map((comparison) => {
    const before = files.get(comparison.baseline);
    const after = files.get(comparison.candidate);
    if (!before || !after)
      throw new Error("Comparison references an unknown artifact");
    const baseline = PNG.sync.read(before);
    const candidate = PNG.sync.read(after);
    if (
      baseline.width !== candidate.width ||
      baseline.height !== candidate.height
    ) {
      throw new Error(
        "Comparison dimensions differ; recapture at the same viewport and scale",
      );
    }
    let changedPixels = 0;
    for (let offset = 0; offset < baseline.data.length; offset += 4) {
      if (
        !baseline.data
          .subarray(offset, offset + 4)
          .equals(candidate.data.subarray(offset, offset + 4))
      ) {
        changedPixels++;
      }
    }
    const label = `${comparison.baseline} -> ${comparison.candidate}`;
    if ((comparison.expect === "changed") !== changedPixels > 0) {
      throw new Error(
        `${label}: expected ${comparison.expect}, measured ${changedPixels} changed pixels`,
      );
    }
    if (
      comparison.changed_pixels !== undefined &&
      comparison.changed_pixels !== changedPixels
    ) {
      throw new Error(
        `${label}: claimed changed_pixels ${comparison.changed_pixels}, measured ${changedPixels}`,
      );
    }
    return {
      baseline: comparison.baseline,
      candidate: comparison.candidate,
      width: baseline.width,
      height: baseline.height,
      changed_pixels: changedPixels,
    };
  });
  console.log(JSON.stringify({ status: "pass", artifacts, comparisons }));
} catch (error) {
  console.error(
    JSON.stringify({
      status: "fail",
      error: error instanceof Error ? error.message : String(error),
    }),
  );
  process.exitCode = 1;
}
