# Delegation Packet

Assume the receiving agent has no conversation context. Include:

- repo path and branch
- one objective
- exact write scope and exclusions
- relevant files, docs, and exemplar
- acceptance criteria
- verification commands and expected results
- evidence format
- stop conditions

Useful stop conditions:

- Live code contradicts the packet.
- A verification command fails twice after a reasonable fix.
- Work requires files outside scope.
- The lane cannot support a claim with concrete evidence.

Parallel lanes own distinct files or remain report-only. Return status, summary, changed
files, commands, findings, residual risk, blockers, and next action.
