---
title: "/eli5"
description: "Explain a topic to a complete beginner with a self-contained HTML picture explainer. Use for /eli5, module behavior, tradeoffs, incident causes, or any big-visual, few-word explanation."
type: skill
sidebar:
  label: "/eli5"
---
![Diagram of the /eli5 skill](/diagrams/skills/eli5.svg)

[Open the editable Excalidraw source](/diagrams/skills/eli5.excalidraw)

Explain the topic to someone who knows nothing about it. Use the request as the topic;
when explicitly invoked, treat `$ARGUMENTS` as authoritative.

## Contract

1. Ground the explanation in evidence before simplifying it. Inspect the relevant source
   material for a module, tradeoff, or incident. For external facts, prefer current primary
   sources. Never invent a causal step to make the story cleaner. Label facts and inference
   separately, including material uncertainty.
2. Choose one mental model that preserves the important truth. Remove jargon when possible;
   define unavoidable jargon beside the picture in ordinary words.
3. Create one self-contained HTML artifact: big pictures, few words, and no essay decorated
   with icons.
4. Verify the explanation against the evidence, then inspect the rendered artifact at wide
   and narrow viewport sizes.

## Audience

Assume no prior topic knowledge, not low intelligence. Use familiar objects, concrete verbs,
and a calm adult tone. Never become childish or patronizing. If omitted detail would reverse
the conclusion, keep it; otherwise defer it to the source notes.

Ask one short question only when choosing the wrong scope would make the explainer misleading.
Otherwise pick the smallest useful scope, state the assumption quietly, and proceed.

## Visual grammar

- Prefer three to six scenes. Give each scene or panel one idea and a clear reading order.
- Use large diagrams, spatial relationships, motion paths, timelines, scales, or before/after
  states. Decorative pictures do not count.
- Keep the main story to short headings and labels. Avoid paragraphs. Let the visuals carry
  sequence, quantity, ownership, and cause.
- For a module, show input -> transformation -> output. For a tradeoff, show what was gained
  and lost. For an incident, show trigger -> propagation -> impact -> recovery, marking facts
  and inference differently.
- End with one picture and one sentence that restate the core mental model.

## HTML artifact

- Use semantic HTML with inline CSS and SVG. Keep every required style, picture, and script in
  the file; do not depend on CDNs, remote fonts, image hotlinks, or a build step.
- Escape untrusted source text instead of inserting raw HTML.
- Make the layout responsive, high-contrast, and readable without animation. Honor
  `prefers-reduced-motion`; do not disable user zoom or rely on color alone.
- At narrow widths, recompose horizontal diagrams into stacked scenes instead of shrinking
  labels until they become unreadable.
- Give each meaningful visual a text alternative or accessible description. Use concise
  visible labels plus `aria-labelledby`, `<figcaption>`, or equivalent semantics.
- Put citations, file locations, assumptions, and necessary nuance in a compact
  `<details>` section named "Sources and assumptions" so the picture story stays terse.
- Add inline JavaScript only when interaction materially improves understanding. The static
  artifact must still communicate the core explanation.

Use the host's native HTML artifact surface when available. Otherwise write the file to a
host-native temporary directory such as one created with
`mktemp -d "${TMPDIR:-/tmp}/eli5.XXXXXX"`; do not add one-shot explainers to the repository.

## Verify and return

Open the result through an isolated browser or host preview, never a human-owned browser.
Check that the first view communicates the topic, labels do not clip, visuals remain legible on
a narrow screen, and every factual or causal claim matches the source material. Repair defects
before returning.

Return the artifact or its absolute path, the one-sentence takeaway, and any material
uncertainty. Do not repeat the full explanation in chat.
