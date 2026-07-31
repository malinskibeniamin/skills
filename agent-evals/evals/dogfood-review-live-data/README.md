# Audit timeline demo

`bun run demo` exercises the audit timeline with the representative live-scale
fixture used by product acceptance.

The timeline contract:

- Event identity is tenant-scoped: `(tenantId, id)`.
- The 20,000-event fixture must report `expected=20000` and `shown=20000`.
- Local processing must stay within the 250 ms performance budget.
