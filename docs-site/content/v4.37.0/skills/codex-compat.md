---
title: "/codex-compat"
description: "Generate Codex hooks.json and AGENTS.md parity surfaces from the Claude hook manifest."
type: skill
sidebar:
  label: "/codex-compat"
---
![Diagram of the /codex-compat skill](/diagrams/skills/codex-compat.svg)

[Open the editable Excalidraw source](/diagrams/skills/codex-compat.excalidraw)

Codex supports Claude-style lifecycle hooks for `SessionStart`, `SubagentStart`, `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PreCompact`, `PostCompact`, `UserPromptSubmit`, `SubagentStop`, and `Stop` (https://developers.openai.com/codex/hooks). Claude-only events with no Codex analog -- `FileChanged`, `WorktreeCreate`, `SessionEnd`, `PostToolUseFailure` (folded into Codex `PostToolUse`) -- use the Stop-batch fallback or are dropped by design. `PreToolUse`/`PostToolUse` matchers support `Bash`, MCP tool names, `apply_patch`, and `Edit|Write` aliases. Map `Edit|Write` hooks direct whenever possible. Run `/read-the-damn-docs` for current hook behavior; use `/plan-arbiter` when direct-vs-fallback mapping is ambiguous.

## What This Creates

- **`.codex/hooks.json`** -- direct translation for supported Claude hooks
- **`.codex/hooks/codex-batch-check.sh`** -- fallback only for checks that cannot run per tool event
- **`AGENTS.md`** + **`CLAUDE.md`** -- shared project rules (Codex reads AGENTS.md, Claude Code reads CLAUDE.md)
- **compatibility matrix** -- classify hooks as `direct`, `direct with shim`, `fallback only`, or `unsupported`

## Steps

1. Read `.claude/settings.json` and classify every hook with the [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/codex-compat/REFERENCE.md) compatibility matrix.
2. Generate `.codex/hooks.json`:
   - `SessionStart`, `UserPromptSubmit`, `Stop` -> direct
   - `PreToolUse` / `PostToolUse` with `Bash`, `Edit|Write`, `apply_patch`, `mcp__.*` -> direct
   - `PermissionRequest` for `Bash` / MCP / `apply_patch` -> direct where scripts understand Codex payloads
   - Unsupported Claude events or handler types -> omit, document, or route to fallback only when semantics stay safe
3. Copy `scripts/codex-batch-check.sh` -> `.codex/hooks/` only if fallback hooks are needed. `chmod +x`.
4. Copy `hooks/frontend-skills.rules` -> `.codex/rules/` (execpolicy floor; works without the hooks feature flag).
5. Generate `AGENTS.md` + `CLAUDE.md` from [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/codex-compat/REFERENCE.md) template.
6. Enable + trust: set `[features] hooks = true` in `config.toml`, then run `/hooks` in the Codex TUI and trust the definitions (re-trust after every hook change; CI uses `--dangerously-bypass-hook-trust` or the managed hooks dir). Optionally wire `notify = ["bash", "<repo>/.claude/hooks/codex-notify.sh"]` for turn-complete telemetry.

## Verify

- [ ] `.codex/hooks.json` contains direct `Edit|Write` PostToolUse hooks when source has them
- [ ] Batch checker is absent unless a real fallback-only hook needs it
- [ ] `.codex/rules/frontend-skills.rules` present and identical to `hooks/frontend-skills.rules`
- [ ] Hooks feature flag on + definitions trusted (`/hooks` shows them active, not pending)
- [ ] `AGENTS.md` + `CLAUDE.md` at repo root
- [ ] `.claude/settings.json` unchanged
