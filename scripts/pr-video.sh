#!/bin/bash
set -euo pipefail

# Before/after PR video evidence.
#
#   scripts/pr-video.sh record <url> <flow-file> <out.webm>
#     Replays one agent-browser command per flow-file line (# comments allowed)
#     with a visible cursor, pausing PR_VIDEO_STEP_MS (default 700) per step.
#     Needs 2+ interaction steps (hover or wait alone is not a flow). Run the
#     same flow file against base and candidate. A failed step fails.
#
#   scripts/pr-video.sh compose <before-video> <after-video> <out-dir>
#     Side-by-side (before left, after right) at one height. The shorter take
#     freezes on its last frame. Rejects static takes (under 8 distinct frames).
#     Writes before-after.mp4 and before-after.gif.
#
#   scripts/pr-video.sh attach <file.mp4>...
#     Uploads to GitHub PR attachments from an isolated agent-browser profile
#     (PR_VIDEO_PROFILE) and prints user-attachments URLs, which GitHub plays
#     inline. The comment box is cleared, never submitted. Exit 3: sign in once.
#
#   scripts/pr-video.sh publish <file>...
#     Commits files to the `pr-evidence` branch under <current-branch>/ with git
#     plumbing (active HEAD, index, and tree untouched), pushes it, and prints
#     SHA-pinned Markdown: GIFs and images render inline; other files are links.
#     PR_VIDEO_REPO_URL overrides the https://github.com/<owner>/<repo> base.

usage() {
  sed -n '6,25p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 2
}

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
MIN_DISTINCT_FRAMES=8
MIN_INTERACTIONS=2
INTERACTION_RE='^(click|dblclick|type|fill|press|keyboard|select|check|uncheck|drag|scroll|upload|open|goto|navigate|find|mouse)[[:space:]]'

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

browser_eval() {
  # agent-browser prints eval results as JSON; unwrap strings.
  agent-browser --session "$1" eval "$2" | jq -r 'if type == "string" then . else tostring end'
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
  agent-browser --session "$session" wait "$step_ms" >/dev/null
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in '' | '#'*) continue ;; esac
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
  printf '%s\n' "$out"
}

attach() {
  [ $# -ge 1 ] || usage
  command -v agent-browser >/dev/null 2>&1 || { echo "pr-video: needs agent-browser" >&2; exit 127; }
  local profile=${PR_VIDEO_PROFILE:-${XDG_STATE_HOME:-$HOME/.local/state}/pr-video/github-profile}
  local session="pr-video-attach-$$" pr_url
  pr_url=${PR_VIDEO_PR_URL:-$(gh pr view --json url --jq .url)}
  mkdir -p "$profile"
  trap 'agent-browser --session "'"$session"'" close >/dev/null 2>&1 || true' EXIT
  agent-browser --session "$session" --profile "$profile" open "$pr_url" >/dev/null
  if [ -z "$(browser_eval "$session" "document.querySelector('meta[name=user-login]')?.content || ''")" ]; then
    echo "pr-video: sign in to GitHub once in the isolated profile, then rerun:" >&2
    echo "  agent-browser --profile '$profile' --headed open https://github.com/login" >&2
    exit 3
  fi
  local file tagged
  for file in "$@"; do
    [ -s "$file" ] || { echo "pr-video: missing file: $file" >&2; exit 1; }
    # Tag the new-comment textarea and its attachment input; never submit.
    tagged=$(browser_eval "$session" "(() => {
      const box = [...document.querySelectorAll('textarea')].reverse()
        .find((t) => t.offsetParent && /comment|body|markdown/i.test(t.name + t.id + t.className));
      let node = box;
      while (node && !node.querySelector?.('input[type=file]')) node = node.parentElement;
      const input = node?.querySelector('input[type=file]');
      if (!box || !input) return '';
      box.setAttribute('data-pr-video-box', '');
      input.setAttribute('data-pr-video-upload', '');
      return 'ok';
    })()")
    [ "$tagged" = ok ] || { echo "pr-video: no comment box with attachments on $pr_url" >&2; exit 1; }
    agent-browser --session "$session" upload '[data-pr-video-upload]' "$file" >/dev/null
    AGENT_BROWSER_DEFAULT_TIMEOUT=120000 agent-browser --session "$session" wait --fn \
      "document.querySelector('[data-pr-video-box]').value.includes('/user-attachments/assets/')" >/dev/null
    browser_eval "$session" "(() => {
      const box = document.querySelector('[data-pr-video-box]');
      const url = box.value.match(/https:\\/\\/github\\.com\\/user-attachments\\/assets\\/[\\w-]+/)[0];
      const setValue = Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value').set;
      setValue.call(box, '');
      box.dispatchEvent(new Event('input', { bubbles: true }));
      return url;
    })()"
  done
}

compose() {
  [ $# -eq 3 ] || usage
  command -v ffmpeg >/dev/null 2>&1 || { echo "pr-video: needs ffmpeg (brew install ffmpeg)" >&2; exit 127; }
  local before=$1 after=$2 out=$3
  for input in "$before" "$after"; do
    [ -s "$input" ] || { echo "pr-video: missing recording: $input" >&2; exit 1; }
    require_motion "$input"
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
  record) shift; record "$@" ;;
  compose) shift; compose "$@" ;;
  attach) shift; attach "$@" ;;
  publish) shift; publish "$@" ;;
  *) usage ;;
esac
