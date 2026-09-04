import { describe, expect, test } from "bun:test";
import { projectHealth } from "./health";

describe("projectHealth", () => {
  test("marks projects with stale active work as stale", () => {
    expect(
      projectHealth(
        [{ status: "active", updatedAt: "2026-01-01T00:00:00Z" }],
        "2026-08-01T00:00:00Z",
      ),
    ).toBe("stale");
  });

  test("marks projects with recent active work as healthy", () => {
    expect(
      projectHealth(
        [{ status: "active", updatedAt: "2026-08-28T00:00:00Z" }],
        "2026-08-01T00:00:00Z",
      ),
    ).toBe("healthy");
  });
});
