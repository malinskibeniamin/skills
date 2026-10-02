---
name: codex-review
description: Run an explicitly requested Codex CLI second-opinion review; optionally publish one consolidated advisory PR comment.
---

# Codex review

One read-only review of a committed branch, with P0-P3 counts, file/line findings,
summary, model/profile, and reviewed HEAD/base SHAs. Advisory, not merge approval.

## Authorization

- Run only when the user explicitly requests Codex review or authorizes a second-model
  pass. Discovering this skill, `/review`, `/go`, and shipping alone are not consent.
- In native Codex, keep review inline unless the user explicitly authorizes another
  model/recursive CLI. Preserve their model, effort, and config; do not run a capability
  probe that calls a model. Implementation of this skill does not authorize using it.
- Apply [provider authorization and minimization](../codex/REFERENCE.md#cross-provider-review-gates).
  Use the existing repository CLI integration; send no secrets or unrelated context.
- Posting needs explicit publishing intent. Default to a local report. Never approve,
  merge, poll for future comments, or enable auto-merge.

## Run

Require `python3`, `git`, authenticated `codex`; posting also requires authenticated
`gh`. Check `codex exec review --help` for `--output-schema` and
`--output-last-message`; unsupported CLI/auth stays a visible failure, not a fallback.
Resolve `skill_dir` to this canonical skill directory, not the Codex index proxy.

Resolve the PR layer's base with [resolve-pr-base.sh](../scripts/resolve-pr-base.sh)
or use the user's explicit ref. Review a clean committed snapshot. On a review-only
request, do not commit WIP to satisfy the runner; review inline and explain the limit.

```bash
python3 "$skill_dir/scripts/codex_review.py" --base "$BASE"
```

Only when publishing is authorized:

```bash
python3 "$skill_dir/scripts/codex_review.py" --base "$BASE" --post --pr "$PR"
```

Add `--repo owner/repo` for an explicit GitHub target. Posting checks the PR is OPEN
and its head/base match local SHAs before reviewing and again before commenting.
Fetch/reconcile stale refs; never reset or discard user work. GitHub comments have
no atomic head precondition: the report's SHAs identify exactly what was reviewed.

The runner reads [model-routing.json](../config/model-routing.json)'s review primary.
An explicit user model/effort wins via `--model`/`--effort`; xhigh requires the routing
policy's usage evidence or explicit effort request. `--profile` selects an existing
Codex profile. No automatic provider switching, AWS defaults, config writes, or retries.
`--timeout` overrides the review deadline; timeout/interruption kills its process group.

Each run saves private artifacts under `.context/codex-review/<HEAD>-*/`: raw JSON,
Markdown report, and CLI logs. Malformed/empty output and changed snapshots fail closed.
Posting failure preserves the report; inspect PR comments before retrying an uncertain
write. Never repost old output as a fresh review.

## Integrate

During authorized delivery, run after commit (and push when posting), before the
final verdict. Triage each finding against source; fix only real defects. A fix/new
HEAD invalidates the review; rerun within the authorized scope, not fixed rounds.
Keep the original endpoint: a PR request gets one CI snapshot; `/go` owns its CI loop.

Report actual model/profile, SHAs, counts, artifact path or posted PR URL, and limits.
Reviewer test claims remain unverified until the owner reproduces them. A clean
second opinion does not replace tests, dogfood, or human judgment.

CLI contract: [noninteractive mode](https://learn.chatgpt.com/docs/non-interactive-mode).
