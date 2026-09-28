# Retrieval policy trial

Compare the previous Codex code-exploration paragraph with the selective retrieval
paragraph in the generated `AGENTS.md`. `create-experiment.ts` changes only that
section; both arms use the same tasks, model, effort, run count, and sandbox.

```sh
bunx @vercel/agent-eval@1.4.0 --dry agent-evals/retrieval-policy/baseline.ts
bunx @vercel/agent-eval@1.4.0 --dry agent-evals/retrieval-policy/selective.ts
```

Paid runs replace `--dry` with `--force`. Run the baseline first, freeze its
receipts, then run the treatment once. Do not select the best attempt per task.
Before paid runs, verify that the sandbox exposes the same TraceDecay tools and
index to both arms; otherwise this is an ambient-copy trial, not a retrieval
trial. No external source-sending tool is installed by this experiment.

Grade task correctness and verification coverage before comparing complete
coding-agent cost, tool calls, and duration. A treatment that loses a baseline
solve fails even if cheaper. Record tool availability, missing retrieval
excerpts, and whether agents read the supplied evidence before widening search.
These two existing fixtures are a wiring check, not representative proof across
TypeScript codebases or exact-symbol lookup. Do not promote a policy from this
small trial alone.

Source of the retrieval ideas: [jevgrep skill](https://github.com/dzhng/jevgrep/blob/main/skills/jevgrep/SKILL.md)
and [architecture](https://github.com/dzhng/jevgrep/blob/main/docs/architecture.md).
