# Cursor skills provenance

Reviewed [cursor/plugins](https://github.com/cursor/plugins/tree/88d47514b82e7c44f00f2b2a72ff6dd12158038c)
at `88d47514b82e7c44f00f2b2a72ff6dd12158038c` on 2026-10-20.

## Selected guidance

`/cli-for-agents` fills a CLI-design gap: non-interactive inputs, layered help,
pipelines, actionable failures, retry safety, and useful output. Its
[adapter](../cursor-skills/cli-for-agents/SKILL.md) preserves repository conventions
and authorization, and resolves upstream's prompt fallback in favor of fast
failure outside an explicitly interactive mode.

The complete [source skill](../vendor/cursor/cli-for-agent/skills/cli-for-agents/SKILL.md)
and [MIT license](../vendor/cursor/cli-for-agent/LICENSE) are copied unchanged from
`cli-for-agent/` at the pin above. The adapter is registered through Claude,
generated Codex discovery, and the shared skill catalog. It activates no hooks,
agents, services, or recurring work.

## Recheck decisions

- All 18 Team Kit skills are unchanged since
  [`679fdaf2c180df94d99b6e3dd862460082b73af6`](https://github.com/cursor/plugins/tree/679fdaf2c180df94d99b6e3dd862460082b73af6/cursor-team-kit/skills),
  preceding the original local import. The skill-tree hash remains
  `f9b154131e86c710c110ad15955f22d287fc8556`; later changes are plugin metadata.
  Existing CI, review, verification, cleanup, and summary owners remain in place.
- Outside Team Kit and pstack, the 15 first-party plugins contain 29 skill
  entrypoints. Twelve additions since that comparison revision are not adopted:
  five Dyl skills duplicate local workflow/review policy; advisor introduces a
  separate model-consultation policy; four Grok Voice and two Origin skills are
  provider-specific and unnecessary for this harness.
- Existing teaching, plugin creation, canvas, compatibility, continual-learning,
  Ralph, and Thermos workflows overlap local owners or require Cursor-specific
  runtime/subagent capabilities. Preserve the existing owners instead of adding
  aliases or implicit delegation.
- Pstack's separate snapshot and refresh remain owned by
  [its lock](../vendor/pstack.lock.json) and
  [compatibility rules](POTETO-COMPATIBILITY.md). Do not import generated harness
  copies as additional skills or overwrite another active refresh.

## Refresh and verification

Resolve one reviewed full commit SHA and read the skill, its local references,
and `cli-for-agent/LICENSE` there. This skill currently has no local references
or helpers. Fetch the selected files without changing their bytes:

```sh
sha=88d47514b82e7c44f00f2b2a72ff6dd12158038c
for file in skills/cli-for-agents/SKILL.md LICENSE; do
  gh api "repos/cursor/plugins/contents/cli-for-agent/$file?ref=$sha" \
    -H 'Accept: application/vnd.github.raw+json' > "vendor/cursor/cli-for-agent/$file"
done
```

Inspect the diff, update the pin and independently verified SHA-256 digests in
`evals/test-cursor-what-did-i-get-done.sh`, and retain host constraints. Regenerate
with `bash scripts/generate-skill-catalog.sh`; run its `--check`,
`bash evals/run.sh cursor-what-did-i-get-done`, `bun run lint:fix`, and
`bun run type:check`. Recheck additions separately rather than silently importing
the whole marketplace. No source attribution implies endorsement by Cursor.
