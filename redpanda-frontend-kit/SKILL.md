---
name: redpanda-frontend-kit
description: Meta-skill that runs the generic frontend-starter-kit plus additional React skills and Redpanda-specific registry workflow. Use when bootstrapping a new Redpanda frontend project or setting up the full Redpanda frontend stack.
---

# Redpanda Frontend Kit

## What This Sets Up

Runs the generic **frontend-starter-kit** first, then adds additional React enforcement and Redpanda-specific tooling:

### Generic (via frontend-starter-kit)
1. **setup-toolchain** — Ban npm/npx/tsc, enforce bun + tsgo, block destructive commands
2. **setup-biome** — Biome + Ultracite with auto-fix hook
3. **setup-quality-gate** — quality:gate script, CI workflow, tsgo Stop hook, bundle guard
4. **setup-llm-optimization** — AI_AGENT=1, output truncation
5. **setup-react-compiler** — React Compiler + memoization check, compiler modes, derived-state detection
6. **setup-zustand** — Zustand best practices enforcement
7. **setup-accessibility** — ARIA enforcement, Playwright AXE, WCAG 2.1 AA
8. **setup-react-rules** — Ban raw HTML, TS escape hatches, XSS vectors, barrel imports, passive listeners, heavy dep warnings (useEffect ban via starter kit)
9. **setup-env-validation** — t3-env + zod, ban raw process.env access
10. **setup-conventional-commits** — Enforce type(scope): description commit format
11. **setup-react-doctor** — Health scoring with Stop hook
12. **setup-tanstack-router** — Route tree auto-generation + anti-pattern enforcement
13. **setup-connect-query** — ConnectRPC + Connect Query + Protobuf enforcement, Standard Schema + protovalidate
14. **setup-e2e-testing** — Playwright + Testcontainers + axe-core accessibility testing

### Diagnostics
15. **test-guardian** — Test health across frameworks, async leak detection

### Redpanda-specific
16. **setup-registry-workflow** — Redpanda UI registry component workflow

## Steps

### 1. Run frontend-starter-kit

This executes all 5 generic skills.

### 2. Run additional React skills

Execute setup-react-rules, setup-react-doctor, setup-tanstack-router, setup-connect-query in order.

For setup-connect-query, detect the protobuf version from `package.json` and install the appropriate variant (v1 or v2).

### 3. Configure Redpanda-specific environment

Set in the SessionStart hook (`.claude/hooks/session-env.sh`):

```bash
echo "export UI_LIB_DIRS=components/ui|redpanda-ui" >> "$CLAUDE_ENV_FILE"
```

Note: `REACT_RULES_BAN_USEEFFECT=1` is already set by the frontend-starter-kit.

Add a Chakra UI / legacy import ban to `.claude/hooks/react-rules-check.sh` (after the TypeScript escape hatches check):

```bash
# ── Redpanda: Ban Chakra UI / legacy imports ────────────────────
if echo "$added_lines" | grep -qE "from\s+['\"]@chakra-ui/"; then
  echo '{"suppressOutput":true,"systemMessage":"@chakra-ui/react is banned. Use shadcn/ui components from @/components/ui/ instead."}' >&2
  exit 2
fi
if echo "$added_lines" | grep -qE "from\s+['\"]@redpanda-data/ui['\"/]"; then
  echo '{"suppressOutput":true,"systemMessage":"@redpanda-data/ui is legacy (Chakra-based). Use redpanda-ui registry components instead."}' >&2
  exit 2
fi
```

### 4. Run Redpanda-specific skills

Execute setup-registry-workflow for Redpanda UI registry component workflow.

### 5. Final verification

- [ ] All `.claude/hooks/` scripts are executable
- [ ] `.claude/settings.json` has all hooks (including zustand-check, tanstack-router-check, connect-query-check)
- [ ] `biome.jsonc` exists
- [ ] `react-doctor.config.json` exists
- [ ] All package.json scripts present: `lint`, `lint:fix`, `type:check`, `test`, `quality:gate`, `doctor`, `generate:routes`
- [ ] connect-query-check.sh matches the detected protobuf version (v1 or v2)

### 6. Commit

Stage everything and commit: `Bootstrap Redpanda frontend kit`
