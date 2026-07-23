# Evals for owned SKILL.md quality under /writing-for-agents.

vendored_skills=$(awk '
  /^VENDORED=\(/ {in_list=1; next}
  in_list && /^\)/ {in_list=0; next}
  in_list {gsub(/^[[:space:]]+|[[:space:]]+$/, ""); if ($0 != "" && $0 !~ /^#/) print $0}
' "$REPO_ROOT/evals/test-matt-vendored-skills.sh" | sort)

owned_skills=$(find "$REPO_ROOT" -maxdepth 2 -name SKILL.md -not -path '*/agent-evals/*' -print \
  | sed "s#^$REPO_ROOT/##; s#/SKILL.md##" \
  | sort \
  | while IFS= read -r skill; do
      if ! printf '%s\n' "$vendored_skills" | grep -Fxq "$skill"; then
        printf '%s\n' "$skill"
      fi
    done)

owned_count=$(printf '%s\n' "$owned_skills" | sed '/^$/d' | wc -l | tr -d ' ')
if [ "$owned_count" -gt 0 ]; then
  echo "  PASS  owned skill set excludes vendored Matt skills ($owned_count owned)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  owned skill set empty"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: owned skill set empty"
fi

long_desc=""
user_desc_triggers=""
missing_preamble=""
while IFS= read -r skill; do
  [ -n "$skill" ] || continue
  skill_file="$REPO_ROOT/$skill/SKILL.md"
  desc=$(awk 'BEGIN{c=0} /^---$/{c++; if(c==2)exit; next} c==1 && /^description:/{sub(/^description:[[:space:]]*/, ""); gsub(/^"|"$/, ""); print; exit}' "$skill_file")
  desc_len=${#desc}
  if [ "$desc_len" -gt 250 ]; then
    long_desc="$long_desc $skill($desc_len)"
  fi
  if grep -q '^disable-model-invocation: true$' "$skill_file" && echo "$desc" | grep -q 'Use when'; then
    user_desc_triggers="$user_desc_triggers $skill"
  fi
done <<< "$owned_skills"

if [ -z "$long_desc" ]; then
  echo "  PASS  owned skill descriptions stay under 250 chars"
  PASS=$((PASS + 1))
else
  echo "  FAIL  owned skill descriptions over 250 chars:$long_desc"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: owned skill descriptions over 250 chars:$long_desc"
fi

if [ -z "$user_desc_triggers" ]; then
  echo "  PASS  owned user-invoked descriptions avoid model trigger prose"
  PASS=$((PASS + 1))
else
  echo "  FAIL  user-invoked descriptions contain trigger prose:$user_desc_triggers"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: user-invoked descriptions contain trigger prose:$user_desc_triggers"
fi

# deslop preamble assertion removed (2026-07 audit): the stamped preamble
# violated single-source-of-truth; hooks + the deslop skill own the rule.
