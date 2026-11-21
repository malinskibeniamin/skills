# Decision deltas

Use for substantial implementation or handoff when the agent made a consequential
choice the request or accepted plan did not settle: scope, persistent data, an API
contract, dependency, external cost, security boundary or rollout behavior. Skip
internal naming, cosmetic discretion and choices explicitly delegated to the agent.

## Audit the gap

Compare the original request, accepted decisions and outcome contract with the actual
diff and behavior. Self-reported uncertainty is a lead, not the whole audit. Surface
material discoveries immediately; do not hold them until closeout.

For each material delta, state:

- **Choice and gap:** what the agent chose and what was unspecified. Distinguish
  user decisions from agent assumptions; never invent user approval.
- **Consequence:** one concrete scenario, the meaningful alternative, and what
  future callers or work now inherit.
- **Evidence and disposition:** source/check, why this choice fits, and whether
  to retain it, correct it, or ask its owner. For a reversible assumption, name
  how to undo it; identify unresolved uncertainty without guessing confidence scores.

Reuse the existing checkpoint, intent map or PR's changed-decisions section. Keep
one current account, not a second mandatory ledger. Consolidate superseded choices
against the final code; preserve consequential rationale at its existing durable owner.

Repeated deltas in one area signal an underspecified slice: re-plan that slice before
widening the patch. At completion, reconcile consequential accepted decisions with
implemented behavior and verification, or explicitly state why no code was needed.
A finished task list alone cannot account for an agreed requirement with no owner.

## Boundaries

This audit supplements code review and tests; it replaces neither. A sound choice is
not evidence of implemented behavior. Correct unsupported choices within authorized
scope; genuinely user-reserved or irreversible decisions still pause their branch.
Silence, a recorded assumption or model agreement never grants approval. Read-only
reviews return findings without changing code, plans or publication state.

Adapted from [dzhng's decision audit](https://github.com/dzhng/skills/blob/873aba8d6331976f92052f54513076abd1ae629f/skills/review/audit-decisions/SKILL.md)
and [completion reconciliation](https://github.com/dzhng/skills/blob/873aba8d6331976f92052f54513076abd1ae629f/skills/implement/implement-spec/SKILL.md).
These references grant no upstream workflow, delegation or configuration permission.
