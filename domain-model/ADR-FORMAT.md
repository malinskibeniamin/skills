# ADR Format

ADRs live in `docs/adr/` with sequential numbering: `0001-slug.md`, `0002-slug.md`.

Create `docs/adr/` lazily — only when first ADR needed.

## Template

```md
# {Short title of the decision}

{1-3 sentences: what's the context, what did we decide, and why.}
```

That's it. Most ADRs = single paragraph. Value = recording *that* a decision was made and *why*.

## Optional Sections

Only include when genuinely valuable:

- **Status** frontmatter (`proposed | accepted | deprecated | superseded by ADR-NNNN`)
- **Considered Options** — only when rejected alternatives worth remembering
- **Consequences** — only when non-obvious downstream effects

## When to Offer an ADR

ALL three must be true:

1. **Hard to reverse** — cost of changing mind later is meaningful
2. **Surprising without context** — future reader will wonder "why on earth?"
3. **Result of real trade-off** — genuine alternatives existed, picked one for specific reasons

Easy to reverse → skip. Not surprising → skip. No real alternative → skip.

### What Qualifies

- **Architectural shape.** "Monorepo." "Write model is event-sourced, read model projected into Postgres."
- **Integration patterns.** "Ordering and Billing communicate via domain events, not HTTP."
- **Technology with lock-in.** Database, message bus, auth provider. Not every library — only quarter-to-swap ones.
- **Boundary decisions.** "Customer data owned by Customer context; others reference by ID only."
- **Deliberate deviations.** "Manual SQL instead of ORM because X." Stops next engineer from "fixing" something deliberate.
- **Invisible constraints.** "Can't use AWS — compliance." "Response times under 200ms — partner API contract."
- **Non-obvious rejections.** Considered GraphQL, picked REST for subtle reasons → record it.

## Numbering

Scan `docs/adr/` for highest existing number, increment by one.
