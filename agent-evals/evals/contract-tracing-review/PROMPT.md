# Task

Use the installed `review` skill to review the synthetic `change.patch` against
the PR-head checkout under `repo/`.

The patch is the complete diff. Files present only under `repo/` are unchanged
fictional repository context. Produce `review.md` with only high-confidence, actionable,
diff-introduced findings. Do not edit source files. Run available checks, but do not treat their passing result as a substitute for tracing the behavior contract.
