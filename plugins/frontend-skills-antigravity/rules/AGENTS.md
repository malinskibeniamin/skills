# Frontend Skills on Antigravity

Follow workspace instructions and the user's requested endpoint. On Antigravity,
keep the explicitly selected Gemini 4 Neon, Carbon, or Hydrogen model and Extra
(`xhigh`) or High effort when offered; never switch models or effort silently.
Claude and Codex routing sections in shared skills or `AGENTS.md` apply only to
those hosts, not Antigravity.

## Tools and verification

- Use Antigravity native tools (`read_file`, `write_file`, `edit_file`,
  `run_command`, or IDE equivalents) and batch independent read/search/edit
  calls in parallel.
- Inside T3 Code, use `preview_*` when browser work is requested and
  `html_preview` -> `html_render` for inline charts or comparisons; do not force
  `agent-browser` over T3 Code's shared preview browser.
- Only invoke a custom subagent when the user explicitly requests delegation. An
  inherited Gemini model is not an independent cross-family review.
- Treat edit diagnostics injected on `PostInvocation` as candidates to verify
  against real code. Antigravity `PostToolUse` does not expose shell stdout or
  stderr, so inspect test, lint, and type-check output directly for warnings
  before claiming completion. A silent hook is not proof of verification.
- Report missing host capabilities (Claude mods, Codex quota meters, provider
  PR watchers) plainly instead of simulating them.
