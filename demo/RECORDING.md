# Record and narrate a walkthrough

Keep original captures, a per-chapter script, action timestamps, captions, and output in
`demos/<slug>/`. Use sanitized fixtures and an isolated session. Record source revisions
and commands; no capture, script, or cloud voice proves customer behavior on its own.

## Browser footage

Use the project's real-app verifier or scripted browser recorder. With this harness:

```bash
HARNESS_ROOT=/absolute/path/to/skills
bash "$HARNESS_ROOT/scripts/pr-video.sh" record http://localhost:3000 flow.txt browser.webm
```

The flow needs a narrated interaction (including hover for a tooltip change) and `##`
narration before each interaction. Preserve its
`.steps.json` action timestamps. This command captures visuals and metadata; it does not
generate speech or burn in captions. The existing HyperFrames comparator burns in
captions for before/after PR evidence. For a single take with burned-in subtitles, use
`pr-video.sh demo browser.webm output/framed` after trimming setup and retiming the
sidecar to start at zero; follow the [review-video contract](../commit-push-pr/VIDEO.md).
A walkthrough chapter can instead use native video and WebVTT.

## Terminal replay

[asciinema CLI](https://docs.asciinema.org/manual/cli/quick-start/) records terminal events:

```bash
asciinema rec --command 'bash terminal-demo.sh' terminal.cast
asciinema play terminal.cast
```

The script should run the actual commands, fail on command errors, and hold output for
reading. Use an isolated shell with sanitized environment and prompt. Inspect the entire
cast, including metadata and escape sequences, for secrets before publication. Do not
capture input or upload to asciinema.org by default. Selectable terminal text may expose
more than the initially visible frame. Use the installed CLI's `--help` for version flags.

## Narration and synchronization

Add speech only when requested or called for by the source. Use supplied audio or an
already-installed, approved local voice; cloud generation, cost, cloning, and data transfer
remain explicit decisions. On macOS, `man say` owns the flags:

```bash
say -v '?'                          # inspect installed voices first
say -v Samantha -f narration.txt -o narration.aiff
ffprobe -v error -show_entries format=duration -of csv=p=0 narration.aiff
```

Generate each narration beat before capturing; measure its duration and hold its real
action/result long enough. Assemble beats at their recorded action offsets, including
setup silence. For example, for verified offsets of 1.5 and 6 seconds:

```bash
ffmpeg -nostdin -n -i beat-1.aiff -i beat-2.aiff -filter_complex \
  '[0:a]adelay=1500:all=1[a0];[1:a]adelay=6000:all=1[a1];[a0][a1]amix=inputs=2:normalize=0[a]' \
  -map '[a]' narration.wav
bash "$HARNESS_ROOT/scripts/demo-voiceover.sh" browser.webm narration.wav output/demo.mp4
```

Replace example offsets with the actual `.steps.json` times; keep voice beats from
overlapping. The helper accepts an **already-aligned timeline track starting at zero**,
replaces original audio, pads only audio silence, and preserves the visual take. It
requires ffmpeg, ffprobe, and jq, refuses existing output and overlong narration, and
publishes no partial file after encode failure. It does not align speech automatically.
To keep original dialog or sound effects, mix them deliberately before this replacement
step. Apply voiceover **after** `pr-video.sh demo` or `compose`: those renderers intentionally
remove input sound. For example, mux `output/framed/demo.mp4` into a new `output/demo.mp4`.
If editing the footage, retime both narration and captions to the edited timeline.
Recapture with longer holds or split the chapter instead of truncating speech or
speeding up product interactions. Listen after muxing; media metadata is not listening.

For a terminal chapter, convert narration to a browser-supported format and set the
player's [`audioUrl`](https://docs.asciinema.org/manual/player/options/#audiourl):

```bash
ffmpeg -nostdin -n -i narration.wav terminal-narration.mp3
```

The player synchronizes play/pause/seek. Keep `speed: 1` and disable idle compression
(`idleTimeLimit: Infinity`) for narration authored against the original timeline. Ensure
the cast lasts through the last spoken word. Keep an adjacent transcript; verify actual
audio playback, since a missing audio file can fall back to terminal-only playback.

## Portable walkthrough page

Copy [templates/walkthrough.html](templates/walkthrough.html) into `output/index.html`.
Replace example text and asset names with observed content. Put these beside it:

- `demo.mp4`, `browser.vtt`: browser chapter plus verified WebVTT captions.
- `terminal.cast`, `terminal-narration.mp3`: terminal chapter with aligned narration.
- `player/`: standalone asciinema player JS/CSS and its license.

For a silent terminal chapter, remove `audioUrl` and its narration preflight/download link,
then label it silent. For a silent browser chapter, retain descriptive captions; do not
leave a missing track. The scaffold is plain
HTML, not a HyperFrames composition. Run it over HTTP, not `file://`; keep every asset
same-origin so it works without a Claude account or third-party CDN at playback time.

Obtain the player from its official npm distribution. This recipe pins the player in one
place; retain its Apache-2.0 license and provenance in the output. No upstream files are
vendored into this harness:

```bash
PLAYER_VERSION=$(jq -er '.devDependencies["asciinema-player"]' "$HARNESS_ROOT/package.json")
mkdir -p output/player
for file in asciinema-player.min.js asciinema-player.css; do
  curl --fail --location "https://cdn.jsdelivr.net/npm/asciinema-player@$PLAYER_VERSION/dist/bundle/$file" \
    --output "output/player/$file"
done
curl --fail --location "https://cdn.jsdelivr.net/npm/asciinema-player@$PLAYER_VERSION/LICENSE" \
  --output output/player/LICENSE
printf 'asciinema-player@%s (Apache-2.0), npm distribution via jsDelivr\n' "$PLAYER_VERSION" \
  > output/player/SOURCE.txt
bunx http-server@14.1.1 output -a 127.0.0.1 -p 8000 -c-1
```

Use current [player installation docs](https://docs.asciinema.org/manual/player/quick-start/)
when deliberately upgrading. Verify downloads succeeded before serving. Author captions
from the script and measured timings, then check them against audio. Review at narrow
and wide viewports, play and seek both chapters, and temporarily remove an asset to verify
visible failure and recovery. Keep descriptive transcripts and downloadable originals.

The root manifest owns the exact player pin; the media canary exercises that version.
Audio seeking needs a server with HTTP byte-range support, not just a successful full-file
download. The example uses [http-server](https://github.com/http-party/http-server);
verify `curl -H 'Range: bytes=0-99' -D - -o /dev/null <audio-url>` returns `206` on the
actual host. A basic server that ignores ranges is not proof of synchronized seeking.
