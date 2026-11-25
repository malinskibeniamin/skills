# Agent-browser skill suite

Source: [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser),
commit [`f85ed4d620c53ace7733a3b7eeef51e5f2532c83`](https://github.com/vercel-labs/agent-browser/tree/f85ed4d620c53ace7733a3b7eeef51e5f2532c83).
The snapshot retains all ten `skill-data/` skills, every skill-local reference and
shell template, the `skills/agent-browser/` discovery stub, and the root
[Apache-2.0 license](agent-browser/LICENSE). Upstream has no separate NOTICE file
at this revision. Copyright and license notices remain in the source files.
These third-party files are Apache-2.0, not this repository's MIT-authored guidance.

[`agent-browser.lock.json`](agent-browser.lock.json) records the full commit,
SHA-256 digest and executable mode of every file, plus local discovery metadata.
The report template's four screenshot links name future consumer captures, not
bundled resources; the packaging checker exempts only those exact placeholders.
The browser CLI, Chrome and cloud SDKs are not bundled. The official
[Chrome guidance snapshot](chrome-modern-web-guidance-NOTICE.md) is vendored separately.
Importing skills installs no CLI or browser and changes no runtime hook or account.
The [host contract](../shared/AGENT-BROWSER.md) records adaptations outside upstream
bytes: browser/session ownership, version matching, safe traffic capture, local
workflow owners and per-rule runtime evidence. Nine browser entrypoints use the
`agent-browser` prefix; `modern-web-guidance` remains directly discoverable.

## Refresh and verify

Use a trusted separate upstream Git checkout and a reviewed full commit SHA:

```bash
python3 scripts/vendor-agent-browser.py --source /path/to/agent-browser --revision <full-sha>
bash scripts/generate-skill-catalog.sh
bash scripts/generate-hook-configs.sh --apply
python3 scripts/vendor-agent-browser.py --check
python3 scripts/vendor-agent-browser.py --check --source /path/to/agent-browser
bash evals/run.sh agent-browser-vendored-skills
```

The importer reads committed blobs, not dirty working files, and refuses local
snapshot/adapter drift, symlinks, unknown skill identities or license changes.
`--check` is offline; adding `--source` compares the complete inventory with the
locked upstream commit. A digest-only check proves local consistency, not origin.
Review new helpers/resources and external references before refreshing. Source
examples referencing the upstream app/CLI are not runnable helpers in this snapshot.

Modern Web Guidance retrieval uses the [host contract](../shared/AGENT-BROWSER.md#modern-web-guidance),
not this snapshot's moving `@latest` examples. The motivating announcement is
[the user-supplied post](https://x.com/ctatedev/status/2122816672625275030);
the import is verified against Git, not the post's sample metrics.
