# Systematic Debugging Reference

## Root Cause Tracing

1. Observe the symptom (error message, wrong output)
2. Find the immediate cause (which line crashes?)
3. Ask: "What called this with bad data?"
4. Trace up the call chain
5. Find where the invalid data ORIGINATED
6. Fix at the source — not at the crash site

## Defense-in-Depth: 4 Validation Layers

After fixing a bug, add validation at multiple layers to make it structurally impossible to recur:

| Layer | Purpose | Example |
|---|---|---|
| Entry point | Reject obviously invalid input | API validates request body |
| Business logic | Ensure data makes sense for operation | Check `projectDir` is non-empty before `path.join` |
| Environment guards | Prevent dangerous operations in context | `if (NODE_ENV === 'production') throw` |
| Debug instrumentation | Capture context for forensics | `console.assert(id, 'Missing ID at createUser')` |

## Common Agent Excuses

| Excuse | Counter |
|---|---|
| "Quick fix is fine for now" | Quick fixes become permanent. Fix the root cause. |
| "I can't reproduce it" | Add logging, check timing, look at the full stack trace. |
| "It's probably a race condition" | "Probably" isn't evidence. Prove it with a test. |
| "Let me just add a null check" | Null checks at the crash site hide the bug upstream. |
| "The error message is misleading" | Read it again, carefully. It usually says exactly what's wrong. |
