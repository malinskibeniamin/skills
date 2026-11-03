# Redesign the hot data path

Read for measured CPU, allocation, memory-bandwidth or locality bottlenecks in
runtime optimization. Web journeys keep [UX measurement](../ux-performance/MEASUREMENT.md);
library comparisons keep [performance analysis](../t3code-skills/performance-analysis/SKILL.md).
Compiler-type cost, network latency and rendering need their own evidence, not a
container rewrite. This pass guides experiments; it proves no speedup by itself.

## Find work before choosing containers

- Sample the running workload with the target's CPU/allocation profiler. Repeated
  debugger pause/resume can suggest where to look; distinguish runnable CPU work
  from waiting. Neither pause counts nor suspicious code spotted in a diff prove
  cost. Confirm candidates in a representative profile before redesigning them.
- Sketch the hot traversal: operations, cardinality/key density, fields touched
  together, bytes read/written, allocations, pointer hops, ownership and lifetimes.
  Identify the limiter: repeated work, algorithmic scaling, allocation, dependent
  loads, bandwidth or synchronization. Use hardware counters when available;
  otherwise label locality/vectorization explanations as hypotheses.
- Delete work and passes first. Then compare a materially different representation,
  not just a faster spelling of the same design. SIMD, batching or parallelism come
  after eliminating unnecessary work and arranging data for the actual access pattern.

## Think bigger than local tuning

"Think bigger", "1% is not enough" or "this should be 10x faster" means reopen the
design, not accumulate micro-optimizations. Adopt the requested scale as the target
for the same operation, workload and correctness contract. Do not silently lower
it to whatever improvement the first patch achieves, or impose 10x on unrelated
tasks that already have an agreed worthwhile delta.

Work backward from the target: for 10x lower latency, budget one tenth of the
baseline time. If untouched critical-path work already exceeds that budget, a
local rewrite cannot reach the goal. Widen the search within authorized scope to
the dominating algorithm, representation or pipeline boundary, not another small
loop. Compare the current design with the simplest cache-free design built for
this workload: eliminate repeated passes/parsing, change algorithmic scaling,
avoid intermediate materialization, batch boundary crossings or remove per-item
allocation/indirection. Choose a falsifiable hypothesis whose ceiling can plausibly
meet the target before polishing it. A rewrite earns its scope from that evidence,
not from size or novelty.

A 1% patch is not completion of a 10x task. Keep it only as a justified stepping
stone, then test the higher-ceiling design. If experiments miss the target or a
hard lower bound rules it out, report **target unmet**, the limiting evidence and
the next structural option. Ambition is a search direction, never permission to
fabricate speedups, benchmark less work or weaken semantics and guardrails.

## Make uncached work fast

Default to redesign, not another computation cache. Inventory memo tables and
derived-result caches on the measured path, including key construction, lookups,
misses, invalidation and retained bytes. Target their removal with a cache-free
algorithm/layout; benchmark that candidate against the original, including misses
and updates. Do not add a result cache to rescue a failed redesign experiment.
Keep a deletion when correctness and the declared performance guardrails pass;
otherwise report the failed hypothesis instead of claiming success.

An explicit no-cache request is a hard constraint: add none, and remove in-scope
computation caches through redesign or report why the target was not met. Keep
unrelated caches outside the edit. HTTP/CDN caching, query ownership/deduplication,
offline persistence and authoritative state are different contracts, not disposable
memo tables. Preserve freshness, authorization and user-visible behavior when
changing them. CPU hardware caches are locality to exploit, not caches to delete.

## Choose storage by access and lifetime

These are preferred experiments when their preconditions fit, not global rewrites.

| Current cost | Redesign to test | Constraint that can defeat it |
| --- | --- | --- |
| Hashing dense bounded IDs, pointer-heavy nodes | Flat contiguous storage with direct indexing; sorted vectors or sparse-to-dense mappings when appropriate | Sparse huge key spaces, arbitrary keys, order, lookup/update mix and mapping maintenance |
| Pointer chasing between records | Array-index handles into an owning slab/arena; flatten adjacency into ranges | Relocation, deletion, slot reuse, stable identity and external references |
| Fetching cold fields while scanning a few hot fields | Hot/cold split, structure of arrays (SoA), or tiled AoSoA instead of array of structures (AoS) | AoS can suit whole-record access; conversion, gathers and synchronized mutations can erase a win |
| Per-object allocations with a common lifetime | Arena/region storage with an explicit reset boundary | Retained high-water memory, escaping references, destructor/resource cleanup and thread ownership |
| Heap lists used as small temporaries | Fixed stack buffer or inline-capacity small vector sized from observed lengths | Inline storage lives with its owner, not necessarily on stack; spill, large stack frames, recursion and copying |
| Dense boolean flags or membership | Word-backed bitset; word-wise intersection, scan or population count when useful | Sparse domains, per-bit mutation overhead, tail bits and concurrent updates sharing a word |

For SoA, preserve row identity, equal lengths and coordinated insert/delete/reorder
across columns. Measure conversion at the owning boundary, not only the inner loop;
[Intel's layout guidance](https://www.intel.com/content/www/us/en/developer/articles/technical/memory-layout-transformations.html)
explains why access patterns decide between AoS, SoA and AoSoA.

For arena-backed data, use stack/inline scratch for shorter-lived temporaries so
they do not accumulate until the arena resets. Arenas commonly support **bulk**
reset/free but not individual reclamation; inspect the actual allocator rather
than assuming either behavior. Reset only after all users finish and perform
required resource cleanup; [bumpalo](https://docs.rs/bumpalo/latest/bumpalo/)
illustrates a bulk-reset allocator that does not automatically run destructors.

Use the target's existing containers, such as
[LLVM's inline vectors and bitsets](https://www.llvm.org/docs/ProgrammersManual.html#picking-the-right-data-structure-for-a-task),
before adding a dependency or hand-building one. Test zero length, inline-capacity
overflow and non-word-aligned bitset sizes; never truncate silently to fit a buffer.

## Pack handles only with a proven budget

When a hot lookup reads metadata before dereferencing, test packing frequently
used flags/kind into the upper bits of an **integer index handle**. State the word
width and bit budget for index, tags, optional generation and invalid sentinel;
derive maximum capacity. Centralize encode/decode and mask before indexing. Test
round trips at zero/max index, every tag, sentinel, overflow and deleted/reused
slots. Keep generations or another stale-handle defense where identity survives
deletion; account for wraparound. Do not steal bits from raw pointers or change a
public/persisted ID format as an incidental optimization. Compare saved loads and
bytes against masks, shifts, capacity limits and mutation complexity.

Respect the runtime: an array of object references is not packed record storage.
JavaScript typed arrays can provide contiguous numeric columns/bitsets, not native
stack allocation. Number bitwise operators use 32-bit integers; ordinary numbers
also have safe-integer limits. Choose and validate widths before packing; measure
BigInt rather than assuming it is free. See
[JavaScript bitwise semantics](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Bitwise_AND).

## Prove the whole-operation gain

Keep one causal experiment at a time. Add a failing public-contract test for any
changed behavior before implementation; prove representation invariants with
boundary or differential tests against an independent reference. Preserve ordering,
identity, errors, ownership and concurrency semantics.

Pair baseline/candidate in the same optimized build, fixture and environment under
[quantify impact](../quantify-impact/SKILL.md). Include construction, conversion,
mutation, reclamation and representative sparse/dense or small/large workloads
where relevant, not only a prebuilt steady-state scan. Separate warm/cold CPU
working sets from application-cache hits/misses. Observe latency/throughput plus
allocation count/bytes and peak/retained memory; check end-to-end impact and tails.

Report the limiter, old/new representation, invariant tests, command/fixture/refs,
run count/spread, worthwhile delta and trade-offs. Keep only a repeatable worthwhile
win without guardrail regressions; revert speculative complexity when unproven.
Carry the new profile into the next experiment, not the old bottleneck assumption.
