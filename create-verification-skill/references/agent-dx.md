# Agent DX and worktree setup

Return a capability-gap list: task blocked, missing control or observation, least-privilege
remedy, and proof it works. Inspect worktree setup, copied configuration, generated
artifacts, isolated test identity/data, debug access, and failure logs. Prefer existing
tools; request only credentials or access the agent cannot obtain. Never copy secret
values into evidence or broaden production access for convenience. For Conductor-specific
setup, load its bundled skill before proposing configuration.

Replay setup/worktree improvements from a cold isolated environment without relying on
an already-running app or warmed artifacts. Record setup-to-ready and failure-to-diagnosis
evidence when claiming faster feedback. If isolation is unavailable, report that gap; do
not disturb another workspace to simulate a cold start.
