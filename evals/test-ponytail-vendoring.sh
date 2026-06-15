# Evals for vendored DietrichGebert/ponytail skills and integration.

UPSTREAM_SHA="687c1b339872289d70f65c5eaabce850b1663867"
PONYTAIL_SKILLS=(ponytail ponytail-audit ponytail-debt ponytail-review)

actual_ponytail_skills=$(
  find "$REPO_ROOT" -maxdepth 2 -name SKILL.md \
    | sed "s#^$REPO_ROOT/##" \
    | grep '^ponytail[^/]*/SKILL\.md$' \
    | sed 's#/SKILL.md##' \
    | sort \
    | tr '\n' ' ' \
    | sed 's/ $//'
)
expected_ponytail_skills="ponytail ponytail-audit ponytail-debt ponytail-review"
if [ "$actual_ponytail_skills" = "$expected_ponytail_skills" ]; then
  echo "  PASS  exactly four Ponytail skills are vendored"
  PASS=$((PASS + 1))
else
  echo "  FAIL  exactly four Ponytail skills are vendored (got: $actual_ponytail_skills)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: exactly four Ponytail skills are vendored"
fi

for skill in "${PONYTAIL_SKILLS[@]}"; do
  run_file_eval "$REPO_ROOT/$skill/SKILL.md" "vendored Ponytail skill exists: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^name: $skill$" "vendored Ponytail skill has matching name: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^description: .+\\. Use when .+" "$skill description follows write-a-skill trigger format"
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

run_content_eval "$REPO_ROOT/ponytail-review/SKILL.md" "delete:|stdlib:|native:|yagni:|shrink:" "ponytail-review keeps review tags"
run_content_eval "$REPO_ROOT/ponytail-review/SKILL.md" "net: -<N> lines possible" "ponytail-review keeps line-reduction metric"
run_content_eval "$REPO_ROOT/ponytail-review/SKILL.md" "Complexity only" "ponytail-review stays complexity-only"

run_content_eval "$REPO_ROOT/ponytail-audit/SKILL.md" "repo-wide|whole repo|whole-repo" "ponytail-audit scans whole repo"
run_content_eval "$REPO_ROOT/ponytail-audit/SKILL.md" "net: -<N> lines, -<M> deps possible" "ponytail-audit keeps repo-wide scoring"
run_content_eval "$REPO_ROOT/ponytail-debt/SKILL.md" "ponytail:" "ponytail-debt harvests ponytail markers"
run_content_eval "$REPO_ROOT/ponytail-debt/SKILL.md" "no-trigger" "ponytail-debt flags markers without triggers"

run_content_eval "$REPO_ROOT/deslop/SKILL.md" "/ponytail-review" "deslop composes ponytail-review before liability gate"
run_content_eval "$REPO_ROOT/deslop/SKILL.md" "/ponytail-audit" "deslop composes ponytail-audit"
run_content_eval "$REPO_ROOT/deslop/SKILL.md" "/ponytail-debt" "deslop composes ponytail-debt"
run_content_eval "$REPO_ROOT/deslop/SKILL.md" "Pair audit/debt with /improve" "deslop pairs audit debt with improve"
run_content_eval "$REPO_ROOT/deslop/REFERENCE.md" "/ponytail-audit.*(/ponytail-debt|marked debt)|/ponytail-debt.*(/ponytail-audit|bloat)" "deslop reference documents audit and debt pass"
run_content_eval "$REPO_ROOT/improve/SKILL.md" "/ponytail-audit" "improve uses ponytail-audit"
run_content_eval "$REPO_ROOT/improve/SKILL.md" "/ponytail-debt" "improve uses ponytail-debt"
run_content_eval "$REPO_ROOT/improve/SKILL.md" "advisor-plan inputs" "improve treats ponytail debt as advisor-plan input"
run_content_eval "$REPO_ROOT/diagnose/SKILL.md" "Ponytail commands" "diagnose owns Ponytail command summary instead of help skill"
run_content_eval "$REPO_ROOT/diagnose/SKILL.md" 'No `/ponytail-help` skill' "diagnose explicitly replaces ponytail-help skill"
run_content_eval "$REPO_ROOT/review/SKILL.md" "ponytail-review-hat" "review includes ponytail-review hat"
run_content_eval "$REPO_ROOT/review/SKILL.md" "/ponytail-review" "review hat invokes ponytail-review"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Subagents: .*ponytail-review-hat|ponytail-review-hat: <status" "review output reports ponytail-review hat status"
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" "/ponytail-review" "commit-push-pr accepts ponytail-review as review evidence"
run_content_eval "$REPO_ROOT/go/SKILL.md" "/ponytail-review.*deslop|/deslop.*ponytail-review" "go routes ship cleanup through ponytail-review and deslop"

run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "/ponytail" "development lifecycle invokes ponytail automatically"
run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "Ponytail.*before.*implementation|before.*implementation.*Ponytail" "development lifecycle runs ponytail before implementation"
run_content_eval "$REPO_ROOT/work/SKILL.md" "/ponytail.*development-lifecycle|development-lifecycle.*ponytail" "work alias carries ponytail into lifecycle"
run_content_eval "$REPO_ROOT/tdd/SKILL.md" "/ponytail" "tdd green phase invokes ponytail"
run_content_eval "$REPO_ROOT/swarm/SKILL.md" "/ponytail" "swarm worker lanes carry ponytail"
run_content_eval "$REPO_ROOT/prototype/SKILL.md" "/ponytail" "prototype uses ponytail for throwaway minimality"
