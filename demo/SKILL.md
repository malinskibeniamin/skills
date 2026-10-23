---
name: demo
description: Create a customer-facing feature recording and publish it in a draft PR.
disable-model-invocation: true
argument-hint: "[branch, PR, feature, or path]"
---

Turn finished work into customer proof. Read [REFERENCE.md](REFERENCE.md).

## Contract

1. Resolve target; default whole current branch/PR from merge-base, including committed, staged, unstaged, relevant untracked work.
2. Choose strongest visible payoff; tell one short problem -> action -> result story.
3. Keep sources and output under `demos/<slug>/`; reuse for updates, never scatter media.
4. Use a capture-first stack: real browser recordings; asciinema `.cast` replays for terminals. Follow [recording and narration recipes](RECORDING.md). A terminal replay is not an MP4.
5. Deliver `output/demo.mp4` for a movie, or `output/index.html` plus its assets for a chaptered walkthrough. Use the [walkthrough scaffold](templates/walkthrough.html) for mixed browser/terminal demos. Label explanatory or simulated material; it is not recorded product evidence.
6. Reuse HyperFrames for optional composition around real footage; preserve an existing Remotion project when it owns the source. Do not install a second renderer just to make a recording.
7. Keep demos understandable muted. Add voiceover only when requested or called for by the source; align narration to recorded actions, retain captions/transcripts, and verify by listening. Cloud speech, cloned voices, and uploads need their applicable authorization.
8. Inspect early/middle/late frames, complete playback, and error paths; repair defects; exclude secrets/private/customer PII. An architecture diagram is valid when motion adds no value, with an accessible description and reason.
9. Never edit README. Honor explicit local/no-push stops; otherwise commit, push current branch, create draft PR with linked artifact; update existing PR without changing review state.
10. macOS: `open -R`; otherwise show `pwd`, absolute path, exact `cd`.

## Done

Return customer story, artifact type/path, capture/render/playback evidence, known limits, and draft PR URL when publication is in scope. Local-only output satisfies an explicit local endpoint, not requested publication.
