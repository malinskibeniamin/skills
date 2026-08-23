import { QueryClient } from "@tanstack/react-query";
import { afterEach, expect, test, vi } from "vitest";
import { dashboardQueryOptions } from "./dashboard-query";

afterEach(() => vi.unstubAllGlobals());

test("reuses an intent preload without caching the wrong search identity", async () => {
  const fetchDashboard = vi.fn(
    async (_input: RequestInfo | URL) =>
      new Response(JSON.stringify({ title: "Sales" })),
  );
  vi.stubGlobal("fetch", fetchDashboard);
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  const historical = dashboardQueryOptions("sales", { asOf: "2026-08-01" });

  await Promise.all([
    queryClient.ensureQueryData(historical),
    queryClient.ensureQueryData(historical),
  ]);
  await queryClient.ensureQueryData(dashboardQueryOptions("sales", {}));

  expect(fetchDashboard).toHaveBeenCalledTimes(2);
  expect(fetchDashboard.mock.calls[0]?.[0]).toContain("asOf=2026-08-01");
  expect(fetchDashboard.mock.calls[1]?.[0]).toContain("asOf=today");
});
