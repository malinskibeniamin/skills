---
name: design-an-interface
description: Generate multiple radically different interface designs for a module using parallel sub-agents. Use when user wants to design an API, explore interface options, compare module shapes, or mentions "design it twice".
---

# Design an Interface

Based on "Design It Twice" from "A Philosophy of Software Design": your first idea is unlikely to be the best. Generate multiple radically different designs, then compare.

## Workflow

### 1. Gather Requirements

Before designing, understand:
- What problem does this module solve?
- Who are the callers? (other modules, external users, tests)
- What are the key operations?
- Any constraints? (performance, compatibility, existing patterns)
- What should be hidden inside vs exposed?

Ask: "What does this module need to do? Who will use it?"

### 2. Generate Designs (Parallel Sub-Agents)

Spawn 3+ sub-agents simultaneously using Agent tool. Each must produce a **radically different** approach.

Assign a different constraint to each agent:
- Agent 1: "Minimize method count — aim for 1-3 methods max"
- Agent 2: "Maximize flexibility — support many use cases"
- Agent 3: "Optimize for the most common case"
- Agent 4: "Take inspiration from [specific paradigm/library]"

Each agent outputs:
1. Interface signature (types/methods)
2. Usage example (how caller uses it)
3. What this design hides internally
4. Trade-offs of this approach

### 3. Present Designs

Show each design with interface signature, usage examples, and what it hides. Present sequentially so user can absorb each before comparison.

### 4. Compare Designs

Compare on:
- **Interface simplicity**: fewer methods, simpler params
- **General-purpose vs specialized**: flexibility vs focus
- **Implementation efficiency**: does shape allow efficient internals?
- **Depth**: small interface hiding significant complexity (good) vs large interface with thin implementation (bad)
- **Ease of correct use** vs **ease of misuse**

Discuss trade-offs in prose, not tables. Highlight where designs diverge most.

### 5. Synthesize

Often the best design combines insights from multiple options. Ask:
- "Which design best fits your primary use case?"
- "Any elements from other designs worth incorporating?"

## Anti-Patterns

- Enforce radical difference between sub-agent designs — similar designs waste the exercise
- Always compare — the value is in contrast
- This is purely about interface shape — do not implement
- Do not evaluate based on implementation effort
