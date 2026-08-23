import { describe, expect, test } from "vitest";
import { dashboardQueryOptions } from "./dashboard-query";

describe("dashboard query identity", () => {
  test("includes every data-driving dependency in the key", () => {
    expect(
      dashboardQueryOptions("sales", { asOf: "2026-08-01" }).queryKey,
    ).toEqual(["dashboard", "sales", { asOf: "2026-08-01" }]);
    expect(dashboardQueryOptions("sales", {}).queryKey).toEqual([
      "dashboard",
      "sales",
      { asOf: undefined },
    ]);
  });
});
