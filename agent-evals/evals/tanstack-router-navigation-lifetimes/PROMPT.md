# Task

Repair the dashboard and account navigation flows in this synthetic TanStack Router app.

The shared dashboard URL can include `asOf` and `debug`. Historical data must be ready for
the first accurate render, must not fetch today's dashboard first, and must not reload when
only `debug` changes. A hover preload followed by a click must reuse app-owned loading work.

The account flow must preserve useful shared work during overlapping navigations, redirect
unauthenticated users through Router control flow, track only resolved pageviews, and focus
the destination heading only after its route content renders. Rapid navigation from a slow
route A to route B must never expose route A afterward. An ordinary loader failure
overtaken by an authentication redirect must not publish stale error UI either.

Use the installed TanStack guidance and public APIs. Keep Query as the cache owner. Do not
change the existing unit tests. Repair the navigation race spec without duration waits, then
run `bun run test` and `bun run typecheck` until both pass.
