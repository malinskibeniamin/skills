# Evals for /prime startup-orientation skill

SKILL_DIR="$REPO_ROOT/prime"

run_file_eval "$SKILL_DIR/SKILL.md" "prime SKILL.md exists"
run_content_eval "$SKILL_DIR/SKILL.md" "^name: prime" "prime has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "startup brief" "prime describes startup brief"
run_content_eval "$SKILL_DIR/SKILL.md" "new chat" "prime triggers on new chat"
run_content_eval "$SKILL_DIR/SKILL.md" "Do not expose modes" "prime has one adaptive surface"
run_content_eval "$SKILL_DIR/SKILL.md" "No script required" "prime stays instruction-only"
run_content_eval "$SKILL_DIR/SKILL.md" "[Rr]ead only the highest-signal files" "prime lets agent choose next reads"
run_content_eval "$SKILL_DIR/SKILL.md" "/prime <seed>" "prime accepts task seed locators"
run_content_eval "$SKILL_DIR/SKILL.md" "Examples:.*#/tmp/handoff|Examples:" "prime has concrete examples"

run_file_eval "$SKILL_DIR/REFERENCE.md" "prime REFERENCE.md exists"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Output contract" "prime reference defines output contract"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Do not paste full CLAUDE.md or AGENTS.md" "prime reference prevents instruction-file pollution"
run_content_eval "$SKILL_DIR/REFERENCE.md" "SessionStart" "prime reference documents hook option"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Manual only" "prime is manual preference, not nudged"
run_content_eval "$SKILL_DIR/REFERENCE.md" "No PRIME.md" "prime rejects stale repo-local PRIME.md"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Seed context" "prime reference includes seed context contract"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Claims to verify" "prime reference reconciles seed claims"
run_content_eval "$SKILL_DIR/REFERENCE.md" "gh issue view" "prime reference can use GitHub issues"
run_content_eval "$SKILL_DIR/REFERENCE.md" "acli jira workitem view" "prime reference can use Jira tickets"
run_content_eval "$SKILL_DIR/REFERENCE.md" "codex/prime" "prime reference documents outside-repo marker"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\"./prime/\"" "prime registered in Claude plugin skills"

if [ -d "$SKILL_DIR/scripts" ] || [ -d "$SKILL_DIR/agents" ] || find "$SKILL_DIR" -mindepth 2 -type f | grep -q .; then
  echo "  FAIL  prime has no bundled scripts or agents"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: prime has no bundled scripts or agents"
else
  echo "  PASS  prime has no bundled scripts or agents"
  PASS=$((PASS + 1))
fi

if grep -R "prime-nudge.sh" "$REPO_ROOT/skill-manifest.json" "$REPO_ROOT/.claude/settings.json" "$REPO_ROOT/.codex/hooks.json" "$REPO_ROOT/hooks/hooks.json" "$REPO_ROOT/hooks/codex-hooks.json" >/dev/null 2>&1 || [ -e "$REPO_ROOT/.claude/hooks/prime-nudge.sh" ]; then
  echo "  FAIL  prime has no prompt nudge hook"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: prime has no prompt nudge hook"
else
  echo "  PASS  prime has no prompt nudge hook"
  PASS=$((PASS + 1))
fi

prime_doc_bytes=$(wc -c < "$SKILL_DIR/SKILL.md" | tr -d ' ')
prime_ref_bytes=$(wc -c < "$SKILL_DIR/REFERENCE.md" | tr -d ' ')
if [ "$prime_doc_bytes" -le 1600 ] && [ "$prime_ref_bytes" -le 1900 ]; then
  echo "  PASS  prime artifacts stay terse"
  PASS=$((PASS + 1))
else
  echo "  FAIL  prime artifacts too verbose (skill=${prime_doc_bytes}B ref=${prime_ref_bytes}B)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: prime artifacts too verbose"
fi
