## Compare implementations

Use one representative workload at the same public entrypoint. Pin the incumbent,
candidate, and fixture, and keep the evaluator outside both implementations. Use
[differential testing](../tdd/DIFFERENTIAL-TESTING.md) for observable behavior, errors,
and durable effects, and [quantify-impact](../quantify-impact/REFERENCE.md#optimization-experiments)
for paired measurements, worthwhile delta, and stop rule. If the decisive behavior
cannot be exercised in isolation, report the gap rather than treating a microbenchmark
as an adoption verdict.

An authorized comparison may use the candidate runtime or library in isolation;
leave project dependencies unchanged. Follow [prototype retention](SKILL.md#retention).
