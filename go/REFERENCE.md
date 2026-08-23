# Go reference

`/go` means actively carry a verified change through delivery. Keep one owner and one
loop: inspect evidence, verify, repair, repeat. Do not dispatch agents or recursive model
calls without explicit authorization.

## Select verification from the diff

Start with repository-native commands rather than this generic example:

```bash
bun run lint:fix
bun run type:check
bun test
```

Then add only checks implied by the changed surface:

| Surface | Evidence |
|---|---|
| Runtime behavior | Targeted test plus real entrypoint invocation |
| Browser/UI | Rendered intended path, loading/error/empty states, keyboard/a11y, console |
| CLI/TUI/report | Actual command or generated artifact, including one invalid input |
| Hook/skill/library | Representative consumer or fixture through its public seam |
| API/schema | Contract test, generated artifacts, compatibility check |
| Dependency | Lockfile, build, affected call sites, current security/advisory check |
| Docs/config | Parser, generator, renderer, or documented command |

For runnable behavior, use the real entrypoint and one credible failure or recovery path.
Implementation edits make earlier behavior evidence stale. Replay the affected path after
repair. Record a limit when the real entrypoint is unavailable rather than substituting a
claim based on code inspection.

## Review the complete change

After checks pass, inspect the diff against the requested outcome:

1. Scope and public contract.
2. Correctness, error paths, types, and credible boundary/race failures.
3. Security, privacy, accessibility, and rendered behavior when touched.
4. Test integrity and untested product behavior.
5. Unnecessary code, prompts, abstractions, dependencies, and generated-file edits.

Fix concrete findings and rerun affected verification. If a high-severity issue persists,
keep repairing or report the external blocker; do not declare success after an arbitrary
review-round cap.

## Delivery

Use `../commit-push-pr/REFERENCE.md` for preflight, explicit staging, conventional commit
format, push, PR creation, and PR body structure.

Before delivery:

- confirm the branch and target base;
- review staged diff and secret scan;
- include verification and real-use evidence in the PR body;
- rebase and use `--force-with-lease` when needed on the current user-owned feature branch
  without another permission prompt;
- never merge, use plain `--force`, or rewrite a default, shared, foreign, or concurrently
  owned branch without explicit permission.

For an explicit `/go`, monitor the PR checks in the foreground:

```bash
gh pr checks <number> --watch
```

Diagnose a failure from its logs, repair locally, rerun relevant checks, commit, push, and
watch again. Resolve actionable human feedback when it already exists. Stop after checks
and requested feedback are clean; do not poll for later approval or manufacture reviewer
comments.

## Handoff

Return the PR URL, CI state, verification commands, real-use result, and any genuine
limits. Do not add optional review artifacts or request reviewers unless the user asked.
