---
name: read-the-damn-docs
description: Research current behavior from primary documentation. Use for third-party APIs, libraries, CLIs, cloud services, API drift, auth, billing, security, migrations, or deploys.
---

Read `references/builder-upstream.md` for full triggers. This is a quick official fact check without creating a research artifact. Durable multi-source reports use built-in deep research and save cited Markdown in the repo's normal notes path.

## Workflow

1. Identify exact package/version/endpoint/CLI/config/helper/schema/product surface.
2. Read local docs/specs/ADRs/generated types first when they own the contract.
3. For external/fast-moving behavior, search current official docs and open the relevant API reference, migration guide, changelog, release notes, SDK source, or types.
4. Extract only needed imports, options, lifecycle/defaults, breaking changes, limits, permissions, examples.
5. Apply facts to repo patterns; never cargo-cult examples.
6. Cite sources when facts affect notes or answer.

## Strong triggers

- Latest/current/official/supported/best practice/today/look it up.
- Package/SDK/model/provider/plugin/CLI install, upgrade, config, import.
- Deprecation, unknown option, missing export, invalid config, unsupported field, version mismatch.
- Hard-to-reverse wire formats, schemas, persistent IDs, events, customer behavior, automation.
- Auth/OAuth, secrets, webhooks, PII, encryption, retention, migration, retry, rate/quotas, billing, deploy.
