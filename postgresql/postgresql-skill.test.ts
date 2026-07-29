import { describe, expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { join } from "node:path";

const skillDirectory = import.meta.dir;

describe("PostgreSQL skill", () => {
  test("routes SQL pull request reviews to dedicated guidance", () => {
    const skill = readFileSync(join(skillDirectory, "SKILL.md"), "utf8");

    expect(skill).toContain("SQL-PR-REVIEW.md");
  });
});
