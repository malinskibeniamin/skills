# Codex Compatibility Reference

## codex-batch-check.sh

Stop hook wrapper that runs all PostToolUse Edit|Write checks on changed files.
Reuses the existing `.claude/hooks/` scripts — no duplication.

> Script: [`scripts/codex-batch-check.sh`](scripts/codex-batch-check.sh)

## .codex/hooks.json template

Generate this from the existing `.claude/settings.json`. Copy PreToolUse Bash, SessionStart, and Stop hooks directly. Add the batch checker as a Stop hook.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/enforce-toolchain.sh",
            "statusMessage": "Checking toolchain..."
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/session-env.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": ".codex/hooks/codex-batch-check.sh",
            "statusMessage": "Running code quality checks on changed files..."
          }
        ]
      }
    ]
  }
}
```

**Notes:**
- PreToolUse Bash hooks work identically on Codex (same JSON format, same `permissionDecision` output)
- SessionStart hooks work identically on Codex
- Stop hooks work identically on Codex (`decision: "block"` continues the turn)
- PostToolUse Edit|Write hooks are NOT in `.codex/hooks.json` — the batch checker handles them

## AGENTS.md template

Generate this at the repo root. It provides soft guidance for rules that Codex can't enforce via hooks.

```markdown
# Project Rules

## Toolchain

- Use `bun` as package manager (not npm/npx)
- Use `tsgo` for type checking (not tsc)
- Always use `--yarn` flag with `bun install` / `bun add`
- Do not install eslint or prettier (this project uses Biome)
- Do not use `rm -rf` except for: node_modules, dist, .next, build, .cache, .turbo, coverage
- Do not use `git push --force` (use `--force-with-lease`)
- Do not use `git reset --hard`

## Code Quality

- Run `bun run lint:fix` before finishing
- Run `bun run type:check` before finishing
- Do not add heavy dependencies to production: moment (use date-fns), lodash (use lodash-es), jquery, core-js, classnames (use clsx)

## React Rules

- Do not use `useEffect` / `useLayoutEffect` / `useInsertionEffect` — use React Query, zustand, or event handlers
- Do not use `dangerouslySetInnerHTML` without DOMPurify
- Do not use `eval()` or `new Function()`
- Do not assign `.innerHTML` directly
- Do not use `as any`, `@ts-ignore`, or `@ts-expect-error`
- Do not remove focus outlines (`outline: none`)
- Do not use manual `useMemo` / `useCallback` / `React.memo` (React Compiler handles this)

## Accessibility

- All `<img>` must have `alt` attribute
- Clickable `<div>` / `<span>` must have `role`, `tabIndex`, and keyboard handler
- `role="combobox"` requires `aria-expanded` and `aria-controls`
- `role="dialog"` requires `aria-label` or `aria-labelledby`
- `role="tablist"` requires child `role="tab"` elements

## Zustand

- Use `create<T>()()` double-parens (not `create<T>()`)
- Use `useShallow` for multi-value selectors
- Use `persist` middleware instead of direct localStorage

## State & Data

- Use zustand for client state, TanStack Query for server state
- Do not use raw `useQuery` / `useMutation` when ConnectRPC is available
```

Customize the AGENTS.md based on which skills are actually installed in the project. Only include sections for installed hooks.
