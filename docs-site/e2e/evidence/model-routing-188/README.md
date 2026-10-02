# Preferred-model documentation evidence

- Base: `a073f90de70e3b4f7ce9323fec069f36be8b078f` (`origin/main`). Base source exported with `git archive`; no branch switching.
- Candidate: this PR's two-model routing policy and synchronized current translations. Archived releases unchanged.
- Browser: isolated Chromium, reduced motion, English browser locale. Desktop 1440×1000; mobile 390×844. Same routes, fonts, and fixtures on both sides.
- Before captures: `before/`. Candidate captures: `../../model-routing.spec.ts-snapshots/` and the four efficient-frontier captures under `../../visual.spec.ts-snapshots/`.
- Video: `flow.gif`, before left / after right. Actual skill search → Codex route table → frontier policy. Playwright recorded isolated contexts after the agent-browser recorder failed; repository ffmpeg composition used. GIF fallback, not a GitHub MP4 player.
- Verification: 13 Playwright cases / 14 screenshot assertions passed without update flags. New routing/search/mobile cases and the four existing frontier cases first failed against base snapshots; only reviewed changes were accepted.
- Coverage: Codex and frontier pages plus Codex search result in English, Polish, Simplified Chinese, and Traditional Chinese; mobile Codex and dark mobile search. No shared layout, form, loading/error, or archived-page behavior changed.
