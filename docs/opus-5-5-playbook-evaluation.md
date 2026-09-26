# "Getting the most out of Opus 5.5" Playbook Evaluation

**Date:** 2026-09-25
**Status:** Adopted where it changes harness behavior, with offsetting cuts; routing promotion waits on context ablation
**Sources:** [Anthropic playbook](https://claude.dev/blog/getting-the-most-out-of-opus-5-5/) (2026-09-22);
Claude API migration notes for `claude-opus-5-5`

## Decision

Routing was settled separately: Opus 5.5 `high` is the primary owner in
`config/model-routing.json`, and context ablation sweeps every Opus 5.5 effort. This record
covers the playbook's prompting and harness advice. Anthropic reports that Opus 5.5 at
`medium` beats Opus 5 at `high` on coding, so the ablation run decides whether a lower
effort earns the default.

## Coverage map

| Playbook advice | Harness status | Where |
|---|---|---|
| Say what done looks like, then let it run | **Already covered** | CLAUDE.md outcome contract (Objective, Guardrails, Verification, Stop) |
| Delete "think carefully" lines | **Already clean; now guarded** | `evals/test-opus-5-5-playbook.sh` scans CLAUDE.md, AGENTS.md, skills, agents, and hooks |
| Name the design styles to leave out | **Adopted** | `prototype/UI.md` exclusion list; `visual-review/REFERENCE.md` slop catalog |
| CLAUDE.md rule for when to stop and when to keep going | **Adopted** | CLAUDE.md Work: status notes go with the next action; no stop on a recap, an offer to continue, or non-blocking options. Destructive stops were already covered |
| Keep permission prompts on for destructive commands | **Already covered** | Execution contract plus `enforce-toolchain.sh` and deny hooks |
| Split big audits across subagents and check each one's evidence | **Already covered; delegation stays opt-in** | `/efficient-frontier` lanes return evidence and the coordinator keeps acceptance; `subagent-stop.sh` validates findings |
| Keep the task list in a file | **Adopted** | CLAUDE.md: the task checklist lives in `.context/implementation-notes.md`; the PostCompact hook tells the model to reread it |
| Read what it needs from you first | **Already covered** | The status line contract (`🟡 awaiting decision`, `🔴 blocked`); Opus 5.5 already leads its reports this way |
| Review before a person does: blockers only, with file, line, and a failing proof | **Already covered** | `/review` output: `[P0\|P1\|P2] <file:line>` with evidence and a verify command |
| Mark what couldn't be confirmed | **Adopted** | `/research` and `/read-the-damn-docs` |
| Don't ask it to show its reasoning in the reply | **Already covered; now guarded** | `shared/intent-map.md` forbids exposing chain of thought; the same eval scans for requests |
| Charts and screenshots attached, not retyped | **Already covered** | `/visual-review` works from visual evidence |
| Settled answers in long app chats, flagged-message switching, fast mode | **N/A** | App and session settings, not harness content. The PostModelSwitch hook already hands the new model its routing record after any switch |

## Cuts

- **Stale hook copies in `shared/`.** Nothing wired nine of them: `intent-detect`, `orchestration-guidance`,
  `orchestration-stop`, `post-compact-context`, `subagent-start`, `subagent-stop`,
  `user-prompt-context`, `violation-nudge`, and `violation-summary-stop`. Several evals
  exercised these copies instead of the `.claude/hooks/` scripts that actually run, and the old
  `post-compact-context.sh` still carried the `[BREVITY:ultra]` prompt that Opus 5.5 guidance
  replaces with a lower effort setting. The copies are deleted, the evals point at `.claude/hooks/`, and
  `evals/test-hooks.sh` rejects any new duplicate. `shared/source-hook-lib.sh` stays because
  skill-script symlinks load it; it now matches the hook copy byte for byte.
- **The hook-enforced endpoint rule in CLAUDE.md.** "Store inferred delivery endpoints only in
  lifecycle state" is enforced by `intent-detect.sh` and tested for behavior, so the ambient sentence
  paid for the keep-going rule. CLAUDE.md stays within its original 4.5 KB budget.

## Open

- Run `agent-evals/context-ablation/` for `claude-opus-5-5` at `low`, `medium`, `high`, and
  `xhigh`, then record the winning effort in `config/model-routing.json`.
- Ablate the ambient `shared/intent-map.md` pointer: Opus 5.5 already reports what it did,
  found, and needs, so the presentation contract may no longer earn its context.
- `/plow-ahead` now duplicates the execution contract and is proposed for removal in its own PR.
