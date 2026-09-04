# Owner-controlled swarm debugging protocol

Use a project with at least three independently diagnosable failures plus one integration
failure. Run a single-owner baseline first. Starting the coordinated trial requires explicit
operator authorization for delegation.

## Coordination contract

- The parent records each worker's non-overlapping file ownership and acceptance check before
  spawning it. Workers do not spawn descendants.
- One parent remains integration owner. It resolves shared-interface decisions, reviews every
  worker diff, runs the combined checks, and owns the final answer.
- Workers report reproduction, root cause, files changed, checks run, and unresolved risk.
- Stop spawning when work is coupled enough that coordination costs more than it saves.

## Trial

1. Capture the initial failing commands and assign only independent failure clusters.
2. Run two or three workers concurrently; preserve parent and child session IDs.
3. Integrate without overwriting another worker's changes, then reproduce the integration
   failure and repair it in the parent.
4. Replay every original failure, the full suite, and one interruption or worker-failure path.

## PASS evidence

- Raw parent/child transcripts prove concurrent work rather than a narrated decomposition.
- Ownership has no overlapping write paths; any reassignment is timestamped and explained.
- All original and combined checks pass with no hidden conflict resolution.
- Wall time, duplicated tool calls, conflicts, interventions, and regressions are compared
  with the single-owner baseline.

An attractive plan or several files written by one session is not multi-agent evidence.
