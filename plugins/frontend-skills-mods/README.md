# Harness lens

Opt-in Claude Code mod, tested with **2.1.287**. Above the prompt, it shows context
usage and the latest successful main-loop `Skill` tool call. Existing shell
checks and Codex behavior are unchanged. Mods have Claude Code's machine access;
review the source before installing. This mod observes only and makes no model,
file, shell or network calls.

## Install and rollback

After adding `malinskibeniamin/skills` as a marketplace:

```bash
/plugin marketplace update skills
/plugin install frontend-skills-mods@skills
/reload-plugins
```

Disable with `claude plugin disable frontend-skills-mods@skills`, or remove with
`claude plugin uninstall frontend-skills-mods@skills`, then reload plugins.

## Behavior and limits

- Context refreshes at session start and after a main-loop turn, not continuously.
  Missing/failed usage shows `Context unavailable` rather than stale figures.
- `Last skill` means a successful `Skill` tool result observed in the main loop.
  It does not cover every slash-command expansion or prove adherence to instructions.
- Host-owned state persists across module reloads within the session. Context and
  skill use separate keys so a pending context refresh cannot erase a skill update.
- The readout composes downstream output in the CLI and Desktop AbovePrompt band.
  Surveys, fewer than 32 columns and subagent transcript views pass through unchanged.
  Other surfaces have no AbovePrompt support.

## Verify or extend

From the repository root, with dependencies installed:

```bash
CLAUDE_BIN=/absolute/path/to/claude bun run test:mods
```

The gate checks the minimum CLI version, installs the local marketplace into a
temporary HOME/config/cache, validates strictly, runs the real mod test kit,
loads `/help` without credentials to emit that build's SDK, type-checks, and
exercises disable/uninstall. No model calls or changes to your Claude config.
Generated `.claude-plugin/types/` stays untracked; the root type checker excludes
this plugin because its dedicated gate owns the host-specific types.

Tests validate rendered element trees, not terminal/Desktop painting. For a
visual check, load this directory with `claude --plugin-dir`, inspect the band
in an isolated session, resize it and switch to a subagent transcript.

Read `extend-harness/MODS.md` in the [source repository](https://github.com/malinskibeniamin/skills)
before adding behavior; it lives outside the standalone plugin cache. The
[official guide](https://claude.dev/blog/getting-started-with-claude-code-mods/)
and [generated types guidance](https://code.claude.com/docs/en/plugins/mods/create#get-the-types-for-your-build)
own the current host contract; this early-access API can change between releases.
