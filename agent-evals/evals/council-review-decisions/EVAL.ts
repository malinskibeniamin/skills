import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";

const decisions = (): unknown =>
  JSON.parse(readFileSync("decisions.json", "utf8"));

describe("council coordinator decisions", () => {
  it("requires repair verification despite perfect scores on a stale candidate", () => {
    expect(decisions()).toHaveLength(3);
    expect(decisions()).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          id: "repaired",
          status: "review-required",
          scope: "repair-delta",
          finding_ids: ["F1"],
          reason: expect.stringMatching(
            /head-a[\s\S]*head-b|head-b[\s\S]*head-a/,
          ),
        }),
      ]),
    );
  });

  it("stops a clean current review without chasing perfect scores", () => {
    expect(decisions()).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          id: "clean",
          status: "clean",
          scope: "none",
          finding_ids: [],
          reason: expect.stringMatching(/\S/),
        }),
      ]),
    );
  });

  it("does not turn an exhausted disputed review into approval or another round", () => {
    expect(decisions()).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          id: "disputed",
          status: "blocked",
          scope: "none",
          finding_ids: ["F2"],
          reason: expect.stringMatching(/\S/),
        }),
      ]),
    );
  });
});
