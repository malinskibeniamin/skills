# Before/after PR video: compose real recordings and publish them off-tree.

PR_VIDEO="$REPO_ROOT/scripts/pr-video.sh"
# Fast default for the geometry checks; the HyperFrames renderer has its own case.
export PR_VIDEO_RENDERER=ffmpeg
export PR_VIDEO_BEFORE_LABEL='Previous: unframed recording'
export PR_VIDEO_AFTER_LABEL='New: focused comparison'
export PR_VIDEO_FOCUS=''

pr_video_check() {
  if eval "$1"; then
    echo "  PASS  $2"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $2"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $2"
  fi
}

if ! command -v ffmpeg >/dev/null 2>&1 || ! command -v ffprobe >/dev/null 2>&1; then
  echo "  SKIP  pr-video needs ffmpeg and ffprobe"
  SKIP=$((SKIP + 1))
else
  work=$(mktemp -d)
  # Unequal sizes and durations: the shorter side must freeze, not truncate.
  ffmpeg -hide_banner -loglevel error -f lavfi -i testsrc=size=320x200:rate=10:duration=1 \
    -c:v libvpx "$work/before.webm"
  ffmpeg -hide_banner -loglevel error -f lavfi -i testsrc2=size=400x300:rate=10:duration=2 \
    -c:v libvpx "$work/after.webm"

  pr_video_check '"$PR_VIDEO" compose "$work/before.webm" "$work/after.webm" "$work/out" >/dev/null 2>&1' \
    'compose exits 0 for two recordings'
  pr_video_check '[ -s "$work/out/before-after.mp4" ] && [ -s "$work/out/before-after.gif" ]' \
    'compose writes mp4 and inline gif'
  width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$work/out/before-after.mp4" 2>/dev/null || true)
  height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$work/out/before-after.mp4" 2>/dev/null || true)
  duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$work/out/before-after.mp4" 2>/dev/null || true)
  pr_video_check '[ "${height:-0}" = 720 ] && [ "${width:-0}" -gt 1000 ]' \
    'compose puts before and after side by side at one height'
  pr_video_check 'awk -v d="${duration:-0}" "BEGIN { exit !(d >= 1.8) }"' \
    'compose keeps the longer recording instead of truncating it'
  pr_video_check '! "$PR_VIDEO" compose "$work/missing.webm" "$work/after.webm" "$work/bad" >/dev/null 2>&1' \
    'compose rejects a missing recording'
  ffmpeg -hide_banner -loglevel error -i "$work/before.webm" -c copy \
    -metadata title=repacked "$work/repacked.webm"
  duplicate_err=$("$PR_VIDEO" compose "$work/before.webm" "$work/repacked.webm" "$work/duplicate-out" 2>&1 >/dev/null || true)
  pr_video_check '[ ! -e "$work/duplicate-out/before-after.mp4" ] && printf "%s" "$duplicate_err" | grep -qi "duplicate"' \
    'compose rejects identical decoded footage even with different container bytes'
  ffmpeg -hide_banner -loglevel error -i "$work/before.webm" \
    -vf 'drawbox=x=1:y=1:w=2:h=2:color=red:t=fill' -c:v ffv1 "$work/subtle.mkv"
  pr_video_check '"$PR_VIDEO" compose "$work/before.webm" "$work/subtle.mkv" "$work/subtle-out" >/dev/null 2>&1' \
    'compose preserves a small genuine pixel change, without a similarity threshold'
  pr_video_check 'PR_VIDEO_FOCUS=10:10:200:100 "$PR_VIDEO" compose "$work/before.webm" "$work/after.webm" "$work/focus-out" >/dev/null 2>&1 && [ "$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$work/focus-out/before-after.mp4")" = "2888,720" ]' \
    'compose applies the same focus crop to both recordings'
  focus_err=$(PR_VIDEO_FOCUS=300:0:200:100 "$PR_VIDEO" compose "$work/before.webm" "$work/after.webm" "$work/bounds-out" 2>&1 >/dev/null || true)
  pr_video_check '[ ! -e "$work/bounds-out/before-after.mp4" ] && printf "%s" "$focus_err" | grep -qi "outside"' \
    'compose rejects an out-of-bounds crop instead of silently shifting it'
  ffmpeg -hide_banner -loglevel error -f lavfi -i color=c=white:size=320x200:rate=10:duration=5 \
    -c:v libvpx "$work/static.webm"
  static_err=$("$PR_VIDEO" compose "$work/static.webm" "$work/after.webm" "$work/static-out" 2>&1 >/dev/null || true)
  pr_video_check '[ ! -e "$work/static-out/before-after.gif" ] && printf "%s" "$static_err" | grep -qi "static"' \
    'compose rejects a recording where nothing moves'

  # Publish to an evidence branch without touching the active tree or index.
  git init -q --bare "$work/remote.git"
  git init -q -b main "$work/repo"
  git -C "$work/repo" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
  git -C "$work/repo" remote add origin "$work/remote.git"
  git -C "$work/repo" remote set-url origin "$work/remote.git"
  git -C "$work/repo" checkout -q -b feature
  printf 'wip\n' > "$work/repo/dirty.txt"
  git -C "$work/repo" add dirty.txt
  before_head=$(git -C "$work/repo" rev-parse HEAD)
  before_index=$(git -C "$work/repo" write-tree)
  published=$(cd "$work/repo" && PR_VIDEO_REPO_URL=https://github.com/o/r \
    "$PR_VIDEO" publish "$work/out/before-after.gif" "$work/out/before-after.mp4" 2>/dev/null || true)
  evidence=$(git -C "$work/remote.git" rev-parse --verify -q refs/heads/pr-evidence || true)
  pr_video_check '[ -n "$evidence" ] && git -C "$work/remote.git" cat-file -e "$evidence:feature/before-after.gif"' \
    'publish pushes files to the pr-evidence branch under the PR branch'
  pr_video_check 'printf "%s" "$published" | grep -qF "https://github.com/o/r/blob/$evidence/feature/before-after.gif?raw=true"' \
    'publish prints a SHA-pinned reviewer URL'
  pr_video_check '[ "$(git -C "$work/repo" rev-parse HEAD)" = "$before_head" ] && [ "$(git -C "$work/repo" write-tree)" = "$before_index" ] && [ "$(git -C "$work/repo" branch --show-current)" = feature ]' \
    'publish leaves HEAD, index, and branch untouched'
  (cd "$work/repo" && PR_VIDEO_REPO_URL=https://github.com/o/r "$PR_VIDEO" publish "$work/before.webm" >/dev/null 2>&1) || true
  second=$(git -C "$work/remote.git" rev-parse --verify -q refs/heads/pr-evidence || true)
  pr_video_check '[ "$(git -C "$work/remote.git" rev-parse "$second^")" = "$evidence" ] && git -C "$work/remote.git" cat-file -e "$second:feature/before-after.gif"' \
    'publish appends to existing evidence instead of replacing it'

  if command -v agent-browser >/dev/null 2>&1; then
    cat > "$work/app.html" <<'HTML'
<html><body style="font:20px sans-serif;padding:40px">
<input id="name" placeholder="Name"><button id="save" onclick="document.getElementById('msg').textContent='Saved ' + document.getElementById('name').value">Save</button>
<p id="msg"></p></body></html>
HTML
    cat > "$work/flow.txt" <<'FLOW'
# Save a display name
## Type the name
fill "#name" "Ada Lovelace"
## Click Save
click "#save"
wait --text "Saved Ada"
FLOW
    pr_video_check 'PR_VIDEO_STEP_MS=300 "$PR_VIDEO" record "file://$work/app.html" "$work/flow.txt" "$work/flow.webm" >/dev/null 2>&1 && [ -s "$work/flow.webm" ]' \
      'record replays a flow file into a video'
    pr_video_check '"$PR_VIDEO" compose "$work/flow.webm" "$work/after.webm" "$work/flow-out" >/dev/null 2>&1' \
      'a recorded flow passes the motion gate'
    pr_video_check 'jq -e ".title == \"Save a display name\" and ([.steps[].caption] == [\"Type the name\", \"Click Save\"]) and (.steps[0].at > 0) and (.steps[1].at > .steps[0].at)" "$work/flow.webm.steps.json" >/dev/null' \
      'record writes the title and timed step captions beside the video'
    if command -v bunx >/dev/null 2>&1 && [ "${PR_VIDEO_EVAL_HYPERFRAMES:-1}" = 1 ]; then
      pr_video_check 'PR_VIDEO_RENDERER=hyperframes "$PR_VIDEO" compose "$work/flow.webm" "$work/after.webm" "$work/hf-out" >/dev/null 2>&1 && [ -s "$work/hf-out/before-after.gif" ]' \
        'hyperframes renderer composes the takes'
      hf_size=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$work/hf-out/before-after.mp4" 2>/dev/null || true)
      pr_video_check '[ "$hf_size" = "1920,880" ] && grep -q ">Previous: unframed recording<" "$work/hf-out/hyperframes/index.html" && grep -q ">Click Save<" "$work/hf-out/hyperframes/index.html"' \
        'hyperframes frame labels both sides and captions each step'
    else
      echo "  SKIP  hyperframes renderer needs bunx"
      SKIP=$((SKIP + 1))
    fi
    printf 'hover "#save"\nwait 2000\n' > "$work/hover.txt"
    pr_video_check '! "$PR_VIDEO" record "file://$work/app.html" "$work/hover.txt" "$work/hover.webm" >/dev/null 2>&1 && [ ! -e "$work/hover.webm" ]' \
      'record rejects a hover-only flow before recording'
    printf 'click "#name"\nclick "#does-not-exist"\n' > "$work/broken.txt"
    pr_video_check '! PR_VIDEO_STEP_TIMEOUT_MS=2000 "$PR_VIDEO" record "file://$work/app.html" "$work/broken.txt" "$work/broken.webm" >/dev/null 2>&1' \
      'record fails when a flow step fails'
  else
    echo "  SKIP  pr-video record needs agent-browser"
    SKIP=$((SKIP + 1))
  fi
  rm -rf "$work"
fi

run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" 'before/after video' \
  'PR reference requires a before/after video for frontend changes'
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" 'scripts/pr-video.sh' \
  'PR reference names the video compose and publish script'
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" 'video' \
  'commit-push-pr gate includes video evidence'
run_content_eval "$REPO_ROOT/pr/SKILL.md" 'video' \
  'pr body guidance ranks video evidence'
run_content_eval "$REPO_ROOT/.claude/hooks/pr-evidence-nudge.sh" 'video' \
  'PR entrypoint reminder mentions the video'
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" 'user-attachments' \
  'PR reference embeds the MP4 as a native GitHub attachment player'
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" 'flow file' \
  'PR reference requires a scripted interaction flow, not a static take'
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" 'HyperFrames' \
  'PR reference frames real recordings with HyperFrames'
