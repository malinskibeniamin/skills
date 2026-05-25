---
name: setup-matt-pocock-skills
description: Scaffold docs/agents config for issue tracker, labels, and domain docs.
disable-model-invocation: true
---

# Setup Matt Pocock Skills

Scaffold per-repo config:

- Issue tracker: GitHub, GitLab, local markdown, or other.
- Triage labels: project strings for canonical roles.
- Domain docs: `CONTEXT.md`, `CONTEXT-MAP.md`, ADR layout.

Prompt-driven. Explore -> present -> confirm -> write.

## 1. Explore

Read existing state. Do not assume.

- `git remote -v`, `.git/config`
- `AGENTS.md`, `CLAUDE.md`; existing `## Agent skills`
- `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, nested ADR dirs
- `docs/agents/`
- `.scratch/`

## 2. Ask decisions one at time

### A. Issue tracker

Explain: where issues live; skills need write/read workflow.

Default from remote. Choices:

- GitHub: `gh issue`
- GitLab: `glab issue`
- Local markdown: `.scratch/<feature>/`
- Other: user describes workflow; record prose

### B. Triage labels

Explain canonical roles -> actual labels/statuses.

Roles:

- `needs-triage`
- `needs-info`
- `ready-for-agent`
- `ready-for-human`
- `wontfix`

Map to existing tracker labels/statuses. Avoid creating dup vocab if repo already has names.

### C. Domain docs

Explain glossary + ADRs feed tdd/diagnose/triage/architecture.

Choose:

- Single context: root `CONTEXT.md` + `docs/adr/`
- Multi-context: root `CONTEXT-MAP.md` points to per-context docs

## 3. Confirm draft

Show draft edits before writing:

- `## Agent skills` block for `AGENTS.md` or `CLAUDE.md`
- `docs/agents/issue-tracker.md`
- `docs/agents/triage-labels.md`
- `docs/agents/domain.md`

## 4. Write

Write only approved files. Preserve existing docs. If block exists, update in place.

## 5. Verify

Confirm files exist and mention selected tracker, labels, domain layout. Tell user which skills now have context.
