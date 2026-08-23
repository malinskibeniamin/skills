---
title: "/ux-copy"
description: "Write clear, inclusive UX copy. Use when changing UI strings, labels, actions, empty states, errors, documentation prose, or Redpanda product terms."
type: skill
sidebar:
  label: "/ux-copy"
---
![Diagram of the /ux-copy skill](/diagrams/skills/ux-copy.svg)

[Open the editable Excalidraw source](/diagrams/skills/ux-copy.excalidraw)


<!-- allow: prose-style this file documents the rules and shows example violations -->

# UX Copy

Read [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/ux-copy/REFERENCE.md) for capitalization, controls, errors, empty states,
inclusive language, and prose rules.

## Product copy

- Use sentence case and front-load the object or result.
- Buttons name the action and object; avoid Yes, No, Submit, OK, or Done.
- Errors state the cause, constraint, and recovery.
- Empty states explain why and provide one next step.
- Labels persist; placeholders provide examples only.
- Destructive language names permanent loss directly.
- Keep regex and validation messages adjacent.
- Stress long localization, large numbers, offline/error states, truncation, and recovery.

With `REDPANDA_KIT=1`, use canonical product names from [GLOSSARY.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/ux-copy/GLOSSARY.md).
Code-string escape: `// allow: ux-copy [reason]`.

## Prose

- Prefer direct sentences and concrete verbs.
- Remove canned openings, AI-tell words, heavy transitions, Latin abbreviations, praise
  triads, and em dashes.
- Keep links descriptive and at the decision point.

Prose escape: `<!-- allow: prose-style [reason] -->`.

## Hook setup

Copy and register these PostToolUse `Edit|Write` hooks:

- `scripts/ux-copy-check.sh`
- `scripts/prose-style-check.sh`
- `scripts/_hook-lib.sh`

Make them executable. Optionally copy `GLOSSARY.md` into project docs for shared domain
language.

## Completion

Verify `ux-copy-check.sh` catches exclamation points, `successfully`, blame language,
generic actions, and vague errors. Verify `prose-style-check.sh` catches canned AI prose,
em dashes, and hard-banned words. When Redpanda mode is active, verify product
capitalization.
