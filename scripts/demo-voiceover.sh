#!/bin/bash
set -euo pipefail

# Replace a real recording's sound with an authored narration track.
# Usage: bash scripts/demo-voiceover.sh <video> <narration-audio> <new-output.mp4>
# Narration starts at zero. Longer narration fails rather than being cut off;
# shorter narration is padded with silence, preserving the complete visual take.

fail() { echo "demo-voiceover: $*" >&2; exit 1; }
[ $# -eq 3 ] || fail "usage: $0 <video> <narration-audio> <new-output.mp4>"
for tool in ffmpeg ffprobe jq; do
  command -v "$tool" >/dev/null 2>&1 || fail "needs $tool on PATH"
done

video=$1 audio=$2 out=$3
for input in "$video" "$audio"; do
  [ -f "$input" ] && [ -s "$input" ] || fail "missing or empty input: $input"
done
[[ "$out" = *.mp4 ]] || fail "output must end in .mp4"
[ ! -e "$out" ] && [ ! -L "$out" ] || fail "output already exists: $out"

duration() {
  local probe
  probe=$(ffprobe -v error -select_streams "$2:0" \
    -show_entries stream=codec_type,duration:format=duration -of json "$1") || fail "cannot inspect $1"
  jq -e --arg kind "$3" '.streams[0].codec_type == $kind' <<< "$probe" >/dev/null ||
    fail "$1 needs a $3 stream"
  # WebM may have no stream duration; validate the encoded MP4 again below.
  jq -er 'def seconds: strings | select(test("^[0-9]+(\\.[0-9]+)?$")) | tonumber | select(. > 0);
    ([.streams[0].duration | seconds][0] // (.format.duration | seconds))' <<< "$probe" ||
    fail "$1 needs a finite positive duration"
}

video_duration=$(duration "$video" v video)
audio_duration=$(duration "$audio" a audio)
awk -v a="$audio_duration" -v v="$video_duration" 'BEGIN { exit !(a <= v) }' ||
  fail "narration is longer than the recording; lengthen real capture holds or split the script"

mkdir -p "$(dirname "$out")"
stage=$(mktemp -d "$(dirname "$out")/.voiceover-XXXXXX")
trap 'rm -f "$stage/demo.mp4"; rmdir "$stage"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if ! ffmpeg -hide_banner -loglevel error -nostdin \
  -i "$video" -i "$audio" -map 0:v:0 -map 1:a:0 \
  -af apad -t "$video_duration" -c:v libx264 -preset medium -crf 18 \
  -pix_fmt yuv420p -c:a aac -movflags +faststart "$stage/demo.mp4"; then
  fail "encoding failed; no output published"
fi
[ -s "$stage/demo.mp4" ] || fail "encoding produced no media"
rendered_duration=$(duration "$stage/demo.mp4" v video)
awk -v a="$audio_duration" -v v="$rendered_duration" 'BEGIN { exit !(a <= v) }' ||
  fail "narration is longer than the encoded video stream; recapture with longer visual holds"
# Publish atomically without overwriting an output created during the encode.
ln "$stage/demo.mp4" "$out" || fail "output already exists or cannot be published: $out"
printf '%s\n' "$out"
