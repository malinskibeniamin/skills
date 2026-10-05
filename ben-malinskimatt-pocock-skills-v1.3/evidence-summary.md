# Matt v1.3 adoption evidence

Decision: adopt glossary naming and reliable dependency loading, not overwrite local workflows. All 27 published registrations already had local adaptations. The 25-session sample favors TDD, PR writing, review and domain modeling. Applied targeted loading/setup changes; retro/spec remain human-requested. Future compliance and productivity gains are unproven. Translation freshness and unrelated browser-baseline failures remain disclosed. No downstream repository migration or plugin install.

## Intent map

Published release + bounded session evidence -> glossary/loading decision -> current consumers/setup and lifecycle/delivery guidance -> artifact RED/GREEN checks and rendered comparisons. Local endpoint/TDD and opt-in delegation rules constrain adoption; frozen releases remain unchanged.

## Pinned upstream comparison

- [v1.3.0](https://github.com/mattpocock/skills/releases/tag/v1.3.0): `984a2c023c9fb42bb6ea40c70a652284a109dc05`.
- 37 upstream folders; 27 registrations covered by 25 distinct local counterparts. Three additional in-progress writing skills adapted; seven unregistered WIP/misc folders not vendored.
- All 30 mapped SKILL files differ textually. Of 85 comparable source/support/metadata files, 84 differ; one credits file identical; none missing after package-path mapping. Textual adaptation is not certified behavioral equivalence.
- `implement` -> `development-lifecycle`; `code-review` -> `review`; setup -> `work-automation-kit`; grilling wrappers consolidated. Preserve local verification, tracker integration, delivery endpoints, frontend evidence and explicit delegation boundaries.

## Applied recommendations

- Rename glossary and format/map pointers together; preserve domain definitions.
- Setup recipe includes graduated/core skills; external PR/MR queue discovery defaults off.
- Claude invokes required dependencies separately; Codex reads complete canonical guidance through generated proxies. Reuse already-loaded guidance; recover missing context after compaction.
- Ordinary tickets keep lifecycle -> TDD -> inline review -> requested delivery. Recommend retro only after an evidenced gap; whole-spec delegation requires approved independently verifiable blocker graphs and explicit human request.

## Usage sample

25 most recently active locally available human-root sessions, excluding this audit, sidechains and subagents: 21 Codex, 4 Claude. Count each skill once per session. Exclude inventories, compaction replay, duplicate text and source-only inspections. Remote-only histories are outside this sample.

| Matt-derived guidance | Sessions /25 |
|---|---:|
| TDD | 19 |
| PR | 13 |
| Review | 11 |
| Domain modeling | 10 |
| Diagnosing bugs | 7 |
| Writing for agents | 5 |
| Grilling | 3 |
| Codebase design | 1 |
| Architecture improvement | 1 |
| Prototype | 1 |

These are guidance-load attempts, not successful execution, compliance or time saved. No explicit human request or Claude Skill invocation of a Matt-derived skill detected; agents mainly loaded these disciplines within local workflows. Absence does not prove never used.

An inline retrospective of one review-heavy session found truncated guidance retrieval and later proxy/canonical recovery. This supports the loading contract, not a missed-defect or productivity claim. Next-task comparison is not yet observed. Private prompts, identifiers, transcript paths and repo names are excluded.

Rollback: revert the feature commits together; glossary and consumer pointers must stay aligned.

## Complete skill map

| Upstream | Local | Registered in v1.3 | Difference |
|---|---|---|---|
| ask-matt | ask-ben | yes | adapted |
| code-review | review | yes | adapted |
| codebase-design | codebase-design | yes | adapted |
| diagnosing-bugs | diagnosing-bugs | yes | adapted |
| domain-modeling | domain-modeling | yes | adapted |
| grill-with-docs | grilling | yes | adapted |
| implement | development-lifecycle | yes | adapted |
| implement-spec | implement-spec | yes | adapted |
| improve-codebase-architecture | improve-codebase-architecture | yes | adapted |
| pr | pr | yes | adapted |
| prototype | prototype | yes | adapted |
| research | research | yes | adapted |
| retro | retro | yes | adapted |
| setup-matt-pocock-skills | work-automation-kit | yes | adapted |
| tdd | tdd | yes | adapted |
| to-spec | to-spec | yes | adapted |
| to-tickets | to-tickets | yes | adapted |
| triage | triage | yes | adapted |
| wayfinder | wayfinder | yes | adapted |
| wizard | wizard | yes | adapted |
| claude-handoff | not vendored | no | not vendored |
| loop-me | not vendored | no | not vendored |
| setup-ts-deep-modules | not vendored | no | not vendored |
| writing-beats | writing-beats | no | adapted |
| writing-fragments | writing-fragments | no | adapted |
| writing-shape | writing-shape | no | adapted |
| git-guardrails-claude-code | not vendored | no | not vendored |
| migrate-to-shoehorn | not vendored | no | not vendored |
| scaffold-exercises | not vendored | no | not vendored |
| setup-pre-commit | not vendored | no | not vendored |
| grill-me | grilling | yes | adapted |
| grilling | grilling | yes | adapted |
| handoff | handoff | yes | adapted |
| teach | teach | yes | adapted |
| to-questionnaire | to-questionnaire | yes | adapted |
| wait-what | wait-what | yes | adapted |
| writing-for-agents | writing-for-agents | yes | adapted |

The accompanying upstream-vs-local before/after unified diffs cover full skill and support text, not only this branch delta. Do not apply them as patches: local adaptations are intentional. No productivity claim.
