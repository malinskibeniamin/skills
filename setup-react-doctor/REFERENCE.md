# React Doctor Reference

## react-doctor-stop.sh

> Script: [`scripts/react-doctor-stop.sh`](scripts/react-doctor-stop.sh)

## Rule Categories

| Category | Biome covers? | Keep in react-doctor? |
|----------|--------------|----------------------|
| Hook dependencies | Yes | No (disabled) |
| Nested components | Yes | No (disabled) |
| Performance patterns | No | Yes |
| Bundle size analysis | No | Yes |
| Dead code detection | No | Yes |
| Security (secrets, XSS) | Partial | Yes |
| Accessibility | Partial | Yes |
| Architecture (prop drilling) | No | Yes |

## CLI Flags

| Flag | Purpose |
|------|---------|
| `--diff` | Only scan changed files |
| `--verbose` | Show file-level details |
| `--score` | Output just the numeric score |
| `--no-lint` | Skip linting (keep dead code) |
| `--no-dead-code` | Skip dead code (keep linting) |
| `--fix` | Auto-fix with AI |