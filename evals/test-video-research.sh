# Evals for automatic, local-first video research ingestion.

SKILL="$REPO_ROOT/video-research/SKILL.md"
ANALYZE="$REPO_ROOT/video-research/scripts/analyze-video.sh"
MLX="$REPO_ROOT/video-research/scripts/mlx-whisper.sh"
OPENAI_WHISPER="$REPO_ROOT/video-research/scripts/openai-whisper.sh"
YTDLP="$REPO_ROOT/video-research/scripts/yt-dlp-uvx.sh"

run_file_eval "$SKILL" "video-research SKILL.md exists"
run_file_eval "$ANALYZE" "video analysis entrypoint exists"
run_executable_eval "$ANALYZE" "video analysis entrypoint is executable"
run_executable_eval "$MLX" "MLX Whisper adapter is executable"
run_executable_eval "$OPENAI_WHISPER" "OpenAI Whisper adapter is executable"
run_executable_eval "$YTDLP" "yt-dlp adapter is executable"

run_content_eval "$SKILL" "^name: video-research$" "video-research has correct name"
run_content_eval "$SKILL" "attached or local video files|video attachments" \
  "video attachments trigger the skill"
run_content_eval "$SKILL" "timestamped transcripts" "skill produces timestamped transcripts"
run_content_eval "$SKILL" "OCR|on-screen text" "skill captures visual text"
run_content_eval "$SKILL" "local-only|local by default" "skill keeps transcription local by default"
run_content_eval "$SKILL" "missing transcript|empty transcript" \
  "skill makes missing transcription visible"
run_content_eval "$REPO_ROOT/research/SKILL.md" "/video-research" \
  "research routes video evidence through video-research"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"./video-research/"' \
  "Claude plugin registers video-research"
run_content_eval "$REPO_ROOT/codex-skills/video-research/SKILL.md" \
  "../../video-research/SKILL.md" "Codex proxy routes to video-research"

_video_tmp=$(mktemp -d)
trap 'find "$_video_tmp" -depth -delete 2>/dev/null || true' EXIT
_video_bin="$_video_tmp/bin"
_video_out="$_video_tmp/out"
_video_source="$_video_tmp/video fixture.mp4"
mkdir -p "$_video_bin"
: > "$_video_source"

cat > "$_video_bin/bunx" <<'SH'
#!/bin/bash
set -eu
printf '%s\n' "$@" > "$FAKE_ANALYZER_ARGS"
printf '%s' "${OPENAI_API_KEY-unset}" > "$FAKE_OPENAI_KEY"
printf '%s' "${TWELVELABS_API_KEY-unset}" > "$FAKE_TWELVELABS_KEY"
if [ "${FAKE_ANALYZER_MODE:-success}" = "missing-backend" ]; then
  cat <<'JSON'
{"warnings":["No speech-to-text backend available. Install Whisper."],"metadata":{"title":"Silent fixture","duration":3},"transcript":[],"ocrResults":[],"timeline":[],"frames":[]}
JSON
  exit 0
fi
cat <<'JSON'
{"warnings":[],"metadata":{"title":"Fixture video","duration":3,"url":"fixture.mp4"},"transcript":[{"time":"0:00","text":"First line"},{"time":"0:02","text":"Second line"}],"ocrResults":[{"time":"0:01","text":"Slide heading"}],"timeline":[],"frames":[]}
JSON
SH
chmod +x "$_video_bin/bunx"

_python_bin=$(dirname "$(command -v python3)")
_video_path="$_video_bin:$_python_bin:/usr/bin:/bin"
_video_args="$_video_tmp/analyzer-args"
_video_key="$_video_tmp/openai-key"
_video_twelvelabs_key="$_video_tmp/twelvelabs-key"

_video_exit=0
PATH="$_video_path" \
  FAKE_ANALYZER_ARGS="$_video_args" \
  FAKE_OPENAI_KEY="$_video_key" \
  FAKE_TWELVELABS_KEY="$_video_twelvelabs_key" \
  TWELVELABS_API_KEY=secret \
  "$ANALYZE" --output-dir "$_video_out" "$_video_source" \
  > "$_video_tmp/stdout" 2> "$_video_tmp/stderr" || _video_exit=$?

if [ "$_video_exit" -eq 0 ] && [ -s "$_video_out/analysis.json" ] && \
  [ -s "$_video_out/transcript.txt" ] && [ -s "$_video_out/research.md" ]; then
  echo "  PASS  analyzer emits JSON, plain text, and research Markdown"
  PASS=$((PASS + 1))
else
  echo "  FAIL  analyzer output contract (exit=$_video_exit)"
  sed 's/^/        /' "$_video_tmp/stderr"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: analyzer output contract"
fi

if grep -qF "First line" "$_video_out/transcript.txt" && \
  grep -qF "[0:02] Second line" "$_video_out/research.md" && \
  grep -qF "Slide heading" "$_video_out/research.md"; then
  echo "  PASS  analyzer preserves transcript timecodes and OCR evidence"
  PASS=$((PASS + 1))
else
  echo "  FAIL  analyzer normalized evidence is incomplete"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: analyzer normalized evidence"
fi

_absolute_source=$(cd "$(dirname "$_video_source")" && pwd)/$(basename "$_video_source")
if grep -Fxq "mcp-video-analyzer@0.7.1" "$_video_args" && \
  grep -Fxq "$_absolute_source" "$_video_args" && \
  grep -Fxq -- "--model" "$_video_args" && grep -Fxq "small" "$_video_args"; then
  echo "  PASS  analyzer pins its engine, preserves spaced paths, and selects a research model"
  PASS=$((PASS + 1))
else
  echo "  FAIL  analyzer invocation drift"
  sed 's/^/        /' "$_video_args"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: analyzer invocation drift"
fi

if [ ! -s "$_video_key" ] && [ ! -s "$_video_twelvelabs_key" ]; then
  echo "  PASS  cloud video services are disabled by default"
  PASS=$((PASS + 1))
else
  echo "  FAIL  analyzer exposed a cloud video API key to its subprocess"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: cloud transcription default"
fi

_missing_exit=0
PATH="$_video_path" \
  FAKE_ANALYZER_ARGS="$_video_args" \
  FAKE_OPENAI_KEY="$_video_key" \
  FAKE_TWELVELABS_KEY="$_video_twelvelabs_key" \
  FAKE_ANALYZER_MODE=missing-backend \
  "$ANALYZE" --output-dir "$_video_tmp/missing" "$_video_source" \
  > "$_video_tmp/missing-stdout" 2> "$_video_tmp/missing-stderr" || _missing_exit=$?
if [ "$_missing_exit" -ne 0 ] && grep -qF "No speech-to-text backend available" "$_video_tmp/missing-stderr"; then
  echo "  PASS  missing speech backend fails visibly"
  PASS=$((PASS + 1))
else
  echo "  FAIL  missing speech backend was treated as successful empty content"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: missing backend visibility"
fi

_adapter_bin="$_video_tmp/adapter-bin"
mkdir -p "$_adapter_bin"
cat > "$_adapter_bin/uvx" <<'SH'
#!/bin/bash
printf '%s\n' "$@" > "$FAKE_UVX_ARGS"
SH
chmod +x "$_adapter_bin/uvx"

FAKE_UVX_ARGS="$_video_tmp/mlx-args" PATH="$_adapter_bin:/usr/bin:/bin" \
  "$MLX" audio.wav --output_format json --model small --output_dir "$_video_tmp/mlx out"
if grep -Fxq "mlx-whisper==0.4.3" "$_video_tmp/mlx-args" && \
  grep -Fxq "mlx-community/whisper-small-mlx" "$_video_tmp/mlx-args" && \
  grep -Fxq -- "--output-format" "$_video_tmp/mlx-args" && \
  ! grep -Fxq -- "--output_format" "$_video_tmp/mlx-args"; then
  echo "  PASS  MLX adapter pins runtime and translates Whisper arguments"
  PASS=$((PASS + 1))
else
  echo "  FAIL  MLX adapter argument translation"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: MLX adapter translation"
fi

FAKE_UVX_ARGS="$_video_tmp/openai-whisper-args" PATH="$_adapter_bin:/usr/bin:/bin" \
  "$OPENAI_WHISPER" audio.wav --output_format json --model small
if grep -Fxq "openai-whisper==20250625" "$_video_tmp/openai-whisper-args" && \
  grep -Fxq -- "--output_format" "$_video_tmp/openai-whisper-args"; then
  echo "  PASS  cross-platform Whisper adapter pins runtime and preserves arguments"
  PASS=$((PASS + 1))
else
  echo "  FAIL  cross-platform Whisper adapter invocation"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: cross-platform Whisper adapter"
fi

FAKE_UVX_ARGS="$_video_tmp/ytdlp-args" PATH="$_adapter_bin:/usr/bin:/bin" \
  "$YTDLP" --version
if grep -Fxq "yt-dlp==2026.7.4" "$_video_tmp/ytdlp-args" && \
  grep -Fxq "yt-dlp" "$_video_tmp/ytdlp-args"; then
  echo "  PASS  yt-dlp adapter pins its local runtime"
  PASS=$((PASS + 1))
else
  echo "  FAIL  yt-dlp adapter invocation"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: yt-dlp adapter"
fi
