# Backend diagrams and maintenance

## When to attempt

Read the actual diff and affected callers. Changes to architecture, data flow, API contracts, or workflows
trigger a focused before/after Excalidraw attempt, including backend-only PRs. Skip docs-only,
formatting, mechanical, or implementation-only edits when these relationships stay unchanged.
File extensions alone do not decide eligibility. State a skip reason when the boundary is unclear.

Invoke `excalidraw-diagram`; it owns creation, export, and visual inspection. A diagram is not a test
or proof that the system works. Keep execution evidence beside the explanation; retain existing
frontend screenshot/video requirements when both kinds of change apply.

## Show the difference

1. Resolve the real PR base (the parent layer for a stack) and its merge-base with the candidate.
   Read the relevant base revision with `git show <base-sha>:<path>` and compare current source,
   including uncommitted work. Record the actual revisions with the artifacts; refresh after edits
   or rebase. Do not manufacture a previous architecture from the candidate alone.
2. Find existing diagrams and their host docs first. Reuse scene IDs and unchanged layout.
   Choose a sequence for ordering, a flow for routing, or a boundary view for ownership.
   Explain one review question: old behavior -> new behavior -> reason/expected value.
   Show public rationale, alternatives, and evidence, not private chain of thought.
3. Render the actual base scene, or reconstruct a clearly labeled view from base source.
   Keep comparable before/after panels with stable names, framing, and scale. Label added,
   removed, and changed parts in text or line styles as well as color. Show only the affected
   path and necessary neighboring boundaries. New systems say `New` rather than inventing history.
4. Mark inferred or unverified relationships explicitly. Link the source paths/symbols supporting
   important edges and the tests supporting behavioral claims. Do not assert faster, safer, or
   cheaper without measurements; distinguish expected benefit from observed evidence.

## Git and freshness

Git is authoritative. Follow existing documentation paths; otherwise use `docs/architecture/`
for maintained views and `.context/excalidraw/<slug>/` for disposable PR comparisons.
Keep each maintained `.excalidraw` beside its PNG (SVG only when available/needed), with a concise
accessible description in the host doc. Prefer PNG in PRs; official rendering does not export SVG.
After direct editing, `.excalidraw` owns the view; Mermaid input is only import provenance.

When code changes invalidate a documented relationship, update that existing scene and rerender
in the same PR. Check linked host docs too. Preserve hand edits, unrelated nodes, IDs, and embedded
images; avoid regenerating the whole repository. In the host doc, record source paths/symbols,
the represented scenario, and how it was verified so later changes can find affected diagrams.
Render after editing source; do not edit a PNG instead. Keep a historical before snapshot separate
from the maintained current view, with its base revision labeled. Git history retains prior versions.
If refresh fails, retain the prior artifact but mark it stale in the PR and host doc instead of
presenting it as current. Do not install background regeneration or new CI gates.

## PR presentation

Place the comparison beside the claim in Summary/Evidence, with a short accessible caption:

```markdown
**Architecture:** synchronous writes -> queued processing; decouples request handling from work.
Expected latency benefit is unmeasured. Added: queue and worker. Unchanged: storage contract.

| Before (base SHA) | After (candidate SHA) |
| --- | --- |
| ![API writes directly to storage](<before-image-url>) | ![API enqueues work; worker writes to storage](<after-image-url>) |

Editable source: [current architecture](<repo-scene-link>). Evidence: <source and test links>.
```

Replace the example with the actual change. Use the existing authenticated PR attachment flow,
or committed image URLs pinned to immutable SHAs in the same repository. Verify reviewer access;
local `.context` paths are not hosted images. Link the tracked editable source for reuse/onboarding.
No automatic Excalidraw+ sync, `share`, or public hosting: uploads need explicit user intent and
must preserve the repository's audience. Do not create an evidence branch just to host diagrams.

## Failure is nonblocking

Missing CLI/browser, conversion, rendering, or upload failure: report the actual error, preserve
valid source and any verified outputs, then continue commit/push/PR delivery. Do not retry
indefinitely or ask the user to waive a diagram gate. Keep broken/empty artifacts out of maintained
docs. If useful, include a clearly labeled Mermaid/text fallback; it is not editable Excalidraw.
Say what is missing, for example `Architecture preview unavailable: browser not found; editable
source committed; rendering not verified.` Refresh stale docs as above. Diagram availability
does not weaken tests or other required checks, and diagram success never substitutes for them.
