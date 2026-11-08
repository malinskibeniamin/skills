# Build-ticket graph

Use from [ticket breakdown](../to-tickets/SKILL.md) before publication and
[spec implementation](../implement-spec/SKILL.md) before selecting work. Decision tickets
remain with [wayfinder](../wayfinder/SKILL.md); this contract covers build slices.

- Read the complete ticket set and authoritative blocking relationships, not list order
  or copied map summaries. Resolve external blockers to their actual status.
- Check unique ticket identities, resolvable blocker references, self-blockers and cycles.
  A cycle or missing reference is a planning gap, not permission to discard an edge.
  Report the affected tickets and resolve only that gap before dependent work starts.
- The **frontier** is unfinished, unclaimed work whose blockers are satisfied. For this
  integration, a build blocker is satisfied only after its result is integrated and
  verified at the integration tip; an agent's completion message is not enough.
  For wide refactors whose agreed plan promises green only at final integration, use
  each batch's limited acceptance checks; retain the final integrate-and-verify ticket
  rather than inventing a per-batch full-green gate.
- Empty frontier with unfinished tickets means blocked, claimed elsewhere, or an invalid
  graph, not completion. Name the blocker/owner; preserve unrelated runnable branches.
- Before publication, show each slice's observable acceptance, what its test seam catches
  and misses, and genuine blockers. After publication, read back ticket links and native
  blocker edges (or the local `Blocked by` references) before handing off.
- Recompute from current ticket and integration state after each completed slice. Parallel
  readiness does not grant delegation or make overlapping state/files independent.

Keep dependencies in one authoritative representation. Use native edges when available;
text fallback is not a second graph to maintain alongside them.
