# Execute, reconcile, and publish

## `execute <plan>`

Explicit execution exits advisor mode and hands the outcome to the current single owner
through `/development-lifecycle`. Read the plan and dependency status, check its recorded
revision against current files, and refresh stale assumptions before editing. Preserve the
requested scope and endpoint; verify the original criteria rather than merely completing
steps. Record justified deviations and actual command results in the plan index when the
plan endpoint includes maintaining it.

Delegation requires separate explicit consent or `/swarm`. If authorized, give the executor
the complete plan, owned paths, current evidence, acceptance criteria, and stop conditions;
the primary owner verifies the integrated result. Do not infer delegation from `execute`.
For repeated failed attempts, use `/agent-watchdog` takeover mode rather than cycling a
stale plan. No execute or reconcile invocation implies merge permission.

Reconcile and issue publication remain advisor operations, with only the artifact or remote
mutations explicitly requested below. For open PR/issue audits and authorized closure,
read [backlog.md](backlog.md).

## `reconcile` -- keep `plans/` alive

Process what happened since the last session. Read `plans/README.md` and every plan file, then per status:

- **DONE** -- spot-check that the done criteria still hold on the current HEAD (cheap ones only). Mark verified in the index. Don't delete plan files -- they're the record.
- **BLOCKED** -- read the reason. Investigate the underlying obstacle in the codebase. Either rewrite the plan around it (new number if the approach changed fundamentally, in-place refresh otherwise) or mark REJECTED with one line of rationale.
- **IN PROGRESS** (stale) -- flag it to the user; an executor probably died mid-run. Check the worktree if one exists.
- **TODO** -- run the drift check. If drifted: re-verify the finding still exists (it may have been fixed in passing), then refresh the "Current state" excerpts and `Planned at` SHA. If the finding is gone, mark REJECTED ("fixed independently").

Finish with a short report: what's verified done, what was refreshed, what's rejected, and what's executable right now.

---

## `--issues` -- publish plans as GitHub issues

Modifier on any planning invocation (`/improve --issues`, `/improve security --issues`). The flag is the user's authorization to create issues -- never create them without it.

1. Preflight: `gh auth status` succeeds and the repo has a GitHub remote. If either fails, write the plan files as normal and say why issues were skipped.
2. Show the list of titles about to become issues; confirm once if interactive.
3. Per plan: `gh issue create --title "<plan title>" --body-file <plan file>`. Labels: `improve` plus the category -- apply only if the labels exist or can be created without erroring; skip labels rather than fail.
4. Record each issue URL in the plan's Status block (`- **Issue**: <url>`) and the index.

The plan file remains the source of truth; the issue is distribution. The self-containment rule pays off here -- the issue body needs no edits to make sense to whoever (or whatever) picks it up.
