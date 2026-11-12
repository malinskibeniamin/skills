# Local home-repo wiki

Keep cross-repo knowledge in `.context/wiki-home/` inside this checkout.
The CLI and skill are tracked; knowledge is gitignored and stays local.
This first version is local-only: no account connectors, automatic AI generation,
repo cloning, Git setup, or scheduled ingestion.

## Start a home

Run from this checkout with Bun:

```sh
bun run wiki --help
bun run wiki --home "$PWD/.context/wiki-home" init
bun run wiki --home "$PWD/.context/wiki-home" repo add skills \
  --path "$PWD" --summary "Shared skills harness" \
  --remote git@github.com:malinskibeniamin/skills.git
```

Choose an empty directory. Existing uninitialized content is rejected, not migrated.
The CLI creates `AGENTS.md`, a `CLAUDE.md` pointer, `wiki/index.md`, `repos/`, and
`.wiki-home.json`. It preserves initialized homes on retries. It does not run `git init`
or create a GitHub repo. Do not create a nested Git repository here by default. If you later move knowledge
to a separate private repo, agree that migration and visibility first.
This local home is per checkout/worktree; it is not synced or backed up. Copy or back it
up before removing this worktree. To follow Matt's session-start pattern, start future
agent sessions in the home. Keep this harness installed through your
existing plugin setup; do not copy it into each child repo.

From an installed plugin, use the absolute canonical script path:

```sh
bun <plugin-root>/wiki/scripts/wiki.ts --home /path/to/skills/.context/wiki-home list
```

No global binary, shell alias, PATH change, or model configuration is installed.
There is no implicit home: `--home` is always required for data commands.
Paths passed to `--home` resolve against the caller's working directory. Prefer absolute
paths; shell-expand `~` or use `"$HOME/..."`, not a quoted literal `"~/..."`.

```text
skills harness                      private home
[wiki skill + CLI] -- --home --> [AGENTS.md / CLAUDE.md]
                                [wiki/index.md -> cited Markdown pages]
                                [repos/*.json -> local repo paths]
                                                |
                                                v
                                [child repo's own rules + worktree]
```

## Store and retrieve knowledge

Write your own synthesis to `notes.md`, then ingest it:

```sh
bun run wiki --home "$PWD/.context/wiki-home" ingest home-pattern \
  --title "Home repo pattern" \
  --source 'https://www.youtube.com/watch?v=hWe-j78vNpc&t=140s' \
  --file ./notes.md
bun run wiki --home "$PWD/.context/wiki-home" list
bun run wiki --home "$PWD/.context/wiki-home" search "home repo" --limit 10
bun run wiki --home "$PWD/.context/wiki-home" read home-pattern
bun run wiki --home "$PWD/.context/wiki-home" repo list
bun run wiki --home "$PWD/.context/wiki-home" lint
```

`ingest --stdin` accepts piped Markdown instead of `--file`. It requires a title and
source reference. Sources may be URLs, issue links, repo/commit locators, or explicit
owner decisions; the CLI stores them without fetching or executing them. A page is
limited to 1 MiB. Slugs use lowercase kebab-case, up to 100 characters; `index` is reserved.

Results are JSON on stdout. Help is plain text. Diagnostics go to stderr, with nonzero
exit status; `lint` instead returns JSON issues and exits 1 when issues exist. Search
is literal, case-insensitive, and capped at 20 matching lines by default (`--limit`:
1–1000). Body line numbers start at 1; title/source matches use line 0. An empty result
is a successful `[]`, not an error. No prompts or stdin reads occur without `--stdin`.

Each page has `title`, `source`, and UTC `date` frontmatter as JSON-quoted strings.
The date records ingestion, not when each claim became true. Read/list/search reject
malformed pages and symlinked knowledge. These checks prevent ordinary accidental
traversal; this is not a sandbox against concurrent hostile filesystem changes.

## Update and recover

An identical ingest is a no-op except for index repair. A different page with the same
slug fails without overwriting it. Add a new dated slug for changed knowledge. If you
edit pages manually, retain frontmatter and add dated supersession links. Re-ingest
an unchanged page with its original title/source to rebuild `wiki/index.md` afterward.
The index is generated; do not hand-edit it. There is no delete or force-overwrite command.

Mutations take a per-home `.wiki-lock` directory and write the index by atomic rename.
Other writers fail promptly. If a process crashes, confirm no writer is running before
manually removing a stale lock. If an ingest saved its page but failed during index
publication, repeat the identical command to repair the index. After interrupted init,
repeat init on that same initialized home. Do not remove the format marker to retry.
Keep a Git history or backup: the CLI is not a backup system or a multi-file transaction.

`lint` checks required metadata, index drift, inline Markdown page links, and `[[slug]]`
links, excluding fenced/inline code examples and HTML comments. Use flat `slug.md` targets with optional `#fragment`, or fragment-only links.
It does not validate external links, heading anchors, reference-style links, orphan
semantics, contradictions, or whether a source supports a claim. Review those yourself.
Repo pointers are validated records, not proof that a checkout exists or is up to date.

## What Matt demonstrates

Source: [The Home Repo Pattern](https://www.youtube.com/watch?v=hWe-j78vNpc),
English captions and on-screen text reviewed on 2026-11-12. This is a local adaptation,
not Matt's private CLI or an exact reconstruction of its commands.

- [2:20](https://www.youtube.com/watch?v=hWe-j78vNpc&t=140s): centralize shared
  skills, instructions, a wiki, and custom tools in one home repo.
- [3:43](https://www.youtube.com/watch?v=hWe-j78vNpc&t=223s): use navigation
  pointers to other repos; each repo still owns its code and history.
- [5:43](https://www.youtube.com/watch?v=hWe-j78vNpc&t=343s): keep business knowledge
  in Markdown. He leaves wiki generation for a later video.
- [6:45](https://www.youtube.com/watch?v=hWe-j78vNpc&t=405s): his private `wiki help`
  exposes service integrations. This version does **not** implement those connectors.

His [linked setup article](https://aihero.dev/the-home-repo-pattern) inventories repos
and shared material, then asks for approval before migration. This CLI neither performs
that inventory nor moves files. An existing home/wiki needs a separately agreed migration.

## Verification

CLI behavior: `bun test ./wiki/scripts/wiki.test.ts`.
Catalog publication: `bash scripts/generate-skill-catalog.sh --check`.
