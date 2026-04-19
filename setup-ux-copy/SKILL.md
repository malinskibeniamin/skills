---
name: setup-ux-copy
description: Enforce UX text style guide via PostToolUse hooks -- bans exclamation points, "successfully", "click here", blame language, Title Case, Yes/No buttons. Redpanda term capitalization with REDPANDA_KIT=1. Use when enforcing UI copywriting standards or UX text consistency.
---

# Setup UX Copy

PostToolUse hook on Edit/Write check `.ts` and `.tsx` files:

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

### Redpanda-specific (REDPANDA_KIT=1)

- Enforce product name capitalization (Admin API, Schema Registry, HTTP Proxy, Redpanda Console)
- Warn on "the console" (use "Redpanda Console")

### Escape hatch

`// allow: ux-copy [reason]` anywhere in file skip all checks.

## Steps

### 1. Create hook script
Copy [`scripts/ux-copy-check.sh`](scripts/ux-copy-check.sh) and [`scripts/_hook-lib.sh`](scripts/_hook-lib.sh) to `.claude/hooks/`. Make executable.

### 2. Configure hook
Add to hooks config: **PostToolUse** (matcher: `Edit|Write`): `.claude/hooks/ux-copy-check.sh`

### 3. Copy glossary (optional, for DDD)
Copy [`GLOSSARY.md`](GLOSSARY.md) to project root or `docs/`. Pair with `ubiquitous-language` community skill.

### 4. Verify
- [ ] Hook blocks `"Something!"` in string literals
- [ ] Hook blocks `"successfully"` in UI strings
- [ ] Hook blocks `<Button>Yes</Button>` in TSX
- [ ] (If `REDPANDA_KIT=1`) Hook blocks `"schema registry"` (lowercase)