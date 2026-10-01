# Documentation site

Blume 2.1.0 renders canonical repository skills, translations, and archived releases.

## Verify

From the repository root:

```sh
bun install --frozen-lockfile
bun run docs:check
bun run docs:build
bun run docs:audit
bunx --no-install playwright install chromium
bun run docs:test:browser
```

`docs:audit` gates the built site's accessibility checks, including theme contrast.
The browser suite exercises onboarding views, shared snippets and Markdown, the
skill directory, related links, search, locale choice, narration, and mobile layout.
Device speech is stubbed in the playback test; it does not verify audible quality.
The suite also checks reviewed Chromium/macOS screenshot baselines for current and
archived pages, all onboarding locales, light/dark layouts, mobile, empty search,
related links, footer, and narration. Baselines are platform-specific; another OS
needs separately reviewed snapshots, not copied or renamed macOS images. For an
intentional visual change, inspect the expected/actual/diff images, update only the
matching test with `bun run docs:test:browser --grep '<test name>' --update-snapshots`,
then rerun the full suite without update flags.
Run the full offline site-health report with `bun run --cwd docs-site blume audit`.

## Canonical origin and agent discovery

The production origin is deliberately not guessed. Set it at build time to enable
canonical URLs, the sitemap, and Blume's generated site skill at `/skill.md`:

```sh
BLUME_SITE_URL=https://your-docs-host.example bun run docs:build
```

Blume validates the URL. Without it, local/static builds still work and repository
skills remain published under `/.well-known/agent-skills/`; the site guide is skipped.
Do not commit localhost as the production origin.

## Features adopted

- Browser narration: no API key, paid synthesis, or narration server.
- Agent-specific onboarding views, shared include snippets with props, and config variables.
- Wide landing/directory layouts and automatically generated skill-directory cards.
- Search keywords and boosts, and related links that only name existing canonical skills.
- Wrapped code, compact header controls, translated call-to-action/footer labels,
  and browser-language homepage routing that respects a manual language choice.
- Custom application metadata, existing Markdown/LLM/skill discovery, and accessibility auditing.

The site's custom filesystem source excludes private `_snippets` and dot paths.
Change the canonical skill generator, not its ignored `content/skills` output.
Do not rewrite archived content when adopting a current-version feature.

## Upgrade patch

`patches/blume@2.1.0.patch` preserves the non-staged custom source's collection root
in both Blume's source and compiled CLI. Without it, Astro reads the default `docs`
directory instead of the materialized `content` tree. This fix was not included in
2.1.0. Remove the patch only after a future version builds this site without it.

## Features not enabled

API pages, OpenAPI overlays/samples/webhooks/callbacks need an actual API, not demo
endpoints. Pattern redirects need moved routes. Hosted assistants, synthesized voices,
bot protection, and rate limiting need a provider/server configuration. Analytics,
written feedback, and consent need a real collection destination and privacy policy;
this upgrade introduces no reader tracking or provider credentials.
