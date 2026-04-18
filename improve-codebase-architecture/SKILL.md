---
name: improve-codebase-architecture
description: Explore codebase for architectural improvement. Focus testability via deepening shallow modules. Use when user want improve architecture, find refactoring opportunities, consolidate tightly-coupled modules, or make codebase more AI-navigable.
---

# Improve Codebase Architecture

Surface architectural friction, improve testability via module-deepening refactors -> GitHub issue RFCs.

**Deep module** = small interface, large implementation. More testable, more AI-navigable, test at boundary not inside.

## Process

### 1. Explore
Use Agent(subagent_type=Explore). Look for:
- One concept require bouncing between many files?
- Interface near as complex as implementation (shallow)?
- Pure functions extracted for testability, but real bugs in how called?
- Tightly-coupled modules create integration risk?
- Untested or hard-to-test areas?

### 2. Present Candidates
Numbered list: cluster of related modules, why coupled, dependency category, test impact. No interfaces yet.

### 3. User Picks

### 4. Frame Problem Space
Constraints any new interface must satisfy. Rough illustrative code sketch.

### 5. Design Interfaces
Spawn 3+ parallel sub-agents, different constraints each. Outputs: signature, usage, what hides, dependency strategy, trade-offs. Give own recommendation.

### 6. User Picks

### 7. Create GitHub Issue
Refactor RFC. See [REFERENCE.md](REFERENCE.md) for template and dependency categories.