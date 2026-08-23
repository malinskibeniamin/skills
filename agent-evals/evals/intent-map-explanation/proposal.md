# Notification preferences

Users need notification preferences to follow them between desktop and laptop sessions.

The initial proposal stored preferences in `localStorage`. It assumed one browser was the user's
only active session. `research/interviews.md` invalidates that assumption. `decision-record.md`
documents an existing server mutation that can own the canonical state, so the current direction is
server-backed preferences with client state limited to unsaved form edits.

The load-bearing implementation is:

- `proto/preferences/v1/preferences.proto` for the preference fields;
- `src/api/preferences.ts` for query and mutation adapters;
- `src/routes/settings/notifications.tsx` for loading, error, empty, dirty, and saved states.

Offline edits may be lost if the user closes the page before reconnecting. Do not add offline sync
in this slice; make the risk visible and preserve the unsaved form state while the page remains open.

Verification must include a failing integration test first, a cross-session persistence test, and
loading, mutation-error, and retry coverage.
