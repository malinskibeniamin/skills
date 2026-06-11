# Evals for /deslop being front-and-center across skills.

missing=""
count=0
while IFS= read -r skill; do
  count=$((count + 1))
  if ! grep -q '/deslop' "$skill"; then
    missing="$missing ${skill#$REPO_ROOT/}"
  fi
done < <(find "$REPO_ROOT" -maxdepth 2 -name SKILL.md \
  -not -path '*/node_modules/*' \
  -not -path '*/agent-evals/*' | sort)

if [ -z "$missing" ]; then
  echo "  PASS  all $count skills foreground /deslop for repo/code changes"
  PASS=$((PASS + 1))
else
  echo "  FAIL  skills missing /deslop:$missing"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: skills missing /deslop:$missing"
fi
