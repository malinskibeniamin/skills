---
name: docs
description: "Write or review factual technical documents: READMEs, design specs, research notes, and runbooks. Use for document authoring or review, not ordinary chat, UI copy, or agent instructions."
---

Write documents that readers can understand, verify, and use.

## Load guidance

1. Read [harness compatibility](../shared/FLIGHTRULES-COMPATIBILITY.md) first.
2. Read the complete [pinned upstream docs skill](../vendor/flightrules/skills/docs/SKILL.md).
3. Apply the compatibility rules wherever upstream differs. Read
   [communication](../shared/communication.md) for first-read structure and author intent.

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
