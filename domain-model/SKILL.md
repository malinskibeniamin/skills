---
name: domain-model
description: "Grilling session that challenges plans against the project's domain model, sharpens terminology, and updates documentation (CONTEXT.md, ADRs) inline as decisions crystallize. Use when user wants to stress-test a plan, define ubiquitous language, create ADRs, or mentions 'domain model'."
---

# Domain Model

Interview relentlessly about every aspect of plan until shared understanding reached. Walk each branch of design tree, resolve dependencies one-by-one. Each question, give recommended answer.

Ask one at a time. If answerable by codebase exploration, explore instead.

## Light DDD -- Document, Don't Prescribe

USE: Ubiquitous Language | Bounded Contexts | ADRs
SKIP: Entities | Value Objects | Aggregates | Domain Events

Goal = "just enough docs" to make codebase navigable. Language into software, not patterns into software.

## Domain Awareness

During codebase exploration, look for existing docs:

### Single context (most repos)

    /
    ├── CONTEXT.md
    ├── docs/adr/
    │   ├── 0001-event-sourced-orders.md
    │   └── 0002-postgres-for-write-model.md
    └── src/

### Multi-context (if CONTEXT-MAP.md exists at root)

    /
    ├── CONTEXT-MAP.md
    ├── docs/adr/                    <- system-wide decisions
    ├── src/
    │   ├── ordering/
    │   │   ├── CONTEXT.md
    │   │   └── docs/adr/            <- context-specific decisions
    │   └── billing/
    │       ├── CONTEXT.md
    │       └── docs/adr/

Create files lazily -- only when first term resolved or first ADR needed.

## During Session

**Challenge glossary**: Term conflicts with CONTEXT.md? Call out now.

**Sharpen language**: Vague or overloaded term? Propose precise canonical term. "You say 'account' -- Customer or User? Different things."

**Concrete scenarios**: Stress-test relationships with edge cases. Force precision on boundaries.

**Cross-reference code**: User states how something works -> verify code agrees. Surface contradictions.

**Update CONTEXT.md inline**: Term resolved -> update now. No batch. See [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md).

**Offer ADRs sparingly**: Only when ALL three true: hard to reverse, surprising without context, result of real trade-off. See [ADR-FORMAT.md](ADR-FORMAT.md).