#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: analyze-video.sh [options] <video-url-or-path>

Options:
  --output-dir <dir>     Save artifacts here (default: temporary directory)
  --language <code>      Force transcript language, for example en or pl
  --model <name>         Whisper model (default: small)
  --ocr-language <codes> Tesseract languages (default: eng)
  -h, --help             Show this help
EOF
}

die() {
  printf 'video-research: %s\n' "$1" >&2
  exit "${2:-64}"
}

output_dir=""
language=""
model="${VIDEO_RESEARCH_MODEL:-small}"
ocr_language="${VIDEO_RESEARCH_OCR_LANGUAGE:-eng}"
source_value=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --output-dir)
      [ "$#" -ge 2 ] || die "--output-dir requires a value"
      output_dir="$2"
      shift 2
      ;;
    --language)
      [ "$#" -ge 2 ] || die "--language requires a value"
      language="$2"
      shift 2
      ;;
    --model)
      [ "$#" -ge 2 ] || die "--model requires a value"
      model="$2"
      shift 2
      ;;
    --ocr-language)
      [ "$#" -ge 2 ] || die "--ocr-language requires a value"
      ocr_language="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      [ -z "$source_value" ] || die "provide exactly one video URL or path"
      source_value="$1"
      shift
      ;;
  esac
done

if [ "$#" -gt 0 ]; then
  [ -z "$source_value" ] || die "provide exactly one video URL or path"
  source_value="$1"
  shift
fi
[ "$#" -eq 0 ] || die "provide exactly one video URL or path"
[ -n "$source_value" ] || { usage >&2; exit 64; }

command -v bunx >/dev/null 2>&1 || die "bunx is required; install Bun first" 69
command -v python3 >/dev/null 2>&1 || die "python3 is required to render artifacts" 69

is_url=0
case "$source_value" in
  *://*)
    source="$source_value"
    is_url=1
    ;;
  *)
    [ -f "$source_value" ] || die "video file not found: $source_value" 66
    source_dir=$(cd "$(dirname "$source_value")" && pwd)
    source="$source_dir/$(basename "$source_value")"
    ;;
esac

if [ -z "$output_dir" ]; then
  output_dir=$(mktemp -d "${TMPDIR:-/tmp}/video-research.XXXXXX")
else
  mkdir -p "$output_dir"
  output_dir=$(cd "$output_dir" && pwd)
fi

frames_dir="$output_dir/frames"
analysis_path="$output_dir/analysis.json"
analysis_tmp="$output_dir/.analysis.json.tmp.$$"
progress_path="$output_dir/progress.log"
transcript_path="$output_dir/transcript.txt"
research_path="$output_dir/research.md"
mkdir -p "$frames_dir"

runtime_bin=""
cleanup() {
  rm -f "$analysis_tmp"
  if [ -n "$runtime_bin" ]; then
    rm -f "$runtime_bin/yt-dlp"
    rmdir "$runtime_bin" 2>/dev/null || true
  fi
}
trap cleanup EXIT

script_dir=$(cd "$(dirname "$0")" && pwd)
runtime_path="$PATH"

needs_ytdlp=0
if [ "$is_url" -eq 1 ]; then
  case "$source" in
    *youtube.com*|*youtu.be*|*vimeo.com*|*tiktok.com*|*instagram.com*|*twitter.com*|*x.com/*|*twitch.tv*|*dailymotion.com*|*facebook.com*|*loom.com*)
      needs_ytdlp=1
      ;;
  esac
fi

if [ "$needs_ytdlp" -eq 1 ] && ! command -v yt-dlp >/dev/null 2>&1; then
  command -v uvx >/dev/null 2>&1 || die \
    "yt-dlp is required for this platform; install yt-dlp or uv before retrying" 69
  runtime_bin=$(mktemp -d "${TMPDIR:-/tmp}/video-research-bin.XXXXXX")
  ln -s "$script_dir/yt-dlp-uvx.sh" "$runtime_bin/yt-dlp"
  runtime_path="$runtime_bin:$PATH"
fi

whisper_bin="${WHISPER_BIN:-}"
if [ -z "$whisper_bin" ] && ! command -v whisper >/dev/null 2>&1 && \
  command -v uvx >/dev/null 2>&1; then
  if [ "$(uname -s)" = "Darwin" ] && [ "$(uname -m)" = "arm64" ]; then
    whisper_bin="$script_dir/mlx-whisper.sh"
  else
    whisper_bin="$script_dir/openai-whisper.sh"
  fi
fi

analyzer_args=(
  "mcp-video-analyzer@0.7.1"
  analyze
  "$source"
  --fields
  "metadata,transcript,frames,chapters,ocrResults,timeline"
  --out
  "$frames_dir"
  --model
  "$model"
  --ocr-language
  "$ocr_language"
)
if [ -n "$language" ]; then
  analyzer_args+=(--language "$language")
fi

analyzer_exit=0
PATH="$runtime_path" \
  OPENAI_API_KEY= \
  TWELVELABS_API_KEY= \
  WHISPER_BIN="$whisper_bin" \
  bunx "${analyzer_args[@]}" > "$analysis_tmp" 2> "$progress_path" || analyzer_exit=$?

if [ "$analyzer_exit" -ne 0 ]; then
  cat "$progress_path" >&2
  die "video analyzer failed with exit $analyzer_exit; log: $progress_path" "$analyzer_exit"
fi
mv "$analysis_tmp" "$analysis_path"

render_exit=0
python3 - "$analysis_path" "$transcript_path" "$research_path" "$source" <<'PY' || render_exit=$?
import json
import pathlib
import sys

analysis_path, transcript_path, research_path, source = sys.argv[1:]

try:
    data = json.loads(pathlib.Path(analysis_path).read_text(encoding="utf-8"))
except (OSError, json.JSONDecodeError) as error:
    print(f"video-research: invalid analyzer JSON: {error}", file=sys.stderr)
    raise SystemExit(65)

if not isinstance(data, dict):
    print("video-research: analyzer JSON root must be an object", file=sys.stderr)
    raise SystemExit(65)

metadata = data.get("metadata") if isinstance(data.get("metadata"), dict) else {}
transcript = data.get("transcript") if isinstance(data.get("transcript"), list) else []
ocr_results = data.get("ocrResults") if isinstance(data.get("ocrResults"), list) else []
frames = data.get("frames") if isinstance(data.get("frames"), list) else []
warnings = [item for item in data.get("warnings", []) if isinstance(item, str)]

def clean(value: object) -> str:
    return " ".join(str(value or "").split())

def evidence_lines(entries: list[object]) -> list[str]:
    lines = []
    for entry in entries:
        if not isinstance(entry, dict):
            continue
        text = clean(entry.get("text"))
        if not text:
            continue
        time = clean(entry.get("time")) or "0:00"
        lines.append(f"[{time}] {text}")
    return lines

transcript_lines = evidence_lines(transcript)
ocr_lines = evidence_lines(ocr_results)
pathlib.Path(transcript_path).write_text(
    "\n".join(line.split("] ", 1)[-1] for line in transcript_lines) +
    ("\n" if transcript_lines else ""),
    encoding="utf-8",
)

title = clean(metadata.get("title")) or "Untitled video"
duration = clean(metadata.get("durationFormatted") or metadata.get("duration")) or "unknown"
markdown = [
    "# Video evidence",
    "",
    f"- **Title:** {title}",
    f"- **Source:** {source}",
    f"- **Duration:** {duration}",
    "",
    "## Transcript",
    "",
]
markdown.extend(transcript_lines or ["_No transcript produced._"])
markdown.extend(["", "## On-screen text", ""])
markdown.extend(ocr_lines or ["_No OCR text detected._"])

if frames:
    markdown.extend(["", "## Frames", ""])
    for frame in frames:
        if not isinstance(frame, dict):
            continue
        time = clean(frame.get("time")) or "unknown"
        file_path = clean(frame.get("filePath"))
        if file_path:
            markdown.append(f"- [{time}] `{file_path}`")

if warnings:
    markdown.extend(["", "## Processing warnings", ""])
    markdown.extend(f"- {clean(warning)}" for warning in warnings)

pathlib.Path(research_path).write_text("\n".join(markdown) + "\n", encoding="utf-8")

for warning in warnings:
    print(f"video-research warning: {warning}", file=sys.stderr)

missing_backend = any("No speech-to-text backend available" in warning for warning in warnings)
if missing_backend:
    raise SystemExit(3)
if not transcript_lines and not ocr_lines:
    print(
        "video-research warning: no speech or OCR text found; inspect the extracted frames",
        file=sys.stderr,
    )
PY

printf 'analysis: %s\ntranscript: %s\nresearch: %s\n' \
  "$analysis_path" "$transcript_path" "$research_path"

if [ "$render_exit" -ne 0 ]; then
  if [ "$render_exit" -eq 3 ]; then
    printf 'video-research: install a local Whisper backend or uv, then rerun; artifacts remain in %s\n' \
      "$output_dir" >&2
  fi
  exit "$render_exit"
fi
