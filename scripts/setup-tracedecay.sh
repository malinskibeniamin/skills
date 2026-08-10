#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Set up the optional TraceDecay code graph companion.

Usage:
  setup-tracedecay.sh [--agent codex|claude] [--project PATH] [--yes] [--dry-run]

Options:
  --agent AGENT  Agent host to configure. Auto-detects Codex, then Claude.
  --project PATH Repository to enroll. Defaults to the current directory.
  --yes          Apply without the confirmation prompt.
  --dry-run      Print the setup plan without changing the system or project.
  -h, --help     Show this help.
EOF
}

AGENT=""
PROJECT="$PWD"
ASSUME_YES=0
DRY_RUN=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --agent)
      [ "$#" -gt 1 ] || { echo "--agent requires codex or claude" >&2; exit 64; }
      AGENT="$2"
      shift 2
      ;;
    --project)
      [ "$#" -gt 1 ] || { echo "--project requires a path" >&2; exit 64; }
      PROJECT="$2"
      shift 2
      ;;
    --yes)
      ASSUME_YES=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      ASSUME_YES=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 64
      ;;
  esac
done

if [ -z "$AGENT" ]; then
  if command -v codex >/dev/null 2>&1; then
    AGENT="codex"
  elif command -v claude >/dev/null 2>&1; then
    AGENT="claude"
  else
    echo "Could not detect Codex or Claude. Pass --agent explicitly." >&2
    exit 69
  fi
fi

case "$AGENT" in
  codex|claude) ;;
  *)
    echo "Unsupported agent: $AGENT (expected codex or claude)" >&2
    exit 64
    ;;
esac

if [ ! -d "$PROJECT" ]; then
  echo "Project directory does not exist: $PROJECT" >&2
  exit 66
fi
PROJECT="$(cd "$PROJECT" && pwd -P)"

echo "TraceDecay setup"
echo "  agent:   $AGENT"
echo "  project: $PROJECT"
echo ""
echo "This optional setup may install the TraceDecay binary, configure the agent host,"
echo "start its user daemon, and create a local project index."

if [ "$ASSUME_YES" -ne 1 ]; then
  printf "Continue? [y/N] "
  read -r answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *)
      echo "Cancelled; no changes made."
      exit 0
      ;;
  esac
fi

run() {
  printf '+ '
  printf '%q ' "$@"
  printf '\n'
  if [ "$DRY_RUN" -ne 1 ]; then
    "$@"
  fi
}

TRACEDECAY_BIN="$(command -v tracedecay 2>/dev/null || true)"
TRACEDECAY_PRESENT=1
if [ -z "$TRACEDECAY_BIN" ]; then
  TRACEDECAY_PRESENT=0
  if ! command -v brew >/dev/null 2>&1; then
    echo "TraceDecay is missing and Homebrew is unavailable." >&2
    echo "Install TraceDecay from https://github.com/ScriptedAlchemy/tracedecay, then rerun this command." >&2
    exit 69
  fi
  run brew install ScriptedAlchemy/tap/tracedecay
  if [ "$DRY_RUN" -ne 1 ]; then
    hash -r
    TRACEDECAY_BIN="$(command -v tracedecay 2>/dev/null || true)"
    if [ -z "$TRACEDECAY_BIN" ]; then
      echo "Homebrew completed but tracedecay is still unavailable on PATH." >&2
      exit 69
    fi
    TRACEDECAY_PRESENT=1
  else
    TRACEDECAY_BIN="tracedecay"
  fi
fi

run "$TRACEDECAY_BIN" install --agent "$AGENT"

if [ "$AGENT" = "codex" ]; then
  CODEX_BIN="$(command -v codex 2>/dev/null || true)"
  if [ -z "$CODEX_BIN" ]; then
    echo "Codex is required to install the generated TraceDecay plugin." >&2
    exit 69
  fi

  codex_plugins="$($CODEX_BIN plugin list --json 2>/dev/null || true)"
  if printf '%s\n' "$codex_plugins" |
    grep -qE '"pluginId"[[:space:]]*:[[:space:]]*"tracedecay@personal"'; then
    echo "TraceDecay Codex plugin already installed."
  else
    run "$CODEX_BIN" plugin add tracedecay@personal
  fi
fi

run "$TRACEDECAY_BIN" daemon install-service

if [ "$TRACEDECAY_PRESENT" -eq 0 ]; then
  run "$TRACEDECAY_BIN" init "$PROJECT"
elif "$TRACEDECAY_BIN" status "$PROJECT" >/dev/null 2>&1; then
  echo "TraceDecay project index already exists."
else
  run "$TRACEDECAY_BIN" init "$PROJECT"
fi

run "$TRACEDECAY_BIN" doctor --agent "$AGENT"

if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry run complete; no changes made."
else
  echo "TraceDecay setup complete. Restart $AGENT before relying on its MCP tools."
fi
