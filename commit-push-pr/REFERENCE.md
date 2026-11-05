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
2. Fetch origin and run the pre-rebase check. For a coherent linear branch whose commits
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
3. Rerun affected tests and repository checks; refresh invalidated review/visual evidence.
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

Frontend or customer-facing surface diff -> `/visual-review` and the visual evidence gate below must run, even if another review skill already ran. Only an explicit user waiver can accept a named missing check; record it in the PR body.

A named review skill is not a separate approval gate. Self-review automatically loads
`/review` through author delivery; a standalone review request remains read-only.
Frontend/customer-facing changes still need visual evidence, not an agent-authored skip.

For backend architecture, data flow, API contract, or workflow changes, follow
[backend diagrams](../excalidraw-diagram/PR-WORKFLOW.md) and invoke `excalidraw-diagram`.
Prepare editable source and render before committing; include the focused comparison in
the PR. Diagram failures warn and continue; this does not weaken the frontend visual gate.

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

```
gh pr create --base <base> --assignee @me --title '<concise outcome>' --body "$(cat <<'EOF'
<one sentence capturing the entire change and why it matters>

- Lane: <Keep the lights on | Quality of life | Feature | Taste>; <optional reviewer focus>; see `/product`
- Testing: <decisive commands/results, before -> after, and gaps>
- Risk: <door, blast radius, rollout limits, and how to revert>
EOF
)"
```

Keep required before/after video, annotated screenshot table, numbered callouts, and
legend inline immediately after the opening for visible changes; follow
[visual evidence](#frontendcustomer-facing-detection--screenshot-table-phase-5).

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

**No size threshold.** Any change an end user could see triggers this gate, including a
one-word label, one-pixel spacing adjustment, focus/hover/disabled state, or removal.

1. **Inventory before edits:** resolve the real PR base (parent for stacks), record its
   merge-base SHA and candidate SHA, and inspect the complete branch diff plus staged,
   unstaged, and relevant untracked work. File extensions are hints, not the decision:
   include TSX/JSX, CSS, HTML, Vue/Svelte/Astro, tokens/themes, fonts/icons/images, copy and
   translations, rendered docs/reports, CLI/TUI, mobile/desktop, and data/config/dependency
   changes that alter rendered output. Trace shared components/styles to affected consumers.
   Map every visible change to `surface/state -> test -> before/after capture -> callout ID`; include
   affected responsive sizes, themes, roles, and loading/empty/error/success states. Add
   keyboard/focus and interaction checks where changed. Mark non-applicable cases with
   concrete reasons. A type-only edit may be non-visible; a backend response change may not.
2. **Capture comparable base/candidate:** use the actual base revision, identical fixture,
   route/state, browser, viewport/DPR, fonts, locale, theme, and motion settings. Stabilize
   clock/data/network and wait for readiness, not sleeps. Reconstruct a missed baseline in
   an isolated detached worktree or existing base deployment; never switch the active tree
   or fabricate a before image. New/removed views show the real prior/replacement flow;
   if none exists, use a visible `New view`/`Removed view` label with reason and the available
   real capture. Reuse `/triage` or earlier review evidence only when revision and scenario still match.
   Write one observable **previous -> new** claim before recording. Keep unchanged setup
   brief; show the changed result at matched steps. If the difference is small, crop both
   sides to the same region, retain a full-view context link, and name the exact control,
   state, or timestamp to inspect. Captions explain old/new behavior, not only clicks.
   Follow [review-video storytelling](VIDEO.md) for CLI/UI capture, single-take new
   capabilities, timed execution models, and whole-video pacing review.
   Also record one before/after video of the changed flow in real UI. The video shows the
   flow happening, never a still page: navigate, click, type, open/submit, and land on the
   changed result (success, error, or new state). Write one flow file (one agent-browser
   command per line: `open`, `click`, `type`, `press`, `scroll`, `wait --text`) and replay
   it on base and candidate with `scripts/pr-video.sh record <url> flow.txt <side>.webm`;
   it draws an arrow cursor, outlines the active control in red, and leaves a readable
   click ring, including for keyboard activation. Prefer `type` over `fill` so keystrokes show.
   Make each action easy to locate at PR display size: keep the cursor and target cue
   visible through the action and its result. For small or dense UI, use matched
   `PR_VIDEO_FOCUS` crops to zoom both takes into the interaction and retain a full-view
   context link. Frame the control and its resulting feedback together; avoid cropping
   away the cursor, error, or success state. Annotate the changed result per
   [visual annotations](#visual-annotations); cursor/click cues alone do not identify the delta.
   For a small change, show its real trigger and result; a tooltip can use a focused
   hover/reveal/dismiss flow without unrelated actions.
   Start the flow file with a `# <flow title>` line. Add **on-screen narration subtitles,
   even without voiceover**: put a `## <narration>` line before every interaction.
   Explain what we do and what changes, not raw commands or selectors: "We enter a task
   name", "We save the task", "The error keeps our input intact". Use short sentences
   that fit within 2 lines. Never infer a successful result or expose secrets in subtitles.
   A final caption plus `wait --text` can narrate the verified outcome:

   ```text
   # Save a task
   ## We enter a task name.
   type "#name" "Review demo"
   ## We save the task.
   click "button[type=submit]"
   ## The task is saved with confirmation.
   wait --text "Saved: Review demo"
   ```

   `record` rejects missing narration before opening the browser. Captions hold for at
   least 2 seconds, or 1 second plus 300 ms per word, respecting longer configured pauses.
   HyperFrames burns them into the MP4 and GIF; no audio track is needed. Use the forced
   HyperFrames renderer below for final evidence; explicit ffmpeg diagnostics have no subtitles.
   Keep a complete, readable journey; trim dead time rather than target a runtime.
   Comparison takes shorter than 5 seconds are slowed for readability. Hold each action long enough to read its caption
   and result: `record` defaults to 1500 ms between uncaptioned setup steps (minimum
   `PR_VIDEO_STEP_MS=1000`) and a 2 second result hold after an uncaptioned readiness wait;
   it does not stack another final hold on an already-readable narrated step. Split long flows at meaningful outcomes; never speed them
   up to fit. `compose` slows each take shorter than 5 seconds, including its captions,
   rather than merely appending a frozen result; it preserves longer footage. `record` requires a narrated
   interaction, including hover for a tooltip. `scripts/pr-video.sh compose before.webm
   after.webm <out-dir>` refuses static takes, source idle spans of 5 seconds or longer,
   excessive end-frame padding, duplicate files, and identical decoded footage
   (including remuxed copies); re-record or trim the
   flow, never pad or loop a still. `compose` frames the real takes with HyperFrames
   (exact pin from root `package.json`, locked local CLI or pinned `bunx` fallback): concrete behavior labels, the title, and step captions timed per
   side. The default fails closed if HyperFrames fails. Explicit ffmpeg is for
   uncaptioned diagnostic output only. It
   never runs `hyperframes init`, which installs global agent skills. Do not substitute
   `/pr-to-video` or other HyperFrames creation workflows: they build synthetic explainers
   from the diff, not the real UI.

   ```bash
   PR_VIDEO_TITLE='Saving now shows confirmation' \
   PR_VIDEO_BEFORE_LABEL='Previous (base SHA): silent save' \
   PR_VIDEO_AFTER_LABEL='New (head SHA): saved notice' \
   PR_VIDEO_FOCUS=200:160:880:440 \
   PR_VIDEO_RENDERER=hyperframes \
     scripts/pr-video.sh compose before.webm after.webm .context/demo
   ```

   Labels are required, distinct, single-line behavior descriptions (up to 60 characters).
   Optional focus is `x:y:width:height` in source pixels, in bounds for both takes, with
   positive even dimensions. Omit it for a useful full view. No similarity threshold:
   a tiny real change must survive; semantic duplication still needs human inspection.
3. **Run visual regression:** use the repository's existing screenshot assertion runner,
   not DOM/text snapshots. Add missing cases for uncovered visible changes. Run against
   existing baselines first; inspect before/after/diff images for every mismatch, fix
   unintended differences, then update only intended snapshots. Rerun without snapshot-update
   flags and require PASS. Never bulk-accept, weaken thresholds, or mask the changed region
   to get green. Shared tokens/layout/dependencies require the full relevant visual suite
   unless the consumer inventory proves a narrower scope. If no runner exists, establish
   the smallest repository-native visual test via `/create-verification-skill`; unavailable
   runtime/fixtures are blockers, not permission to substitute a screenshot for a test.
4. **Check completeness:** run `/visual-review`; reconcile the final diff and affected
   consumers against the inventory, test results, and captures. Every affected surface/state
   must be accounted for. Inspect changed and unexpectedly unchanged snapshots. Record exact
   normal test command/result, baseline updates, revision pair, environment, and remaining
   limits. Check [visual annotations](#visual-annotations) against every inventory item.
   New edits, rebases, base changes, or failed CI invalidate affected evidence;
   refresh the tests, captures, callouts, legend, and PR body before declaring it current.
   A green suite alone does not prove the inventory complete; never claim exhaustive coverage from filenames.
5. **Publish visible evidence:** put **What changed: previous -> new; look here** directly
   above the video and focused screenshot pair. Each row owns a distinct observable delta;
   group unchanged states in a coverage note instead of repeating nearly identical images.
   Automatically annotate screenshots and other visual evidence using
   [visual annotations](#visual-annotations); a video alone does not satisfy this requirement.
   Put behavior and revision labels on the media, not just the table headers. Keep a
   full-view context link when cropping. Check the comparison at PR display size: the
   reviewer must identify the old/new result without searching the page. If not, focus
   framing or clarify the claim before publishing. Exact-file/frame checks cannot detect
   differently timed recordings of unchanged UI.

   When no visible delta exists, say **No visible UI change**, show one labeled verification
   capture if useful, and prove the actual change with tests/output. Renderer fixtures are
   pipeline demonstrations, not product before/after evidence. Never alter fixture data,
   theme, zoom, or state to manufacture a product difference. Link diff images
   and the full visual-test report when available. Use repository-approved, reviewer-accessible
   image hosting or committed snapshot raw URLs pinned to immutable SHAs. Without other
   hosting, prefer [native GitHub CLI attachments](https://docs.github.com/en/github-cli/github-cli/attaching-files-with-github-cli)
   for inline MP4 players: `gh pr create --body-file <body> --attach <media>` or
   `gh pr edit <number> --body-file <body> --attach <media>`. Put `![](<local MP4 path>)`
   alone in its paragraph in the body; gh replaces it with a user-attachments URL.
   `scripts/pr-video.sh attach [--body-file <body>] before-after.mp4` edits the current
   PR (override with `PR_VIDEO_PR_URL`), appending without replacing its body by default,
   and prints the **PR URL**, not asset URLs. It uses existing gh authentication and
   needs repository push access, no browser, profile, cookie extraction, or UI edits.
   Exit 3 means upgrade gh for `--attach` support; never fall back to browser uploads.
   When native upload is unavailable, use the published inline GIF and state the missing
   player; `scripts/pr-video.sh publish <files>` pushes screenshots and GIF to the
   `pr-evidence` branch without touching the PR branch and prints SHA-pinned Markdown.
   Do not present a downloadable MP4 as an inline video. On upload failure, read
   the PR body before retrying only missing files: gh can save successful attachments
   even when it exits nonzero. Review captures
   for secrets/personal data before upload; use sanitized fixtures, never public hosting for
   private evidence without authorization. Local paths are not reviewer-visible evidence.
   Neither are localhost, expiring session URLs, or artifact ZIP links. `gh pr comment --attach`
   uploads media to a comment, not the PR body. Missing capture/test/hosting blocks
   publication unless the user explicitly waives the named gap; put that waiver and
   limitation in the body, never PASS.
6. **Verify publication:** Re-read the actual PR body after create/edit/reopen/stack submit.
   Use `gh pr view <number> --json body,url` to verify the uploaded media references and
   body placement, revision pair, annotated screenshot references, matching callout legend,
   and concise impact/test bullets. Confirm native video
   URLs occupy their own paragraph and no attached local paths remain. CLI readback
   proves publication, not playback or every reviewer's access; name any unverified
   access limits. Do not launch a browser merely to upload, edit, or verify publication.
   If the user explicitly requests rendered playback/access verification, use one
   isolated session, close it afterward, and never take over a human-owned browser.
   Do not overwrite unrelated reviewer notes. Omit the visual section only when the
   inventory establishes no user-visible effect; keep that rationale in verification evidence.

### Visual annotations

For every visible PR change, create annotated evidence as part of ordinary authoring and
upkeep, with no separate request or optional recap skill. This includes small copy, font,
color, spacing, icon, layout, responsive, focus/hover/disabled, loading/error/empty/success-state,
and motion changes, across web, mobile, desktop, CLI/TUI, rendered docs, and reports.

- **Point to the delta:** put numbered callouts with arrows, rings, or boxes on the actual
  before/after screenshots. Reuse each change's ID across paired images, crops, and video
  beats; positions can differ when elements move. Cover every distinct visible delta, not
  just the headline feature. For new/removed content, mark the real prior/replacement
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
  retain and link unannotated full-resolution originals, revision pair, and environment.
  Apply the same privacy/access checks to originals as to annotated media before upload.
  Do not regenerate, retouch, or alter UI pixels to suggest a change. Keep markers outside
  important text, show context for crops, and split dense comparisons rather than crowding.
- **Inspect and refresh:** check final rendered media at PR display size: callout targets,
  numbers, legend, and old/new difference must be legible and consistent. Refresh affected
  overlays and legend with recaptures after edits/base changes. Publish annotated images
  inline, not only in local HTML, downloads, or a video. Missing annotation tooling/evidence
  follows the existing named-gap/user-waiver rule; text-only descriptions are not a silent
  substitute. Read-only reviews report gaps without editing or publishing.

The PR-entrypoint hook is an advisory reminder, not a completeness detector or a hard CI
gate. This workflow owns semantic detection and evidence collection on every supported
host, including hosts without hooks. Follow `visual-review/REFERENCE.md` for deeper review
evidence; local HTML reports are supplementary, never a substitute for embedded images.

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
