# LLM Failure Modes -- Self-Check Before Done

Required reading for `code-reviewer`, `adversarial-reviewer`, `self-reviewer`.

Based on observed LLM-coding pathologies (Karpathy, et al). Run every item before declaring work complete. Each mode: problem, mitigation, verification command.

First 7 modes = single-agent coding failures. Second tier (modes 8-21) = **Multi-Agent System Failure Taxonomy (MAST)** from Cemri et al., NeurIPS 2025 -- covers failures in agent + subagent orchestration (relevant when reviewer spawns sub-reviewers, lifecycle agent spawns phase subagents, or `grill-me` runs multi-turn debate).

---

## 1. Hallucinated APIs

**Problem**: Model invents function, method, import, or package that doesn't exist. Confident signature, no implementation.

**Mitigation**: Before calling any symbol not written this session, grep for definition in repo or `node_modules`. Read actual export. Don't trust recall.

**Verify**:
```
rg -n "export (function|const|class) <symbol>" src/ node_modules/<pkg>/
```

---

## 2. Confident Wrong Types

**Problem**: Types compile in head but runtime shape differs. Stale API version. Off-by-one in enum or index. Optional treated as required.

**Mitigation**: Run `tsgo` every edit. Run actual test, not mental simulation. If type inferred from schema, re-fetch schema.

**Verify**:
```
bun run type:check && bun test path/to/affected.test.ts
```

---

## 3. Unvalidated LLM Shapes

**Problem**: JSON from another LLM call (sub-agent, tool response, user-pasted) passed directly into typed code. No zod, no guard.

**Mitigation**: Every LLM-origin payload through zod parser before touching typed code. `z.object(...).parse(raw)` -- not `as T`.

**Verify**:
```
rg "JSON.parse" src/ | rg -v "\.parse\("
```

---

## 4. SSRF via URL Fetch

**Problem**: User- or LLM-supplied URL fetched without origin allowlist. Internal metadata endpoints exposed. `localhost`, `169.254.*`, `file://`, `gopher://`, redirect chains.

**Mitigation**: Allowlist scheme (https only), allowlist host (or denylist private ranges), cap redirects, cap response size.

**Verify**:
```
rg "fetch\(|axios\.|got\(|request\(" src/ | rg -v "allowlist|validateUrl"
```

---

## 5. Silent Fallbacks

**Problem**: `catch { return null }`, `catch { return [] }`, or `try { ... } catch {}`. Swallows real error. User sees empty UI, you see nothing in logs.

**Mitigation**: Every catch: set error state, re-throw typed, or call error handler. Log at decision point with `requestId`. Show user failure.

**Verify**:
```
rg "catch\s*\([^)]*\)\s*\{\s*(return|\}|//)" src/
```

---

## 6. Stale Memory

**Problem**: Model cites fact (file path, function signature, config key) true earlier in session or repo history but now wrong. File moved, symbol renamed, schema changed.

**Mitigation**: Before citing path or symbol from memory, re-read. `git status` and `git log --oneline -20` before trusting own context.

**Verify**:
```
git log --oneline --since="1 day ago" -- <file-you-plan-to-cite>
```

---

## 7. Mock != Prod

**Problem**: Unit tests pass with mocked DB/API/queue. Integration path has real driver, real migration, real serialization -- breaks on deploy.

**Mitigation**: At least one integration test per seam hits real driver against ephemeral service. Mock at edge, not middle. Verify migration runs forward + backward.

**Verify**:
```
rg "vi\.mock|createRouterTransport" test/ | wc -l
bun test --run e2e/
```

---

---

# Multi-agent orchestration audits

Reviewing a session that orchestrated subagents (lifecycle agents, grill fan-out,
resolve-pr-feedback, swarm)? Read [references/mast-failure-modes.md](./references/mast-failure-modes.md)
for the MAST taxonomy and its `mast_checks` output block. Skip it for ordinary diffs.

## Machine-Readable Checklist

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "checks": [
    { "id": "hallucinated-api",      "check": "Every external symbol grep-verified in repo or node_modules", "command": "rg -n 'export (function|const|class) <symbol>'", "severity": "CRITICAL", "scope": "single-agent" },
    { "id": "confident-wrong-types", "check": "tsgo clean AND affected test executed",                        "command": "bun run type:check && bun test <path>",          "severity": "CRITICAL", "scope": "single-agent" },
    { "id": "unvalidated-llm-shape", "check": "All LLM-origin JSON passed through zod .parse()",              "command": "rg 'JSON.parse' src/",                           "severity": "HIGH",     "scope": "single-agent" },
    { "id": "ssrf-url-fetch",        "check": "URL fetches have scheme+host allowlist and redirect cap",      "command": "rg 'fetch\\(|axios\\.|got\\(' src/",              "severity": "CRITICAL", "scope": "single-agent" },
    { "id": "silent-fallback",       "check": "No empty catch blocks; every catch sets state or rethrows",    "command": "rg 'catch\\s*\\([^)]*\\)\\s*\\{\\s*(return|\\}|//)' src/", "severity": "HIGH", "scope": "single-agent" },
    { "id": "stale-memory",          "check": "Cited paths/symbols re-read in current session",                "command": "git log --oneline --since='1 day ago' -- <file>", "severity": "MEDIUM",  "scope": "single-agent" },
    { "id": "mock-vs-prod",          "check": "At least one integration test per seam hits real driver",      "command": "bun test --run e2e/",                            "severity": "HIGH",     "scope": "single-agent" }
  ]
}
```

---

---

## Usage in Reviewer Agents

Each reviewer MUST include in output JSON:

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

`fail` on any `CRITICAL` Karpathy item blocks review from returning `status: APPROVED`.

## References

- Karpathy tier: observed single-agent LLM coding pathologies, crystallized from repeated failures in production.
- MAST tier: Cemri M., Pan M., Yang S. et al. *Why Do Multi-Agent LLM Systems Fail?* NeurIPS 2025 Track on Datasets and Benchmarks. arXiv:2503.13657 (285 citations, 48 influential, as of 2026-04). Dataset: huggingface.co/datasets/mcemri/MAST-Data. Code: github.com/multi-agent-systems-failure-taxonomy/MAST.
