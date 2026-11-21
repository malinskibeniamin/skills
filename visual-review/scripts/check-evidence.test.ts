import { afterEach, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { existsSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { PNG } from "pngjs";

const directories: string[] = [];
afterEach(() => {
  for (const directory of directories.splice(0)) {
    rmSync(directory, { recursive: true, force: true });
  }
});

function fixture() {
  const directory = mkdtempSync(join(tmpdir(), "visual-evidence-"));
  directories.push(directory);
  return {
    artifact(id: string, content: Buffer = Buffer.from("measured output")) {
      writeFileSync(join(directory, id), content);
      return {
        id,
        path: id,
        sha256: createHash("sha256").update(content).digest("hex"),
      };
    },
    run(manifest: object) {
      const path = join(directory, "evidence.json");
      writeFileSync(path, JSON.stringify(manifest));
      const script = fileURLToPath(
        new URL("check-evidence.ts", import.meta.url),
      );
      if (!existsSync(script))
        throw new Error(`Missing evidence CLI: ${script}`);
      const result = Bun.spawnSync([process.execPath, script, path], {
        cwd: tmpdir(),
      });
      return {
        code: result.exitCode,
        stdout: result.stdout.toString(),
        stderr: result.stderr.toString(),
      };
    },
  };
}

test("verifies artifact bytes relative to the manifest, not the invoking repository", () => {
  const f = fixture();
  const artifact = f.artifact("measurement.txt");
  const result = f.run({ schema_version: 1, artifacts: [artifact] });
  expect(result.code).toBe(0);
  expect(JSON.parse(result.stdout)).toMatchObject({
    status: "pass",
    artifacts: [{ id: artifact.id, sha256: artifact.sha256 }],
  });
});

function image(rgba: number[], width = 2, filterType: 0 | 4 = 0) {
  const png = new PNG({ width, height: 2 });
  png.data = Buffer.from(rgba);
  return PNG.sync.write(png, { filterType });
}

test.each([
  ["color", [0, 76, 0, 255]],
  ["alpha", [255, 0, 0, 128]],
])("measures %s-only changes through the PNG CLI comparison", (_name, rgba) => {
  const f = fixture();
  const baseline = f.artifact(
    "before.png",
    image(Array(4).fill([255, 0, 0, 255]).flat()),
  );
  const candidate = f.artifact("after.png", image(Array(4).fill(rgba).flat()));
  const result = f.run({
    schema_version: 1,
    artifacts: [baseline, candidate],
    comparisons: [
      {
        baseline: baseline.id,
        candidate: candidate.id,
        expect: "changed",
        changed_pixels: 4,
      },
    ],
  });
  expect(result.code).toBe(0);
  expect(JSON.parse(result.stdout)).toMatchObject({
    status: "pass",
    comparisons: [
      {
        baseline: baseline.id,
        candidate: candidate.id,
        width: 2,
        height: 2,
        changed_pixels: 4,
      },
    ],
  });
});

test("rejects PNG re-encoding as a visual fix and accepts it as an unchanged control", () => {
  const f = fixture();
  const rgba = Array(4).fill([255, 0, 0, 255]).flat();
  const before = image(rgba, 2, 0);
  const after = image(rgba, 2, 4);
  expect(before.equals(after)).toBe(false);
  const artifacts = [
    f.artifact("before.png", before),
    f.artifact("after.png", after),
  ];
  for (const expectation of ["changed", "unchanged"]) {
    const result = f.run({
      schema_version: 1,
      artifacts,
      comparisons: [
        { baseline: "before.png", candidate: "after.png", expect: expectation },
      ],
    });
    if (expectation === "changed") {
      expect(result.code).toBe(1);
      expect(result.stderr).toContain("expected changed, measured 0");
      expect(result.stdout).toBe("");
    } else {
      expect(result.code).toBe(0);
      expect(JSON.parse(result.stdout).comparisons[0].changed_pixels).toBe(0);
    }
  }
});

test.each(["missing", "modified", "duplicate"])(
  "rejects %s artifact evidence",
  (failure) => {
    const f = fixture();
    const original = f.artifact(
      "shot.png",
      image(Array(4).fill([255, 0, 0, 255]).flat()),
    );
    const artifact =
      failure === "missing" ? { ...original, path: "absent.png" } : original;
    if (failure === "modified")
      f.artifact("shot.png", Buffer.from("modified after capture"));
    const result = f.run({
      schema_version: 1,
      artifacts: failure === "duplicate" ? [artifact, artifact] : [artifact],
    });
    expect(result.code).toBe(1);
    expect(result.stdout).toBe("");
    expect(result.stderr).toContain(
      failure === "missing"
        ? "absent.png"
        : failure === "modified"
          ? "sha256 mismatch"
          : "Duplicate artifact id",
    );
  },
);

test.each([
  [
    "invented count",
    { changed_pixels: 0 },
    "claimed changed_pixels 0, measured 4",
  ],
  [
    "wrong expectation",
    { expect: "unchanged" },
    "expected unchanged, measured 4",
  ],
  [
    "missing comparison artifact",
    { baseline: "unknown.png" },
    "unknown artifact",
  ],
  ["unsupported measurement", { luminance: 44 }, "Unrecognized key"],
])("rejects %s without a success receipt", (_name, change, message) => {
  const f = fixture();
  const artifacts = [
    f.artifact("before.png", image(Array(4).fill([0, 0, 0, 255]).flat())),
    f.artifact("after.png", image(Array(4).fill([255, 255, 255, 255]).flat())),
  ];
  const result = f.run({
    schema_version: 1,
    artifacts,
    comparisons: [
      {
        baseline: "before.png",
        candidate: "after.png",
        expect: "changed",
        ...change,
      },
    ],
  });
  expect(result.code).toBe(1);
  expect(result.stdout).toBe("");
  expect(result.stderr).toContain(message);
});

test.each(["dimensions", "corrupt PNG"])(
  "rejects %s rather than producing comparison numbers",
  (failure) => {
    const f = fixture();
    const artifacts = [
      f.artifact("before.png", image(Array(4).fill([0, 0, 0, 255]).flat())),
      f.artifact(
        "after.png",
        failure === "dimensions"
          ? image(Array(2).fill([0, 0, 0, 255]).flat(), 1)
          : Buffer.from("not a PNG"),
      ),
    ];
    const result = f.run({
      schema_version: 1,
      artifacts,
      comparisons: [
        { baseline: "before.png", candidate: "after.png", expect: "changed" },
      ],
    });
    expect(result.code).toBe(1);
    expect(result.stdout).toBe("");
    if (failure === "dimensions")
      expect(result.stderr).toContain("dimensions differ");
    else expect(JSON.parse(result.stderr).status).toBe("fail");
  },
);
