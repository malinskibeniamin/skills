---
name: systematic-debugging
description: "Use when fixing bugs, investigating errors, debugging crashes, or triaging issues. 4-phase root cause analysis: reproduce → analyze → hypothesize → fix at source. Never fix symptoms."
---

# Systematic Debugging

## Iron Law

**No fixes without root cause investigation first.**

Never fix the symptom. Never add a workaround. Find where the invalid data originated and fix it there.

## Four Phases

### 1. Reproduce — Make it fail consistently

- Read the error message carefully (the FULL message)
- Write a failing test that demonstrates the bug
- Check `git log` for recent changes near the failure
- If intermittent: gather diagnostic evidence, check timing assumptions

### 2. Analyze — Find working examples

- Find similar working code in the same codebase
- Read the reference implementation COMPLETELY
- Identify what differs between working and broken
- Trace data flow: where does the invalid data originate?

### 3. Hypothesize — Form and test ONE theory

- State clearly: "I think X is the root cause because Y"
- Test the hypothesis (add logging, change one variable)
- If wrong: update hypothesis, don't add workarounds
- If right: proceed to fix

### 4. Fix — At the source, with defense-in-depth

- Fix where the invalid data ORIGINATES, not where it crashes
- Add a test that would have caught this
- Consider defense-in-depth: validate at multiple layers
- Run the full related test suite to check for regressions

See [REFERENCE.md](REFERENCE.md) for root cause tracing, defense-in-depth layers, and rationalization counters.
