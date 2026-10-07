# Claude Code mod authoring

Use for Claude-native session behavior, commands or interface rendering. Keep
cross-runtime enforcement in existing settings hooks; a mod is not a portable
replacement for them. The opt-in `frontend-skills-mods` plugin demonstrates the
boundary with Harness desk and its context lens. Tested host: **Claude Code 2.1.287**; older versions
cannot load mods. Early-access API drift requires checking the target build.

## Contract -> implementation -> proof

1. Name the observable outcome, host surfaces, trust boundary and rollback.
   Define what remains prompt guidance versus deterministic enforcement.
2. Inspect [official events/API](https://code.claude.com/docs/en/plugins/mods/reference)
   and [interface rendering](https://code.claude.com/docs/en/plugins/mods/interface).
   Load locally with `claude --plugin-dir ./plugins/frontend-skills-mods` to emit
   `.claude-plugin/types/`; trust those declarations over online examples.
3. Write a failing public-contract test in the plugin's `tests/` using
   `claude-code/testing`. Run `claude plugin test <plugin-dir>` without model calls.
4. Edit the single module in `hooks/hooks.json`: module paths resolve relative to
   that file. Export `register`; use `on(event, matcher, async ($, e, next) => ...)`.
   Compose `next(e)` and preserve results unless changing them is the stated outcome.
5. Keep bounded session state in `$.state`, declare its `PluginState` keys in
   `types/index.d.ts`, and reference that file from the plugin manifest's `types`.
   Use independent keys for independent updates. Filter main-loop-only observations
   using `e.agentId`; render only on supported surfaces and yield to reserved UI.
6. Exercise failure/recovery, downstream composition and reload-relevant state.
   Run `CLAUDE_BIN=/absolute/path/to/claude bun run test:mods` for isolated cache
   installation, strict validation, generated-host type checking and rollback.
   Inspect actual terminal/Desktop painting separately; the test kit checks trees.

## Packaging and trust

The Claude marketplace owns the separate local plugin entry; the Codex marketplace
stays unchanged. Version the mod independently. Extend `/extend-harness` guidance
rather than adding a new always-loaded skill for each mod. Generate skill catalog
changes with `bash scripts/generate-skill-catalog.sh`.

Mods run with Claude Code's machine permissions. Runtime isolation is not a security
sandbox. Review dependencies and code, minimize I/O and retained data, and preserve
permission decisions. Safety-denying mods need explicit failure policy and denied,
allowed, unsupported and recovery-path tests before replacing a guard.

[Create/reload](https://code.claude.com/docs/en/plugins/mods/create) and
[test-kit](https://code.claude.com/docs/en/plugins/mods/test) docs are the authoring
references. Browse [official samples](https://github.com/anthropics/claude-code-playground/tree/main/claude-code/mods)
for inspiration, not as authority over your generated host types.

## Harness desk ownership

One `/harness` command and pane own proof, skills, replay and brief; keep the context
band small rather than stacking competing sample bands. The shipped implementations
observe downstream tool results, never approve or rewrite tools. Workflow brief
is the explicit opt-in exception to observation: it enriches model-only prompt
context with user-configured guidance, preserving the submitted text.

- Proof receipts recognize exact foreground main-loop checks. Read-only Git
  comparisons are bounded and explicitly stale/unverified when insufficient;
  they do not certify a release or infer visual/dogfood evidence.
- Skill history records tool outcomes and provenance, not adherence, installed
  versions or reference reads. A background fork is launch evidence only.
- Replay consumes successful, non-staged returned `Edit`/`Write` patches, not
  pre-tool snapshots. Retention and control-character handling are bounded;
  sensitive exclusion is best effort, not a secret-security guarantee. No undo.
- Brief starts off; require all fields and explicit enable. Preserve incoming
  context and provenance, skip commands/autonomous origins, and show the exact
  injected block. Editing pauses it; session end resets it. User text sent in
  context is not revoked by clearing local state. No automatic rule/skill loading.

This is repo-owned code inspired by the samples, not a vendored upstream copy.
If copying sample code later, pin its commit and retain its license/notices.
The [mod README](../plugins/frontend-skills-mods/README.md) owns operational
limits and rollback. Add $-using helpers inside the registered hooks module:
passing `$` to a helper imported from another module is unsupported by this host.
Pure helpers may be shared. The manifest's types contract must be self-contained:
no imports or re-exports; host types such as `StateFamily` resolve inside its
`declare module "claude-code"` block. Register each event/matcher once; extend an existing
handler rather than duplicating it. Native op mocks return `{ value: ... }`;
tests must exercise the generated target-build contract, not a guessed adapter.
