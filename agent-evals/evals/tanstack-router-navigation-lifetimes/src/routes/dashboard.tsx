import { createFileRoute } from "@tanstack/react-router";
import { z } from "zod";
import { DashboardPage } from "../dashboard-page";
import { dashboardQueryOptions } from "../dashboard-query";

export const Route = createFileRoute("/dashboards/$dashboardId")({
  validateSearch: z.object({
    asOf: z.string().optional(),
    debug: z.boolean().catch(false),
  }),
  loader: ({ context, params }) =>
    context.queryClient.prefetchQuery(
      dashboardQueryOptions(params.dashboardId, {}),
    ),
  errorComponent: DashboardError,
  component: DashboardPage,
});
