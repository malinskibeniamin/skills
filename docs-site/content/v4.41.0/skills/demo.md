---
description: "Create a customer-facing feature recording and publish it in a draft PR."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["demo"]}
sidebar: {"label":"/demo"}
title: "/demo"
type: "skill"
---
![Diagram of the /demo skill](/diagrams/skills/demo.svg)

[Open the editable Excalidraw source](/diagrams/skills/demo.excalidraw)


Turn finished work into customer proof. Read [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.41.0/demo/REFERENCE.md).

## Contract

1. Resolve target; default whole current branch/PR from merge-base: committed, staged, unstaged, relevant untracked.
2. Tell one customer problem -> action -> payoff story.
3. Keep sources/output in `demos/<slug>/`; reuse for updates.
4. Use a capture-first stack: real browser footage; asciinema `.cast` terminal replays (not MP4). Follow [recipes](https://github.com/malinskibeniamin/skills/blob/v4.41.0/demo/RECORDING.md).
5. Deliver `output/demo.mp4` or `output/index.html` with assets; use the [walkthrough scaffold](https://github.com/malinskibeniamin/skills/blob/v4.41.0/demo/templates/walkthrough.html). Label simulations/explanations, not recorded evidence.
6. Compose optionally with existing HyperFrames; preserve existing Remotion sources. No second renderer for recordings.
7. Keep muted playback understandable. Requested/source-required voiceover must align with actions, retain captions/transcripts, and pass listening checks. Cloud speech, cloned voices, and uploads require authorization.
8. Inspect early/middle/late frames, full playback, and error paths; fix defects; redact secrets/private/customer PII. When motion adds no value, use an architecture diagram with accessible description and reason.
9. Never edit README. Honor local/no-push stops; otherwise commit, push current branch, create draft PR with artifact link. Preserve existing PR review state.
10. macOS: `open -R`; otherwise show `pwd`, absolute path, exact `cd`.

## Done

Return story, artifact type/path, capture/render/playback evidence, limits, and PR URL when publication is in scope. Local output satisfies only an explicit local endpoint.
