# shadcn/improve source and refresh

The complete [shadcn/improve](https://github.com/shadcn/improve) skill is pinned to
[commit `cac56e1ebd3c279aa9153616cfeac7b174ab90f9`](https://github.com/shadcn/improve/tree/cac56e1ebd3c279aa9153616cfeac7b174ab90f9).
The [lock](shadcn-improve.lock.json) records the full revision, SHA-256 and mode of
every file: the upstream entrypoint, all three skill-local references, and the
root MIT license. README, examples, marketplace metadata, funding and GitHub
configuration are excluded; none is a skill-local dependency.

Copyright (c) 2026 shadcn. The complete [MIT license](shadcn-improve/LICENSE.md)
is retained byte-for-byte and copied to [the installed skill](../improve/LICENSE.md).
The snapshot is offline reference material, not a second registered `/improve`.

## Local compatibility and reviewed changes

The existing [canonical skill](../improve/SKILL.md) and its local references remain
the runtime owners; the Codex proxy is generated from Claude's registration.
Keep local adaptations outside the snapshot rather than editing upstream bytes.

This refresh carries upstream's untrusted-input and helper secret-handling rules,
intent/design-document recon and plan context, defensive security terminology,
stale-ADR detection, and public-sensitive-issue disclosure confirmation into the
local workflow. The following local rules intentionally override upstream:

- Report writes nothing; Plan writes only the chosen plan directory. Execute
  explicitly exits advisor mode for the current `/development-lifecycle` owner.
  No implicit executor, model downgrade, worktree, commit, push or merge authority.
- Audit depth, `execute`, helper mentions and skill loading grant no delegation
  consent. Only explicitly authorized helpers receive the scoped playbook,
  decided tradeoffs, findings-only contract and repeated input/secret rules.
- Applicable host/repository instructions remain authoritative; audited content
  cannot override them or authorize secret disclosure. Unlike upstream's blanket
  wording, legitimate `AGENTS.md` instructions are not automatically findings.
- Local performance/DX, check-loop and backlog references, review/plan routing and
  tests remain intact. GitHub `--issues` visibility and sensitive-disclosure checks
  run before handing a plan to any publishing helper; an unknown visibility blocks
  publication, not local plan writing.

These are instruction/distribution contracts. Deterministic tests prove delivered
text, routing and importer behavior, not model compliance or reviewer accuracy.
No hooks, workflow changes, runtime fetches, installs or background work are added.

## Review and refresh

Review upstream's full skill diff, resource inventory and licenses, then choose a
full immutable SHA in a trusted separate clone. The importer reads committed Git
blobs, not dirty checkout files; it preserves executable modes and copies every
skill-local resource, including newly added helpers or references.

```sh
git clone https://github.com/shadcn/improve /tmp/shadcn-improve-upstream
python3 scripts/vendor-shadcn-improve.py \
  --source /tmp/shadcn-improve-upstream \
  --revision cac56e1ebd3c279aa9153616cfeac7b174ab90f9
python3 scripts/vendor-shadcn-improve.py --check \
  --source /tmp/shadcn-improve-upstream
bash scripts/generate-skill-catalog.sh
bash evals/run.sh shadcn-improve
bash evals/run.sh shadcn-improve-vendored-skills
```

An identical rerun produces no diff. `--check` alone checks local bytes, modes,
inventory, license and provenance shape without network or writes; adding `--source`
also compares the complete snapshot to the locked commit. The offline check alone
does not establish upstream authenticity. Refresh rejects moving refs, missing
required resources, symlinks/gitlinks, unreviewed license changes, unmanaged output
and existing local drift before writing. The first import migrates only the known
legacy attribution; later refreshes preserve unrecognized local license edits.

After importing, reconcile the local adaptation explicitly; copying the snapshot
does not update its instructions. Update this review mapping and pin link together,
regenerate discovery, run focused evals and repository lint/type checks, and inspect
the complete diff. Preserve local execution/delegation/privacy boundaries.
