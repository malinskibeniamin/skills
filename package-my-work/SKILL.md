---
name: package-my-work
description: Package UI recordings with deliberate resolution, input cues, detail zooms and pacing. Use after every authored UI change and for requested demos or shareable clips; not npm packaging.
argument-hint: "[feature, URL, PR, or existing recording] [audience/channel]"
---

Package every authored consumer/end-user UI change in every consuming repository, per PR;
reuse current captures across iterations. [Scope and completion gate](PACKAGING.md#per-pr-delivery).
Make the work easy to see, not more impressive than it is. Read [PACKAGING.md](PACKAGING.md).
Local adaptation of [Emil Kowalski's packaging brief](https://x.com/emilkowalski/status/2122704498334339368),
not a copy of his unpublished course skill; [provenance](PROVENANCE.md).

## Outcome contract

Resolve the feature/revision, real entrypoint, intended viewer/channel, aspect ratio and
requested endpoint. Inspect existing demo sources first. Ask only for consequential missing
choices; otherwise state a reversible default. Packaging alone authorizes no upload, PR,
new renderer, paid service or product UI changes. Honor local/no-commit/no-push stops;
repository delivery policy still owns requested source changes.

## Capture -> focus -> package -> inspect

1. Choose one starting state -> action -> payoff story. Use sanitized fixtures and an
   isolated browser; preserve genuine error/recovery behavior when relevant.
2. Match CSS viewport, captured pixels and export size deliberately. Check text at the
   actual viewing size; a larger export cannot recover a blurry capture.
3. Match cues to input: mouse arrow at the actual pointer, contact indicator for touch/pen,
   focus highlight for keyboard. Show deliberate movement before activation, track drags
   directly, and keep controls unobscured. Never simulate a mouse click for keyboard use.
4. Establish context, then zoom/crop only where a detail would be unreadable. Keep the
   action and result together; use the existing compositor, not app/browser zoom changes.
5. Reuse [capture/narration recipes](../demo/RECORDING.md) and the
   [PR video pipeline](../commit-push-pr/VIDEO.md). Trim setup/dead air, retime captions/audio,
   hold readable results, and prefer restrained framing over decorative transitions.
6. Inspect representative frames and complete playback at delivery size, muted too.
   Verify dimensions, duration, frame rate, codec, size, input alignment, zoom legibility,
   captions, redaction and any audio. Repair and replay; report unavailable checks honestly.

## Handoffs

- `/demo` owns the customer story, `demos/<slug>/` source/output, narration/walkthrough,
  diagram fallback and its requested publication. Its explicit-only invocation remains
  with the user; these shared recording recipes are usable without invoking `/demo`.
- Every UI PR (including mixed changes and follow-ups) requires the hosted recording and
  explicit packaging declaration in [per-PR delivery](PACKAGING.md#per-pr-delivery).
- PR interaction evidence follows `commit-push-pr/VIDEO.md`, reusing the same
  real take. Every authored UI change needs a polished clip; a review request stays read-only.
- Product motion stays with `/animate` or `/gestures`; packaging changes presentation,
  not shipped behavior. Terminal replays stay with `/demo`'s asciinema recipes.

## Done

Return the artifact's absolute path, story, capture/export settings, playback checks and
material edits/limits. Link requested MP4/PNG files directly; publish only through the
already-authorized delivery workflow. Missing source access is a blocker to faithful capture,
not permission to reconstruct a convincing success. Required UI packaging remains blocked
until captured or explicitly waived; optional polish gaps do not block unrelated non-UI work.
Retain the final required clip and only requested/reusable supporting assets.
