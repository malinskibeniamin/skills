# Evals for repository-wide project-name hygiene.

_forbidden_token=$(printf 'cmVkcGFuZGE=' | base64 -d)
_files_list=$(mktemp)
git -C "$REPO_ROOT" ls-files -z > "$_files_list"
_leaks=$(python3 - "$REPO_ROOT" "$_forbidden_token" "$_files_list" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1])
needle = sys.argv[2].lower()
files_list = Path(sys.argv[3])
allowed = ["redpanda-ui", "@redpanda-data/ui"]
raw = files_list.read_bytes().split(b"\0")
leaks = []

for item in raw:
    if not item:
        continue
    rel = item.decode()
    path = root / rel
    if not path.exists():
        continue

    rel_scrubbed = rel.lower()
    for token in allowed:
        rel_scrubbed = rel_scrubbed.replace(token, "")
    if needle in rel_scrubbed:
        leaks.append(rel)
        continue

    try:
        text = path.read_text(errors="ignore").lower()
    except OSError:
        continue
    for token in allowed:
        text = text.replace(token, "")
    if needle in text:
        leaks.append(rel)

print("\n".join(leaks))
PY
)
rm -f "$_files_list"

if [ -z "$_leaks" ]; then
  echo "  PASS  forbidden project token absent except approved UI guardrails"
  PASS=$((PASS + 1))
else
  echo "  FAIL  forbidden project token found outside approved UI guardrails"
  echo "$_leaks" | sed 's/^/        /'
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: forbidden project token found outside approved UI guardrails"
fi
