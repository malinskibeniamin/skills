# Reference

## Dependency Categories

1. **In-process**: Pure computation, no I/O. Always deepenable.
2. **Local-substitutable**: Dependencies with local test stand-ins (e.g., PGLite for Postgres).
3. **Remote but owned (Ports & Adapters)**: Your own services across a network boundary. Define a port interface.
4. **True external (Mock)**: Third-party services you don't control. Mock at the boundary.

## Testing Strategy

Core principle: **replace, don't layer.**
- Old unit tests on shallow modules are waste once boundary tests exist — delete them
- Write new tests at the deepened module's interface boundary
- Tests assert on observable outcomes through the public interface

## Issue Template

    ## Problem
    Describe the architectural friction.

    ## Proposed Interface
    The chosen interface design with signature, usage example, and what it hides.

    ## Dependency Strategy
    Which category applies and how dependencies are handled.

    ## Testing Strategy
    New boundary tests to write, old tests to delete, test environment needs.

    ## Implementation Recommendations
    Durable architectural guidance NOT coupled to current file paths.
