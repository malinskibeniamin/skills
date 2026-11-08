# Prompt and tool-description optimization

Use within the [hill-climb contract](../SKILL.md), authorized scope and shared budget.

For prompt/tool-description optimization:

1. **Derive the eval:** categorize real failures from authorized history through supported
   tools; redact private data in reusable fixtures. Assert expected behavior and, for tool
   routes, tool choice, arguments, target and side effects. Include valid controls and
   confusable alternatives, using the full relevant tool inventory and current schemas.
   Refresh stale contracts before baselining.
2. **Stabilize correctness:** declare supported models, routes and deployed discovery/tool-search
   modes. Repeat cases across that matrix; report per-case sample pass rates as well as case
   coverage. One lucky pass is not reliable correctness; missing cells remain unverified.
   Within authorized edit scope, retain the regression suite in existing tests/evals and save
   the passing instruction checkpoint before compression.
3. **Compress:** freeze that suite and tool inventory as guardrails. Reduce context
   incrementally, rerunning controls and held-out cases across the declared matrix. Measure
   actual injected tokens per mode, not only file size. Shorter instructions that worsen
   tool choice lose; evaluator repairs must retain valid and known-bad controls.

Use [writing for agents](../../writing-for-agents/SKILL.md);
model/context-route changes retain [efficient frontier's evaluation gate](../../efficient-frontier/SKILL.md#promotion).

Source: [Theo's walkthrough](https://x.com/theo/status/2118465321032106235), 26:37-30:27.
