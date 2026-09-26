#!/bin/bash
set -euo pipefail

# Before/after PR video evidence.
#
#   scripts/pr-video.sh compose <before-video> <after-video> <out-dir>
#     Side-by-side (before left, after right) at one height. The shorter take
#     freezes on its last frame. Writes before-after.mp4 (linked) and
#     before-after.gif (inline: GitHub renders GIFs from URLs, not videos).
#
#   scripts/pr-video.sh publish <file>...
#     Commits files to the `pr-evidence` branch under <current-branch>/ with git
#     plumbing (active HEAD, index, and tree untouched), pushes it, and prints
#     SHA-pinned Markdown. `gh` cannot upload PR attachments; this is the host.
#     PR_VIDEO_REPO_URL overrides the https://github.com/<owner>/<repo> base.

usage() {
  sed -n '6,16p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 2
}

GIF_LIMIT_BYTES=$((10 * 1024 * 1024))

duration_of() {
  local seconds
  seconds=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$1")
  if ! printf '%s' "$seconds" | grep -qE '^[0-9]+(\.[0-9]+)?$'; then
    echo "pr-video: no duration in $1; remux it with ffmpeg -i in -c copy out.mp4" >&2
    exit 1
  fi
  printf '%s\n' "$seconds"
}

compose() {
  [ $# -eq 3 ] || usage
  command -v ffmpeg >/dev/null 2>&1 || { echo "pr-video: needs ffmpeg (brew install ffmpeg)" >&2; exit 127; }
  local before=$1 after=$2 out=$3
  for input in "$before" "$after"; do
    [ -s "$input" ] || { echo "pr-video: missing recording: $input" >&2; exit 1; }
  done
  local longest
  longest=$(awk -v a="$(duration_of "$before")" -v b="$(duration_of "$after")" \
    'BEGIN { print (a > b ? a : b) }')
  mkdir -p "$out"

  local side='fps=15,scale=-2:720,setsar=1,tpad=stop_mode=clone:stop_duration=3600'
  ffmpeg -hide_banner -loglevel error -y -i "$before" -i "$after" -filter_complex \
    "[0:v]${side},pad=iw+8:ih:0:0:color=gray[b];[1:v]${side}[a];[b][a]hstack=inputs=2,scale=trunc(iw/2)*2:720[v]" \
    -map '[v]' -t "$longest" -c:v libx264 -pix_fmt yuv420p -crf 28 -movflags +faststart \
    "$out/before-after.mp4"
  ffmpeg -hide_banner -loglevel error -y -i "$out/before-after.mp4" -filter_complex \
    '[0:v]fps=10,scale=min(1200\,iw):-2:flags=lanczos,split[x][y];[x]palettegen=stats_mode=diff[p];[y][p]paletteuse=dither=bayer:bayer_scale=4' \
    "$out/before-after.gif"

  local gif_bytes
  gif_bytes=$(wc -c < "$out/before-after.gif" | tr -d ' ')
  if [ "$gif_bytes" -gt "$GIF_LIMIT_BYTES" ]; then
    echo "pr-video: before-after.gif is over GitHub's 10 MB image limit; trim the takes" >&2
    exit 1
  fi
  printf '%s\n' "$out/before-after.mp4" "$out/before-after.gif"
}

repo_url() {
  if [ -n "${PR_VIDEO_REPO_URL:-}" ]; then
    printf '%s\n' "${PR_VIDEO_REPO_URL%/}"
    return
  fi
  git remote get-url origin | sed -E 's#^git@([^:]+):#https://\1/#; s#^ssh://git@#https://#; s#\.git$##'
}

publish() {
  [ $# -ge 1 ] || usage
  local branch ref=refs/heads/pr-evidence parent="" index
  branch=$(git branch --show-current)
  [ -n "$branch" ] || { echo "pr-video: detached HEAD; check out the PR branch" >&2; exit 1; }
  if git fetch -q origin "+$ref:refs/pr-video/evidence" 2>/dev/null; then
    parent=$(git rev-parse refs/pr-video/evidence)
  fi

  index=$(mktemp)
  trap 'rm -f "$index"' RETURN
  export GIT_INDEX_FILE=$index
  if [ -n "$parent" ]; then git read-tree "$parent"; else git read-tree --empty; fi
  local file blob
  for file in "$@"; do
    [ -s "$file" ] || { echo "pr-video: missing file: $file" >&2; exit 1; }
    blob=$(git hash-object -w "$file")
    git update-index --add --cacheinfo "100644,$blob,$branch/$(basename "$file")"
  done
  local tree commit
  tree=$(git write-tree)
  unset GIT_INDEX_FILE
  commit=$(git -c user.name="$(git config user.name || echo pr-video)" \
    -c user.email="$(git config user.email || echo pr-video@localhost)" commit-tree "$tree" ${parent:+-p "$parent"} -m "evidence: $branch")
  # Non-fast-forward means a concurrent publish won; rerun to append on top.
  git push -q origin "$commit:$ref"

  local base
  base=$(repo_url)
  for file in "$@"; do
    local name url
    name=$(basename "$file")
    url="$base/blob/$commit/$branch/$name?raw=true"
    case "$name" in
      *.gif | *.png | *.jpg | *.jpeg | *.webp) printf '![%s](%s)\n' "$name" "$url" ;;
      *) printf '[%s](%s)\n' "$name" "$url" ;;
    esac
  done
}

case "${1:-}" in
  compose) shift; compose "$@" ;;
  publish) shift; publish "$@" ;;
  *) usage ;;
esac
