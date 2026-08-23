import { queryOptions } from "@tanstack/react-query";

export interface DashboardDependencies {
  asOf?: string;
}

export const dashboardQueryOptions = (
  dashboardId: string,
  dependencies: DashboardDependencies,
) =>
  queryOptions({
    queryKey: ["dashboard", dashboardId],
    queryFn: ({ signal }) =>
      fetch(
        `/api/dashboards/${dashboardId}?asOf=${dependencies.asOf ?? "today"}`,
        {
          signal,
        },
      ).then((response) => response.json()),
  });
