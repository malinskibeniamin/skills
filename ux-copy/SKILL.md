---
name: ux-copy
description: Write clear, inclusive UX copy. Use when changing UI strings, labels, actions, empty states, errors, documentation prose, or product terminology.
---

<!-- allow: prose-style this file documents the rules and shows example violations -->

# UX Copy

Read [REFERENCE.md](REFERENCE.md) for capitalization, controls, errors, empty states,
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

Use the project's canonical product names and glossary when available.
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

Make them executable. Keep shared product terminology in project documentation.

## Completion

Verify `ux-copy-check.sh` catches exclamation points, `successfully`, blame language,
generic actions, and vague errors. Verify `prose-style-check.sh` catches canned AI prose,
em dashes, and hard-banned words. Verify canonical product capitalization when the
project defines it.
