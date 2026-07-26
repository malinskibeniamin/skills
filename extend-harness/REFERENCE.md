# Harness Extension Reference

## Severity

| Function | Exit | Use |
|---|---:|---|
| `hook_block` | 2 | correctness that must be fixed |
| `hook_block_strict` | 2 | security-critical, no escape |
| `hook_warn` | 0 | actionable style or risk |
| `hook_nudge` | 0 | usually-suboptimal pattern |
| `hook_info` | 0 | telemetry only |
| `hook_emit_diagnostic` | 0 or 2 | ranged machine-readable finding |

Stop hooks use `hook_stop_block` for bounded blocking and `hook_stop_context` for visible
feedback that keeps the turn alive. Prose emitters truncate at 8,000 characters.

## Manifest objects

```json
{"script": "snyk-project-create-guard.sh", "if": "Bash(snyk *)"}
{"script": "ci-warning-audit.sh", "async": true, "asyncRewake": true, "statusMessage": "Auditing CI"}
```

- `if`: Claude permission-rule filter; fail open. Codex omits it, so keep the script guard.
- `async` and `asyncRewake`: background execution and wake-on-failure.
- `statusMessage`: spinner text.
- `timeout`: seconds.

Toolchain denials also belong in `permissions.deny` and the Codex execpolicy mirror.

## Generated surfaces

Edit `skill-manifest.json`, then:

```bash
bash scripts/generate-hook-configs.sh --apply
bash scripts/generate-hook-configs.sh --check
```

Generated `.claude/settings.json`, `hooks/hooks.json`, and Codex wrappers are outputs.

## Debugging

```bash
HOOK_DEBUG=1 HOOKS_FAIL_CLOSED=1 claude
tail -f /tmp/hook-session-*/debug.log
```

`claude --safe-mode` disables hooks, skills, instructions, and MCP. If the problem
disappears, re-enable surfaces until the owner is isolated.
