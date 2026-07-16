# React/frontend pattern mining — cloudv2, console, ui-registry (2019 → 2026)

Evidence base for encoding the company's frontend engineering taste into this harness (hooks, skills, exemplars). Produced 2026-07-16 by mining:

- **Commits**: 10,624 frontend commits across `cloudv2` (apps/cloud-ui, adp-ui, admin-ui, adp-console, tests/e2e-ui), `console` (frontend/), and `ui-registry` — themed diff-reading passes weighted by author (see `author-weights.md`).
- **PR review comments**: the complete universe — 39,742 comments (cloudv2 35,273 + console 4,089 + ui-registry 380); 100% of frontend comments read or mechanically classified.

## Read this first

**`findings/durability-map.md`** — stratifies everything into Tier 1 timeless invariants (encode unconditionally), Tier 2 current-stack rules (encode in stack-tagged, wholesale-replaceable groups), Tier 3 superseded dead-stack guidance (never encode; ban-list instead). The corpus spans seven full stack migrations (Chakra→shadcn/Base UI, RTK Query→connect-query, Formik/Yup→RHF/protovalidate, react-router→TanStack, MobX/Redux→zustand, React 18→19, CRA/jest→rsbuild/vitest); any quoted guidance carries its era.

## Contents

| File | What it holds |
|---|---|
| `HANDOFF.md` | Implementation entry point: contradiction fixes, hook candidates, skill/exemplar additions, next actions |
| `author-weights.md` | User-assigned quality weights (Engineer A 10 → Engineer K 2) used to weigh evidence |
| `findings/durability-map.md` | The timeless / current-stack / superseded stratification |
| `findings/pr-contention.md` | 46 findings (C1-C46) + 3 grilling questions from 100% review-comment coverage, 2020-2026 |
| `findings/data-fetching.md` `forms.md` `routing-state.md` `errors-resilience.md` `testing.md` `design-taste.md` `architecture-evolution.md` | Themed deep-mines of the commit corpus, each pattern with 3+ SHA evidence |
| `findings/pr-craft-and-reviews.md` | PR body/title/size conventions + review-feedback taxonomy (400 merged PRs) |
| `findings/engineer-b.md` `engineer-c.md` `engineer-d.md` `remaining-authors.md` | Per-author taste profiles for the full weighted roster |

## Reproducing the corpora

Commit lists: `git log --author=<x> --pretty="%h|%ad|%s" --date=short -- <frontend paths>` in each repo (redirect to a file — piped git output gets truncated by the local rtk filter). Review comments: `gh api --paginate "repos/ORG/<repo>/pulls/comments?per_page=100" --jq '<slim TSV projection>'`.
