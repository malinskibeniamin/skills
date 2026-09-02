# Design-rationale research

Recover rationale from evidence. First determine how the current system works; then ask
why the choice exists.

## Frame the question

- Name the decision, behavior, regression, or threshold being explained.
- Anchor it to exact code, configuration, incident, metric, or user-visible behavior.
- State the time range and plausible alternatives. Do not assume the current state was
  intentional.

## Establish the code trail

Start with code and source control first.

1. Locate the owning symbol and current behavior with the repository's indexed search.
2. Inspect blame, commits, pull requests, and diffs around its introduction and later
   changes.
3. Use commit messages as leads, not proof. Follow linked issues and documents.

## Expand evidence lanes

Discover available local tools and connectors. Search each relevant, available lane; a
negative result is evidence. Do not claim a lane was searched when access was missing.

| Lane | Look for |
|---|---|
| Issue tracker | requirements, alternatives, acceptance criteria, linked incidents |
| Long-form docs | RFCs, ADRs, product decisions, migration plans |
| Real-time chat | contemporary trade-offs, operational context, unresolved dissent |
| Observability and error tracking | when behavior changed and what failed |
| Product analytics | data-backed thresholds and measured impact |

Research inline. Parallel tool calls are fine. Parallel agents require explicit delegation
or `/swarm`; this workflow never grants it.

## Synthesize without inventing intent

Classify every material conclusion:

- **Direct evidence** -- a source explicitly states the reason.
- **Inference** -- evidence supports the reason but no source states it; include confidence.
- **Contradictions** -- sources disagree or implementation diverges from recorded intent.
- **Unknowns** -- missing records, inaccessible lanes, or unanswered causal links.

Prefer contemporary evidence over retrospective summaries. Distinguish why the choice was
made from why it remains today.

Lead with the answer, then provide the evidence chain. End with **Sources consulted**, a
coverage list marking each relevant lane as searched, unavailable, or skipped with reason.
Name paths, commits, tickets, documents, timestamps, and metric windows precisely.
