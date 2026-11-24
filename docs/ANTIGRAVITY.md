# Frontend Skills for Gemini on Antigravity

Use T3 Code's [Antigravity provider](https://github.com/pingdotgg/t3code/blob/main/docs/user/providers-antigravity.md),
standalone Antigravity CLI (`agy`), Antigravity 2.0, or Antigravity IDE. This
opt-in package targets the [Antigravity customization format](https://antigravity.google/docs/customization-discovery/),
not legacy Gemini CLI. Claude Code and Codex installations and routing in
`config/model-routing.json` are unchanged; Antigravity model defaults live in
`config/antigravity-model-routing.json` and root host guidance lives in
`GEMINI.md`.

## Set up a workspace

1. In T3 Code, open **Settings > Providers > Antigravity** on the environment
   that runs the project. Enable it, install its runtime there, and sign in.
   Separate standalone CLI or IDE sign-in is not enough.
2. On that environment, from a checkout of this harness, build and verify the
   plugin into the **actual project or worktree** you will open in T3 Code.
   Requires Python 3.10+, Git, Bash, and jq. Consumer checks still need the
   project's usual toolchain.

   ```sh
   python3 scripts/build-antigravity-plugin.py --verify \
     /path/to/workspace/.agents/plugins/frontend-skills
   ```

   - **Profiles:** `--profile core` (default) keeps all catalog skills explicitly
     invocable by name while marking vendored adapter packs and other-host
     skills (`codex`, `codex-compat`, `setup-*`) as `disable-model-invocation: true`
     so Gemini's auto-discovery menu stays focused and low-token. Pass
     `--profile full` to preserve canonical auto-invocation flags verbatim.
   - **In-place updates:** pass `--update --verify` to stage and validate the
     bundle before replacing it. For opt-in updates from published tags, see
     [release updates](../README.md#releases-and-automatic-updates).
   - **Standalone Antigravity:** build to a staging directory and run
     `agy plugin validate --strict <bundle>` followed by
     `agy plugin install <bundle>`. The tested CLI imported skills and agents
     but skipped hooks; use workspace discovery for hooks and verify in T3.
     Keep machine-local bundles out of Git.
3. Start an Antigravity thread in the same workspace. Pick **Gemini 4 Neon**
   first, or **Gemini 4 Carbon** / **Gemini 4 Hydrogen** when offered. Select
   Extra (`xhigh`) or High effort and do not silently substitute models.
   [Google's model table](https://antigravity.google/docs/models) lists plan
   availability; the host catalog determines what is active in the session.
4. Verify live discovery before relying on the harness:
   - Load `tdd` and confirm canonical instructions load directly in one read
     (no double-hop proxy stub).
   - Explicitly request a read-only `code-reviewer` invocation and confirm it ran.
   - Run `npm --version` in a disposable workspace and confirm a **hook denial**
     recommending `bun`, not a terminal result.
   - Make a disposable React edit with `<div role="tablist" />` using
     `write_file` or `edit_file`, then verify the next `PostInvocation` receives
     the accessibility diagnostic. Repeat on the models you intend to use.

## Coverage and known host limits

- **Skills and subagents:** Every canonical `SKILL.md` and `agents/*.md` body is
  inlined at build time with relative links rewritten into the bundle's `source/`
  tree (zero double-hop reads). Subagents inherit the selected Gemini model and
  expose both ACP (`read_file`) and IDE (`view_file`, `grep_search`,
  `find_by_name`, `list_dir`) read-only tools. Reviewers whose Claude shell
  access was command-scoped get no shell access on Antigravity.
- **Full 6-event hook lifecycle:**
  - `SessionStart`: validates prerequisites, binds worktree/branch state, and
    attaches Gemini 4 calibration guidance via `shared/model-prompting.sh`.
   - `PreInvocation`: runs `user-prompt-context.sh` and `intent-detect.sh` on
     a new prompt, not on each tool-loop invocation. A final idle `Stop`
     resets deduplication so the next turn can repeat the same prompt.
  - `PreToolUse`: enforces `pre-bash.sh` (resolving `cwd` from either ACP
    top-level `cwd` or IDE `args.Cwd`), fast-allows `mcp_t3-code_*` while
    routing bloated MCP servers through `mcp-ban.sh`, and fast-gates
    `copyright-check.sh` and `bend-laws-guard.sh` on both ACP (`write_file`,
    `edit_file`) and IDE (`write_to_file`, `replace_file_content`,
    `multi_replace_file_content`) edit tools.
  - `PostToolUse`: runs `post-tool-batch.sh` on ACP and IDE edits (preserving
    exact added lines) and tracks consecutive `run_command` errors (escalating
    at 3 failures).
  - `PostInvocation`: drains queued edit and failure diagnostics into model
    context.
  - `Stop`: triggers on `"NO_TOOL_CALL"` (ACP/CLI/2.0) or `"model_stop"`, honors
    Antigravity's native `continuationActive` bit so repair retries stay bounded
    at one continuation, and runs `stop-dispatch.sh` for edited or active
    delivery sessions.
- **Host limits that remain explicit:** Antigravity `PostToolUse` does not pass
  shell stdout/stderr, so `test-warning-check` cannot inspect command output
  automatically. Inspect test, lint, and type-check output directly for warnings
  before claiming done. Claude mods, Codex quota readers, and provider-owned PR
  monitoring are not ported. These hooks are not a sandbox: shell and MCP
  edits do not emit native edit events, and Antigravity can ignore timed-out hooks.

## Verification commands

```sh
bun run test:antigravity          # ACP + IDE hook contracts, link integrity, budgets
bun run harness:health --check    # Cross-host lifecycle and token-budget gate
```

These run credential-free in CI (`.github/workflows/evals.yml`). They do not
verify live discovery or model behavior. See
`shared/model-prompting.md#gemini-4-on-antigravity` for Gemini 4 prompting
calibration and the [native hook contract](https://antigravity.google/docs/hooks)
for raw event schemas.
