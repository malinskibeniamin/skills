# deslop owns the complexity tag taxonomy (Ben: "treat each line of code
# as a potential thing that can break" -- the idea is the requirement).

for tag in "delete:" "stdlib:" "native:" "yagni:" "shrink:"; do
  run_content_eval "$REPO_ROOT/deslop/SKILL.md" "$tag" "deslop defines $tag tag"
done
run_content_eval "$REPO_ROOT/deslop/SKILL.md" "NEEDS_CHANGES" "deslop blocks the ship path on low-value diffs"
run_content_eval "$REPO_ROOT/deslop/SKILL.md" "repository audits" "deslop owns repo-wide bloat audit"
