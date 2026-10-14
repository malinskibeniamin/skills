# Evals for /handoff skill.

# Exercise the published command twice: BSD mktemp needs trailing Xs.
_handoff_tmp=$(mktemp -d "${TMPDIR:-/tmp}/handoff-eval.XXXXXX")
_handoff_command=$(sed -n 's/.*Unix: `\(handoff_file=.*\)`\..*/\1/p' "$REPO_ROOT/handoff/SKILL.md")
_handoff_first=""
_handoff_second=""
if [ -n "$_handoff_command" ] &&
  _handoff_first=$(TMPDIR="$_handoff_tmp" /bin/bash -c "set -e; $_handoff_command; printf '%s' \"\$handoff_file\"") &&
  _handoff_second=$(TMPDIR="$_handoff_tmp" /bin/bash -c "set -e; $_handoff_command; printf '%s' \"\$handoff_file\"") &&
  [ -f "$_handoff_first" ] && [ -f "$_handoff_second" ] &&
  [ "$_handoff_first" != "$_handoff_second" ] &&
  [ "$(dirname "$_handoff_first")" = "$_handoff_tmp" ] &&
  [ "$(dirname "$_handoff_second")" = "$_handoff_tmp" ]; then
  echo "  PASS  published handoff command creates unique host-temp files"
  PASS=$((PASS + 1))
else
  echo "  FAIL  published handoff command creates unique host-temp files"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: published handoff command creates unique host-temp files"
fi
rm -rf "$_handoff_tmp"


run_file_eval "$REPO_ROOT/handoff/SKILL.md" "handoff skill exists"
run_content_eval "$REPO_ROOT/handoff/SKILL.md" "name: handoff" "handoff frontmatter name"
run_content_eval "$REPO_ROOT/handoff/SKILL.md" 'mktemp "\$\{TMPDIR:-/tmp\}/handoff-XXXXXX"' "handoff uses the host temp path"
run_content_eval "$REPO_ROOT/handoff/SKILL.md" 'handoff_file=\$\(mktemp' "handoff creates a temp artifact"
if grep -qE 'cat .*handoff_file.*>/dev/null' "$REPO_ROOT/handoff/SKILL.md"; then
  echo "  FAIL  handoff performs a no-op temp-file read"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: handoff performs a no-op temp-file read"
else
  echo "  PASS  handoff has no no-op temp-file read"
  PASS=$((PASS + 1))
fi
run_content_eval "$REPO_ROOT/handoff/SKILL.md" "Do not duplicate artifacts" "handoff avoids artifact duplication"
run_content_eval "$REPO_ROOT/handoff/SKILL.md" "[Rr]edact.*sensitive|secrets.*personal data" "handoff redacts sensitive information"
run_content_eval "$REPO_ROOT/handoff/SKILL.md" "Suggested skills" "handoff suggests next skills"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\./handoff/" "handoff registered in Claude plugin skills"
run_content_eval "$REPO_ROOT/ask-ben/SKILL-CATALOG.md" "/handoff" "generated catalog documents handoff"
