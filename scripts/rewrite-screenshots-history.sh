#!/usr/bin/env bash
set -euo pipefail

# Runbook: strip docs/screenshots media from git HISTORY (~30MB of mp4/gif
# bloating every clone). Rewrites all history -> requires a coordinated
# force-push of main by the OWNER. Do not run casually; do not run from CI.
#
# Preconditions (verify every one):
#   1. All PRs merged or rebased -- history rewrite orphans open branches.
#   2. Every collaborator warned: they must re-clone or `git fetch && git reset --hard`.
#   3. A fresh backup clone exists somewhere untouched.
#   4. `git filter-repo` installed (brew install git-filter-repo).
#
# What it does: removes historical BLOBS of docs/screenshots media while
# keeping the CURRENT files in the working tree (re-added in a fresh commit),
# so README/docs links keep working and only history slims down.

if [ "${1:-}" != "--i-know-what-i-am-doing" ]; then
  echo "This rewrites ALL git history and requires a force-push of main."
  echo "Read the preconditions in this script, then rerun with --i-know-what-i-am-doing"
  exit 1
fi

command -v git-filter-repo >/dev/null 2>&1 || { echo "install git-filter-repo first (brew install git-filter-repo)"; exit 1; }

ROOT=$(git rev-parse --show-toplevel)
cd "$ROOT"
[ -z "$(git status --porcelain)" ] || { echo "working tree must be clean"; exit 1; }

# 1. Stash current media out of the repo
STASH_DIR=$(mktemp -d)
cp -R docs/screenshots "$STASH_DIR/screenshots"

# 2. Strip the path from all history (filter-repo removes the remote on purpose)
git filter-repo --path docs/screenshots --invert-paths --force

# 3. Restore current media as a single fresh commit
mkdir -p docs
cp -R "$STASH_DIR/screenshots" docs/screenshots
git add docs/screenshots
git commit -m "docs(screenshots): re-add current media after history rewrite"

echo ""
echo "Done locally. Next steps (manual, owner-only):"
echo "  git remote add origin git@github.com:malinskibeniamin/skills.git"
echo "  git push --force-with-lease origin main"
echo "  # then every collaborator re-clones; retag the latest release from the new history"
echo "Consider moving future media to Git LFS or a release asset instead."
