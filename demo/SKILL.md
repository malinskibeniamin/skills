---
name: demo
description: Create a customer-facing feature recording and publish it in a draft PR.
disable-model-invocation: true
argument-hint: "[branch, PR, feature, or path]"
---

Turn finished work into customer proof. Read [REFERENCE.md](REFERENCE.md).

## Contract

1. Resolve target; default whole current branch/PR from merge-base, including committed, staged, unstaged, relevant untracked work.
2. Choose strongest visible payoff; tell one short problem -> action -> result story.
3. Commit under `demos/<slug>/`; reuse for updates, never scatter media.
4. Prefer Remotion and render `demos/<slug>/output/demo.mp4`; reuse real captures when more credible.
5. Fall back only on concrete Remotion blocker or no motion value: rendered sequence/state/flow or architecture diagram; Mermaid for simple graph, `/excalidraw-diagram` for art-directed space. Record reason.
6. Inspect frames/full diagram; repair defects; exclude secrets/private/customer PII. Diagram fallback needs concise accessible description.
7. Never edit README. Commit, push current branch, create draft PR with linked artifact; update existing PR without changing review state.
8. macOS: `open -R`; otherwise show `pwd`, absolute path, exact `cd`.

## Done

Return customer story, artifact type/path, render/validation evidence, fallback reason, draft PR URL. Local-only artifact is blocked, not complete.
