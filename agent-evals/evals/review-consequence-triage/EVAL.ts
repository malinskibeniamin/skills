import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";

const triage = (): unknown => JSON.parse(readFileSync("triage.json", "utf8"));

describe("review consequence triage", () => {
  it("preserves serious cross-tenant deletion despite a rare-path nit label", () => {
    expect(triage()).toHaveLength(2);
    expect(triage()).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          id: "S1",
          severity: expect.stringMatching(/^P[01]$/),
          disposition: "fix",
          reason: expect.stringMatching(/tenant/i),
        }),
      ]),
    );
  });

  it("does not turn unsupported future scale into mandatory repair", () => {
    expect(triage()).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          id: "S2",
          severity: "P3",
          disposition: expect.stringMatching(/^(reject|advisory)$/),
          reason: expect.stringMatching(/500|limit|measur|evidence/i),
        }),
      ]),
    );
  });
});
