# Evals for the evidence-backed /postgresql skill and its corpus updater.

SKILL_DIR="$REPO_ROOT/postgresql"
SKILL="$SKILL_DIR/SKILL.md"
EVIDENCE="$SKILL_DIR/references/EVIDENCE.md"
WEEKLY="$SKILL_DIR/references/WEEKLY-REPORT.md"
JET="$SKILL_DIR/references/GO-JET.md"
INDEX="$SKILL_DIR/references/source-index.jsonl"
REFRESH="$SKILL_DIR/scripts/refresh-corpus.ts"
REFRESH_TEST="$SKILL_DIR/scripts/refresh-corpus.test.ts"

run_file_eval "$SKILL" "postgresql skill exists"
run_file_eval "$EVIDENCE" "postgresql evidence policy exists"
run_file_eval "$WEEKLY" "postgresql weekly report contract exists"
run_file_eval "$JET" "postgresql go-jet guidance exists"
run_file_eval "$INDEX" "postgresql source-decision index exists"
run_executable_eval "$REFRESH" "postgresql corpus updater is executable"
run_file_eval "$REFRESH_TEST" "postgresql corpus updater tests exist"

run_content_eval "$SKILL" "workload" "postgresql starts from workload evidence"
run_content_eval "$SKILL" "read-only" "postgresql defaults production diagnosis to read-only"
run_content_eval "$SKILL" "explicit approval" "postgresql gates production changes on approval"
run_content_eval "$SKILL" "actual SQL" "postgresql requires actual emitted SQL"
run_content_eval "$SKILL" "rollback|forward-fix" "postgresql requires a recovery path"
run_content_eval "$SKILL" "verification" "postgresql requires post-change verification"
run_content_eval "$SKILL" "PostgreSQL 19.*preview|19 preview" "postgresql isolates preview guidance"
run_content_eval "$EVIDENCE" "10,350" "evidence policy records corpus coverage"
run_content_eval "$EVIDENCE" "official PostgreSQL" "official PostgreSQL sources outrank vendors"
run_content_eval "$EVIDENCE" "vendor.*claim|Vendor.*claim" "vendor claims remain labeled"
run_content_eval "$WEEKLY" "p50.*p95.*p99|p95.*p99" "weekly report covers latency percentiles"
run_content_eval "$WEEKLY" "restore" "weekly report covers restore confidence"
run_content_eval "$JET" "generator.*deletes|deletes.*destination" "go-jet warns about generated-folder deletion"
run_content_eval "$JET" "QRM" "go-jet treats result mapping as a correctness surface"
run_content_eval "$REPO_ROOT/review/SKILL.md" "postgresql" "review panel routes PostgreSQL changes"
run_content_eval "$REPO_ROOT/scripts/generate-skill-catalog.sh" '"postgresql"' "catalog generator knows postgresql"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"./postgresql/"' "Claude plugin registers postgresql"

if [ -f "$INDEX" ]; then
  if python3 - "$INDEX" <<'PY'
import json
import sys

path = sys.argv[1]
seen = set()
included = 0
total = 0
for line_number, line in enumerate(open(path), 1):
    record = json.loads(line)
    required = {"source", "kind", "url", "status", "reviewed_at"}
    missing = required - record.keys()
    if missing:
        raise SystemExit(f"line {line_number}: missing {sorted(missing)}")
    if record["url"] in seen:
        raise SystemExit(f"line {line_number}: duplicate URL {record['url']}")
    seen.add(record["url"])
    if record["status"] == "included":
        if not record.get("topics"):
            raise SystemExit(f"line {line_number}: included record needs topics")
        included += 1
    elif record["status"] == "excluded":
        if not record.get("reason"):
            raise SystemExit(f"line {line_number}: excluded record needs a reason")
    else:
        raise SystemExit(f"line {line_number}: invalid status {record['status']}")
    total += 1
if total < 10000 or included < 1000:
    raise SystemExit(f"source index unexpectedly small: total={total} included={included}")
PY
  then
    echo "  PASS  source-decision index has valid unique records"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  retained-source index schema is invalid"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: source-decision index schema"
  fi
fi

if [ -f "$REFRESH_TEST" ]; then
  if bun test "$REFRESH_TEST"; then
    echo "  PASS  postgresql corpus updater tests pass"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  postgresql corpus updater tests fail"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: postgresql corpus updater tests"
  fi
fi
