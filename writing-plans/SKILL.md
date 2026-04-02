---
name: writing-plans
description: "Use when creating implementation plans, breaking work into tasks, or converting PRDs into actionable steps. Plans written for maximum clarity — every step shows exact code, commands, and expected output."
---

# Writing Plans

## Core Principle

Write plans for **an enthusiastic junior engineer with poor taste, no judgement, and an aversion to testing.** If they can execute the plan correctly, anyone can.

## Plan Header (required)

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence]
**Architecture:** [2-3 sentences]
**Tech Stack:** [Key technologies]
```

## Task Structure (exact format)

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.tsx`
- Modify: `exact/path/to/existing.tsx`
- Test: `exact/path/to/file.test.tsx`

- [ ] **Step 1: [Action]**
  [Exact code block or command]
  Expected: [What should happen]

- [ ] **Step 2: [Action]**
  [Exact code block or command]
```

## Rules

1. **Bite-sized tasks** — 2-5 minutes each
2. **No placeholders** — no "TBD", "add error handling", "similar to Task N"
3. **Every step shows actual content** — full code, not descriptions of code
4. **Exact file paths always** — never "the config file" or "the test"
5. **Exact commands with expected output** — `bun test --run` → "should see 3 passed"
6. **DRY, YAGNI, TDD** — test before implement, no speculative code

See [REFERENCE.md](REFERENCE.md) for templates and self-review checklist.
