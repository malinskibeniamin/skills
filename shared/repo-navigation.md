# Repo navigation

Use when orienting in unfamiliar code, choosing commands, or reconciling stale guidance.

## Resolve current owners

- Confirm repo/worktree, branch, and target package. Discover applicable instruction
  files and their linked architecture/domain/testing docs; read existing paths only.
  A missing scoped doc means use its applicable parent, not repeated probes for the
  same absent file. Recheck after evidence of new scoped guidance.
- Use target-package scripts and runner configs for commands, test tiers, and file
  selection; use current component policy and imports for UI ownership. Harness
  defaults, personal memory, handoffs, and historical proposals are leads, not
  reasons to migrate a working repo or invent a config. Resolve conflicting docs
  against executable source; report stale guidance with its replacement pointer.
- Start at the task's entry point and adjacent tests in the maintained architecture
  map. If absent, discover narrowly and retain the verified pointers for this task;
  widen only for a named missing behavior, caller, or test. Revalidate cached paths
  and command recipes against the current checkout before using them.

## Retrieve without outage loops

- Discover tools with a bounded capability/name query; return matching names and
  short descriptions, then inspect the selected candidates' schemas. Widen for a
  named missing capability rather than dumping the entire tool catalog.
- Use the TraceDecay graph before broad shell search or whole-file reads. Ask a
  scoped context question for unfamiliar behavior; use narrow path/symbol lookup
  otherwise. Reuse unchanged excerpts within the task; re-read after relevant edits,
  scope changes or context loss. Required per-task instruction reads still apply. Treat role
  labels as leads, verbatim source as evidence; incomplete retrieval stays unknown.
  Use callers, callees, affected tests, or test maps for relationships.
- After an MCP timeout, disconnect, or unavailable transport, try `tracedecay tool`
  once with an explicit caller-enforced deadline. Cancel only the invocation you
  started, not shared services. If CLI also stalls or cannot reach its project
  index, or a deadline cannot be enforced, use scoped `rg` and file reads. Record
  the outage once; retry graph retrieval only after observable recovery, not for
  each new symbol. Never query TraceDecay databases directly.
- Correct schema/argument errors and retry the corrected call; an empty result is
  not an outage. For a warming index, do useful scoped work before one narrow
  readiness check. A stale index or generated/ignored artifacts outside the graph
  also permits scoped native reads. Quote shell globs and exclude unrelated
  generated/vendor trees, unless those artifacts are the target.

## Leave shared context

When authorized changes reveal a missing or stale area contract, update the existing
maintained area guide before handoff. Keep a small front door in scoped `AGENTS.md` or
`CLAUDE.md`, respecting source generators. Record load-bearing invariants, shared helpers,
ownership boundaries, entrypoints and known failure modes; link the owning verification
and recovery commands and consequential decisions. Add a scoped guide only when no current
owner exists and the next contributor would otherwise need to rediscover those facts.

Verify pointers against the changed checkout and replace stale statements in place.
Keep transient task state, pending checks and next actions in the local checkpoint or PR,
not permanent area rules. A new session should be able to locate the contract and exercise
it without the original author or a feed of every PR. This is guidance, not proof of
shared understanding; read-only reviews report gaps without editing.
