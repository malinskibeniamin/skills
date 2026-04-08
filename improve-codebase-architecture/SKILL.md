---
name: improve-codebase-architecture
description: Explore a codebase to find opportunities for architectural improvement, focusing on making the codebase more testable by deepening shallow modules. Use when user wants to improve architecture, find refactoring opportunities, consolidate tightly-coupled modules, or make a codebase more AI-navigable.
---

# Improve Codebase Architecture

Explore a codebase, surface architectural friction, discover opportunities for improving testability, and propose module-deepening refactors as GitHub issue RFCs.

A **deep module** has a small interface hiding a large implementation. Deep modules are more testable, more AI-navigable, and let you test at the boundary instead of inside.

## Process

### 1. Explore the codebase

Use Agent tool with subagent_type=Explore. Look for friction:
- Where does understanding one concept require bouncing between many small files?
- Where are modules so shallow that the interface is nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called?
- Where do tightly-coupled modules create integration risk in the seams between them?
- Which parts of the codebase are untested, or hard to test?

### 2. Present candidates

Numbered list of deepening opportunities with: cluster of related modules, why they're coupled, dependency category, test impact. Do NOT propose interfaces yet.

### 3. User picks a candidate

### 4. Frame the problem space

Write constraints any new interface would need to satisfy. Include a rough illustrative code sketch.

### 5. Design multiple interfaces

Spawn 3+ sub-agents in parallel, each with a different design constraint. Each outputs: interface signature, usage example, what it hides, dependency strategy, trade-offs. Give your own recommendation.

### 6. User picks an interface

### 7. Create GitHub issue

Create a refactor RFC issue. See [REFERENCE.md](REFERENCE.md) for the issue template and dependency categories.
