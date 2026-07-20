---
name: extend-harness
description: Extend the frontend-skills hook harness: add rules, tune severity tiers, view analytics, debug non-firing hooks.
disable-model-invocation: true
---

# Extend the Harness
## 1. Never hand-edit generated configs

`.claude/settings.json` and `hooks/hooks.json` generated. Edit `skill-manifest.json`, regenerate:

```bash
bash scripts/generate-hook-configs.sh --apply
bash scripts/generate-hook-configs.sh --check   # drift check (lefthook runs this pre-push)
```

## 2. Add a new rule (grep-expressible)

Per-edit checks live as sourceable libs under `.claude/hooks/checks/` and run through the `PostToolBatch` dispatcher (`post-tool-batch.sh`) -- one process per parallel tool batch on Claude; Codex re-expands them to per-call wrappers via the generator.

0. First ask: can Biome/Ultracite express it? Single-element lint rules belong in the Biome config, not a hook (see the delegation header in `checks/accessibility-check.lib.sh`). Hooks are for cross-element, cross-file, workflow, or LLM-behavior rules.
1. Write `checks/my-check.lib.sh` exposing `run_my_check()` -- start from an existing `*.lib.sh` as template -- plus a thin `.claude/hooks/my-check.sh` wrapper (copy any 450-byte sibling).
2. Add the wrapper filename to the matcher block in `skill-manifest.json` (usually `PostToolUse.Edit|Write`).
3. Regenerate: `bash scripts/generate-hook-configs.sh --apply`.
4. Test: feed synthetic edit event on stdin:

```bash
echo '{"hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"/tmp/x.ts"}}' | bash .claude/hooks/my-check.sh
```

## 3. Pick the right severity tier

| Function | Exit | Claude sees | Logged | Use when |
|---|---|---|---|---|
| `hook_block` | 2 | systemMessage | JSONL | Must fix before continuing |
| `hook_block_strict` | 2 | `[STRICT]` prefix | JSONL | Security-critical, no escape hatch |
| `hook_warn` | 0 | systemMessage | JSONL | Should fix, but proceed |
| `hook_nudge` | 0 | `[nudge]` prefix | JSONL | Pattern suboptimal most cases |
| `hook_info` | 0 | -- | JSONL | Telemetry only, no UI |
| `hook_emit_diagnostic` | 0 or 2 | LSP JSON with `range` + `fix` | JSONL | Machine-parseable with auto-fix |

Default `hook_warn` for style, `hook_block` for correctness, `hook_info` for observation.

Stop tier extras: `hook_stop_block` (decision:block, budgeted two under the
harness's 8-consecutive-block cap, downgrades to visible systemMessage after;
budget resets on each user prompt), `hook_stop_context` (additionalContext --
feedback that keeps the turn alive, softer than block). All prose emitters
truncate at 8,000 chars (`_hook_cap_msg`) -- Codex forwards ~2.5K tokens max.

## 3b. Per-entry hook options (manifest objects)

A manifest entry is a script name string, or an object when the hook needs
Claude-side options:

```json
{"script": "snyk-project-create-guard.sh", "if": "Bash(snyk *)"}
{"script": "ci-warning-audit.sh", "async": true, "asyncRewake": true, "statusMessage": "Auditing green CI logs"}
```

- `if` -- permission-rule filter; harness skips the spawn when no subcommand
  matches (checks `&&`/`$()`/backticks; fails open). Tool events only. Codex
  output drops it -- the script's own stdin guard must stay.
- `async` / `asyncRewake` -- background; rewake shows stderr to Claude as a
  system reminder on exit 2 (emit plain text there, not JSON).
- `statusMessage` spinner text for slow sync hooks | `timeout` seconds.

Guardrails without a process: `permissions.deny` param matching --
`Agent(model:haiku)` makes never-Haiku a hard rule (generator preserves the
`permissions` block). Codex mirror: `hooks/frontend-skills.rules` execpolicy
(see codex-compat REFERENCE) -- sync it when adding toolchain bans.

Skill-scoped hooks: skill frontmatter may carry a `hooks:` block (settings
shape) active only while the skill runs -- see `golang/SKILL.md` (per-edit Go
checks) and `resolve-pr-feedback/SKILL.md` (agent-type Stop verifier). Prefer
this over the global surface for single-vertical checks.

## 4. When grep isn't enough

Grep can't express nested interactives, exhaustive switches, or useState-object-ref leaks reliably. AST-level patterns: handle in code review for now, or file issue for future Biome custom-rule integration. Don't fake with fragile multi-line regex -- too many false positives.

## 5. View analytics

```
/hook-audit --all
```

Reports per-hook P50/P95 latency, blocks/warns/nudges/infos per rule, zero-fire candidates (prune), over-aggressive hooks (soften). Needs >=5 session summaries in `~/.claude/hook-metrics/`.

## 6. Debug a hook that isn't firing

```bash
HOOK_DEBUG=1 HOOKS_FAIL_CLOSED=1 claude
```

Then: `tail -f /tmp/hook-session-*/debug.log`. Fail-closed turns crash-into-silent-exit into crash-into-visible-block.

To rule the harness itself in or out: `claude --safe-mode` starts with ALL
customizations off (hooks, skills, CLAUDE.md, MCP) -- if the problem
disappears there, it's ours. `/doctor` flags slow hooks with real latency
numbers; treat anything it names as a P95 budget bug.

## 7. Verification checklist

- [ ] `skill-manifest.json` lists script under correct event+matcher
- [ ] `bash scripts/generate-hook-configs.sh --check` exits 0
- [ ] Script executable (`chmod +x`)
- [ ] Sources `_hook-lib.sh`, parses input, filters extension, handles escape hatch
- [ ] Test fixture added to `evals/` if non-trivial
- [ ] `bash evals/run.sh` passes
