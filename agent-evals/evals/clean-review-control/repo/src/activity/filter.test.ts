import { expect, test } from "vitest";
import { matchesActivity, type ActivityRecord } from "./filter";

const record: ActivityRecord = {
  summary: "shared-42 changed service/other-99",
  actor: { id: "shared-42" },
  target: { kind: "service", id: "other-99" },
  rule: { name: "maintainers" },
};

test("structured filters use their own fields, not unrelated text", () => {
  expect(matchesActivity(record, { targetId: "shared-42" })).toBe(false);
  expect(matchesActivity(record, { ruleName: "changed" })).toBe(false);
  expect(
    matchesActivity(record, {
      targetKind: "service",
      targetId: "other-99",
      ruleName: "maintainers",
    }),
  ).toBe(true);
});

test("free text is trimmed and case insensitive; empty filters impose no restriction", () => {
  expect(matchesActivity(record, { text: " CHANGED " })).toBe(true);
  expect(matchesActivity(record, { text: "missing" })).toBe(false);
  expect(matchesActivity(record, { targetId: "", text: "" })).toBe(true);
});
