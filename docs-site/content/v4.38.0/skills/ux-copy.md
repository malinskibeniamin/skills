---
title: "/ux-copy"
description: "Write clear, concise, inclusive interface copy. Use when changing UI strings, labels, buttons, empty states, errors, toasts, help text, or product terminology."
type: skill
sidebar:
  label: "/ux-copy"
---
![Diagram of the /ux-copy skill](/diagrams/skills/ux-copy.svg)

[Open the editable Excalidraw source](/diagrams/skills/ux-copy.excalidraw)


<!-- allow: prose-style this file documents the rules and shows example violations -->

# UX Copy

Read [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/ux-copy/REFERENCE.md) for capitalization, controls, messages, links,
placeholders, and inclusive language.

## Interface copy

- Use sentence case and front-load the object or result.
- Give each label, helper, placeholder, tooltip, and error a distinct job.
- Buttons name the action and object; avoid Yes, No, Submit, OK, or Done.
- Errors state the cause, constraint, and recovery.
- Empty states explain why and provide one next step.
- Labels persist; placeholders provide examples only.
- Completion toasts use a subject and past-tense verb.
- Use please, sorry, and thank you only for genuine inconvenience.
- Destructive language names permanent loss directly.
- Keep regex and validation messages adjacent.
- Stress long localization, large numbers, offline/error states, truncation, and recovery.

Use the project's canonical product names and glossary when available.
Code-string escape: `// allow: ux-copy [reason]`.

## Markdown lint

`prose-style-check.sh` provides narrow in-repo Markdown checks for filler, links,
inclusive terms, and heading case. Follow the project's documentation standards as the
source of truth.

Prose escape: `<!-- allow: prose-style [reason] -->`.

## Hook setup

Copy and register these PostToolUse `Edit|Write` hooks:

- `scripts/ux-copy-check.sh`
- `scripts/prose-style-check.sh`
- `scripts/_hook-lib.sh`

Make them executable. Keep shared product terminology in project documentation.

## Completion

Verify `ux-copy-check.sh` catches exclamation points, `successfully`, blame language,
generic actions, vague errors, verbose toasts, and placeholder mistakes. Verify
`prose-style-check.sh` catches canned AI prose, em dashes, non-descriptive links,
non-inclusive terms, and title-case headings. Verify canonical product capitalization
when the project defines it.
