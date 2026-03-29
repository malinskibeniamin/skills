# Codex Compatibility Reference

## codex-batch-check.sh

Stop hook wrapper that runs all PostToolUse Edit|Write checks on changed files.
Reuses the existing `.claude/hooks/` scripts — no duplication.

```bash
#!/bin/bash
set -euo pipefail

# Stop hook for Codex: batch-run all PostToolUse Edit|Write checks on changed files.
# Codex doesn't support Edit|Write matchers, so we run them at Stop instead.

# Find all changed JS/TS files
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
changed_files=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(js|jsx|ts|tsx|mjs|mts|cjs|cts)$' || true)

if [ -z "$changed_files" ]; then
  exit 0
fi

# Also check package.json changes (for bundle-guard)
changed_pkg=$(git diff --name-only HEAD 2>/dev/null | grep -E 'package\.json$' || true)

# Collect all PostToolUse hook scripts from .claude/hooks/
hooks_dir="$repo_root/.claude/hooks"
if [ ! -d "$hooks_dir" ]; then
  exit 0
fi

errors=""

# Run each PostToolUse hook on each changed file
for file in $changed_files; do
  abs_path="$repo_root/$file"
  [ -f "$abs_path" ] || continue

  for hook in "$hooks_dir"/*-check.sh; do
    [ -x "$hook" ] || continue
    hook_name=$(basename "$hook")

    # Skip hooks that aren't PostToolUse Edit|Write checks
    case "$hook_name" in
      *-check.sh) ;; # react-rules-check, accessibility-check, zustand-check, etc.
      *) continue ;;
    esac

    # Simulate a Write tool call JSON — same format the hooks expect
    input="{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$abs_path\"}}"

    hook_stderr=""
    hook_exit=0
    hook_stderr=$(echo "$input" | "$hook" 2>&1 >/dev/null) || hook_exit=$?

    if [ $hook_exit -ne 0 ] && [ -n "$hook_stderr" ]; then
      # Extract the systemMessage from the JSON output
      msg=$(echo "$hook_stderr" | grep -o '"systemMessage":"[^"]*"' | head -1 | sed 's/"systemMessage":"//;s/"$//' || true)
      if [ -n "$msg" ]; then
        errors="$errors\n[$hook_name] $file: $msg"
      fi
    fi
  done
done

# Run bundle-guard on changed package.json files
if [ -n "$changed_pkg" ]; then
  for pkg in $changed_pkg; do
    abs_path="$repo_root/$pkg"
    [ -f "$abs_path" ] || continue

    bundle_guard="$hooks_dir/bundle-guard.sh"
    if [ -x "$bundle_guard" ]; then
      input="{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$abs_path\"}}"
      hook_stderr=""
      hook_exit=0
      hook_stderr=$(echo "$input" | "$bundle_guard" 2>&1 >/dev/null) || hook_exit=$?

      if [ $hook_exit -ne 0 ] && [ -n "$hook_stderr" ]; then
        msg=$(echo "$hook_stderr" | grep -o '"systemMessage":"[^"]*"' | head -1 | sed 's/"systemMessage":"//;s/"$//' || true)
        if [ -n "$msg" ]; then
          errors="$errors\n[bundle-guard] $pkg: $msg"
        fi
      fi
    fi
  done
fi

if [ -n "$errors" ]; then
  truncated=$(printf '%b' "$errors" | head -30)
  escaped=$(printf '%s' "$truncated" | jq -Rs .)
  echo "{\"decision\":\"block\",\"reason\":\"Code quality checks found issues. Fix these before finishing:\\n\"$escaped\"\"}" >&2
  exit 2
fi

exit 0
```

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
