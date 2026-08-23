import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/account")({
  beforeLoad: ({ context }) => {
    analytics.track("account navigation");
    if (!context.user) context.router.navigate({ to: "/login" });
  },
  loader: ({ navigate }) =>
    fetch("/api/account").catch(() => navigate({ to: "/login" })),
  errorComponent: AccountError,
  component: AccountPage,
});
