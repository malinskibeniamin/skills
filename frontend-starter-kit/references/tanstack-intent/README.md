# TanStack Intent setup

For the full profile, complete the canonical [TanStack Intent setup](../../../tanstack-intent/SETUP.md)
after installing TanStack dependencies. This configures the `@tanstack/*` allowlist,
explicit task mappings, and official Claude/Codex edit gates.

## Verify

- `bunx @tanstack/intent@latest list --json` reports installed package versions and skills.
- Agent configuration contains Intent's managed mapping and hook blocks.
