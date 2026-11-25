# Frontend Skills for Gemini in T3 Code

Use T3 Code's [Antigravity provider](https://github.com/pingdotgg/t3code/blob/main/docs/user/providers-antigravity.md), which runs Google's official ACP agent. This opt-in package targets the [Antigravity customization format](https://antigravity.google/docs/customization-discovery/), not legacy Gemini CLI. Claude Code and Codex installations and model routing are unchanged.

## Set up a workspace

1. In T3 Code, open **Settings > Providers > Antigravity** on the environment that runs the project. Enable it, install its runtime there, and sign in. Separate standalone CLI or IDE sign-in is not enough.
2. On that environment, from a checkout of this harness, build into the **actual project or worktree** you will open in T3 Code. Use Python 3.10+, Git, Bash, and jq; consumer checks also need the consumer's usual toolchain.

   ```sh
   python3 scripts/build-antigravity-plugin.py /path/to/workspace/.agents/plugins/frontend-skills
   ```

   The output must not already exist. To update, build into a fresh staging directory and replace the previous local bundle after inspecting it. If it is machine-local, keep the bundle out of Git (for example, with a local exclude). For standalone Antigravity only, you can instead build elsewhere and run `agy plugin validate <bundle>` and `agy plugin install <bundle>`. Do not assume another profile sees that install. The tested standalone CLI imported skills and agents but reported hooks skipped; use workspace discovery for the hook-capable bundle and verify in T3.
   For opt-in updates from published tags, see [release updates](../README.md#releases-and-automatic-updates).
3. Start an Antigravity thread in the same workspace. Pick **Gemini 4 Neon** first, or **Carbon** or **Hydrogen** if the provider lists them. Select Extra (`xhigh`) where offered and don't silently substitute a different model or effort. [Google's model table](https://antigravity.google/docs/models) lists plan restrictions; the T3 provider catalog determines what's available in the session.
4. Before relying on the harness, verify discovery in that thread: load the `tdd` skill (including its canonical instructions), explicitly request one read-only `code-reviewer` invocation, and try `npm --version` in a disposable workspace. Expect a **hook denial** with the Bun recommendation, not a terminal command result. Make a disposable React edit containing a tablist without tabs, then check that the next model invocation receives the edit diagnostic. A model's claim that a hook ran isn't verification. Repeat on the other models you intend to use.

## Coverage and gaps

- **Skills and subagents:** The package exposes the canonical catalog and agent roles. It preserves explicit-only skill metadata and inherits the selected model rather than mapping roles to new model defaults. Reviewers whose Claude shell access was command-scoped get no shell access on Antigravity; supply the required evidence from the parent. Host-specific workflows (Claude mods, Codex delegation, quotas, and provider-owned PR monitoring) are not ported.
- **Shell and native edits:** The adapter translates the shell gate, pre-edit copyright/Bend checks, and post-edit batch checks. It never auto-approves a call. Edit diagnostics are forwarded on `PostInvocation` because Antigravity's `PostToolUse` cannot inject them directly. This is a workflow check, not a sandbox. Shell-created files, arbitrary MCP edits, and filesystem-wide changes do not generate native edit events.
- **Completion:** In a single workspace, an idle model stop after an observed native edit runs the shared Stop checks and can request one repair continuation per unchanged prompt. Unresolved checks after that are logged, not marked as passed. Delivery-endpoint inference, final status enforcement, lifecycle/compaction tracking, and output-dependent test warning checks are not ported. Run consumer checks explicitly before delivery. Antigravity can ignore a hook that times out or fails to launch.

Run the credential-free package and hook tests with `python3 scripts/test-antigravity-plugin.py`. These test the built package and JSON contract, not ACP discovery or model behavior. See the [native hook contract](https://antigravity.google/docs/hooks) for the event and tool schema.
