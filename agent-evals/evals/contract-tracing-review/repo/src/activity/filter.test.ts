import { describe, expect, it } from "vitest";

import { matchesActivity, type ActivityRecord } from "./filter";

const fixture: ActivityRecord = {
  summary: "shared-42 updated service/other-99 — allowed by maintainers",
  actor: { id: "" },
  target: { kind: "", id: "" },
  rule: { name: "" },
};

describe("matchesActivity", () => {
  it("filters the activity summary by target identifier", () => {
    expect(matchesActivity(fixture, { targetId: "other-99" })).toBe(true);
  });
});
