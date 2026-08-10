# Architecture lenses

Use this reference while exploring candidates. The output remains the report defined in
`HTML-REPORT.md`.

## Error-prevention lenses

| Smell | Architectural direction |
|---|---|
| Two lists must stay synchronized | derive both behaviors from one owned representation |
| Validation repeats at every caller | parse or construct one validated domain type |
| Flags permit illegal combinations | represent valid states as a state machine or union |
| Callers repeat one sequence | absorb the sequence behind a deep module interface |
| Policy is copied across adapters | own policy in one module; adapters only translate |
| Helpers test green while choreography fails | move choreography behind the tested interface |

Trace reads, writes, transitions, retries, and recovery. A candidate must name the error class,
show the path that permits it, and identify the owner that will preserve the target invariant.

## Dependency categories

1. **In-process:** pure computation; usually safe to absorb.
2. **Local-substitutable:** dependency has a faithful local adapter.
3. **Remote but owned:** use a port only when production and test adapters both exist.
4. **External:** keep translation and failure policy at one narrow seam.

## Reject candidates that

- move checks without changing representation or ownership
- add a wrapper whose interface matches its implementation
- invent a seam for one adapter
- centralize unrelated behavior
- depend on a hypothetical future caller
- cannot migrate through a reversible slice

## Tests and migration

Tests verify observable outcomes at the deepened interface. Replace helper-level tests only when
the new interface covers their meaningful behavior. The migration plan names expand, migrate, and
contract steps; compatibility checks; rollback; and the point where old representations disappear.
