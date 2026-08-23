---
title: "/read-the-damn-docs"
description: "Research current behavior from primary documentation. Use for third-party APIs, libraries, CLIs, cloud services, API drift, auth, billing, security, migrations, or deploys."
type: skill
sidebar:
  label: "/read-the-damn-docs"
---
![Diagram of the /read-the-damn-docs skill](/diagrams/skills/read-the-damn-docs.svg)

[Open the editable Excalidraw source](/diagrams/skills/read-the-damn-docs.excalidraw)

Read `references/builder-upstream.md` for the complete docs-first trigger list.

Do not guess where authoritative docs can answer the question. This is the quick official fact check path, usually without creating a research artifact. When the user wants a durable cited report or multi-source synthesis, delegate to the built-in deep-research skill, then save the findings as a Markdown file where the repo already keeps such notes (or a sensible path, stating where).

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
