# Task

Use the installed `review` skill to review the synthetic `change.patch` against
the PR-head checkout under `repo/`. The patch is the complete diff.

Requirements: each nonempty structured filter matches its corresponding field
exactly. The optional text query searches the summary case-insensitively after
trimming the query. Empty filters impose no restriction.

Write `review.json` with `findings` (an array of high-confidence, actionable,
diff-introduced findings with `file`, `line`, `title`, and `severity` fields) and
`verification` (a string describing checks, results, and limits). Do not edit source files.
