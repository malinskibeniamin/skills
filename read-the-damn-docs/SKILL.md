---
name: read-the-damn-docs
description: Use for third-party APIs, libraries, frameworks, CLIs, cloud services, SDKs, fast-moving behavior, current/latest/official answers, API drift errors, auth, billing, security, privacy, migrations, deploys, or data behavior.
---

# Read The Damn Docs

Repo/code changes: run `/deslop` before commit, push, PR, or merge.
Read `references/builder-upstream.md` for the complete docs-first trigger list.

Do not guess where authoritative docs can answer the question.

## Required workflow

1. Identify the exact surface: package, version, endpoint, CLI, config, local helper, schema, or product behavior.
2. Read local repo docs/specs/ADRs/generated types first when they define the contract.
3. For third-party or fast-moving behavior, search current official docs and open the relevant API reference, migration guide, changelog, release notes, SDK source, or type definitions.
4. Extract only facts needed: option names, imports, lifecycle rules, defaults, breaking changes, limits, permissions, examples.
5. Apply the docs to the code. Do not cargo-cult examples that conflict with repo patterns.
6. Cite sources in research notes or final answer when docs facts matter.

## Strong triggers

- User says latest, current, official, supported, best practice, today, now, or look it up.
- Adding, upgrading, configuring, or importing packages, SDKs, models, providers, plugins, or CLIs.
- Errors mention deprecation, unknown options, missing exports, invalid config, unsupported fields, or version mismatch.
- Decisions are expensive to reverse: public wire formats, database schema, persistent ids, event names, customer-visible behavior, external automation.
- Auth, OAuth scopes, secrets, webhooks, PII, encryption, retention, migrations, retries, rate limits, quotas, billing, or deploy behavior is involved.
