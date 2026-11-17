# Recording craft

This is the shared craft layer for every authored UI change and requested UI clips.
For PR scope, freshness and the completion gate, use [per-PR delivery](#per-pr-delivery). `/demo` owns its customer-facing
workflow; [review videos](../commit-push-pr/VIDEO.md) own PR evidence and media gates.
Reuse their recorder, sidecars, renderer pin and attachment procedure. No new renderer or
installation is required merely to record. These defaults are local heuristics, not Emil's
undisclosed course rules or a destination's current upload limits.

## Frame for where it will be watched

Choose the destination before capture. A landscape 1920x1080, 30 fps clip is a useful
starting point for a full-screen demo; a focused 1280x720 take often reads better inline
in a PR. For a phone journey, use the actual responsive viewport and touch-capable context,
then choose a portrait export. Check the destination's current limits only when publishing.
Keep base/candidate viewport, scale, data and input identical for comparisons.

CSS viewport, device scale factor, recorded video size and export dimensions are separate
settings. In Playwright, set both `viewport` and `recordVideo.size`; its default video size
can downscale a large viewport. High-DPI screenshots do not prove video resolution. Inspect
the actual capture with `ffprobe`, not the browser window size. Keep text readable at the
reader's display size; capture closer instead of enlarging already-rasterized text.

The existing agent-browser adapter accepts explicit CSS dimensions:

```bash
PR_VIDEO_VIEWPORT=1920x1080 bash "$HARNESS_ROOT/scripts/pr-video.sh" \
  record http://localhost:3000 flow.txt take.webm
```

Set `HARNESS_ROOT` to the installed harness path. Use an agent-browser build whose
`--help` exposes `--init-script`; an older binary earlier on PATH is not a supported recorder. `flow.txt` uses the narration/readiness
contract in [recording recipes](../demo/RECORDING.md#browser-footage). This adapter sets a
viewport, not frame rate, DPR or a touch device. Use the project's recorder or the host's
recording capability for those settings; verify what that tool actually supports.

## Input is part of the story

- **Mouse:** one visible cursor, its tip on the actual hit point; show a short, deliberate
  approach before click/hover. Script intermediate pointer moves in the recorder rather
  than easing only the overlay: the hit target must not activate ahead of the visible cursor.
  During a drag, keep the marker 1:1 with input. Use a subtle click pulse, then move away
  from the result. Preserve pointer/text/resize affordances when they explain the action;
  the bundled fixed arrow is an action cue, not a reproduction of every native cursor.
- **Touch/pen:** use real touch/pen events and contact coordinates, no desktop arrow or
  hover prerequisite. Track the contact during movement; remove it on release/cancel.
  The bundled overlay shows the primary contact, not a multi-touch/pinch visualization.
  A narrow desktop recording is not physical-device evidence. Label emulation honestly.
- **Keyboard:** let focus and the resulting state explain Tab/Enter/Space/typing; show
  key labels only when needed. No pointer travel or click pulse for keyboard activation.
- Keep cues capture-only, inert and out of the accessibility tree. Never change product
  layout, event targets, pointer capture, focus behavior, native zoom or hit testing.

The [bundled overlay](../scripts/pr-video-cursor.js) follows pointer events with no delayed
transform. It observes input; it does not smooth automated jumps, generate gestures or
validate that a control worked. Real product-state assertions still establish readiness.
Prefer the host/project recorder when it already supplies correct cues; avoid double cursors.

## Focus without losing context

Establish the relevant screen, approach the control, then tighten framing around a small
label, hover state or result only if it is hard to read. Keep spatial continuity and avoid
following every cursor wobble. Return to context when the next action needs it. Use cuts
or an existing compositor's bounded zoom; camera motion is optional, not a second product
animation. Preserve a full-frame original and leave captions outside the focal content.

For a fixed detail comparison, the existing pipeline crops both real takes identically:

```bash
PR_VIDEO_FOCUS=184:128:912:392 bash "$HARNESS_ROOT/scripts/pr-video.sh" \
  compose before.webm after.webm output
```

Coordinates are `x:y:width:height` in source pixels; replace these example values with a
verified crop. This is a static focus crop, not automatic moving zoom. For a single take or
moving zoom, use the project's existing compositor or an explicit FFmpeg edit, keeping
source coordinates, even export dimensions and captions aligned. Do not claim automatic
zoom support in `pr-video.sh demo`. Recapture closer if the zoom would blur the detail.

## Package, then watch the export

Start near the first meaningful action. Cut setup, retries caused by automation, loading
dead air and redundant endings; keep genuine error/recovery steps when part of the claim.
Disclose cuts over slow operations; edited footage cannot establish latency. Prefer one
focal point, restrained background/padding, clear caption contrast and a readable final hold.
Use real states, not synthetic screenshot choreography as evidence of interaction.

Keep muted playback understandable. Use the existing `.steps.json` caption contract and
retime it after edits. Voiceover stays opt-in under [narration recipes](../demo/RECORDING.md#narration-and-synchronization);
listen after muxing. Optional music, frames or captions must not hide the feature or errors.

For broad compatibility, export MP4 with H.264, yuv420p and faststart via the existing
pipeline; retain frame rate sufficient to show the interaction. A GIF is only a preview.
Check the final file rather than just source footage or a successful renderer exit:

```bash
ffprobe -v error -select_streams v:0 \
  -show_entries stream=codec_name,width,height,pix_fmt,avg_frame_rate:format=duration,size \
  -of json output/demo.mp4
```

Inspect early/action/detail/final frames and full playback at actual delivery size. Confirm
cursor/contact timing, caption dwell, crop edges, legible text, aspect ratio and no private
content. Replay the journey on the current revision. Preserve actual product timing or
label edits; never pad/loop/wiggle the cursor to bypass the PR pipeline's activity gate.
If a slow narrated walkthrough needs longer static holds, use `/demo`'s native-video chapter
path instead of weakening PR evidence gates. Share only after redaction and only at the
requested endpoint; an inaccessible or unreviewed export is not a finished package.

## Technical references

- [Playwright video](https://playwright.dev/docs/videos): explicit capture size and context close.
- [Playwright mouse](https://playwright.dev/docs/api/class-mouse#mouse-move): real intermediate movement.
- [Pointer types](https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent/pointerType): input-specific cues.


## Per-PR delivery

Apply this in every repository consuming the harness, on every authored PR with a
consumer/end-user-facing UI delta. Cover web, mobile/native, desktop and end-user CLI/TUI
surfaces, including authenticated, admin/operator and embedded UI-not just public pages.
Changed styling, text, layout, responsive states, accessibility and interaction all count;
component/library PRs use their real consumer or existing runnable example. API-only,
headless internals and behavior-preserving mechanical work can declare non-applicability.

Review the full PR against its actual base, not just the latest commit. Package the changed
user journeys and results; one clip or a concise set of chapters may cover related changes.
Every materially distinct affected surface needs coverage, not one recording per file or edit.
For static changes, show the real entry into the changed state; do not fabricate activity.
Mixed UI/backend PRs still require the clip and any unexplained non-UI contract diagram.
The before/after screenshot table remains separate evidence, not a replacement for the clip.
For end-user CLI/TUI, retain the original asciinema cast; record its real playback when an
inline PR video is needed rather than synthesizing terminal output or discarding the replay.

Before PR creation, after UI follow-up edits or relevant base movement, and before handoff:
load this skill, inspect/reuse still-current captures, refresh invalidated beats, and check
playback against the published head. Put the reviewer-accessible recording inline in the
PR body with a short account of covered journeys and any untested surface. Keep draft or
ready state as found. Local, commit-only and push-only endpoints keep their publication stops;
review-only work evaluates missing packaging without capturing, editing or posting.

Every PR body must include exactly one visible declaration, outside code/comments:

- UI change: `UI packaging: https://approved-host.example/demo.mp4` (or a native GitHub video
  attachment URL). Display that same recording inline; keep captions/playback checks.
- No UI delta: `UI packaging: not applicable - <concrete non-UI reason>`.
- Recording explicitly waived by the owner: `UI packaging: waived - <reason>; approval: <reference>`.
  Name the actual approval; missing access is a blocker, not permission to invent a waiver.

The existing lifecycle Stop hook invokes `scripts/pr-visual-evidence.py` for PR/ship
endpoints in Claude and Codex consumers. It requires the declaration plus the existing
visual evidence contract; screenshots, diagrams, hidden examples, local paths and a generic
`Visual evidence: not applicable` line cannot silently stand in for UI packaging.
This is a publication-presence gate, not automatic UI-scope detection or a media/MIME,
accessibility, freshness or playback verifier. Opaque GitHub attachment URLs are author-attested
recordings. Authors/reviewers still verify truthful scope, actual owner approval, complete
coverage, media type, reader access and correspondence to the current head. A passing gate
alone is not evidence that the skill ran or the UI works. Installation ships the hook;
it does not change consumer-hosted branch protection or deploy updates to existing installs.
