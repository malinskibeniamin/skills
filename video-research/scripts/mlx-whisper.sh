#!/bin/bash
set -euo pipefail

command -v uvx >/dev/null 2>&1 || {
  echo "video-research: uvx is required for the MLX Whisper adapter" >&2
  exit 69
}

model_repo() {
  case "$1" in
    tiny) echo "mlx-community/whisper-tiny" ;;
    tiny.en) echo "mlx-community/whisper-tiny.en-mlx" ;;
    base) echo "mlx-community/whisper-base-mlx" ;;
    base.en) echo "mlx-community/whisper-base.en-mlx" ;;
    small) echo "mlx-community/whisper-small-mlx" ;;
    small.en) echo "mlx-community/whisper-small.en-mlx" ;;
    medium) echo "mlx-community/whisper-medium-mlx" ;;
    medium.en) echo "mlx-community/whisper-medium.en-mlx" ;;
    large) echo "mlx-community/whisper-large-mlx" ;;
    large-v2) echo "mlx-community/whisper-large-v2-mlx" ;;
    large-v3) echo "mlx-community/whisper-large-v3-mlx" ;;
    turbo|large-v3-turbo) echo "mlx-community/whisper-large-v3-turbo" ;;
    *) echo "$1" ;;
  esac
}

translated=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --model)
      [ "$#" -ge 2 ] || { echo "video-research: --model requires a value" >&2; exit 64; }
      translated+=(--model "$(model_repo "$2")")
      shift 2
      ;;
    --output_format) translated+=(--output-format "$2"); shift 2 ;;
    --output_dir) translated+=(--output-dir "$2"); shift 2 ;;
    --output_name) translated+=(--output-name "$2"); shift 2 ;;
    --initial_prompt) translated+=(--initial-prompt "$2"); shift 2 ;;
    --word_timestamps) translated+=(--word-timestamps "$2"); shift 2 ;;
    --device|--compute_type|--beam_size)
      echo "video-research: $1 is unsupported by MLX Whisper; unset the matching WHISPER_* option" >&2
      exit 64
      ;;
    *)
      translated+=("$1")
      shift
      ;;
  esac
done

exec uvx --python 3.12 --from mlx-whisper==0.4.3 mlx_whisper "${translated[@]}"
