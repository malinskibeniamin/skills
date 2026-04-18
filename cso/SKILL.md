---
name: cso
description: "Use when preparing to ship a PR (after /simplify, before /commit-push-pr) to run a pre-ship security audit on the current diff using OWASP Top 10 + STRIDE. Blocks ship on CRITICAL findings."
---

# CSO — Pre-Ship Security Audit

OWASP Top 10 + STRIDE over current PR diff. Block ship on CRITICAL.

## Input

`$ARGUMENTS`: empty (audit current diff) or PR number.

## Workflow

### 1. Capture Diff
`git diff origin/main...HEAD` → changed files + hunks. Large diff → batch per file.

### 2. OWASP Top 10 Pass

Per category, read diff + flag risk. Skip categories with zero surface in diff.

| Code | Category | Look For |
|---|---|---|
| A01 | Broken access control | missing authz check, IDOR, path traversal |
| A02 | Crypto failures | weak algo, hardcoded key, plaintext secret |
| A03 | Injection | SQL/NoSQL/LDAP/OS/template concat, unsanitized input |
| A04 | Insecure design | missing rate limit, no lockout, trust-client |
| A05 | Security misconfig | default creds, verbose errors, open CORS |
| A06 | Vulnerable deps | new pkg → check advisory db |
| A07 | Auth failures | weak session, no MFA path, token in URL |
| A08 | Integrity failures | unsigned update, untrusted deserialization |
| A09 | Logging failures | no audit log on auth/authz, PII in logs |
| A10 | SSRF | user-controlled URL fetched server-side |

### 3. STRIDE Pass

| Letter | Threat | Diff Signal |
|---|---|---|
| S | Spoofing | identity assumed, not verified |
| T | Tampering | mutable without integrity check |
| R | Repudiation | no audit trail on state change |
| I | Info disclosure | data leaks via error/response/log |
| D | DoS | unbounded loop, regex catastrophic, no timeout |
| E | Elevation | privilege check missing or late |

### 4. Finding Table

    | Sev | Cat | File:Line | Issue | Fix |
    |---|---|---|---|---|
    | CRITICAL | A03 | x.ts:42 | raw concat in query | parameterize |
    | HIGH | STRIDE-I | y.ts:17 | stack in 500 resp | generic msg |

Severity: CRITICAL (RCE/auth bypass/secret leak) · HIGH (exploit w/ context) · MED (hardening) · LOW (defense-in-depth).

### 5. Gate

Any CRITICAL → **BLOCK ship**. Print findings + remediation. Exit non-zero.

HIGH+ → require user ack before proceeding.

### 6. Escape Hatch

Line comment `// allow: security-review [reason]` on flagged line → skip that finding. Reason mandatory. Logged to PR summary.

## Output

Markdown table + per-finding remediation snippet. No file edits — plan only.

## Scope

Diff only. Pre-existing issues out of scope (note briefly, don't block).
