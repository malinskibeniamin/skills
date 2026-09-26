# Before/after PR video: compose real recordings and publish them off-tree.

PR_VIDEO="$REPO_ROOT/scripts/pr-video.sh"

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
# Real interaction, replayed identically on base and candidate.
fill "#name" "Ada Lovelace"
click "#save"
wait --text "Saved Ada"
FLOW
    pr_video_check 'PR_VIDEO_STEP_MS=300 "$PR_VIDEO" record "file://$work/app.html" "$work/flow.txt" "$work/flow.webm" >/dev/null 2>&1 && [ -s "$work/flow.webm" ]' \
      'record replays a flow file into a video'
    pr_video_check '"$PR_VIDEO" compose "$work/flow.webm" "$work/flow.webm" "$work/flow-out" >/dev/null 2>&1' \
      'a recorded flow passes the motion gate'
    printf 'hover "#save"\nwait 2000\n' > "$work/hover.txt"
    pr_video_check '! "$PR_VIDEO" record "file://$work/app.html" "$work/hover.txt" "$work/hover.webm" >/dev/null 2>&1 && [ ! -e "$work/hover.webm" ]' \
      'record rejects a hover-only flow before recording'
    printf 'click "#name"\nclick "#does-not-exist"\n' > "$work/broken.txt"
    pr_video_check '! PR_VIDEO_STEP_TIMEOUT_MS=2000 "$PR_VIDEO" record "file://$work/app.html" "$work/broken.txt" "$work/broken.webm" >/dev/null 2>&1' \
      'record fails when a flow step fails'
    attach_status=0
    PR_VIDEO_PR_URL="file://$work/app.html" PR_VIDEO_PROFILE="$work/profile" \
      "$PR_VIDEO" attach "$work/flow-out/before-after.mp4" >/dev/null 2>"$work/attach.err" || attach_status=$?
    pr_video_check '[ "$attach_status" = 3 ] && grep -q "github.com/login" "$work/attach.err"' \
      'attach stops with a one-time login instruction when the profile is signed out'
  else
    echo "  SKIP  pr-video record and attach need agent-browser"
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
