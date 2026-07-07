# Evals for vendored DietrichGebert/ponytail skills and integration.

UPSTREAM_SHA="687c1b339872289d70f65c5eaabce850b1663867"

expected_ponytail_skills="ponytail"
actual_ponytail_skills=$(
  find "$REPO_ROOT" -maxdepth 2 -name SKILL.md \
    | sed "s#^$REPO_ROOT/##" \
    | grep '^ponytail[^/]*/SKILL\.md$' \
    | sed 's#/SKILL.md##' \
    | sort \
    | tr '\n' ' ' \
    | sed 's/ $//'
)
if [ "$actual_ponytail_skills" = "$expected_ponytail_skills" ]; then
  echo "  PASS  exactly one Ponytail skill is vendored (family consolidated 4->1 in 4.27.0)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  exactly one Ponytail skill is vendored (got: $actual_ponytail_skills)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: exactly one Ponytail skill is vendored"
fi

PONYTAIL_SKILLS=("ponytail")
for skill in "${PONYTAIL_SKILLS[@]}"; do
  run_file_eval "$REPO_ROOT/$skill/SKILL.md" "vendored Ponytail skill exists: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^name: $skill$" "vendored Ponytail skill has matching name: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^description: .+\\. Use when .+" "$skill description follows writing-great-skills trigger format"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^## Examples?$" "$skill includes concrete examples"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "Caveman|terse" "$skill uses caveman terse style"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "vendored_from: https://github.com/DietrichGebert/ponytail" "vendored Ponytail skill records upstream URL: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "upstream_commit: $UPSTREAM_SHA" "vendored Ponytail skill records upstream commit: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "license: MIT" "vendored Ponytail skill keeps MIT license: $skill"
  run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\\./$skill/" "Claude plugin registers Ponytail skill: $skill"
done

if [ ! -e "$REPO_ROOT/ponytail-help/SKILL.md" ]; then
  echo "  PASS  ponytail-help skill is not vendored"
  PASS=$((PASS + 1))
else
  echo "  FAIL  ponytail-help skill is not vendored"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: ponytail-help skill is not vendored"
fi
if ! grep -q "\\./ponytail-help/" "$REPO_ROOT/.claude-plugin/plugin.json"; then
  echo "  PASS  Claude plugin does not register ponytail-help"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Claude plugin does not register ponytail-help"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Claude plugin does not register ponytail-help"
fi

run_content_eval "$REPO_ROOT/ponytail/SKILL.md" "^description: Writes the least code that works\\. Use when" "ponytail description uses third person"
run_content_eval "$REPO_ROOT/ponytail/SKILL.md" "best code is the code never written|best line of code" "ponytail preserves core less-code principle"
run_content_eval "$REPO_ROOT/ponytail/SKILL.md" "Stdlib|standard library" "ponytail preserves standard library rung"
run_content_eval "$REPO_ROOT/ponytail/SKILL.md" "Native platform|native" "ponytail preserves native platform rung"
run_content_eval "$REPO_ROOT/ponytail/SKILL.md" "Already-installed dependency|installed dependency" "ponytail preserves installed dependency rung"
run_content_eval "$REPO_ROOT/ponytail/SKILL.md" "input validation at trust boundaries" "ponytail keeps safety boundary"
run_content_eval "$REPO_ROOT/ponytail/SKILL.md" "failing test first|/tdd" "ponytail aligns with harness TDD gate"


run_content_eval "$REPO_ROOT/deslop/SKILL.md" "Complexity tags" "deslop owns the complexity tag taxonomy"
run_content_eval "$REPO_ROOT/improve/SKILL.md" "advisor-plan inputs" "improve treats ponytail debt as advisor-plan input"
run_content_eval "$REPO_ROOT/diagnosing-bugs/SKILL.md" "debt ledger" "diagnosing-bugs routes to the consolidated ponytail"

run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "/ponytail" "development lifecycle invokes ponytail automatically"
run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "Ponytail.*before.*implementation|before.*implementation.*Ponytail" "development lifecycle runs ponytail before implementation"
run_content_eval "$REPO_ROOT/work/SKILL.md" "/ponytail.*development-lifecycle|development-lifecycle.*ponytail" "work alias carries ponytail into lifecycle"
run_content_eval "$REPO_ROOT/tdd/SKILL.md" "/ponytail" "tdd green phase invokes ponytail"
run_content_eval "$REPO_ROOT/swarm/SKILL.md" "/ponytail" "swarm worker lanes carry ponytail"
run_content_eval "$REPO_ROOT/prototype/SKILL.md" "/ponytail" "prototype uses ponytail for throwaway minimality"
