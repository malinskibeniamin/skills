import { describe, expect, it } from "bun:test";
import {
  existsSync,
  mkdtempSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { installAntiSlop } from "./install.mjs";

const expectedRules = [
  "no-chained-type-assertions.ts",
  "no-unknown-type-aliases.ts",
  "no-widen-then-assert.ts",
];

const expectedBiomePlugins = [
  "no-chained-type-assertions.grit",
  "no-direct-unknown-type-aliases.grit",
];

function withTemporaryProject(run: (project: string) => void): void {
  const project = mkdtempSync(join(tmpdir(), "install-anti-slop-"));
  try {
    run(project);
  } finally {
    rmSync(project, { recursive: true, force: true });
  }
}

describe("install-anti-slop", () => {
  it("copies the curated plugin into the default destination", () => {
    withTemporaryProject((project) => {
      installAntiSlop({ cwd: project });
      const target = join(project, "tools/oxlint/anti-slop");

      expect(readdirSync(join(target, "rules")).sort()).toEqual(expectedRules);
      expect(readFileSync(join(target, "index.ts"), "utf8")).toContain(
        '"no-chained-type-assertions"',
      );
      expect(readFileSync(join(target, "LICENSE"), "utf8")).toContain(
        "MIT License",
      );
    });
  });

  it("copies the structural profile for Biome repositories", () => {
    withTemporaryProject((project) => {
      installAntiSlop({ cwd: project, linter: "biome" });
      const target = join(project, "tools/biome/anti-slop");

      expect(readdirSync(target).sort()).toEqual(expectedBiomePlugins);
    });
  });

  it("force-replaces stale Biome profile files", () => {
    withTemporaryProject((project) => {
      installAntiSlop({ cwd: project, linter: "biome" });
      const target = join(project, "tools/biome/anti-slop");
      writeFileSync(join(target, "stale-rule.grit"), "stale\n");

      installAntiSlop({ cwd: project, force: true, linter: "biome" });

      expect(existsSync(join(target, "stale-rule.grit"))).toBe(false);
      expect(readdirSync(target).sort()).toEqual(expectedBiomePlugins);
    });
  });

  it("refuses to overwrite an existing installation", () => {
    withTemporaryProject((project) => {
      installAntiSlop({ cwd: project });
      const index = join(project, "tools/oxlint/anti-slop/index.ts");
      writeFileSync(index, "project-owned\n");

      expect(() => installAntiSlop({ cwd: project })).toThrow(
        "Refusing to overwrite",
      );
      expect(readFileSync(index, "utf8")).toBe("project-owned\n");
    });
  });

  it("replaces stale files only when force is explicit", () => {
    withTemporaryProject((project) => {
      installAntiSlop({ cwd: project });
      const target = join(project, "tools/oxlint/anti-slop");
      writeFileSync(join(target, "stale-rule.ts"), "stale\n");

      installAntiSlop({ cwd: project, force: true });

      expect(existsSync(join(target, "stale-rule.ts"))).toBe(false);
      expect(readdirSync(join(target, "rules")).sort()).toEqual(expectedRules);
    });
  });

  it("refuses to force-replace a directory that is not anti-slop", () => {
    withTemporaryProject((project) => {
      const source = join(project, "src");
      mkdirSync(source);
      writeFileSync(join(source, "app.ts"), "keep\n");

      expect(() =>
        installAntiSlop({ cwd: project, destination: "src", force: true }),
      ).toThrow("does not look like an anti-slop installation");
      expect(readFileSync(join(source, "app.ts"), "utf8")).toBe("keep\n");
    });
  });

  it("rejects destinations outside the target repository", () => {
    withTemporaryProject((root) => {
      const project = join(root, "project");
      mkdirSync(project);

      expect(() =>
        installAntiSlop({ cwd: project, destination: "../escaped" }),
      ).toThrow("inside the target repository");
      expect(existsSync(join(root, "escaped"))).toBe(false);
    });
  });

  it("rejects destinations whose parent symlink escapes the repository", () => {
    withTemporaryProject((root) => {
      const project = join(root, "project");
      const outside = join(root, "outside");
      mkdirSync(project);
      mkdirSync(outside);
      symlinkSync(outside, join(project, "tools"), "dir");

      expect(() =>
        installAntiSlop({ cwd: project, destination: "tools/anti-slop" }),
      ).toThrow("inside the target repository");
      expect(existsSync(join(outside, "anti-slop"))).toBe(false);
    });
  });
});
