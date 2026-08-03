#!/bin/bash
set -euo pipefail

command -v uvx >/dev/null 2>&1 || {
  echo "video-research: uvx is required for the yt-dlp adapter" >&2
  exit 69
}

exec uvx --python 3.12 --from yt-dlp==2026.7.4 yt-dlp "$@"
