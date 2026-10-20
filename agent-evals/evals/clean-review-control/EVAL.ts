import { readFileSync } from "node:fs";
import { expect, it } from "vitest";

it("does not prescribe unnecessary fixes on the clean control", () => {
  const report: unknown = JSON.parse(readFileSync("review.json", "utf8"));
  if (
    !report ||
    typeof report !== "object" ||
    !("findings" in report) ||
    !("verification" in report)
  )
    throw new Error("Missing structured review");
  expect(report.findings).toEqual([]);
  if (typeof report.verification !== "string")
    throw new Error("Missing verification evidence");
  expect(report.verification.trim().length).toBeGreaterThan(0);
});
