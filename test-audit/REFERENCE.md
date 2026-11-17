# Test diagnosis and deletion evidence

Load the relevant section from [test audit](SKILL.md) before repairing flaky checks or deleting coverage.

## Flaky checks

A diagnostic rerun tests a stated cause; retry-until-green is not verification. Preserve
the first failure, control state/time/randomness at existing seams, replace sleeps with
observable conditions, and replay from clean state after repair. Never silently skip,
loosen assertions, add sleeps or raise retries to claim a pass.

If the root cause remains unknown, report the failing check and uncovered contract under
the [repair limit](../shared/verifiability.md#choose-the-evidence-loop). Quarantine/deletion
needs the repository owner's policy and the [candidate evidence](SKILL.md#candidate-evidence); a flaky result alone
does not justify removing a real regression. Leave the coverage gap visible.

## Candidate evidence

Record every field below before editing. A missing field means the candidate is not ready for deletion:

- exact test name and location;
- what failure it can actually detect;
- non-test callers of the covered production or support seam;
- stronger remaining owner-boundary proof, or why no proof is needed;
- relevant history and the reason the test or seam exists;
- production or test-support deletion unlocked;
- risk and the focused validation command.
