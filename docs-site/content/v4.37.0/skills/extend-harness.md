---
title: "/extend-harness"
description: "Extend and debug the frontend-skills hook harness, rules, severity tiers, and analytics."
type: skill
sidebar:
  label: "/extend-harness"
---
![Diagram of the /extend-harness skill](/diagrams/skills/extend-harness.svg)

[Open the editable Excalidraw source](/diagrams/skills/extend-harness.excalidraw)

Edit source manifests and libraries, never generated configs. Read
[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/extend-harness/REFERENCE.md) for severity tiers, manifest options, parser contracts, and
debugging.

## Add a rule

1. Ask whether Biome or Ultracite can express it. Use hooks only for cross-element,
   cross-file, workflow, or agent-behavior rules.
2. Start from a neighboring `.claude/hooks/checks/*.lib.sh`. Expose one `run_*` function
   and add the matching thin `.claude/hooks/*.sh` wrapper.
3. Register the wrapper in `skill-manifest.json`, usually under
   `PostToolUse.Edit|Write`.
4. Add a focused fixture under `evals/`; capture failing then passing evidence.
5. Regenerate and test:

```bash
bash scripts/generate-hook-configs.sh --apply
echo '{"hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"/tmp/x.ts"}}' |
  bash .claude/hooks/my-check.sh
```

Use `hook_warn` for style, `hook_block` for correctness, `hook_block_strict` for
security-critical rules, and `hook_info` for observation. Prefer skill-scoped hooks when
only one vertical needs the rule.

## Choose the implementation

- Permission-filtered or async entries use manifest objects; keep each script's stdin
  guard because Codex drops Claude-only filters.
- Mechanically provable structure belongs in Biome or an AST rule. Leave ambiguous
  structural judgment to review; avoid fragile multiline grep.
- Keep toolchain bans synchronized with `hooks/frontend-skills.rules`.

## Audit or debug

- Run `/hook-audit --all` for latency, firing, and zero-fire candidates.
- Start `HOOK_DEBUG=1 HOOKS_FAIL_CLOSED=1 claude` for a missing hook.
- Use `claude --safe-mode` to isolate customizations.
- Treat `/doctor` latency findings as P95 budget failures.

## Completion

- `skill-manifest.json` owns the rule and matcher.
- The script is executable, sources `_hook-lib.sh`, parses stdin, filters paths, and
  documents its escape hatch.
- The focused fixture proves RED -> GREEN.
- `bash scripts/generate-hook-configs.sh --check` passes.
- `bash evals/run.sh` passes.
