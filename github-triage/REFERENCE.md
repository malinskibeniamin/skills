# GitHub Triage Reference

## Triage Workflow (Specific Issue)

### Step 1: Gather Context

Before presenting anything:
- Read full issue: body, comments, labels, reporter, age
- Parse prior triage notes from previous sessions
- Explore codebase for relevant domain context
- Read `.out-of-scope/*.md` — check if matches prior rejection

### Step 2: Present Recommendation

Tell maintainer: category (bug/enhancement) + reasoning, state recommendation + reasoning. If matches prior out-of-scope: "Similar to `.out-of-scope/concept.md` — rejected before because X. Still feel the same?"

Wait for direction.

### Step 3: Bug Reproduction (bugs only)

Attempt to reproduce before grilling:
- Follow reporter's steps
- Explore relevant code paths
- Run tests or trace logic
- Report success/failure to maintainer
- Lack of detail → strong signal for `needs-info`

### Step 4: Grilling Session (if needed)

Flesh out issue to complete spec. Interview maintainer.

### Step 5: Apply Outcome

| Outcome | Action |
|---|---|
| ready-for-agent | Post agent brief comment (see below) |
| ready-for-human | Post summary + why can't delegate |
| needs-info | Post triage notes + questions |
| wontfix (bug) | Comment explaining why → close |
| wontfix (enhancement) | Write `.out-of-scope/` → comment → close |

---

## Agent Brief Format

Durable spec an AFK agent works from. Original issue = context; brief = contract.

### Principles

**Durability over precision**: Describe interfaces/types/contracts. NO file paths, NO line numbers.

**Behavioral, not procedural**: WHAT system should do, not HOW to implement.

**Complete acceptance criteria**: Each independently verifiable.

**Explicit scope boundaries**: State what's out of scope.

### Template

```markdown
## Agent Brief

**Category:** bug / enhancement
**Summary:** one-line description

**Current behavior:**
What happens now.

**Desired behavior:**
What should happen. Be specific about edge cases.

**Key interfaces:**
- `TypeName` — what changes and why
- `functionName()` — current vs expected return

**Acceptance criteria:**
- [ ] Specific, testable criterion 1
- [ ] Specific, testable criterion 2

**Out of scope:**
- Thing NOT to change
- Adjacent feature that's separate
```

---

## Out-of-Scope Knowledge Base

`.out-of-scope/` directory stores rejected feature requests. Institutional memory + deduplication.

### Structure

```
.out-of-scope/
├── dark-mode.md
├── plugin-system.md
└── graphql-api.md
```

One file per **concept**, not per issue. Multiple issues grouped.

### File Format

```markdown
# Dark Mode

This project does not support dark mode or user-facing theming.

## Why This Is Out of Scope

[Substantive reason — not "we don't want this" but WHY. Reference project scope, technical constraints, or strategic decisions. Must be durable — no "too busy right now".]

## Prior Requests

- #42 — "Add dark mode support"
- #87 — "Night theme for accessibility"
```

### When to Check

During triage Step 1. Match by concept similarity, not keyword — "night theme" matches `dark-mode.md`.

### When to Write

Only when **enhancement** (not bug) rejected as `wontfix`:
1. Check if matching file exists
2. Exists → append to "Prior Requests"
3. Not exists → create new file
4. Comment on issue linking to file
5. Close with `wontfix`

---

## Needs Info Output

```markdown
## Triage Notes

**What we've established so far:**
- point 1
- point 2

**What we still need from you (@reporter):**
- specific question 1
- specific question 2
```

Capture ALL grilling progress in "established" — don't lose work. Questions must be specific and actionable.
