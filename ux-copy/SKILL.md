---
name: ux-copy
description: Write clear, concise, inclusive interface copy. Use when changing UI strings, labels, buttons, empty states, errors, toasts, help text, or product terminology.
---

<!-- allow: prose-style this file documents the rules -->

[REFERENCE.md](REFERENCE.md) owns capitalization, controls, messages, links, placeholders, inclusion.

## Copy

- Sentence case; front-load object/result.
- Labels, helpers, placeholders, tooltips, errors each have one job.
- Buttons name action+object, not Yes/No/Submit/OK/Done.
- Errors give cause, constraint, recovery; empty states give reason and one next step.
- Labels persist; placeholders are examples only.
- Completion toasts use subject + past-tense verb.
- Use please/sorry/thanks only for real inconvenience.
- Name permanent destructive loss directly.
- Keep regex and validation messages adjacent.
- Stress localization length, numbers, offline/error, truncation, recovery.

Use project glossary and canonical product names. Code escape: `// allow: ux-copy [reason]`.

## Lint/hooks

`prose-style-check.sh` checks Markdown filler, links, inclusive terms, heading case; repo docs standards win. Escape: `<!-- allow: prose-style [reason] -->`.

Install executable PostToolUse `Edit|Write` hooks: `scripts/ux-copy-check.sh`, `scripts/prose-style-check.sh`, `scripts/_hook-lib.sh`.

Verify UX hook catches exclamation, `successfully`, blame, generic actions, vague errors, verbose toasts, placeholders. Verify prose hook catches canned AI prose, em dashes, vague links, exclusionary terms, title-case headings, and canonical capitalization.
