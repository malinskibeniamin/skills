# Commit-push-pr reference

When finishing or recovering another agent's local-only work, follow
[remote completion](../shared/remote-completion.md) before reporting delivery.

## Pre-rebase check

Resolve the PR base, then run `<plugin-root>/scripts/rebase-cost-preflight.sh <base-ref>`
(this repository root while developing the skill). Repeated paths are a heuristic, not
measured conflict or token savings. Before rebasing an ordinary coherent owned PR, use
the guarded consolidation below rather than replaying every fixup conflict separately.

## Automatic rebase

During delivery, feedback repair, or authorized monitoring, inspect the current PR's real
base, not an assumed default. Missing base commits trigger rebasing even when branch
protection does not report `BEHIND`, and even with no new review feedback.

1. Confirm ownership of the current non-default feature branch, a clean worktree, no active
   git operation or concurrent owner, and local HEAD equal to the published PR HEAD. Record
   that published SHA for the push lease. Defer unsafe ownership/worktree states visibly;
   never stash, reset, or switch another worktree to make them eligible.
2. Fetch origin and run the pre-rebase check. Inspect relevant base changes since divergence
   for superseded intent or changed ownership/contracts, even without textual conflicts.
   Stop obsolete work before rewriting; a materially different product/architecture choice
   needs its owner, not a mechanical rebase. For a coherent linear branch whose commits
   belong to the current Git identity, consolidate before rebase:
   `<plugin-root>/scripts/pr-maintenance-squash.sh <fetched-base-ref> <observed-pr-head>
   "<conventional-commit-message>"`. The helper retains the tree and reflog recovery,
   uses compare-and-swap ref mutation and never resets/stashes. A default/base branch,
   dirty tree, active operation or changed HEAD fails closed. Foreign authorship, merge
   topology and stack/dependent boundaries must be preserved: skip consolidation visibly
   when ineligible and choose the safe topology-preserving rebase, not a blind squash.
   Rebase onto the fetched PR base. Resolve routine conflicts from feature intent,
   tests, and current base behavior, not blanket `ours`/`theirs`. Continue without asking
   the human to click Update branch or approve a routine rebase. Only a genuine access,
   ownership, or material owner-reserved semantic decision blocks this work.
3. Inspect the final base diff and compare the saved pre-rebase series with `git range-diff`,
   accounting for intentional consolidation. Confirm intended behavior survived and no
   already-landed or retired behavior was reintroduced. Rerun affected tests and repository
   checks; refresh invalidated review/visual evidence.
   Push immediately with `git push --force-with-lease=refs/heads/<branch>:<observed-pr-head>
   origin HEAD:refs/heads/<branch>`. A rejected lease means remote work changed: inspect it,
   never retry with plain force or silently refresh the lease.
4. Re-read the PR; verify published HEAD matches local HEAD and includes the target base.
   Keep draft state and the same PR; take the endpoint's CI action. A later base advance
   becomes the next maintenance pass, not proof that the completed rebase failed.

Enabled [local PR maintenance](../resolve-pr-feedback/AUTO-REVIEW.md) also wakes the original
bound session for base advances and failed CI. Prefer the host-authorized native watcher;
ordinary delivery does not silently install or enable a persistent local job.
Stack descendants remain outside the current branch's authorization.

## Review evidence (Phase 0 pre-flight)

For an existing review-gate plan or opted-in consumer, refresh [gate evidence and its
generated PR block](../review/GATES.md) on the published candidate. Use the validated
state, not a hand-written approval table. Preserve human context and expose actual
executor/model, skips and missing/stale evidence. Do not enable agents or a new review
profile as a publication side effect. An agent result never implies human sign-off.

Before the PR endpoint, run applicable self-review axes with their owning skills. Use
[authorized council review](../shared/TSTACK.md#council) when requested; keep its independent
reports separate from author self-review. Without delegation consent, review inline:

- `/review` -- correctness, value (`/product` hat), and maintainability
- `/improve-codebase-architecture` -- deep-module and invariant redesigns that remove error classes
- `/prototype` -- redesign module or layout
- `/visual-review` -- multi-hat review for frontend/visual/customer-facing surface diffs

For customer-facing changes, inspect affected rendering with `/visual-review` at the
risk-appropriate depth. Apply [proportionate verification](../shared/verifiability.md#proportionate-verification):
a small label/style edit does not automatically need screenshots, video, new visual tests,
or an evidence waiver. Preserve explicit project/user requirements; report real limits.

A named review skill is guidance, not a separate approval gate. Self-review loads
`/review` through author delivery; a standalone review request remains read-only.
Architecture prototypes remain conditional. For backend/API/Protobuf/contract or data-flow
changes without screenshots/video explaining the affected behavior, include
[backend diagrams](../excalidraw-diagram/PR-WORKFLOW.md). Show the changed contract, ordering,
or ownership; a UI screenshot alone may leave these relationships unexplained.

## Conventional commit types (Phase 3)

Group changed files by purpose:

| Type | Matches |
|------|---------|
| `docs` | *.md, SKILL.md, REFERENCE.md, comments-only changes |
| `test` | *.test.ts, *.test.tsx, *.spec.ts, EVAL.ts, agent-evals/ |
| `refactor` | restructure, no behavior change |
| `style` | formatting, whitespace, lint-only fixes |
| `fix` | bug fixes, error corrections |
| `feat` | new features, components, endpoints |
| `chore` | config, deps, build scripts, tooling |
| `perf` | perf improvements |
| `ci` | CI/CD pipeline changes |
| `build` | build system changes |

File fit multiple -> pick most specific.

## Auto-label map (Phase 5)

Use the [repository metadata contract](references/metadata.md) for every PR, including
drafts: repository conventions before generic type labels, self-assignment, and team-first
CODEOWNERS review routing. It also owns draft deferral and metadata readback/recovery.

## PR body template (Phase 5)

Run `/quantify-impact` for every PR, including non-UI changes. Use the
[compact PR contract](../shared/communication.md#match-the-artifact): one opening sentence
and only essential supporting bullets. The template is the default, not a checklist of
sections to expand.

Apply `/pr`'s [human-review handoff](../shared/review-contract.md#human-review-handoff)
after self-verification: assess all five criteria and surface the closest-review paths.
Keep sensitive-path owner requests/deferred routing current through the metadata contract.

```
gh pr create --base <base> --assignee @me --title '<concise outcome>' --body "$(cat <<'EOF'
<one sentence capturing the entire change and why it matters>

- Lane: <Keep the lights on | Quality of life | Feature | Taste>; <scope alignment/deviations, review focus and owner routing/gaps>; see `/product`
- Testing: <decisive tests, real-entrypoint/computer-use evidence, results and gaps>
- Risk: <door, blast radius, rollout limits, rollback/recovery, production error detection and gaps>
EOF
)"
```

Place useful or explicitly required visual media inline after the opening; follow
[visual evidence](#frontendcustomer-facing-detection--screenshot-table-phase-5).
Routine visible edits need no automatic media bundle.

Link long logs/matrices and specialist receipts, or put them in one collapsed
`<details>` block. Retain the current dogfood receipt for runnable changes, dependency
upgrade evidence for dependency diffs, stack context for dependent PRs, and material
changed decisions. These are conditional evidence, not default expanded sections.
Measured impact uses `/quantify-impact`'s `## Proven impact` table and method; unsupported
performance claims retain `Value not proven`. Keep test status, material risks, and
rollback visible. No commit dump, repeated rationale, or separate recap artifact.

Use a body file for long bodies rather than fragile shell quoting. For native media, pass
each referenced local file with `--attach <path>` on create or edit. GitHub CLI rewrites
those references to uploaded assets; keep the video image reference alone in its paragraph
to render a player. Updates use `gh pr edit <number> --body-file <file> --attach <media>`;
preserve user-authored context outside the evidence sections. Without a body flag,
`gh pr edit <number> --attach <media>` appends media and preserves the existing body.

Append `--label <label1> --label <label2>` per repo-verified label. For non-drafts, append
verified team-first `--reviewer <org/team>` handles; drafts record deferred routing instead.

Resolve `<base>` with `scripts/resolve-pr-base.sh` from the plugin root. For a stack layer,
this is the branch immediately below it, not the stack trunk. Ordinary `/commit-push-pr`
publishes only the current layer; `gh stack submit` belongs to an explicit `/stacked-prs`
endpoint because it can publish every unsubmitted branch.

**Draft mode**: changes look WIP (TODO comments, incomplete impl, test stubs) -> add `--draft`.

The compact body follows `/pr`; its conditional evidence requirements still apply.

## Frontend/customer-facing detection + screenshot table (Phase 5)

Select evidence for the visual risk, not every visible pixel. Inspect affected rendered
behavior and shared consumers; a routine label/style edit needs no automatic media set,
new runner or snapshot. Preserve existing required checks and explicit user/project evidence.

1. **Scope:** resolve the real PR base (parent for stacks) and inspect the complete diff,
   including staged/unstaged/relevant untracked work. Identify affected surfaces and states;
   expand to viewports, themes, keyboard or failure paths only when the change warrants it.
2. **Check:** run relevant existing visual tests when applicable. Inspect mismatches before
   intended baseline updates, then rerun normally. Never bulk-accept or weaken assertions
   to pass. Add a new case/runner only for a credible uncovered risk, not every visible edit.
3. **Capture when useful:** prefer one focused screenshot or comparable base/candidate pair.
   Use real revisions, matching fixtures/state/viewport/theme; wait for readiness, not sleeps.
   Reuse current captures. Reconstruct a needed base without disturbing the active worktree;
   never fabricate a before image or alter fixture data to manufacture a difference.
4. **Record only when needed:** use video for requested demos or interaction/motion that
   stills cannot adequately explain. Follow [review-video storytelling](VIDEO.md) and
   `scripts/pr-video.sh` for real capture/composition. Do not automatically create a video,
   GIF, flow file, annotated copy and HTML report for the same change.
5. **Diagram fallback:** backend/API/Protobuf/contract, architecture, data-flow or workflow
   changes without explanatory captures require a source-grounded architecture, sequence or
   flow diagram inline after the opening. Follow [backend diagrams](../excalidraw-diagram/PR-WORKFLOW.md):
   prefer Excalidraw; use inline Mermaid when export/hosting is unavailable. No rendering
   tool or upload failure silently waives the explanation. Mixed changes need a diagram
   too when captures do not explain the changed non-UI contract.
6. **Summarize:** put the decisive command/result and material limits in the existing PR.
   Include only media that helps the reviewer, with a short previous -> new claim. Keep
   captures/logs in temporary or ignored scratch unless requested, already required, or a
   reusable maintenance asset. Refresh only evidence invalidated by subsequent edits.

When publishing media, use repository-approved hosting and check privacy/access. Native
GitHub CLI attachments support inline MP4: put `![](<local MP4 path>)` alone in its
paragraph and pass `--attach <media>` with `gh pr create/edit --body-file <body>`.
`scripts/pr-video.sh attach [--body-file <body>] <media>` uses that path; its `publish`
command provides SHA-pinned image/GIF hosting on `pr-evidence` without touching the PR
branch. Never publish private evidence without authorization. Re-read the hosted body;
local paths and localhost links are not reviewer-accessible proof. CLI readback proves
publication, not playback. Do not launch a browser just to verify publication.

Before completion, `lifecycle-stop.sh` reads the hosted body and runs
`scripts/pr-visual-evidence.py`: include a hosted Markdown image/video, HTML image/video,
standalone GitHub attachment URL, or a non-empty inline Mermaid diagram. For docs-only,
formatting, mechanical or other changes with no behavior/contract/relationship delta,
use `Visual evidence: not applicable - <concrete reason>`. A routine UI edit with no
useful capture may use that exception; eligible backend changes may not. Exemptions
are reviewable author assertions, not machine-verified scope. The gate checks presence,
not diagram correctness, accessibility or coverage; author/review still owns those.
Commit/push-only and genuine blocked/awaiting-decision endpoints retain their stops.

Optional capture/annotation/hosting gaps do not block an otherwise verified change;
required diagram explanations use inline Mermaid instead.
A missing explicitly required check remains a named gap needing the owner's decision,
not a fabricated PASS or permission to relax repository policy.

### Visual annotations

Use annotations only when requested or needed to locate a non-obvious delta in media
already worth retaining. A clear screenshot and caption need no annotated duplicate or
legend. When annotations help, use the following recipe on the selected captures only.

- **Point to the delta:** put numbered callouts with arrows, rings, or boxes on the actual
  before/after screenshots. Reuse each change's ID across paired images, crops, and video
  beats; positions can differ when elements move. Cover the selected comparison; avoid
  redundant annotated copies. For new/removed content, mark the real prior/replacement
  location and label absence honestly; do not invent a matching element.
- **Explain the numbers:** place a concise numbered legend beside/below the media:
  `1. <element/state>: <previous> -> <new>; <user consequence>`. Name measured values only
  when verified. Include descriptive alt text and a text legend; color alone is insufficient.
- **Beyond video:** annotate stills, focused crops, and supporting diff images too. For
  recordings/GIFs, use timed callouts or focus highlights and captions identifying the
  changed result; reference the same IDs and useful timestamps in the legend. A cursor
  halo or generic "Before / After" label is not a change annotation. CLI/report evidence
  points to the changed output region; source-grounded diagrams label changed nodes/edges
  when included, but remain explanations rather than proof of rendered behavior.
- **Preserve evidence:** overlay annotations deterministically on copies of real captures;
  keep unmodified originals in temporary scratch; publish them only when useful or required.
  Record the revision pair and relevant environment.
  Apply the same privacy/access checks to originals as to annotated media before upload.
  Do not regenerate, retouch, or alter UI pixels to suggest a change. Keep markers outside
  important text, show context for crops, and split dense comparisons rather than crowding.
- **Inspect and refresh:** check final rendered media at PR display size: callout targets,
  numbers, legend, and old/new difference must be legible and consistent. Refresh affected
  overlays and legend with recaptures after edits/base changes. Publish annotated images
  inline when publishing media. Optional annotation tooling gaps need no waiver; a concise
  caption or unannotated crop may suffice. Read-only reviews report gaps without editing or publishing.

The PR-entrypoint hook is an advisory reminder, not a completeness detector or a hard CI
gate. This workflow selects proportionate evidence on every supported host. Follow
`visual-review/REFERENCE.md` only for deeper review when warranted; a separate HTML report
is not an ordinary PR deliverable.

## HyperFrames updates and recording quality

Keep the engine upstream, not vendored. Root `package.json` owns the exact stable
`hyperframes` renderer version; `bun.lock` owns its transitive versions. Install
with `bun install --frozen-lockfile`. `compose` prefers that installed version and
uses exact-version `bunx` only when it is absent or mismatched. Never use `@latest`
in a deliverable or maintain a second pin in the shell script.

`.github/dependabot.yml` checks HyperFrames daily and opens at most one update PR.
The `PR video canary` workflow must pass: real Chromium typing, save, service
failure, retry -> forced HyperFrames render -> decoded-frame comparisons with
source recordings and visible title/label/caption checks. Review its MP4 and PNG
artifacts plus upstream release notes before merging; no automatic merge. It is a
pipeline fixture, not a substitute for the changed application's own demo.
Its panels exercise distinct success and recovery journeys, explicitly labeled as fixture
paths rather than previous/new product versions. Matched cropping is checked against the
original recordings; duplicated source takes must not be used to test a comparison.
The canary also decodes the recorded cursor and active-control outline during typing,
save, failure, and retry, so DOM-only overlays cannot count as captured evidence.

```bash
bun install --frozen-lockfile
bunx --no-install playwright install chromium
node_modules/.bin/hyperframes browser ensure
bun run test:pr-video
```

Canary artifacts live under `.context/pr-video-canary/`. ffmpeg, ffprobe, and jq
are required. Both `PR_VIDEO_RENDERER=hyperframes` and the default `auto` fail
closed. Explicit `ffmpeg` is uncaptioned diagnostic output, not final evidence.
The canary also rejects burst-then-idle footage and renders a single take with
timed subtitles and a highlighted explanatory execution model.

MP4 is the primary review artifact; GIF is only a lightweight inline preview.
Rendering uses `delivery` quality and lossless PNG source-frame extraction to
avoid adding JPEG artifacts to UI text. The GIF remains 10 fps and at most 1200
pixels wide; judge text/motion in the MP4. Rendering cannot restore detail or
frames missing from the original capture. Keep real app footage, not synthetic
explainers, as the evidence.

Official authoring skills update separately through the upstream
[HyperFrames plugin](https://github.com/heygen-com/hyperframes/blob/main/skills/hyperframes/references/plugin-installation.md).
Let its plugin manager own updates; do not copy all upstream skills into this
repository or run initialization just to refresh them. Review new upstream
workflows when a recording needs them; renderer updates do not update skills.

## Dependency upgrade section

Dependency diff = `package.json`, `bun.lock`, `yarn.lock`, `go.mod`, or `go.sum`.

If present, add `Dependency upgrade path` section. Reuse `/upgrade-dependency` notes directly; never create or link a local Markdown report. If change is not a package upgrade (lockfile regen, fixture, rollback), record skip reason. Do not omit silently.
