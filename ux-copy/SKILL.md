---
name: ux-copy
description: UX text style for UI strings and prose -- sentence case, action labels, banned phrases, inclusive language, Redpanda terms. Use when writing or reviewing UI copy, labels, empty states, error messages, or docs prose.
---

<!-- allow: prose-style this file documents the rules and shows example violations -->

# Setup UX Copy
Two PostToolUse hooks on Edit/Write: one for code-string UX copy, one for prose.

## ux-copy-check.sh (`.ts` and `.tsx`)

- **Ban** exclamation points in UI strings
- **Ban** "successfully" (use past-tense verb: "Topic created")
- **Ban** "click here" and bare "here" link text
- **Ban** blame language ("Oops", "Uh oh", "Whoops")
- **Ban** "Yes"/"No" button labels (use action verbs)
- **Ban** non-inclusive terms (whitelist/blacklist -> allowlist/denylist, master/slave -> leader/follower)
- **Warn** possessive pronouns in titles/nav ("My Settings" -> "Settings")
- **Warn** bold/italic/monospace in string literals
- **Warn** ALL CAPS for emphasis (not acronyms)
- **Warn** Title Case (3+ consecutive capitalized words)
- **Warn** spelled-out numbers (1-9 as numerals in UI)
- **Warn** "and/or" (use "and", "or", or "A, B, or both")
- **Warn** "etc.", "e.g.", "i.e.", "please", "via", "There is/are" starters
- **Warn** generic CTA labels ("Submit", "OK", "Done") -- name the action
- **Warn** vague error copy ("Invalid input", "Something went wrong") -- state cause + recovery
- **Warn** dead-end empty states ("No data", "No items found") -- explain why + next step

### Copywriting articulation

- Microcopy must guide and reassure: labels, errors, placeholders, tooltips, toasts.
- CTA text owns the action: "Save changes" beats "Submit".
- Front-load scannable copy: lead with the object or result users need.
- Error messages say what happened and how to recover.
- Placeholders are examples or hints only; never the label.
- Success messages are specific and brief: "Saved" or "Topic created", not "Done".
- Destructive language is explicit: delete, remove, revoke, disconnect. Do not soften permanent loss.
- Contextual help sits near the thing it explains and should remove the next question.
- Numeric formatting, truncation, and locale-sensitive text are part of UX copy quality.
- Labels, helper text, placeholders, tooltips, and errors each do different work; cut redundant writing.
- Stress copy with long localized strings, huge numbers, empty/error/offline states, and destructive actions.
- Product naming can add identity only when clarity and recovery language stay intact.

### Redpanda-specific (REDPANDA_KIT=1)

- Enforce product name capitalization (Admin API, Schema Registry, HTTP Proxy, Redpanda Console)
- Warn on "the console" (use "Redpanda Console")

### Escape hatch

`// allow: ux-copy [reason]` anywhere in file skip all checks.

## prose-style-check.sh (`.md`, `.mdx`, `.markdown`)

For documentation, READMEs, PR description files, and any markdown prose.

- **Ban** em dashes (Unicode U+2014). Use commas, periods, or parentheses.
- **Ban** canned AI openers ("Let's dive in", "Here's why", "In conclusion", "In today's digital landscape").
- **Ban** AI-tell words (hard list): delve, tapestry, realm, pivotal, underscore.
- **Warn** AI-tell words (soft list): leverage, foster, intricate, nuanced, robust, comprehensive, significantly, showcase.
- **Warn** "not just X, but Y" / "not just X, it's Y" contrast framing.
- **Warn** heavy transitions (Moreover, Furthermore, Additionally, Nevertheless).
- **Warn** Latin abbrevs (e.g., i.e., etc.).
- **Warn** rule-of-three praise lists (e.g., "fast, efficient, and reliable").

Fenced code, indented code, inline code spans, and URLs are stripped before matching to reduce false positives.

### Escape hatch

`<!-- allow: prose-style [reason] -->` or `// allow: prose-style [reason]` anywhere in file skips all checks.

## Steps

### 1. Create hook scripts
Copy [`scripts/ux-copy-check.sh`](scripts/ux-copy-check.sh), [`scripts/prose-style-check.sh`](scripts/prose-style-check.sh), and [`scripts/_hook-lib.sh`](scripts/_hook-lib.sh) to `.claude/hooks/`. Make executable.

### 2. Configure hooks
Add to hooks config: **PostToolUse** (matcher: `Edit|Write`):
- `.claude/hooks/ux-copy-check.sh`
- `.claude/hooks/prose-style-check.sh`

### 3. Copy glossary (optional, for DDD)
Copy [`GLOSSARY.md`](GLOSSARY.md) to project root or `docs/`. Pair with `/grilling` and `/domain-modeling` for project-wide terminology work.

### 4. Verify
- [ ] Hook blocks `"Something!"` in string literals
- [ ] Hook blocks `"successfully"` in UI strings
- [ ] Hook blocks `<Button>Yes</Button>` in TSX
- [ ] Hook blocks em dash (U+2014) in `.md` files
- [ ] Hook blocks "Let's dive in" in `.md` files
- [ ] Hook blocks "delve" in `.md` files
- [ ] (If `REDPANDA_KIT=1`) Hook blocks `"schema registry"` (lowercase)
