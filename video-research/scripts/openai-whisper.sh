#!/bin/bash
set -euo pipefail

command -v uvx >/dev/null 2>&1 || {
  echo "video-research: uvx is required for the OpenAI Whisper adapter" >&2
  exit 69
}

exec uvx --python 3.12 --from openai-whisper==20250625 whisper "$@"
