# Factual docs in this harness

The [docs-only snapshot](../vendor/flightrules/NOTICE.md) supplies writing guidance, not a
second installed harness. The [docs skill](../docs/SKILL.md) loads it on document tasks.
The optional [factual-docs output style](../output-styles/factual-docs.md) keeps only the
session-wide communication subset. Neither surface installs review gates, agents, build
systems, or background work.

## Adapt upstream to the requested artifact

These rules take precedence over conflicting upstream instructions:

- **Scope:** technical documents only. Ordinary chat, UI copy, PR/status messages, and
  agent instructions retain their existing owners. Preserve the user's endpoint and
  repository instructions; loading a skill grants no new action permissions.
- **Reader attention:** [communication](communication.md) owns first-read budgets,
  author intent, and human-facing structure. Keep explicit artifact schemas and templates.
- **Sections and filenames:** ELI5 sections, date prefixes, and all-zero evergreen dates
  are optional conventions, not requirements. Preserve canonical paths and existing
  sections unless the user or repository asks to change them. Do not retrofit other files.
- **Diagrams:** draw when structure changes understanding; use the existing supported
  format, including Mermaid or ASCII. A labeled proposed diagram is valid in a design
  document. Never present a proposed path as implemented, or repeat a diagram in prose.
- **Uncertainty:** preserve uncertainty and modal meaning. Do not replace "may", "might", or "could" with
  "can" when that strengthens a claim. Keep recommendations distinct from requirements.
- **Language:** use short, grammatical, active sentences and consistent terms. Upstream
  word limits and punctuation/verb bans are editing heuristics, not grounds to distort
  meaning, remove qualifiers, invent facts, or change literal artifacts.
- **References:** use descriptive subjects for durable documents. Keep exact identifiers
  where needed to reproduce behavior. Process documents and PR/status messages may name
  real steps, tickets, or PRs when those references carry useful context.

Keep the upstream file byte-for-byte unchanged. Make future adaptations here rather than
patching the snapshot. Updating the pin requires reviewing the source and refreshing its
integrity evidence; no upstream installation instructions are part of this integration.
