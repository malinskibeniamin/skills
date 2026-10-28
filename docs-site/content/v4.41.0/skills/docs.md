---
description: "Write or review factual technical documents: READMEs, design specs, research notes, and runbooks. Use for document authoring or review, not ordinary chat, UI copy, or agent instructions."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["docs"]}
sidebar: {"label":"/docs"}
title: "/docs"
type: "skill"
---
![Diagram of the /docs skill](/diagrams/skills/docs.svg)

[Open the editable Excalidraw source](/diagrams/skills/docs.excalidraw)


Write documents that readers can understand, verify, and use.

## Load guidance

1. Read [harness compatibility](https://github.com/malinskibeniamin/skills/blob/v4.41.0/shared/FLIGHTRULES-COMPATIBILITY.md) first.
2. Read the complete [pinned upstream docs skill](https://github.com/malinskibeniamin/skills/blob/v4.41.0/vendor/flightrules/skills/docs/SKILL.md).
3. Apply the compatibility rules wherever upstream differs. Read
   [communication](https://github.com/malinskibeniamin/skills/blob/v4.41.0/shared/communication.md) for first-read structure and author intent.

## Write or review

1. Identify the audience, requested artifact, source evidence, and endpoint. Reuse the
   existing path, template, and terminology. Review-only requests produce findings, not edits.
2. Lead with the reader's outcome. Distinguish current behavior, proposals, estimates,
   and unknowns. Source numerical claims and include reproducible commands for stated results.
3. Preserve author intent and exact code, commands, identifiers, quoted errors, and facts.
   Simplify prose without deleting material qualifications. Diagram meaningful structure in
   the repository's supported format; label proposed paths as proposals.
4. Verify each changed claim against its source. Run the repository's document/link checks;
   if no checker exists, resolve changed internal file links and relevant cross-references
   with a tool. Validate fragments when supported. Never claim unrun commands succeeded.
5. Report the result, observed verification, and unresolved evidence gaps. Follow the
   requested endpoint; this skill does not authorize unrelated publishing or configuration.

For public TypeScript API JSDoc, runnable examples and cross-links, load
[JSDoc guidance](https://github.com/malinskibeniamin/skills/blob/v4.41.0/t3code-skills/jsdocs/SKILL.md). General technical prose stays here.
