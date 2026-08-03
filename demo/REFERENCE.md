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

- Aim for 20-45 seconds, 1920x1080, and 30 fps unless the target channel requires another
  format. Make it understandable muted; use concise on-screen captions.
- Establish the problem, demonstrate the smallest realistic action sequence, then hold on
  the payoff long enough to read it. End with a practical next step, not generic hype.
- Keep one focal point per scene. At 1080p, start near 84 px for headlines and 44 px for
  important supporting text; preserve generous safe areas.
- Capture real UI states when available. Use diagrams for invisible behavior, not as
  decoration around an already-clear surface.

## Build with Remotion

1. Use installed official `remotion-best-practices`, `remotion-create`,
   `remotion-markup`, and `remotion-render` skills. If unavailable, read the current
   [Remotion Agent Skills](https://www.remotion.dev/docs/ai/skills),
   [render CLI](https://www.remotion.dev/docs/cli/render), and
   [still CLI](https://www.remotion.dev/docs/cli/still) docs before implementation.
2. Reuse an existing Remotion project when practical. Otherwise scaffold inside
   `demos/<slug>/` with the repository package manager; in Bun repos translate the official
   scaffold to `bunx create-video@latest --yes --blank --no-tailwind demos/<slug>`.
3. Keep each scene in a focused component. Drive animation from `useCurrentFrame()` and
   `interpolate()`; CSS transitions and CSS keyframe animations do not render reliably.
4. Put captures and approved media in the composition's `public/` directory. Keep all
   customer claims traceable to the target diff or observed product behavior.
5. Render deterministically from the Remotion project root:

   ```bash
   bunx remotion render <entry-point> <composition-id> output/demo.mp4 --codec=h264
   ```

   Keep the recording small enough for the Git host. Reduce duration or bitrate before
   lowering legibility; do not introduce Git LFS unless the repository already uses it.

## Verify the artifact

1. Render stills from early, middle, and late frames. Inspect them visually, then watch the
   complete `demo.mp4` for clipping, timing, legibility, blank frames, stale UI, and abrupt
   cuts. Fix and re-render rather than documenting avoidable defects.
2. Check the recording's duration, dimensions, codec, file size, and non-zero exit status
   using available Remotion or media inspection commands.
3. Replay the customer action against the current product. The recording must not promise
   behavior the target branch cannot reproduce.

## Diagram fallback

Use the fallback only after one documented concrete blocker prevents a faithful Remotion
render, or when a static explanation communicates the customer value better than motion.
Create `demos/<slug>/output/architecture.svg` plus editable Mermaid source. Prefer a sequence
diagram for interactions and a flow or architecture diagram for structure. Render and inspect
the SVG; do not deliver source-only Mermaid. Put the blocker and fallback rationale in the PR.

## Publish

1. Never edit a README as part of `/demo`.
2. Follow `/commit-push-pr` with explicit draft mode. Create a missing PR with `--draft`;
   update an existing PR and preserve its current draft or ready state.
3. Add a `## Demo` section to the PR body with the customer story, repository-relative
   artifact link, exact render command, validation evidence, and fallback reason if present.
4. Take one CI snapshot. Then reveal `demo.mp4` with `open -R` on macOS, or print its
   absolute path plus a shell-quoted `cd` command for the output directory.
