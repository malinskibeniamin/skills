# Evals for current mattpocock/skills WIP surface.

CLAUDE_HANDOFF="$REPO_ROOT/claude-handoff/SKILL.md"
WIZARD="$REPO_ROOT/wizard/SKILL.md"
WIZARD_TEMPLATE="$REPO_ROOT/wizard/template.sh"
TO_SPEC="$REPO_ROOT/to-spec/SKILL.md"
TO_TICKETS="$REPO_ROOT/to-tickets/SKILL.md"
PLUGIN="$REPO_ROOT/.claude-plugin/plugin.json"

for skill in claude-handoff wizard to-spec to-tickets; do
  run_file_eval "$REPO_ROOT/$skill/SKILL.md" "Matt WIP skill exists: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^name: $skill$" "Matt WIP skill has matching name: $skill"
  run_content_eval "$PLUGIN" "\\./$skill/" "Claude plugin registers Matt WIP skill: $skill"
done

run_content_eval "$CLAUDE_HANDOFF" "claude --bg --name" "claude-handoff launches named background agent"
run_content_eval "$CLAUDE_HANDOFF" "command -v claude|claude CLI" "claude-handoff checks Claude CLI availability"
run_content_eval "$CLAUDE_HANDOFF" "launch fails|unavailable" "claude-handoff has launch failure fallback"
run_content_eval "$CLAUDE_HANDOFF" "Redact.*API keys.*passwords" "claude-handoff requires redaction"
run_content_eval "$CLAUDE_HANDOFF" "suggested skills" "claude-handoff includes suggested skills"

run_content_eval "$LOOP_ME" "/grilling" "loop-me uses grilling discipline"
run_content_eval "$LOOP_ME" "one question at a time" "loop-me asks one workflow question at a time"
run_content_eval "$LOOP_ME" "workflows/\\*\\.md" "loop-me writes workflow specs"
run_content_eval "$LOOP_ME" "NOTES\\.md" "loop-me records workspace notes"
run_content_eval "$LOOP_ME" "implementer agent could build it without asking" "loop-me has implementation-ready done bar"

run_file_eval "$WIZARD_TEMPLATE" "wizard template exists"
run_executable_eval "$WIZARD_TEMPLATE" "wizard template is executable"
run_content_eval "$WIZARD" "Don't run it end-to-end yourself" "wizard forbids agent end-to-end execution"
run_content_eval "$WIZARD" "Trace it statically|trace it statically" "wizard requires static trace verification"
for helper in stage open_url ask_secret write_env set_secret set_var confirm; do
  run_content_eval "$WIZARD_TEMPLATE" "$helper" "wizard template exposes $helper helper"
done

run_content_eval "$TO_SPEC" "/to-tickets" "to-spec hands approved specs to to-tickets"
run_content_eval "$TO_TICKETS" "blocking edges" "to-tickets requires blocking edges"
run_content_eval "$TO_TICKETS" "Work the \\*\\*frontier\\*\\*" "to-tickets explains frontier work"

for retired_skill in to-prd to-issues; do
  if [ -e "$REPO_ROOT/$retired_skill/SKILL.md" ]; then
    echo "  FAIL  retired planning skill absent: $retired_skill"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: retired planning skill still exists: $retired_skill"
  else
    echo "  PASS  retired planning skill absent: $retired_skill"
    PASS=$((PASS + 1))
  fi
done
