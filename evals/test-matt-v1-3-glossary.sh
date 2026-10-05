# Public artifact contracts for the published v1.3 glossary convention.

run_file_eval "$REPO_ROOT/GLOSSARY.md" "root glossary uses the published filename"
run_file_eval "$REPO_ROOT/domain-modeling/GLOSSARY-FORMAT.md" "domain-modeling ships the renamed format reference"

if [ -e "$REPO_ROOT/CONTEXT.md" ] || [ -e "$REPO_ROOT/domain-modeling/CONTEXT-FORMAT.md" ]; then
  echo "  FAIL  old glossary files are retired"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: old glossary files remain"
else
  echo "  PASS  old glossary files are retired"
  PASS=$((PASS + 1))
fi

for file in domain-modeling/SKILL.md domain-modeling/GLOSSARY-FORMAT.md \
  grilling/SKILL.md improve-codebase-architecture/SKILL.md pr/SKILL.md \
  prime/REFERENCE.md wait-what/SKILL.md work-automation-kit/REFERENCE.md \
  work-automation-kit/templates/domain.md; do
  run_content_eval "$REPO_ROOT/$file" 'GLOSSARY\.md' "consumer uses the glossary convention: $file"
  if [ -f "$REPO_ROOT/$file" ] && grep -qE 'CONTEXT(-MAP|-FORMAT)?\.md' "$REPO_ROOT/$file"; then
    echo "  FAIL  consumer has no stale glossary pointer: $file"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: stale glossary pointer: $file"
  else
    echo "  PASS  consumer has no stale glossary pointer: $file"
    PASS=$((PASS + 1))
  fi
done

run_content_eval "$REPO_ROOT/domain-modeling/SKILL.md" '\[GLOSSARY-FORMAT\.md\]\(\./GLOSSARY-FORMAT\.md\)' \
  "producer links its shipped glossary format"
for file in domain-modeling/GLOSSARY-FORMAT.md work-automation-kit/REFERENCE.md \
  work-automation-kit/templates/domain.md wait-what/SKILL.md; do
  run_content_eval "$REPO_ROOT/$file" 'GLOSSARY-MAP\.md' "multi-context consumer follows the renamed map: $file"
done

for skill in implement-spec pr retro tdd codebase-design review; do
  run_content_eval "$REPO_ROOT/work-automation-kit/SKILL.md" "(^|[[:space:]])${skill}([[:space:]]|$)" "setup includes the v1.3 skill or prerequisite: $skill"
done
run_content_eval "$REPO_ROOT/work-automation-kit/templates/domain.md" '/domain-modeling.*creates.*lazily' \
  "setup names the actual lazy glossary producer"
run_content_eval "$REPO_ROOT/work-automation-kit/REFERENCE.md" 'off.*do not ask|off.*without.*question' \
  "setup leaves external PR triage off without another question"
for tracker in github gitlab; do
  run_content_eval "$REPO_ROOT/work-automation-kit/templates/issue-tracker-$tracker.md" \
    'request surface: no' "setup defaults external request triage off: $tracker"
done
run_content_eval "$REPO_ROOT/triage/SKILL.md" 'request surface.*missing.*no|missing.*request surface.*no' \
  "triage excludes external discovery unless the tracker opts in"
