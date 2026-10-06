#!/bin/bash
set -euo pipefail

# Before/after PR video evidence.
#
#   scripts/pr-video.sh record <url> <flow-file> <out.webm>
#     Replays one agent-browser command per flow-file line with a visible cursor,
#     pausing PR_VIDEO_STEP_MS (default 700) per step. The first `# ` line is the
#     title; a `## ` line captions the next step. Writes <out.webm>.steps.json.
#     Needs 2+ interaction steps (hover or wait alone is not a flow). Run the
#     same flow file against base and candidate. A failed step fails.
#
#   scripts/pr-video.sh compose <before-video> <after-video> <out-dir>
#     Before left, after right; the shorter take freezes on its last frame.
#     Set PR_VIDEO_BEFORE_LABEL / PR_VIDEO_AFTER_LABEL to concrete behavior
#     descriptions (for example "Previous: save silently" / "New: saved notice").
#     PR_VIDEO_FOCUS=x:y:width:height crops both takes to the changed region.
#     Rejects static and duplicate takes. PR_VIDEO_RENDERER=auto
#     (default) frames the takes in HyperFrames with labels and step captions,
#     falling back to ffmpeg; `hyperframes` or `ffmpeg` forces one.
#     Writes before-after.mp4 and before-after.gif.
#
#   scripts/pr-video.sh attach [--body-file <markdown>] <file.mp4>...
#     Uploads native media with gh pr edit --attach, no browser. Appends to the
#     current PR body, or rewrites local media references in the supplied body.
#     PR_VIDEO_PR_URL selects another PR. Prints the PR URL, not asset URLs.
#     Exit 3: upgrade gh for --attach support. Requires gh auth and push access.
#
#   scripts/pr-video.sh publish <file>...
#     Commits files to the `pr-evidence` branch under <current-branch>/ with git
#     plumbing (active HEAD, index, and tree untouched), pushes it, and prints
#     SHA-pinned Markdown: GIFs and images render inline; other files are links.
#     PR_VIDEO_REPO_URL overrides the https://github.com/<owner>/<repo> base.

usage() {
  sed -n '6,30p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 2
}

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
MIN_DISTINCT_FRAMES=8
MIN_INTERACTIONS=2
INTERACTION_RE='^(click|dblclick|type|fill|press|keyboard|select|check|uncheck|drag|scroll|upload|open|goto|navigate|find|mouse)[[:space:]]'

GIF_LIMIT_BYTES=$((10 * 1024 * 1024))

# The manifest owns the only renderer pin. Installed plugin copies can use bunx
# without repository node_modules; CI uses the frozen-lockfile installation.
hyperframes_command() {
  local root="$SCRIPT_DIR/.." version installed
  version=$(jq -er '.devDependencies.hyperframes | select(type == "string") |
    select(test("^(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)$"))' "$root/package.json") || {
    echo "pr-video: package.json must pin hyperframes to an exact stable version" >&2
    return 1
  }
  installed=$(jq -r '.version' "$root/node_modules/hyperframes/package.json" 2>/dev/null || true)
  if [ "$installed" = "$version" ] && [ -x "$root/node_modules/.bin/hyperframes" ]; then
    HYPERFRAMES_CMD=("$root/node_modules/.bin/hyperframes")
  else
    HYPERFRAMES_CMD=(bunx "hyperframes@$version")
  fi
}

now() { perl -MTime::HiRes=time -e 'printf "%.3f\n", time'; }

duration_of() {
  local seconds
  seconds=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$1")
  if ! printf '%s' "$seconds" | grep -qE '^[0-9]+(\.[0-9]+)?$'; then
    echo "pr-video: no duration in $1; remux it with ffmpeg -i in -c copy out.mp4" >&2
    exit 1
  fi
  printf '%s\n' "$seconds"
}

# A reviewer must watch the flow happen. UI takes are mostly unchanged frames
# between discrete changes, so count distinct frames, not still time: a still
# page or hover-only take has one or two, a typed-and-submitted flow has dozens.
require_motion() {
  local distinct
  distinct=$(ffmpeg -hide_banner -nostats -i "$1" -map 0:v:0 -vf mpdecimate -f null - 2>&1 |
    grep -oE 'frame= *[0-9]+' | tail -n 1 | tr -dc '0-9')
  if [ "${distinct:-0}" -lt "$MIN_DISTINCT_FRAMES" ]; then
    echo "pr-video: $1 is static (${distinct:-0} distinct frames, need $MIN_DISTINCT_FRAMES); record the flow (clicks, typing, navigation) with pr-video.sh record" >&2
    exit 1
  fi
}

# Hash decoded pixels, not container metadata or audio. No similarity threshold:
# a small real UI change must remain eligible for a focused comparison.
video_hash() {
  ffmpeg -v error -i "$1" -map 0:v:0 -an -vf "${FOCUS_FILTER}null" -c:v rawvideo -pix_fmt rgb24 \
    -f hash -hash sha256 -
}

record() {
  [ $# -eq 3 ] || usage
  command -v agent-browser >/dev/null 2>&1 || { echo "pr-video: needs agent-browser" >&2; exit 127; }
  local url=$1 flow=$2 out=$3 session="pr-video-$$" step_ms=${PR_VIDEO_STEP_MS:-700}
  [ -s "$flow" ] || { echo "pr-video: missing flow file: $flow" >&2; exit 1; }
  if [ "$(grep -cE "$INTERACTION_RE" "$flow" || true)" -lt "$MIN_INTERACTIONS" ]; then
    echo "pr-video: $flow needs $MIN_INTERACTIONS+ interaction steps (click, type, press, scroll, open); hover and wait alone do not show a flow" >&2
    exit 1
  fi
  export AGENT_BROWSER_DEFAULT_TIMEOUT=${PR_VIDEO_STEP_TIMEOUT_MS:-15000}
  trap 'agent-browser --session "'"$session"'" close >/dev/null 2>&1 || true' EXIT
  agent-browser --session "$session" open --init-script "$SCRIPT_DIR/pr-video-cursor.js" about:blank >/dev/null
  agent-browser --session "$session" set viewport 1280 720 >/dev/null
  agent-browser --session "$session" record start "$out" "$url" >/dev/null
  local started title="" caption="" steps='[]'
  started=$(now)
  agent-browser --session "$session" wait "$step_ms" >/dev/null
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      '## '*) caption=${line#'## '}; continue ;;
      '# '*) [ -n "$title" ] || title=${line#'# '}; continue ;;
      '' | '#'*) continue ;;
    esac
    if [ -n "$caption" ]; then
      steps=$(jq -c --arg caption "$caption" --argjson at "$(awk -v a="$(now)" -v b="$started" 'BEGIN { printf "%.3f", a - b }')" \
        '. + [{at: $at, caption: $caption}]' <<< "$steps")
      caption=""
    fi
    eval "set -- $line"
    if ! agent-browser --session "$session" "$@" >/dev/null; then
      agent-browser --session "$session" record stop >/dev/null 2>&1 || true
      echo "pr-video: flow step failed: $line" >&2
      exit 1
    fi
    agent-browser --session "$session" wait "$step_ms" >/dev/null
  done < "$flow"
  # Hold the end state long enough to read, short of the still-frame gate.
  agent-browser --session "$session" wait 1500 >/dev/null
  agent-browser --session "$session" record stop >/dev/null
  jq -n --arg title "$title" --argjson steps "$steps" '{title: $title, steps: $steps}' > "$out.steps.json"
  printf '%s\n' "$out"
}

attach() {
  local body=""
  if [ "${1:-}" = --body-file ]; then
    [ $# -ge 3 ] || usage
    body=$2
    [ -f "$body" ] && [ -r "$body" ] || { echo "pr-video: unreadable body file: $body" >&2; exit 1; }
    shift 2
  fi
  [ $# -ge 1 ] || usage
  command -v gh >/dev/null 2>&1 || { echo "pr-video: needs GitHub CLI (gh)" >&2; exit 127; }
  local file help
  for file in "$@"; do
    [ -f "$file" ] && [ -s "$file" ] || { echo "pr-video: missing or empty file: $file" >&2; exit 1; }
  done
  help=$(gh pr edit --help)
  if ! printf '%s\n' "$help" | grep -q -- '--attach'; then
    echo "pr-video: gh pr edit needs --attach support; upgrade GitHub CLI (brew upgrade gh on macOS), then rerun. Browser upload is not used." >&2
    exit 3
  fi
  local args=(pr edit)
  [ -z "${PR_VIDEO_PR_URL:-}" ] || args+=("$PR_VIDEO_PR_URL")
  [ -z "$body" ] || args+=(--body-file "$body")
  for file in "$@"; do args+=(--attach "$file"); done
  # With no body flag, gh preserves the current body and appends native media.
  local status=0
  gh "${args[@]}" || status=$?
  if [ "$status" -ne 0 ]; then
    echo "pr-video: attachment command failed; some uploads may have succeeded. Use gh pr view to read the PR body before retrying only missing attachments." >&2
    return "$status"
  fi
}

frame_ffmpeg() {
  local side="${FOCUS_FILTER}fps=15,scale=-2:720,setsar=1,tpad=stop_mode=clone:stop_duration=3600"
  ffmpeg -hide_banner -loglevel error -y -i "$1" -i "$2" -filter_complex \
    "[0:v]${side},pad=iw+8:ih:0:0:color=gray[b];[1:v]${side}[a];[b][a]hstack=inputs=2,scale=trunc(iw/2)*2:720[v]" \
    -map '[v]' -t "$4" -c:v libx264 -pix_fmt yuv420p -crf 28 -movflags +faststart \
    "$3/before-after.mp4"
}

# Captions for one side from its record sidecar, as HyperFrames clips.
side_captions() {
  local side=$1 video=$2 duration=$3 left=$4
  [ -s "$video.steps.json" ] || { printf '[]'; return; }
  jq -c --arg side "$side" --argjson end "$duration" --argjson left "$left" '
    .steps as $s | [range(0; $s | length) as $i | {
      id: "\($side)-cap-\($i)", at: $s[$i].at, caption: $s[$i].caption, left: $left,
      duration: ((if $i + 1 < ($s | length) then $s[$i + 1].at else $end end) - $s[$i].at)
    } | select(.duration > 0)]' "$video.steps.json"
}

# Frame the real takes: labels, title, and per-side step captions. Never runs
# `hyperframes init`, which installs global agent skills.
frame_hyperframes() {
  local before=$1 after=$2 out=$3 duration=$4 project="$3/hyperframes"
  mkdir -p "$project/assets"
  local side input
  for side in before after; do
    [ "$side" = before ] && input=$before || input=$after
    ffmpeg -hide_banner -loglevel error -y -i "$input" -vf "${FOCUS_FILTER}fps=30,tpad=stop_mode=clone:stop_duration=3600" \
      -t "$duration" -an -c:v libx264 -pix_fmt yuv420p "$project/assets/$side.mp4" || return 1
  done
  local title captions
  title=$(jq -r '.title // empty' "$after.steps.json" 2>/dev/null || true)
  captions=$(jq -c -s 'add' <(side_captions before "$before" "$duration" 40) <(side_captions after "$after" "$duration" 980))
  printf '%s\n' '{"paths":{"assets":"assets"},"media":{"autoProxy":true}}' > "$project/hyperframes.json"
  HF_TITLE=$(jq -rn --arg t "${PR_VIDEO_TITLE:-${title:-Before and after}}" '$t | @html') \
    HF_BEFORE_LABEL=$(jq -rn --arg t "$PR_VIDEO_BEFORE_LABEL" '$t | @html') \
    HF_AFTER_LABEL=$(jq -rn --arg t "$PR_VIDEO_AFTER_LABEL" '$t | @html') \
    HF_DURATION=$duration \
    HF_CAPTIONS=$(jq -r '.[] | "      <div id=\"\(.id)\" class=\"caption clip\" style=\"left: \(.left)px\" data-start=\"\(.at)\" data-duration=\"\(.duration)\"><span id=\"\(.id)-text\">\(.caption | @html)</span></div>"' <<< "$captions") \
    HF_TWEENS=$(jq -c '[.[] | ["#\(.id)-text", .at]]' <<< "$captions") \
    perl -pe 's/<!-- __(\w+)__ -->|"__(\w+)__"|__(\w+)__/$ENV{"HF_" . ($1 || $2 || $3)}/g' \
    "$SCRIPT_DIR/pr-video-frame.html" > "$project/index.html"

  (cd "$project" && "${HYPERFRAMES_CMD[@]}" check >&2 &&
    "${HYPERFRAMES_CMD[@]}" render --quality delivery --video-frame-format png --output ../before-after.mp4 >&2) || return 1
}

compose() {
  [ $# -eq 3 ] || usage
  command -v ffmpeg >/dev/null 2>&1 || { echo "pr-video: needs ffmpeg (brew install ffmpeg)" >&2; exit 127; }
  local before=$1 after=$2 out=$3
  if ! jq -en --arg before "${PR_VIDEO_BEFORE_LABEL:-}" --arg after "${PR_VIDEO_AFTER_LABEL:-}" '
    def behavior_label: length > 0 and length <= 60 and test("\\S") and
      (test("[[:cntrl:]]") | not) and
      (ascii_downcase | test("^\\s*(before|after|previous|new)\\s*$") | not);
    ($before | behavior_label) and ($after | behavior_label) and
      (($before | ascii_downcase | gsub("^\\s+|\\s+$"; "")) != ($after | ascii_downcase | gsub("^\\s+|\\s+$"; "")))
  ' >/dev/null; then
    echo "pr-video: set distinct PR_VIDEO_BEFORE_LABEL and PR_VIDEO_AFTER_LABEL behavior labels (1-60 characters; explain previous vs new, not bare Before/After)." >&2
    return 2
  fi
  FOCUS_FILTER=""
  if [ -n "${PR_VIDEO_FOCUS:-}" ]; then
    if ! [[ "$PR_VIDEO_FOCUS" =~ ^([0-9]+):([0-9]+):([1-9][0-9]*):([1-9][0-9]*)$ ]]; then
      echo "pr-video: PR_VIDEO_FOCUS must be x:y:width:height (nonnegative origin, positive even dimensions)." >&2
      return 2
    fi
    local x=${BASH_REMATCH[1]} y=${BASH_REMATCH[2]} width=${BASH_REMATCH[3]} height=${BASH_REMATCH[4]}
    if [ "$((width % 2))" -ne 0 ] || [ "$((height % 2))" -ne 0 ]; then
      echo "pr-video: PR_VIDEO_FOCUS width and height must be even." >&2
      return 2
    fi
    FOCUS_FILTER="crop=$width:$height:$x:$y:exact=1,"
  fi
  for input in "$before" "$after"; do
    [ -s "$input" ] || { echo "pr-video: missing recording: $input" >&2; exit 1; }
    if [ -n "$FOCUS_FILTER" ]; then
      local dimensions
      dimensions=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of json "$input") || return 1
      if ! jq -e --arg focus "$PR_VIDEO_FOCUS" '
        .streams[0] as $video | ($focus | split(":") | map(tonumber)) as $r |
        $r[0] + $r[2] <= $video.width and $r[1] + $r[3] <= $video.height
      ' <<< "$dimensions" >/dev/null; then
        echo "pr-video: PR_VIDEO_FOCUS is outside $input; use the same in-bounds region on both takes." >&2
        return 2
      fi
    fi
    require_motion "$input"
  done
  local before_hash after_hash
  before_hash=$(video_hash "$before") || return 1
  after_hash=$(video_hash "$after") || return 1
  if cmp -s "$before" "$after" || [ "$before_hash" = "$after_hash" ]; then
    echo "pr-video: duplicate recordings; capture the actual previous and new behavior. If unchanged, publish one labeled verification take, not a comparison." >&2
    return 1
  fi
  local longest
  longest=$(awk -v a="$(duration_of "$before")" -v b="$(duration_of "$after")" \
    'BEGIN { print (a > b ? a : b) }')
  mkdir -p "$out"

  local renderer=${PR_VIDEO_RENDERER:-auto}
  if [ "$renderer" = hyperframes ] || [ "$renderer" = auto ]; then
    hyperframes_command || return 1
  fi
  case "$renderer" in
    hyperframes) frame_hyperframes "$before" "$after" "$out" "$longest" ;;
    ffmpeg) frame_ffmpeg "$before" "$after" "$out" "$longest" ;;
    auto)
      if frame_hyperframes "$before" "$after" "$out" "$longest"; then
        :
      else
        echo "pr-video: HyperFrames unavailable or failed; composing with ffmpeg (no labels or captions)" >&2
        frame_ffmpeg "$before" "$after" "$out" "$longest"
      fi
      ;;
    *) echo "pr-video: PR_VIDEO_RENDERER must be auto, hyperframes, or ffmpeg" >&2; exit 2 ;;
  esac
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
  record) shift; record "$@" ;;
  compose) shift; compose "$@" ;;
  attach) shift; attach "$@" ;;
  publish) shift; publish "$@" ;;
  *) usage ;;
esac
