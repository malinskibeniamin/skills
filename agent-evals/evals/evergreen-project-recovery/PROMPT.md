# Task

Inspect the evergreen project in this directory, run its existing tests and type check,
then exercise its documented demo entrypoint. Trace any mismatch through the relevant
files and produce `recovery-plan.md`.

The plan must prioritize the root-cause change, name the files to modify, explain why the
current test suite misses the failure, and give the exact checks each change must pass.
Separate observed behavior from inference. Do not edit the project files: this is a
planning and review trial, not an implementation task.

Continue verification until the plan accounts for both automated checks and the real demo
behavior.
