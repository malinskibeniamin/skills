# Runtime verifier proof loop

Adapt [pstack's proof loop](../../vendor/pstack/skills/create-formal-verification-skill/SKILL.md#prove-it-before-you-hand-off)
to the mapped journey's decisive assertion. Assert the
[expected outcome](../../shared/verifiability.md#verify-against-the-original-contract);
driver success or a screenshot alone is not enough.

Reuse current evidence or run the same assertion on a known-bad
build, supported isolated fixture, or scratch break in a disposable copy of the real app. It must fail for the intended
behavior mismatch, not a launch, driver, or setup error. If it misses the break, repair the verifier and replay both.
Discard the scratch break and rerun on the original build to confirm its result. Report any original product failure
separately. If safe replay is unavailable, report sensitivity as unverified and name why.
