# Public skill instructions are the output contract. Wizard behavior is tested
# separately through the generated script in wizard/template.test.ts.

run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" 'read.*canonical.*SKILL.md' \
  "router reads canonical guidance before recommending or skipping a skill"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" 'yes.*accepts.*recommend' \
  "grilling yes accepts the recommendation"
run_content_eval "$REPO_ROOT/tdd/SKILL.md" 'catches.*misses' \
  "TDD states coverage and blind spots at each seam"
run_content_eval "$REPO_ROOT/diagnosing-bugs/SKILL.md" 'mutation.*pristine|pristine.*mutation' \
  "diagnosis verifies a forced RED mutation against pristine state"
run_content_eval "$REPO_ROOT/review/SKILL.md" 'CODING_STANDARDS.md.*CONTRIBUTING.md' \
  "review discovers explicit standards sources"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" 'wayfinder:<type>.*only|only.*wayfinder:<type>' \
  "decision tickets do not enter the implementation triage queue"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" 'real IDs|real identifiers' \
  "wayfinder cross-references use assigned identifiers"
run_content_eval "$REPO_ROOT/to-tickets/SKILL.md" 'Omit.*Blocked by.*native|native.*omit.*Blocked by' \
  "native blockers have one source of truth"
run_content_eval "$REPO_ROOT/work-automation-kit/REFERENCE.md" 'create.*missing.*labels|Create.*missing.*labels' \
  "workflow setup creates only missing configured labels"
run_content_eval "$REPO_ROOT/work-automation-kit/templates/issue-tracker-github.md" 'gh issue view <number> --json number,title,body,labels,comments' \
  "GitHub ticket reads include labels and comments"
run_content_eval "$REPO_ROOT/work-automation-kit/templates/issue-tracker-github.md" 'gh api --paginate.*pulls\?state=open' \
  "external PR discovery uses paginated provider association data"
run_content_eval "$REPO_ROOT/work-automation-kit/templates/issue-tracker-gitlab.md" 'glab issue list --output json' \
  "GitLab issue lists use the supported output flag"
run_content_eval "$REPO_ROOT/handoff/SKILL.md" '\$TMPDIR.*\/tmp.*%TEMP%' \
  "handoff identifies the host temporary directory"
run_content_eval "$REPO_ROOT/teach/SKILL.md" 'position.*correct|correct.*position' \
  "teaching avoids answer-position clues"
run_content_eval "$REPO_ROOT/retro/SKILL.md" '[Tt]actical.*[Ss]trategic|[Ss]trategic.*[Tt]actical' \
  "retro separates task completion from future environment improvements"
run_content_eval "$REPO_ROOT/README.md" '49dd158d1076134a641b33efb035946536778336' \
  "README pins the reviewed upstream refresh"
