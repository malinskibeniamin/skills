# TanStack Intent setup

Complete this after the project's TanStack dependencies are installed.

## 1. Trust TanStack package skills

Merge the allowlist into the nearest workspace `package.json`:

```json
{
  "intent": {
    "skills": ["@tanstack/*"]
  }
}
```

Keep narrower existing entries when the repository intentionally trusts only selected
TanStack packages.

## 2. Install guidance and enforcement

```bash
bunx @tanstack/intent@latest install --map
bunx @tanstack/intent@latest hooks install --scope project --agents claude,codex
```

`install --map` writes explicit task mappings while preserving content outside its managed
block. The official hooks expose the available catalog and keep the edit gate active until
matching full guidance loads.

## 3. Verify

```bash
bunx @tanstack/intent@latest list --json
```

- Every installed TanStack framework appears under `packages` with its actual version.
- Relevant task guidance appears under `skills` with a loadable `use` id.
- Agent config contains the managed Intent block and project hooks.

Rerun `install --map` after adding another Intent-enabled package. Package upgrades bring
their version-matched skills with them; verify the new catalog before using changed APIs.
