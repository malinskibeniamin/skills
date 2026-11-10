# Backend diagrams and maintenance

## Required fallback

Read the actual diff and affected callers. Changes to architecture, data flow, API contracts, or workflows,
including backend behavior, frontend-backend contracts, BFFs, Protobuf and generated-client semantics,
require a source-grounded architecture, sequence or flow diagram when screenshots/video do not
explain the affected behavior. Backend-only PRs take this route automatically; no extra user request.
Mixed UI/backend changes still need a diagram for contracts the captures leave unexplained.
Skip docs-only, formatting, mechanical or implementation-only edits only when behavior, contracts
and relationships stay unchanged; record a concrete reason under the [visual-evidence contract](../commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5).
File extensions alone do not decide eligibility.

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

## Rendering failure is nonblocking; explanation remains required

Missing CLI/browser, conversion, rendering or upload failure: report the actual error, preserve
valid source and verified outputs, and include a fenced `mermaid` diagram directly in the PR body
before continuing delivery. Use the same source-grounded changed path and an accessible caption;
label the fallback as Mermaid, not editable Excalidraw. A local scene link or prose-only failure
notice does not satisfy the requirement. Do not retry indefinitely or require Excalidraw installation.
Keep broken/empty artifacts out of maintained docs; refresh stale docs as above. Ordinary diagram
uploads remain within the repository's audience; public sharing is still opt-in. Diagram success
never substitutes for tests or other required checks.

The lifecycle Stop gate checks the published body's evidence presence, including drafts, using
`scripts/pr-visual-evidence.py`; author/review verifies semantic applicability and diagram accuracy.
Keep new PR-only sources temporary unless requested or reusable; update existing maintained scenes.
