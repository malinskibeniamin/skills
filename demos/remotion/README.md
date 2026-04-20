# Skills Demos (Remotion)

Render marketing videos + README GIFs with [Remotion](https://www.remotion.dev/) -- React components in, MP4/WebM/GIF out.

## Compositions

| ID | Length | Output | Purpose |
|---|---|---|---|
| `ExplainerDemo` | ~60s @ 1920x1080 | `docs/screenshots/explainer.mp4` | Landing-page video. Tells the pain -> fix -> install -> proof story. |
| `HookFireDemo` | ~12s @ 1280x720 | `docs/screenshots/hook-fire.gif` | README hero GIF. Hook blocking a banned cast in real time. |

## Setup

```bash
cd demos/remotion
bun install --yarn
```

Remotion renders via Chromium -- first run downloads headless Chrome (~170MB).

## Preview (interactive)

```bash
bun run studio
```

Opens Remotion Studio at `localhost:3000`. Scrub timeline, tweak props, hot-reload compositions.

## Render

```bash
# Hero GIF for README
bun run render:gif

# Full explainer MP4 (for landing page, social, docs hero)
bun run render

# Explainer as GIF (larger file -- use MP4 when possible)
bunx remotion render ExplainerDemo ../../docs/screenshots/explainer.gif --codec=gif --image-format=png
```

Output writes to `docs/screenshots/`. Commit rendered artifacts so README embeds don't break.

## Editing compositions

- `src/compositions/*.tsx` -- per-video scenes (one file = one composition)
- `src/components/*.tsx` -- reusable primitives (Terminal, TypedLine, BigText, Scene)
- `src/theme.ts` -- colors + font stack (matches GitHub dark theme for consistency with plugin-card.png)
- `src/Root.tsx` -- register compositions + dimensions/fps

Each composition is a React component that receives no props; animate via `useCurrentFrame()`. See Remotion docs for `interpolate`, `spring`, `Sequence`, `AbsoluteFill`.

## Adding a new composition

1. Create `src/compositions/MyDemo.tsx` exporting `MyDemo: React.FC`
2. Register in `src/Root.tsx`:
   ```tsx
   <Composition id="MyDemo" component={MyDemo} durationInFrames={...} fps={30} width={...} height={...} />
   ```
3. Add render script in `package.json`:
   ```json
   "render:my-demo": "remotion render MyDemo ../../docs/screenshots/my-demo.gif --codec=gif --image-format=png"
   ```

## Why Remotion (vs vhs / asciinema / manual)

- **Deterministic** -- same input frame -> same pixel output. No re-record drift.
- **Programmable** -- change a constant (token counts, hook timing), re-render.
- **Code-reviewable** -- video edits land as git diffs, not binary churn.
- **High production value** -- real React, real typography, real animations. Fits a polished landing page.

Tradeoff: heavier than asciinema for a terminal-only clip. Use `vhs` if you only need a terminal recording and don't need branding/animation.
