import { useSuspenseQuery } from "@tanstack/react-query";
import { getRouteApi } from "@tanstack/react-router";
import { dashboardQueryOptions } from "./dashboard-query";

const routeApi = getRouteApi("/dashboards/$dashboardId");

export function DashboardPage() {
  const { dashboardId } = routeApi.useParams();
  const { asOf } = routeApi.useSearch();
  const dashboard = useSuspenseQuery(
    dashboardQueryOptions(dashboardId, { asOf }),
  );
  return <h1>{dashboard.data.title}</h1>;
}
