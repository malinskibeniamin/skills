import { existsSync, readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";

const review = () => readFileSync("review.md", "utf8");

describe("contract-tracing review", () => {
  it("creates the requested review artifact", () => {
    expect(existsSync("review.md")).toBe(true);
  });

  it("reports the structured-field versus presentation-text mismatch", () => {
    const content = review();
    expect(content).toMatch(/\bP1\b|P1 Major/i);
    expect(content).toMatch(/target[._ ]kind/i);
    expect(content).toMatch(/target[._ ]id/i);
    expect(content).toMatch(/rule[._ ]name/i);
    // Transferable contract: structured semantic fields outrank presentation text.
    expect(content).toMatch(
      /summary[\s\S]*(?:substring|includes|text search)|(?:substring|includes|text search)[\s\S]*summary/i,
    );
  });

  it("reverse-traces the claim into unchanged producer and schema artifacts", () => {
    const content = review();
    expect(content).toMatch(/src\/activity\/mapper\.ts|toActivityRecord/i);
    expect(content).toMatch(/schema\/activity\.schema\.json|target.*rule/i);
    expect(content).toMatch(/producer|mapper|canonical|authoritative/i);
  });

  it("gives a concrete cross-field collision", () => {
    const content = review();
    expect(content).toContain("shared-42");
    expect(content).toMatch(
      /actor[\s\S]*(?:unrelated|different|wrong)[\s\S]*target|target[\s\S]*(?:unrelated|different|wrong)[\s\S]*actor/i,
    );
  });

  it("explains why the fixture made the defect look green", () => {
    const content = review();
    expect(content).toMatch(/fixture|filter\.test\.ts/i);
    expect(content).toMatch(
      /(?:omit|empty|missing|lack)[\s\S]*(?:target[._ ](?:kind|id)|rule[._ ]name|structured field)/i,
    );
  });

  it("prescribes field-scoped comparison and regression coverage", () => {
    const content = review();
    expect(content).toMatch(/field-scoped|structured[\s\S]*(?:equal|compare)/i);
    expect(content).toMatch(/summary[\s\S]*(?:generic|free-text|text query)/i);
    expect(content).toMatch(/cross-field|collision|regression test/i);
  });
});
