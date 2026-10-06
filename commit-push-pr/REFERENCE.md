# Commit-push-pr reference

## Pre-rebase check

Resolve the PR base, then run the bundled `<plugin-root>/scripts/rebase-cost-preflight.sh <base-ref>` (this repository root while developing the skill). Files touched by multiple commits are a prompt to inspect fixups, not proof of conflicts or token savings. Squash only coherent fixups on the current user-owned branch; preserve meaningful commits and branch topology. The script is read-only and never rewrites history.

## Review evidence (Phase 0 pre-flight)

Before the PR endpoint, run the applicable review axes inline:

- `/review` -- correctness, value (`/av` hat), and semantic density
- `/ms` -- one lane, named beneficiary, cost or revenue evidence (the ms hat inside `/review`)
- `/improve-codebase-architecture` -- deep-module and invariant redesigns that remove error classes
- `/prototype` -- redesign module or layout
- `/visual-review` -- multi-hat review for frontend/visual/customer-facing surface diffs

Frontend or customer-facing surface diff -> `/visual-review` and the visual evidence gate below must run, even if another review skill already ran. Only an explicit user waiver can accept a named missing check; record it in the PR body.

A named review skill is not a separate approval gate. Use `/review` only when requested;
frontend/customer-facing changes still need visual evidence, not an agent-authored skip.

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

Map commit types to GitHub labels. Verify label exist first: `gh label list --search "<name>" --json name --jq '.[0].name'` -- only add existing labels.

| Commit type | Label |
|-------------|-------|
| `feat` | `enhancement` |
| `fix` | `bug` |
| `docs` | `documentation` |
| `perf` | `performance` |
| `ci` | `ci` |
| `test` | `testing` |

## PR body template (Phase 5)

Run `/quantify-impact` for every PR, including non-UI changes. Lead with the outcome,
use short bullets, and omit unused sections. Frontend PRs show before telling: the
before/after video and screenshot table sit directly under Summary, and prose only names
what the visuals cannot show. No commit
dump, boilerplate attribution, repeated rationale, or separate recap artifact. Keep full
logs/matrices in reviewer-accessible evidence links; keep before/after images in the body.

```
gh pr create --base <base> --assignee @me --title '<concise outcome>' --body "$(cat <<'EOF'
## Summary
- Lane: <Keep the lights on | Quality of life | New value | Taste> -- <who benefits and how; see `/ms`>
- <observable behavior change and why it matters; 1-3 bullets>
<optional: the smallest `/pr` summary view (pseudocode, call/component/file tree, Mermaid, or diff sketch) when bullets hide the shape>

## Before / after
<omit entire section if no frontend/customer-facing surface changes -- see Frontend detection below>

**What changed:** <previous behavior> -> <new behavior>. Look at <region/state/timestamp>.

**Video** (previous left, new right): <flow reaching the changed result>

![](<local MP4 path also passed to gh --attach>)

<fallback only when attach is blocked: ![before-after flow](<pinned gif url>)>

| Changed region/state | Previous: <old behavior> | New: <new behavior> | Look here |
|------|--------|-------|-------|
| <route/component> | ![before](<url>) | ![after](<url>) | <what changed> |

- Visual regression: `<normal command>` - PASS; <test count and report link>
- Coverage: <affected views/states, viewports/themes; inventory link if large>
- Baseline: `<base SHA>` -> `<head SHA>`; <fixture/browser/viewport>
- Limits: <explicit user-waived gaps only; omit if none>

## Impact
- Value: <one /ss bucket: keep the lights on | quality of life | feature | design bet> for <beneficiary>; trigger: <why now>
- <automatic /quantify-impact value assessment; replace with Proven impact below when measured>

## Proven impact
<omit unless meaningful measured evidence replaces Impact>

| Metric | Before | After | Delta |
|---|---:|---:|---:|
| <direct metric> | <base> | <candidate> | <absolute and %> |

- **Value proven:** <product or codebase benefit>
- Method: <command, fixture/runs, environment, base/candidate>
<explicit unproven performance claims instead get an Impact bullet: Value not proven + limitation>

## Stack context
- <stacked PR only: parent, layer position, dependent PRs, draft/ready>

## Merge danger
- Door: <one-way or two-way: can this be rolled back cheaply? destructive or hard-to-reverse effects are one-way>
- Blast radius: <who or what breaks if wrong: consumers, layout, data, deploys>

## Reviewer guide
- <non-trivial diffs only: entry point, deliberate limitation>
- Riskiest hunk: <the file or hunk to push back on, and the assumption behind it>
- Not fixed here: <adjacent problems found and deliberately left; omit if none>

## Dogfood evidence
<omit only when no runnable behavior changed; otherwise copy the current /dogfood receipt>

- Verdict:
- Entrypoint:
- Actions and break attempts:
- Observations:
- Repairs and replay:
- Limits:

## Dependency upgrade path
<omit entire section if no dependency-file diff>

- Upgrade evidence: <what broke / adapted / adopted + verify commands, or skip reason>
- Packages:
- SemVer confidence:
- Risk gate:
- Security notes:

## Tests
- <command and actual result; short checklist for remaining manual review only>
- <changed behavior without visuals: the test that failed before and passes after>
EOF
)"
```

Use a body file for long bodies rather than fragile shell quoting. For native media, pass
each referenced local file with `--attach <path>` on create or edit. GitHub CLI rewrites
those references to uploaded assets; keep the video image reference alone in its paragraph
to render a player. Updates use `gh pr edit <number> --body-file <file> --attach <media>`;
preserve user-authored context outside the evidence sections. Without a body flag,
`gh pr edit <number> --attach <media>` appends media and preserves the existing body.

Append `--label <label1> --label <label2>` per verified label.

Resolve `<base>` with `scripts/resolve-pr-base.sh` from the plugin root. For a stack layer,
this is the branch immediately below it, not the stack trunk. Ordinary `/commit-push-pr`
publishes only the current layer; `gh stack submit` belongs to an explicit `/stacked-prs`
endpoint because it can publish every unsubmitted branch.

**Draft mode**: changes look WIP (TODO comments, incomplete impl, test stubs) -> add `--draft`.

Summary, evidence, and merge danger follow `/pr` (vendored from Matt Pocock); this template
adds the harness's impact, visual, dogfood, dependency, and test sections.

## Frontend/customer-facing detection + screenshot table (Phase 5)

**No size threshold.** Any change an end user could see triggers this gate, including a
one-word label, one-pixel spacing adjustment, focus/hover/disabled state, or removal.

1. **Inventory before edits:** resolve the real PR base (parent for stacks), record its
   merge-base SHA and candidate SHA, and inspect the complete branch diff plus staged,
   unstaged, and relevant untracked work. File extensions are hints, not the decision:
   include TSX/JSX, CSS, HTML, Vue/Svelte/Astro, tokens/themes, fonts/icons/images, copy and
   translations, rendered docs/reports, CLI/TUI, mobile/desktop, and data/config/dependency
   changes that alter rendered output. Trace shared components/styles to affected consumers.
   Map every visible change to `surface/state -> test -> before/after capture`; include
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
   Also record one before/after video of the changed flow in real UI. The video shows the
   flow happening, never a still page: navigate, click, type, open/submit, and land on the
   changed result (success, error, or new state). Write one flow file (one agent-browser
   command per line: `open`, `click`, `type`, `press`, `scroll`, `wait --text`) and replay
   it on base and candidate with `scripts/pr-video.sh record <url> flow.txt <side>.webm`;
   it draws a visible cursor and paces steps. Prefer `type` over `fill` so keystrokes show.
   A static-only change still gets a flow that reaches, scrolls to, and hovers/focuses it.
   Start the flow file with a `# <flow title>` line and put a `## <caption>` line before
   each step reviewers should read. Keep each take under 20 seconds. `record` refuses flows
   with fewer than two interaction steps, and `scripts/pr-video.sh compose before.webm
   after.webm <out-dir>` refuses static takes (under 8 distinct frames), duplicate files,
   and identical decoded footage (including remuxed copies); re-record the
   flow, never pad or loop a still. `compose` frames the real takes with HyperFrames
   (exact pin from root `package.json`, locked local CLI or pinned `bunx` fallback): concrete behavior labels, the title, and step captions timed per
   side. It falls back to plain ffmpeg side by side when HyperFrames is unavailable. It
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
   limits. New edits, rebases, base changes, or failed CI invalidate affected evidence;
   refresh the tests, captures, and PR body before declaring it current. A green suite alone
   does not prove the inventory complete; never claim exhaustive coverage from filenames.
5. **Publish visible evidence:** put **What changed: previous -> new; look here** directly
   above the video and focused screenshot pair. Each row owns a distinct observable delta;
   group unchanged states in a coverage note instead of repeating nearly identical images.
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
   body placement, revision pair, and concise impact/test bullets. Confirm native video
   URLs occupy their own paragraph and no attached local paths remain. CLI readback
   proves publication, not playback or every reviewer's access; name any unverified
   access limits. Do not launch a browser merely to upload, edit, or verify publication.
   If the user explicitly requests rendered playback/access verification, use one
   isolated session, close it afterward, and never take over a human-owned browser.
   Do not overwrite unrelated reviewer notes. Omit the visual section only when the
   inventory establishes no user-visible effect; keep that rationale in verification evidence.

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

```bash
bun install --frozen-lockfile
bunx --no-install playwright install chromium
node_modules/.bin/hyperframes browser ensure
bun run test:pr-video
```

Canary artifacts live under `.context/pr-video-canary/`. ffmpeg, ffprobe, and jq
are required. `PR_VIDEO_RENDERER=hyperframes` fails closed; `auto` may fall back
to plain ffmpeg without labels/captions. Use the forced renderer for quality
checks and final demos where framing is required.

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
