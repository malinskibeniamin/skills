---
name: design-an-interface
description: Generate multiple radically different interface designs for a module using parallel sub-agents. Use when user wants to design an API, explore interface options, compare module shapes, or mentions "design it twice".
---

# Design an Interface

"Design It Twice" (A Philosophy of Software Design): first idea rarely best. Generate radically different designs, compare.

## Workflow

### 1. Gather Requirements
- What problem? Who calls it? Key operations? Constraints? What hidden vs exposed?
- Ask: "What does this module need to do? Who will use it?"

### 2. Generate Designs (Parallel Sub-Agents)
Spawn 3+ agents simultaneously. Each **radically different** approach with different constraint:
- Agent 1: minimize method count (1-3 max)
- Agent 2: maximize flexibility
- Agent 3: optimize for common case
- Agent 4: inspiration from [specific paradigm]

Each outputs: interface signature, usage example, what it hides, trade-offs.

### 3. Present Designs
Show sequentially: signature, usage, what it hides. Let user absorb each before comparison.

### 4. Compare
- Interface simplicity (fewer methods, simpler params)
- General-purpose vs specialized
- Implementation efficiency
- Depth: small interface hiding complexity (good) vs large interface thin impl (bad)
- Ease of correct use vs ease of misuse

Discuss in prose, not tables. Highlight divergence points.

### 5. Synthesize
Best design often combines insights. Ask: "Which fits your case? Any elements from others worth incorporating?"

## Anti-Patterns
- Similar designs waste exercise -- enforce radical difference
- Always compare -- value in contrast
- Interface shape only -- no implement
- Ignore implementation effort in evaluation