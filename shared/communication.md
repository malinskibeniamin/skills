# Protect reader attention

Use for human-facing plans, RFCs, PRs, reviews, replies, documents, and status updates.
Optimize total author-plus-reader effort, not generated volume. AI may help brainstorm,
draft, check facts, or edit; it does not supply the author's understanding or endorsement.

## First read

Lead with the answer, decision, result, or requested action. Give enough context for someone
who did not see the prompts. Default to the shortest useful response; 200 words is not a target.

Above **200 words**, put a brief of at most **120 words** first, covering only applicable items:

- **What / why:** the decision or outcome, who benefits, and why it matters now.
- **Risk:** the load-bearing trade-off, uncertainty, or rollout constraint.
- **Ask:** the specific input needed, or the next action and who owns it; say when none is needed.
- **Evidence:** the decisive observation or verification, with a pointer to detail.

Order remaining detail by importance. Link existing evidence; keep logs, diffs, inventories,
and background below the brief or in an existing appendix. Each paragraph must change a
reader's understanding, decision, or action. Required output schemas, urgent findings, and
safety evidence outrank default length budgets; omit empty template sections.

An explicit user word limit applies to the whole requested text, including its appendix.
Check the count with a tool such as `wc -w`; revise rather than trusting the model's estimate.
If required evidence cannot fit, name the conflict rather than silently dropping it.

## Own the meaning

- Check every claim against observed evidence; label inference, proposals, and unverified
  claims. Explain conclusions as observation -> consequence -> decision, not private reasoning.
- Preserve the author's intent, terminology, emphasis, and uncertainty when editing.
  Prefer focused corrections; wholesale rewriting needs a request, not an assumption that
  polished prose is better. Flag ambiguity instead of inventing the intended meaning.
- Never invent human endorsement, consensus, sign-off, opinions, or lived experience.
  Mark unresolved choices as proposals; do not claim that the author reviewed an AI draft.
  This adds no approval gate to already-authorized delivery.
- The sender owns every sentence they share. If a sentence cannot be explained or supported,
  revise or remove it. Label an unendorsed **AI-generated excerpt** as exploratory material,
  not a conclusion. Judge substance; an AI-detector score proves neither authorship nor correctness.

## Match the artifact

- **RFC / plan:** problem and stakes -> proposed decision -> alternatives and trade-off ->
  open questions -> verification and rollout. Distinguish proposed from shipped work;
  a retrospective implementation summary is not evidence of prior agreement.
- **PR:** value and reviewer focus before the change sketch; then observed verification,
  residual limits, blast radius, and rollback. A file-by-file changelog cannot replace the why.
- **Review / reply:** findings first, with evidence, consequence, and correction. Reply to
  feedback with the change made, a reasoned disagreement, or a concrete unresolved question;
  paraphrasing the comment is not an answer. Keep value judgments separate from defects.
- **Status:** result or blocker, decisive verification, and next action. Omit tool chronology,
  repeated conclusions, and claims of checks not run.

Use an existing diagram, focused diff, or concrete example only when it clarifies the decision.
Keep the same first-read budget across prose and an intent map; do not double the explanation.

## Protect attention while working

Use deterministic scripts, CLIs, libraries, or a small reusable app for regular, repeatable
work. Reserve agent judgment for irregular, uncertain, or ad hoc work. Fix slow checks and
feedback loops before hiding latency with more agents. Delegation still requires explicit
consent; once authorized, use only bounded lanes with a reason to run concurrently.
Keep one owner for synthesis; adding a communication-only agent is not the default.

## Sources

- [Run fewer agents](https://blog.exe.dev/etoomanythings): attention and feedback-loop cost.
- [I don't want to read what you didn't write](https://blog.colinbreck.com/i-dont-want-to-read-what-you-didnt-write/): context, voice, and understanding.
- [Inverted pyramid](https://owl.purdue.edu/owl/subject_specific_writing/journalism_and_journalistic_writing/the_inverted_pyramid.html): essential information first.
- [Clay's AI writing policy](https://www.clay.com/blog/ai-writing-policy): sender responsibility and reader time.

Length thresholds are harness defaults, not claims from these sources.
