---
name: write-a-skill
description: Create new agent skills with proper structure, progressive disclosure, and bundled resources. Use when user wants to create, write, or build a new skill.
---

# Write a Skill

## Process

### 1. Gather requirements

Ask the user:
- What task or domain does this skill cover?
- What are the primary use cases?
- Are any scripts or automation needed?
- Any reference materials to bundle?

### 2. Draft the skill

Create the skill directory with appropriate files:

    skill-name/
    ├── SKILL.md           # Main instructions (required, under 100 lines)
    ├── REFERENCE.md       # Detailed docs (if SKILL.md would exceed 100 lines)
    ├── EXAMPLES.md        # Usage examples (if needed)
    └── scripts/           # Utility scripts (if needed)

### 3. Description requirements

- Max 1024 characters, third person
- First sentence: what it does
- Second sentence: "Use when [specific triggers]"

### 4. When to add scripts

Add bundled scripts when:
- The operation is deterministic (same code every time)
- The same code would be generated repeatedly without a script
- Errors need explicit handling

### 5. When to split files

Split beyond SKILL.md when:
- SKILL.md exceeds 100 lines
- Content has distinct domains (e.g., reference tables vs workflow)
- Advanced features are rarely needed (progressive disclosure)

### 6. Review with user

Run through the checklist:
- [ ] Description includes trigger phrases
- [ ] SKILL.md under 100 lines
- [ ] No time-sensitive info (dates, versions that will go stale)
- [ ] Consistent terminology throughout
- [ ] Concrete examples included
- [ ] References are one level deep (SKILL → REFERENCE, not SKILL → REF1 → REF2)
