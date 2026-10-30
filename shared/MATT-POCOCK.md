# Matt Pocock skill compatibility

The complete source suite, including engineering, productivity, in-progress and
misc skills, is pinned in [the lock](../vendor/mattpocock.lock.json).
[Provenance and refresh](../vendor/mattpocock-NOTICE.md) own the import procedure.

## Host contract

These rules take precedence over the source snapshot:

- Preserve the user's repository, requested outcome and endpoint. Loading or
  invoking a skill grants no delegation, persistent scheduling, merge, deployment,
  global configuration or unrelated installation permission. Explicit user intent
  must authorize those actions separately. Without delegation consent, work inline.
- Use the target repository's toolchain, current dependencies, scripts and rules.
  Source commands are examples, not permission to install a different harness,
  formatter, package manager or test runner. Inspect named commands before use;
  unavailable host capabilities remain a reported limitation.
- Keep source bytes unchanged. The snapshot is reference material, not a runnable
  upstream checkout. Resolve skill-local references there, but execute repository
  commands against the target checkout. Modify local policy here or in its owner.
- Every upstream skill has an explicit-only `/matt-<upstream-name>` entrypoint.
  This includes experiments and misc tools without adding duplicate autonomous
  triggers. Normal unprefixed entrypoints keep their existing owners and invocation
  policies. Translate upstream skill calls through the owner mapping below; follow
  [dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Existing owners

Each adapter names its local owner when one exists; use that workflow rather than
replacing it with source instructions. The lock records the complete mapping.

- `ask-matt` -> `ask-ben`; `code-review` -> `review`.
- `grill-me`, `grill-with-docs`, `grilling` -> `grilling`; load `domain-modeling`
  when glossary or ADR decisions matter.
- `implement` -> `development-lifecycle`; `setup-matt-pocock-skills` ->
  `work-automation-kit`.
- Other mapped skills keep their unprefixed owner, including `pr`, `implement-spec`,
  `tdd`, research, diagnosis, architecture, planning, handoff and writing workflows.
- A source skill without a local owner uses its explicit-only `/matt-...` adapter
  under these compatibility rules. This does not install its tools or automation.

## Delegation and long-running work

Upstream review, research, architecture, grilling and wayfinding can start agents
automatically; here they stay inline without explicit authorization. When authorized,
start each agent with a fresh context window and a self-contained brief containing
source, task and evidence pointers, not a fork of the coordinator's conversation.
Use one fresh implementer per ticket, and a separate fresh implementer for review
repairs. Preserve the selected model, isolated worktrees and other owners' edits.

`chief-of-staff` is an in-progress reference. Agree on a bounded goal and authorized
actions before starting work. Persistent schedules and background execution require
explicit scope; skip unsupported host tools. Retain dated, commit-cited knowledge
only in the agreed project location, keep secrets out, and correct contradictions
instead of treating memory as authority. `claude-handoff` cannot launch another
session without explicit authorization; ordinary handoff remains a document.

## Setup and migrations

- `git-guardrails-claude-code`: enter only for an explicit hook-installation request.
  Scope project versus global settings, preserve existing hooks and verify behavior.
  Vendoring never activates this hook or changes delivery permissions.
- `setup-pre-commit`: reuse existing formatting and quality commands. In a Biome
  project, retain Biome rather than adding Prettier; preserve hook configuration.
- `setup-ts-deep-modules`: assess the requested package boundary before changing
  dependency-cruiser or imports. Do not enforce this experimental architecture on
  an unrelated repository or rewrite its compiler configuration automatically.
- `migrate-to-shoehorn`: keep helpers in tests, verify the installed API and preserve
  meaningful validation/type checks; do not weaken production types.
- `scaffold-exercises`: apply course layout only to a requested course workspace;
  use its actual linter, and report missing course tooling instead of inventing proof.
- `loop-me`: plans workflow specifications; it does not deploy or schedule them.

## Refresh existing adaptations

Run the importer at a reviewed full commit SHA, then compare the previous pin's
source changes and reconcile each affected local owner. The importer prints affected
owners on subsequent refreshes and never overwrites authored adaptations. Review
new source capabilities against the branches above before using them. Regenerate
Claude/Codex discovery and run the import and prompt contract tests before delivery.
