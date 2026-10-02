# Local auto-review wake-up

Trusted GitHub review comments -> local `gh` polling -> original feature session ->
`/resolve-pr-feedback` -> fixes, verification, push, and evidence-backed replies.

Configure once on a Mac with this harness installed at a **stable path**, `bun`,
authenticated `gh`, and the feature agent's authenticated CLI. This uses native
`codex exec resume UUID` or `claude --print --resume UUID`; it does not inject a
message into Conductor's local UI. Conductor's public CLI targets cloud workspaces.

## Enable

Only enable when the user explicitly requests unattended repair. Pick exact trusted
reviewer logins from the PR's `gh api` output; arbitrary bots cannot trigger it.

```bash
bun <plugin-root>/scripts/pr-review-auto.ts enable \
  --reviewer 'chatgpt-codex-connector[bot]' --reviewer 'github-copilot[bot]'
```

The user-local launchd job polls once per minute, while the Mac is awake and online.
It reads inline comments, review bodies, and issue comments with `gh api --paginate
--slurp`. New/edited trusted feedback triggers one repair; unchanged feedback and
the repair's own push do not. `configure` writes consent/settings without installing
the job; `tick` runs one sweep, useful with another scheduler.

Enabled Claude/Codex hooks bind newly created PRs to the creating session. Existing
PRs, compound shell commands, or tools with opaque payloads need one explicit bind:

```bash
bun <plugin-root>/scripts/pr-review-auto.ts bind --agent codex --session <original-session-uuid>
bun <plugin-root>/scripts/pr-review-auto.ts tick --dry-run
bun <plugin-root>/scripts/pr-review-auto.ts status
```

Bind in the **original feature worktree**, after its branch is pushed. Use the exact
session UUID from the session's hook payload or CLI, never `--last`. Once enabled,
the delivery skill performs this binding when publishing future PRs. Registration
will not replace another session's ownership.

## Safety and limits

- Only open same-repository PRs, on their bound non-default branch, with clean trees
  and local HEAD equal to GitHub HEAD, can dispatch. Busy session hooks defer work.
  Untracked files count as dirty. Other worktrees, fork PRs, changed origins, closed
  PRs, and unpublished commits are left untouched.
- The resumed agent fetches **all applicable** feedback through `gh`, not just the
  trigger. Review text stays untrusted; prompts contain IDs, not comment bodies.
  Replies/resolution need fix or non-applicability evidence. Draft status stays
  unchanged; never merge, approve, reset, stash, bypass permissions, or delegate.
- Existing model/config/auth/permission settings remain in effect. Configure the
  original CLI for unattended edits and `gh`/git access before enabling. Permission
  denial must be reported, not converted into a successful repair claim.
- `status` and user-only logs distinguish **delivered** from **fixed**. CLI exit zero
  acknowledges delivery, not semantic completion. Failed CLI runs pause paid retries:
  inspect `run-*.log`, fix the cause, then `retry --session UUID`.
- Hook activity tracking requires enabled hooks in every session using that worktree.
  This is not an atomic Conductor/UI lock. Do not use the same feature session
  interactively during repair. Crashed sessions or killed jobs fail closed: after
  confirming no agent is running, disable the job and remove only its stale activity
  entry or `.lock` directory from the state directory before enabling again.
- State lives under `${XDG_STATE_HOME:-$HOME/.local/state}/frontend-skills/pr-review-auto`;
  `PR_REVIEW_AUTO_HOME` overrides it. State/logs are user-only. No secrets in the plist.
  Repository code runs with the resumed agent's privileges: allow only repositories
  and reviewers you trust. This is not cloud/offline automation.

## Stop or move ownership

```bash
bun <plugin-root>/scripts/pr-review-auto.ts disable
bun <plugin-root>/scripts/pr-review-auto.ts unbind --session <uuid>
```

Disable revokes queued dispatch; an already running repair may finish. Keep the stable
installation while enabled. Unbind before deliberately choosing a replacement owner.

Sources: [Codex resume](https://developers.openai.com/codex/noninteractive), installed
`claude --help`, [Conductor agent controls](https://conductor.build/docs/reference/agent-behavior).
