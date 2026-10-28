# Measurement and decision records

Use before experiments in [jobs](jobs.md), [test signal](test-signal.md), or
[tooling](tooling.md). Choose a measurement proportional to the change, not a
mandatory benchmark campaign for a trivial deletion.

## Establish comparable evidence

Capture exact base/head and workflow revisions, event and checked-out ref, runner
image/architecture/resources, tool/browser versions, selected tests, workers/shards,
cache keys/state, and service/fixture inputs. Preserve first-attempt results separately
from retries, canceled runs, and infrastructure incidents. Label local versus hosted
measurements; developer-laptop timings cannot predict hosted queue time.

Separate three outcomes:

- **Feedback latency:** commit/event to meaningful failure or the final required result.
  Include queueing, dependency waits, setup, execution, aggregation, and upload when
  they block that result. Also report time to first useful failure.
- **Compute:** sum job execution time across runners; resource size and provider billing
  determine cost. Parallel execution can lower latency while increasing runner-minutes.
  Use current observed billing, not invented rates or CPU counts inferred from labels.
- **Protection:** retained contracts, first-attempt failure rate, caught negative controls,
  line/branch coverage on the same source denominator, and feedback deferred off PRs.

## Locate the critical path

For each DAG node, model `finish = max(predecessor finishes) + queue + execution`;
sources start at the measured workflow/event origin. Include waiting/setup inside
execution only once. The final result is the longest relevant path, not the sum of
parallel job durations. Provider timestamps help separate dependency wait from queueing.

Compute each job's slack to the final result. Shortening a 3-minute lint job does
not reduce a 12-minute browser gate if they already overlap; it may still save compute.
After removing a bottleneck, remeasure: another path can become dominant. Balance the
tail by moving/removing work, never by sleeping in the faster jobs.

## Run a fair experiment

Declare the hypothesis, primary metric, worthwhile delta, protection guardrails,
resource/cost ceiling, stop condition, and rollback before comparing results. Change
one lever or explicitly name interacting levers, such as runner size and worker count.

Alternate baseline/candidate order when practical; repeat comparable runs rather than
comparing an unusually cold baseline with a warm candidate. Measure cold and warm cache
cases separately and weight by an observed hit rate, not a best-case hit. Keep unrelated
builds, video renderers, and other test suites off the benchmark machine. Otherwise a
timeout may measure competition you introduced instead of the proposed configuration.

Report samples, raw durations, median, range, and tails only when sample size supports
them. Do not present a p95 from a handful of runs as a stable population estimate.
Keep failed/canceled samples visible; a fast failure is not a faster successful suite.
Select the simplest stable option within noise when no worthwhile gain is demonstrated.

## Retain the decision, not a dashboard ritual

Use the repository's existing evidence location. A useful row contains:

`point -> job/contract -> observation -> hypothesis -> experiment -> before/after -> decision`

Attach command/config and commit/run IDs, cache/resource conditions, failure controls,
sample limits, remaining detection risk, owner, and revert. For deferred work, name the
missing evidence and next bounded experiment. Use rejected results to avoid repeating
an unsuccessful optimization. No external service, recurring job, or agent is authorized
merely because ongoing measurement would be useful.
