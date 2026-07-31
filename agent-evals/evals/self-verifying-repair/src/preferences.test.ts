import { describe, expect, test } from "bun:test";
import { DEFAULT_PREFERENCES, loadPreferences } from "./preferences";

describe("loadPreferences", () => {
  test("uses defaults when storage is empty or corrupted", () => {
    expect(loadPreferences(null)).toEqual(DEFAULT_PREFERENCES);
    expect(loadPreferences("not json")).toEqual(DEFAULT_PREFERENCES);
  });

  test("preserves valid fields and rejects invalid fields independently", () => {
    expect(
      loadPreferences(
        JSON.stringify({
          compact: true,
          pinnedProjectIds: ["alpha", "", "alpha", 42, "beta"],
          theme: "neon",
        }),
      ),
    ).toEqual({
      compact: true,
      pinnedProjectIds: ["alpha", "beta"],
      theme: "light",
    });
  });

  test("returns independent arrays on every load", () => {
    const first = loadPreferences(null);
    first.pinnedProjectIds.push("mutated");

    expect(loadPreferences(null)).toEqual(DEFAULT_PREFERENCES);
    expect(DEFAULT_PREFERENCES.pinnedProjectIds).toEqual([]);
  });
});
