# Evals for Cursor Team Kit /what-did-i-get-done vendoring and harness wiring.

SKILL=what-did-i-get-done
PLUGIN="$REPO_ROOT/.claude-plugin/plugin.json"

run_file_eval "$REPO_ROOT/$SKILL/SKILL.md" "Cursor commit-summary skill exists"
run_content_eval "$REPO_ROOT/$SKILL/SKILL.md" "^name: $SKILL$" "Cursor commit-summary skill has matching name"
run_content_eval "$PLUGIN" "\./$SKILL/" "Claude plugin registers Cursor commit-summary skill"
run_content_eval "$REPO_ROOT/$SKILL/SKILL.md" "authored git commits|commits authored by the current git user email" "skill summarizes authored commits by time range"
run_content_eval "$REPO_ROOT/ask-ben/SKILL-CATALOG.md" "/$SKILL" "ask-ben routes commit-summary skill"
run_content_eval "$REPO_ROOT/README.md" "/$SKILL" "README lists commit-summary skill"

# The imported CLI guidance is a published skill, with immutable source and license.
run_file_eval "$REPO_ROOT/cursor-skills/cli-for-agents/SKILL.md" "Cursor CLI skill is available"
run_content_eval "$PLUGIN" '\./cursor-skills/cli-for-agents/' "Claude registers Cursor CLI skill"
run_content_eval "$REPO_ROOT/codex-skills/cli-for-agents/SKILL.md" '../../cursor-skills/cli-for-agents/SKILL.md' "Codex loads canonical Cursor CLI skill"
run_content_eval "$REPO_ROOT/ask-ben/SKILL-CATALOG.md" '/cli-for-agents' "router exposes Cursor CLI skill"

if python3 - "$REPO_ROOT" <<'PY'
import hashlib
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
expected = {
    "vendor/cursor/cli-for-agent/skills/cli-for-agents/SKILL.md": "1cddd028d24ece48cd538fc1d84e49f5922dc8d04ee88caf12666b0557575e09",
    "vendor/cursor/cli-for-agent/LICENSE": "702f5f331b56aff0e33d8c7826df5202559f894145eb70355c6477b55b5bb8a0",
}
for relative, digest in expected.items():
    path = root / relative
    assert not path.is_symlink(), f"Vendored source is a symlink: {relative}"
    assert hashlib.sha256(path.read_bytes()).hexdigest() == digest, f"Snapshot drift: {relative}"
PY
then
  echo "  PASS  Cursor CLI source and MIT notice match the reviewed revision"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Cursor CLI source or MIT notice drifted"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Cursor CLI provenance"
fi
