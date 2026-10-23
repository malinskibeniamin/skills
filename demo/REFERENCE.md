# Customer demo reference

## Ground the story

1. Resolve the remote default branch and inspect the whole diff from its merge-base.
   Include committed, staged, unstaged, and relevant untracked files. Exclude unrelated
   pre-existing work.
2. Map changed behavior to the real customer entrypoint. Prefer observed behavior over
   inferred claims; run the product through an isolated browser or its actual public seam.
3. Pick one outcome with the clearest customer value. Use a **problem -> action -> payoff**
   arc. Do not narrate file names, framework choices, or internal architecture unless that
   knowledge helps the customer use or trust the feature.
4. Reuse approved product copy, branding, and assets. Redact secrets, tokens, private URLs,
   customer PII, internal-only data, and unrelated browser chrome. Never use a human-owned
   browser session.

## Storyboard

- For a short movie, aim for 20-45 seconds, 1920x1080, and 30 fps unless the target channel
  requires another format. For a walkthrough, split by customer outcome instead of imposing
  one total duration. Make either format understandable muted with captions and transcripts.
- Establish the problem, demonstrate the smallest realistic action sequence, then hold on
  the payoff long enough to read it. End with a practical next step, not generic hype.
- Keep one focal point per scene. At 1080p, start near 84 px for headlines and 44 px for
  important supporting text; preserve generous safe areas.
- Capture real UI states when available. Use diagrams for invisible behavior, not as
  decoration around an already-clear surface.

## Capture-first stack

Use [RECORDING.md](RECORDING.md) for executable capture, narration, and packaging recipes.

- **Browser:** record the real product in an isolated session. Reuse the project's verifier,
  Playwright, or `scripts/pr-video.sh record` for scripted flows. Keep visible cursor/action
  cues and readiness assertions. Native `<video controls>` plays the result; it does not
  identify which recorder produced it.
- **Terminal:** record real commands with asciinema and retain the `.cast`. Embed it with
  asciinema player for sharp, selectable text. A generated cast or mock terminal must be
  labeled simulated; a `.cast` download is not an inline GitHub video.
- **Narration:** retain the script and measured action offsets. Prefer an already-approved
  local voice or supplied audio. Add an aligned track to browser footage with
  `scripts/demo-voiceover.sh`; use the player's `audioUrl` for terminal narration.
  Neither path generates speech or guesses word/action alignment.
- **Walkthrough page:** embed separate chapters, captions, transcripts, and commands using
  [templates/walkthrough.html](templates/walkthrough.html). Copy its local player assets
  and licenses; serve over HTTP. A Claude Artifact can host a wrapper but is not a required
  authoring tool or an access guarantee. Verify the actual reader-facing URL.
- **Composition:** keep the existing HyperFrames renderer pin and installed official
  authoring skills for titles, framing, and transitions around captures. The
  [PR video pipeline](../commit-push-pr/VIDEO.md)
  owns single-take subtitles, before/after comparisons, and their evidence gates.
  Mux narration after composition, which intentionally removes input sound. Do not use the comparator to
  manufacture differences between unchanged takes or force a long tutorial into 30 seconds.

Preserve an existing Remotion project when it owns the source; use its installed version
and current [official authoring guidance](https://www.remotion.dev/docs/ai/skills).
Otherwise a real recording needs no new renderer. Creative explainers may use installed
HyperFrames, but cannot replace real recordings as proof of shipped product behavior.
Never run renderer initialization merely to capture footage or install global skills.

Keep files small enough for the Git host. Reduce duration or bitrate before lowering
legibility; do not introduce Git LFS unless the repository already uses it.

## Verify the artifact

1. Render stills from early, middle, and late frames. Inspect them visually, then watch the
   complete `demo.mp4` for clipping, timing, legibility, blank frames, stale UI, and abrupt
   cuts. Listen to every narrated chapter; captions and scripts alone do not prove audio
   exists or is synchronized. Fix and re-render rather than documenting avoidable defects.
2. Check the recording's duration, dimensions, codec, file size, and successful exit status
   using `ffprobe` or the existing renderer's inspection commands.
3. Replay the customer action against the current product. The recording must not promise
   behavior the target branch cannot reproduce.
4. For a walkthrough, test play/pause/seek and terminal audio sync, keyboard access,
   narrow layouts, and media-load failures. Inspect console/network errors. Check the
   transcript and captions against the actual audio and command output; a silent fallback
   from missing narration is not a passing narrated demo. Verify local assets and downloads
   without relying on the author's logged-in session.

## Diagram fallback

Use a diagram when a static explanation communicates the customer value better than motion,
or document the concrete blocker preventing a faithful recording. An explanation is not
recording evidence; missing access to the product remains a limit.
Prefer a sequence diagram for interactions, a state diagram for lifecycle changes, and a flow
or architecture diagram for structure. Use Mermaid for a simple graph-shaped explanation; use
`/excalidraw-diagram` when grouping, annotation, or exact placement carries the story.

Create `demos/<slug>/output/diagram.svg` plus one canonical editable source: Mermaid `.mmd`
or `.excalidraw`, never both presented as synchronized. Render and inspect the SVG; do not
deliver editable source alone. Add a caption and concise accessible description or equivalent
text alternative to the PR. Put the blocker and fallback rationale there too.

## Publish

1. Never edit a README as part of `/demo`.
2. Honor the requested endpoint. When publication is in scope, follow `/commit-push-pr`
   with explicit draft mode. Create a missing PR with `--draft`;
   update an existing PR and preserve its current draft or ready state.
3. Add a `## Demo` section to the PR body with the customer story, repository-relative
   artifact link, exact capture/render command, validation evidence, and fallback reason if
   present. Native MP4 attachments use the existing PR media procedure. HTML and `.cast`
   need a reader-accessible page or explicit download labels; repository HTML links and
   authenticated artifact URLs are not proof of rendered playback. Do not upload private
   captures to a new public host without authorization.
4. Take one CI snapshot. Then reveal `demo.mp4` with `open -R` on macOS, or print its
   absolute path plus a shell-quoted `cd` command for the output directory.
