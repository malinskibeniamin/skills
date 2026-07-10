#!/usr/bin/env bash
set -euo pipefail

# Single-source rules: CLAUDE.md is the hand-written source of truth.
# AGENTS.md (Codex) is GENERATED = header + CLAUDE.md body + Codex appendix.
# Usage: generate-agents-md.sh --apply | --check   (lefthook runs --check)

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
SRC="$ROOT/CLAUDE.md"
APPENDIX="$ROOT/.agents/codex-appendix.md"
OUT="$ROOT/AGENTS.md"

_render() {
  echo "<!-- GENERATED from CLAUDE.md + .agents/codex-appendix.md by scripts/generate-agents-md.sh -- do not edit by hand -->"
  cat "$SRC"
  if [ -f "$APPENDIX" ]; then
    echo ""
    cat "$APPENDIX"
  fi
}

case "${1:---check}" in
  --apply)
    _render > "$OUT"
    echo "AGENTS.md regenerated from CLAUDE.md + codex-appendix"
    ;;
  --check)
    if ! _render | diff -q - "$OUT" >/dev/null 2>&1; then
      echo "DRIFT: AGENTS.md differs from generated output. Run scripts/generate-agents-md.sh --apply" >&2
      exit 1
    fi
    echo "OK: AGENTS.md matches generated output"
    ;;
  *)
    echo "usage: $0 --apply|--check" >&2
    exit 1
    ;;
esac
