# Review videos: show an action and its consequence

Use for real CLI, UI, form, button, or hover recordings. The reviewer should see
what someone does, what changes, and why that result matters. A moving cursor,
animated caption, or architecture slide alone is not evidence of product behavior.

## Choose the story before recording

Write a few beats: starting state -> meaningful action -> visible result. Show an
error and recovery when they explain the change. Start near the first action;
remove setup, loading gaps, repeated output, and idle tails. Keep enough time to
read each result. Prefer a short complete journey over a tour of every test case;
longer journeys are useful when each beat adds information, not to meet a runtime.

- **Changed behavior:** capture the same scenario on base and candidate. Use
  `pr-video.sh compose before.webm after.webm out` for matched, focused comparisons.
- **New capability or one complete journey:** use
  `pr-video.sh demo recording.mp4 out`. It accepts real terminal or browser footage,
  keeps its timing, and renders a single large take with subtitles. Explain why
  there is no prior equivalent; retain comparable baseline evidence when it exists.
- **Small visual change:** show the actual trigger and changed result. A tooltip
  may need only hover -> reason appears -> dismiss. Do not add unrelated typing or
  navigation to manufacture activity. A screenshot remains useful alongside it.

Use the repository's native recording workflow or the host's recording tools;
`pr-video.sh record` is the agent-browser adapter, not a prerequisite for `demo`.
Record genuine commands/output or UI interactions, not a reconstruction from the
diff. Disclose fixtures, local authentication, cuts, and untested integration seams.

## Subtitles and optional execution context

`record` writes `<recording>.steps.json`. For other capture tools, author that
sidecar against the **edited footage**, in seconds:

```json
{
  "title": "A failed save keeps the draft",
  "diagram": ["Browser form", "Save handler", "Error response", "Draft retained"],
  "steps": [
    { "at": 0, "caption": "Submit the draft.", "active": 0 },
    { "at": 3, "caption": "The service rejects the save.", "active": 2 },
    { "at": 6, "caption": "The draft remains ready to retry.", "active": 3 }
  ]
}
```

`demo` requires a title (up to 80 characters), ordered steps starting at zero,
and nonempty captions (up to 80 characters). Each caption lasts until the next
step or the recording's end: at least 2 seconds or 1 second plus 0.3 seconds per
word, whichever is longer. Shorten prose instead of covering the screen. Burned-in
subtitles work without audio; no music or voiceover is required for review evidence.

Omit `diagram` and `active` for full-width footage. When explanation helps, use
2-6 short diagram nodes (up to 60 characters each) and optional zero-based `active`
indices to walk through command -> RPC -> handler -> result, or form -> request ->
state update. The execution model sits beside the real footage; it never replaces
it. Base nodes and relationships on inspected source or traces and cite those
sources in the PR. Its highlight is an explanation, **not a measured live trace**;
never infer server execution, causality, or latency from a click alone.

```bash
scripts/pr-video.sh demo recording.mp4 out
scripts/pr-video.sh attach out/demo.mp4
```

## Quality gate and review

Both composition paths inspect source pixels **before** captions or diagrams.
They reject static takes and any near-static run of at least 5 seconds, reporting
its start time. Comparison also refuses to freeze the shorter take for 5 seconds
or longer. Split matched beats or use one truthful journey; do not pad, loop, or
wiggle the cursor to pass. Focused comparisons inspect the same source crop.

The idle detector uses FFmpeg `freezedetect` with a 0.001 mean frame-difference
threshold. This is a dead-air heuristic, not proof of meaningful activity. Small
changes may need a closer recording; video noise or unrelated animation can evade
it. Manually watch the **whole rendered MP4 at PR display size**: first action is
prompt, each beat changes something relevant, subtitles match observed outcomes,
text is legible, and the ending arrives as soon as the result is clear. If a real
slow operation needs explanation, cut the wait, mark the cut, and disclose elapsed
time separately; do not imply an edited demo measures speed.

The default renderer fails closed when HyperFrames fails. Explicit
`PR_VIDEO_RENDERER=ffmpeg` is uncaptioned diagnostic output, not final PR evidence.
GIF is a preview; judge the MP4. Publish the reviewed media inline using the
[existing attachment procedure](REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5).
