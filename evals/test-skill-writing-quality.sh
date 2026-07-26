# Repository-wide SKILL.md quality guard.

skills=$(jq -r '.skills[]' "$REPO_ROOT/.claude-plugin/plugin.json" | sed 's#^\./##; s#/$##')
skill_count=$(printf '%s\n' "$skills" | sed '/^$/d' | wc -l | tr -d ' ')

missing=""
long_descriptions=""
long_skills=""
user_trigger_prose=""

while IFS= read -r skill; do
  [ -n "$skill" ] || continue
  skill_file="$REPO_ROOT/$skill/SKILL.md"
  if [ ! -f "$skill_file" ]; then
    missing="$missing $skill"
    continue
  fi

  frontmatter=$(awk 'BEGIN{c=0} /^---$/{c++; if(c==2)exit; next} c==1{print}' "$skill_file")
  description=$(printf '%s\n' "$frontmatter" | sed -n 's/^description:[[:space:]]*//p' | head -1)
  description=${description#\"}
  description=${description%\"}

  if printf '%s\n' "$frontmatter" | grep -q '^disable-model-invocation: true$'; then
    max_description=100
    if printf '%s\n' "$description" | grep -Eqi '\bUse (when|on|for)\b'; then
      user_trigger_prose="$user_trigger_prose $skill"
    fi
  else
    max_description=200
  fi

  description_length=${#description}
  if [ "$description_length" -gt "$max_description" ]; then
    long_descriptions="$long_descriptions $skill($description_length>$max_description)"
  fi

  line_count=$(wc -l < "$skill_file" | tr -d ' ')
  if [ "$line_count" -gt 100 ]; then
    long_skills="$long_skills $skill($line_count)"
  fi
done <<< "$skills"

if [ "$skill_count" -gt 0 ] && [ -z "$missing" ]; then
  echo "  PASS  all $skill_count registered canonical skills exist"
  PASS=$((PASS + 1))
else
  echo "  FAIL  registered canonical skill inventory: count=$skill_count missing:$missing"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: registered canonical skill inventory"
fi

if [ -z "$long_descriptions" ]; then
  echo "  PASS  descriptions stay within invocation budgets"
  PASS=$((PASS + 1))
else
  echo "  FAIL  descriptions exceed invocation budgets:$long_descriptions"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: descriptions exceed invocation budgets:$long_descriptions"
fi

if [ -z "$long_skills" ]; then
  echo "  PASS  canonical SKILL.md files stay at or below 100 lines"
  PASS=$((PASS + 1))
else
  echo "  FAIL  canonical SKILL.md files exceed 100 lines:$long_skills"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: canonical SKILL.md files exceed 100 lines:$long_skills"
fi

if [ -z "$user_trigger_prose" ]; then
  echo "  PASS  user-invoked descriptions avoid trigger prose"
  PASS=$((PASS + 1))
else
  echo "  FAIL  user-invoked descriptions contain trigger prose:$user_trigger_prose"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: user-invoked descriptions contain trigger prose:$user_trigger_prose"
fi
