# Antigravity and Gemini host rules

This file applies when running this repository on Antigravity (ACP, CLI, IDE, or
Antigravity 2.0) with Gemini 4 Neon, Carbon, or Hydrogen. It supplements
`AGENTS.md` and overrides Codex-only sections in `AGENTS.md` on this host.

## Host precedence

- Keep the explicitly selected Gemini model (`gemini-4-neon`, `gemini-4-carbon`,
  or `gemini-4-hydrogen`) and requested effort (`xhigh` / Extra or `high`). Do
  not silently substitute Claude or Codex models from `config/model-routing.json`.
  Antigravity routing lives in `config/antigravity-model-routing.json`.
- Ignore the `## Codex-specific` section in `AGENTS.md` when running on
  Antigravity; follow Antigravity's native tool, permission, and delegation
  contracts instead.
- Inside T3 Code, use `preview_*` when browser work is requested and
  `html_preview` -> `html_render` for charts or visual comparisons.

## Execution and verification

- Batch independent reads, searches, and edits in parallel rather than serial
  single-call turns.
- Antigravity `PostToolUse` does not receive command stdout/stderr. Inspect test,
  lint, and type-check output directly for warnings before claiming done.
- Run `bun run lint:fix`, `bun run type:check`, and `bun run test:antigravity`
  before finishing Antigravity harness changes.
- See `shared/model-prompting.md#gemini-4-on-antigravity` and
  `docs/ANTIGRAVITY.md` for plugin setup, verification, and calibration.
