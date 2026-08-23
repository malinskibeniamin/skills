import { QueryClient } from "@tanstack/react-query";
import {
  createRootRouteWithContext,
  createRouter,
} from "@tanstack/react-router";

const queryClient = new QueryClient();
const routeTree = createRootRouteWithContext<{ queryClient: QueryClient }>()(
  {},
);

export const router = createRouter({
  routeTree,
  context: { queryClient },
  defaultPreload: "intent",
});
