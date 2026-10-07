---
name: extend-harness
description: "Extend the harness: shell rules, Claude Code mods, severity tiers, and analytics."
disable-model-invocation: true
---

Edit manifests/libraries, not generated configs. [REFERENCE.md](REFERENCE.md): severities, options, parser contracts, debugging.

Claude mods: [MODS.md](MODS.md). Cross-runtime enforcement stays in settings hooks.

## Add rule

1. Prefer Biome/Ultracite; hooks cover cross-element/file, workflow, agent behavior.
2. Copy `.claude/hooks/checks/*.lib.sh`: one `run_*` function and thin `.claude/hooks/*.sh` wrapper.
3. Register in `skill-manifest.json`, usually `PostToolUse.Edit|Write`.
4. Add focused `evals/` fixture; prove RED -> GREEN.
5. Regenerate and test:

```bash
bash scripts/generate-hook-configs.sh --apply
echo '{"hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"/tmp/x.ts"}}' | bash .claude/hooks/my-check.sh
```

Use `hook_warn` for style, `hook_block` correctness, `hook_block_strict` security, `hook_info` observation. Prefer skill-scoped hooks for one vertical.

## Implementation

- Manifest objects carry permission/async filters; retain stdin guards: Codex drops Claude-only filters.
- Structure: Biome/AST. Ambiguous judgment: review, not multiline grep.
- Sync toolchain bans with `hooks/frontend-skills.rules`.

## Audit/debug

`/hook-audit --all`: latency/firing/zero-fire; `HOOK_DEBUG=1 HOOKS_FAIL_CLOSED=1 claude`: missing hooks; `claude --safe-mode`: isolate customization. `/doctor` latency is a P95 budget failure.

## Done

Manifest owns matcher; executable script sources `_hook-lib.sh`, parses stdin, filters paths, documents escape; fixture proves RED -> GREEN; generator `--check` and `bash evals/run.sh` pass.
