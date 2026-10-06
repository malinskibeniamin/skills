# Harness desk

Opt-in Claude Code mods, tested with **2.1.287**. Inspect check receipts, Skill
calls and successful edit patches in one native pane. Harness lens keeps its
context/last-skill readout above the prompt. Existing shell enforcement and
Codex behavior stay unchanged.

Review before installing: mods have Claude Code's machine access. This plugin
makes bounded read-only Git/process and file-metadata calls for comparisons;
no file writes, model/network calls, permission changes or automatic undo.
Live terminal/Desktop painting and before/after captures remain unverified.

## Install and rollback

After adding `malinskibeniamin/skills` as a marketplace:

```bash
/plugin marketplace update skills
/plugin install frontend-skills-mods@skills
/reload-plugins
```

Disable with `claude plugin disable frontend-skills-mods@skills`, or remove with
`claude plugin uninstall frontend-skills-mods@skills`, then reload plugins.

## One pane, three views

```text
/harness proof    Check receipts and repo comparison
/harness skills   Skill Flight Recorder
/harness replay   Step through returned edit patches
```

Commands run without a model turn. Tabs, refresh, previous/next, clear and close
use native buttons. If a pane cannot be placed, the command still returns text.

### Proof Desk

Only exact foreground main-loop Bash commands are recognized:
`bun run type:check`, `bun run lint`, `bun run lint:fix`, `bun run test`,
`bun run test:mods`. Compound commands, aliases, subagents and background checks
are not evidence. A host error is failed; denial is denied; interrupted,
backgrounded or special-return-code outcomes are incomplete. Concurrent checks
keep the latest started receipt, not whichever finishes last.

A passed result is compared with bounded Git fingerprints before/after the
check and on `/harness proof` or **Refresh repo state**. Changes produce stale;
unavailable comparisons produce unverified. Every tool call invalidates the
last comparison. External edits require refresh; fingerprints are non-atomic,
not continuous monitoring or release certification. Dogfood and visual evidence
remain missing: the mod cannot infer them from a successful command.

Comparison scope: session cwd must equal the Git root; HEAD and tracked/unignored
working content only. No ignored dependencies, environment or full staging-state
proof. Limit: 200 surviving changed/untracked files, 4 MiB each, 16 MiB combined,
1.5 seconds per Git query. Symlinks, submodules, failed/truncated output and
unsupported hosts become unverified. Git runs with optional locks, fsmonitor,
external diffs, textconv and hash-object filters disabled. The tested SDK supports
process calls only on CLI; Desktop comparisons are unavailable, receipts still display.

### Skill Flight Recorder

Latest 24 completed `Skill` calls: resolved name when available, outcome and
main/subagent provenance. Read-only loading differs from execution; a background
fork is a launch with unknown outcome, not completed work. No arguments, prompts,
error text or fork result bodies retained. Clear discards history, including
already-in-flight calls; it does not erase the separate Last skill readout.

Not an instruction-adherence audit. Slash expansion, installed versions and
which references Claude actually read are not attributed by this recorder.

### Edit replay

Independent implementation inspired by [Replay Theater](https://github.com/anthropics/claude-code-playground/tree/main/claude-code/mods/replay-theater),
not copied upstream code. Retains only successful, non-staged `Edit`/`Write`
**returned patches**, including owner-modified output. Not attempted inputs or
full file contents. Other tools and external edits are not recorded.

Completion order; tool id, agent and observed main-turn id attached at call
start. A late subagent completion is not attributed to a guessed agent turn.
Empty patches say diff unavailable. Session memory only: latest 20 entries,
8 KiB per serialized entry, 64 KiB combined. Old entries evict; clipped patches
are labeled. Clear cancels in-flight retention; no snapshots, persistence or undo.

Sensitive paths and recognizable secret markers are excluded without retaining
their names or contents; terminal controls are neutralized. Filters are
**best effort, not guaranteed redaction**. Unrecognized secrets may appear in
ordinary-file patches. Disable the plugin when that risk is unacceptable.

## Harness lens

- Context refreshes at session start and after main-loop turns, not continuously.
  Missing/failed usage shows unavailable rather than stale figures.
- Last skill means the latest successful main-loop `Skill` result, not an active
  skill, completed background work or proven adherence.
- Host-owned state survives module reloads within the session. Independent keys
  protect skill observations from pending context updates.
- CLI/Desktop AbovePrompt composes downstream output; surveys, fewer than 32
  columns and subagent views pass through. Other surfaces lack this band.

## Verify or extend

```bash
CLAUDE_BIN=/absolute/path/to/claude bun run test:mods
```

From repo root with dependencies installed: isolated HOME/config/cache install,
strict validation, real host-kit tests, generated SDK compilation and rollback.
No model calls or changes to your Claude config. Generated `.claude-plugin/types/`
is untracked; the dedicated gate owns host-specific types, not root typecheck.

Tests validate native element trees and interactions, not terminal/Desktop paint.
Separate live visual checks and before/after captures remain a draft gap.
Read `extend-harness/MODS.md` in the [source repository](https://github.com/malinskibeniamin/skills)
(outside the standalone cache). [Official authoring](https://code.claude.com/docs/en/plugins/mods/create)
and the target build's generated declarations own this early-access contract.
