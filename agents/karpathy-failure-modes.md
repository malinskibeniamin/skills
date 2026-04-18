# LLM Failure Modes — Self-Check Before Done

Required reading for `code-reviewer`, `adversarial-reviewer`, `self-reviewer`.

Based on observed LLM-coding pathologies (Karpathy, et al). Run every item before declaring work complete. Each mode: problem, mitigation, verification command.

---

## 1. Hallucinated APIs

**Problem**: Model invents a function, method, import, or package that does not exist. Confident signature, no implementation.

**Mitigation**: Before calling any symbol you did not write this session, grep for its definition in the repo or `node_modules`. Read the actual export. Do not trust recall.

**Verify**:
```
rg -n "export (function|const|class) <symbol>" src/ node_modules/<pkg>/
```

---

## 2. Confident Wrong Types

**Problem**: Types compile in your head but runtime shape differs. Stale API version. Off-by-one in enum or index. Optional treated as required.

**Mitigation**: Run `tsgo` on every edit. Run the actual test, not a mental simulation. If the type was inferred from a schema, re-fetch the schema.

**Verify**:
```
bun run type:check && bun test path/to/affected.test.ts
```

---

## 3. Unvalidated LLM Shapes

**Problem**: JSON from another LLM call (sub-agent, tool response, user-pasted) passed directly into typed code. No zod, no guard.

**Mitigation**: Every LLM-origin payload goes through a zod parser before touching typed code. `z.object(...).parse(raw)` — not `as T`.

**Verify**:
```
rg "JSON.parse" src/ | rg -v "\.parse\("
```

---

## 4. SSRF via URL Fetch

**Problem**: User-supplied or LLM-supplied URL fetched without origin allowlist. Internal metadata endpoints exposed. `localhost`, `169.254.*`, `file://`, `gopher://`, redirect chains.

**Mitigation**: Allowlist scheme (https only), allowlist host (or denylist private ranges), cap redirects, cap response size.

**Verify**:
```
rg "fetch\(|axios\.|got\(|request\(" src/ | rg -v "allowlist|validateUrl"
```

---

## 5. Silent Fallbacks

**Problem**: `catch { return null }`, `catch { return [] }`, or `try { ... } catch {}`. Swallows the real error. User sees empty UI, you see nothing in logs.

**Mitigation**: Every catch: set error state, re-throw typed, or call error handler. Log at decision point with `requestId`. Show user the failure.

**Verify**:
```
rg "catch\s*\([^)]*\)\s*\{\s*(return|\}|//)" src/
```

---

## 6. Stale Memory

**Problem**: Model cites a fact (file path, function signature, config key) that was true earlier in session or earlier in repo history but is now wrong. File moved, symbol renamed, schema changed.

**Mitigation**: Before citing a path or symbol from memory, re-read it. `git status` and `git log --oneline -20` before trusting your own context.

**Verify**:
```
git log --oneline --since="1 day ago" -- <file-you-plan-to-cite>
```

---

## 7. Mock != Prod

**Problem**: Unit tests pass with mocked DB/API/queue. Integration path has real driver, real migration, real serialization — breaks on deploy.

**Mitigation**: At least one integration test per seam exercises real driver against ephemeral service. Mock at edge, not middle. Verify migration runs forward and backward.

**Verify**:
```
rg "vi\.mock|createRouterTransport" test/ | wc -l
bun test --run e2e/
```

---

## Machine-Readable Checklist

Agents iterate this array. Each item has `id`, `check`, `command`, `severity`.

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "checks": [
    { "id": "hallucinated-api",      "check": "Every external symbol grep-verified in repo or node_modules", "command": "rg -n 'export (function|const|class) <symbol>'", "severity": "CRITICAL" },
    { "id": "confident-wrong-types", "check": "tsgo clean AND affected test executed",                        "command": "bun run type:check && bun test <path>",          "severity": "CRITICAL" },
    { "id": "unvalidated-llm-shape", "check": "All LLM-origin JSON passed through zod .parse()",              "command": "rg 'JSON.parse' src/",                           "severity": "HIGH" },
    { "id": "ssrf-url-fetch",        "check": "URL fetches have scheme+host allowlist and redirect cap",      "command": "rg 'fetch\\(|axios\\.|got\\(' src/",              "severity": "CRITICAL" },
    { "id": "silent-fallback",       "check": "No empty catch blocks; every catch sets state or rethrows",    "command": "rg 'catch\\s*\\([^)]*\\)\\s*\\{\\s*(return|\\}|//)' src/", "severity": "HIGH" },
    { "id": "stale-memory",          "check": "Cited paths/symbols re-read in current session",                "command": "git log --oneline --since='1 day ago' -- <file>", "severity": "MEDIUM" },
    { "id": "mock-vs-prod",          "check": "At least one integration test per seam hits real driver",      "command": "bun test --run e2e/",                            "severity": "HIGH" }
  ]
}
```

---

## Usage in Reviewer Agents

Each reviewer MUST include in its output JSON:

```json
"karpathy_checks": {
  "hallucinated-api": "pass|fail|n/a",
  "confident-wrong-types": "pass|fail|n/a",
  "unvalidated-llm-shape": "pass|fail|n/a",
  "ssrf-url-fetch": "pass|fail|n/a",
  "silent-fallback": "pass|fail|n/a",
  "stale-memory": "pass|fail|n/a",
  "mock-vs-prod": "pass|fail|n/a"
}
```

A `fail` on any `CRITICAL` item blocks the review from returning `status: APPROVED`.
