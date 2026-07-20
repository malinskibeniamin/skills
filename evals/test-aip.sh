# Evals for /aip skill and protobuf hook.

SKILL_DIR="$REPO_ROOT/aip"
SKILL="$SKILL_DIR/SKILL.md"
REFERENCE="$SKILL_DIR/REFERENCE.md"

run_file_eval "$SKILL" "aip skill exists"
run_file_eval "$REFERENCE" "aip reference exists"
run_content_eval "$SKILL" "[Aa]pproved.*normative" \
  "aip skill treats approved AIPs as normative"
run_content_eval "$SKILL" "draft.*reviewing.*advisory|draft/reviewing.*advisory" \
  "aip skill treats draft and reviewing AIPs as advisory"
run_content_eval "$SKILL" "official.*google\.aip\.dev|google\.aip\.dev.*official" \
  "aip skill consults the official source"
run_content_eval "$SKILL" "applicable|applicability" \
  "aip skill selects conventions by applicability"
run_content_eval "$SKILL" "api-linter" \
  "aip skill uses api-linter when available"
run_content_eval "$SKILL" "openapi" \
  "aip skill auto-loads for OpenAPI schemas"
run_content_eval "$REFERENCE" 'AIP-134 requires an `update_mask` field but specifies it as optional' \
  "aip reference preserves AIP-134 optional update-mask semantics"
run_content_eval "$REFERENCE" 'string etag = 3;' \
  "aip reference leaves resource etag without field behavior"

if _aip_reference_error=$(python3 - "$REFERENCE" 2>&1 <<'PY'
from pathlib import Path
import re
import sys

reference = Path(sys.argv[1]).read_text()
expected = {
    1: "approved", 2: "approved", 3: "approved", 8: "approved",
    9: "approved", 100: "approved", 111: "approved", 121: "approved",
    122: "approved", 123: "approved", 124: "approved", 126: "approved",
    127: "approved", 128: "approved", 129: "approved", 130: "approved",
    131: "approved", 132: "approved", 133: "approved", 134: "approved",
    135: "approved", 136: "approved", 140: "approved", 141: "approved",
    142: "approved", 143: "approved", 144: "approved", 145: "approved",
    146: "approved", 147: "approved", 148: "approved", 149: "approved",
    151: "approved", 152: "approved", 153: "approved", 154: "approved",
    155: "approved", 156: "approved", 157: "approved", 158: "approved",
    159: "approved", 160: "approved", 161: "approved", 162: "draft (advisory)",
    163: "approved", 164: "approved", 165: "approved", 180: "approved",
    181: "approved", 182: "reviewing (advisory)", 185: "approved", 190: "approved",
    191: "approved", 192: "approved", 193: "approved", 194: "approved",
    200: "approved", 202: "approved", 203: "approved", 205: "approved",
    210: "approved", 211: "approved", 213: "approved", 214: "approved",
    215: "approved", 216: "approved", 217: "approved", 231: "approved",
    233: "approved", 234: "approved", 235: "approved", 236: "approved",
}
titles = {
    1: "AIP Purpose and Guidelines", 2: "AIP Numbering", 3: "AIP Versioning",
    8: "AIP Style and Guidance", 9: "Glossary", 100: "API Design Review FAQ",
    111: "Planes", 121: "Resource-oriented design", 122: "Resource names",
    123: "Resource types", 124: "Resource association", 126: "Enumerations",
    127: "HTTP and gRPC Transcoding", 128: "Declarative-friendly interfaces",
    129: "Server-Modified Values and Defaults", 130: "Methods",
    131: "Standard methods: Get", 132: "Standard methods: List",
    133: "Standard methods: Create", 134: "Standard methods: Update",
    135: "Standard methods: Delete", 136: "Custom methods", 140: "Field names",
    141: "Quantities", 142: "Time and duration", 143: "Standardized codes",
    144: "Repeated fields", 145: "Ranges", 146: "Generic fields",
    147: "Sensitive fields", 148: "Standard fields", 149: "Unset field values",
    151: "Long-running operations", 152: "Jobs", 153: "Import and export",
    154: "Resource freshness validation", 155: "Request identification",
    156: "Singleton resources", 157: "Partial responses", 158: "Pagination",
    159: "Reading across collections", 160: "Filtering", 161: "Field masks",
    162: "Resource Revisions", 163: "Change validation", 164: "Soft delete",
    165: "Criteria-based delete", 180: "Backwards compatibility",
    181: "Stability levels", 182: "External software dependencies",
    185: "API Versioning", 190: "Naming conventions",
    191: "File and directory structure", 192: "Documentation", 193: "Errors",
    194: "Automatic retry configuration", 200: "Precedent", 202: "Fields",
    203: "Field behavior documentation", 205: "Beta-blocking changes",
    210: "Unicode", 211: "Authorization checks", 213: "Common components",
    214: "Resource expiration", 215: "API-specific protos", 216: "States",
    217: "Unreachable resources", 231: "Batch methods: Get",
    233: "Batch methods: Create", 234: "Batch methods: Update",
    235: "Batch methods: Delete", 236: "Policy preview",
}

sections = list(re.finditer(r"^## AIP-(\d+) - (.+)$", reference, re.MULTILINE))
found = [int(match.group(1)) for match in sections]
if len(found) != len(set(found)) or sorted(found) != sorted(expected):
    print(f"expected AIP ids {sorted(expected)}, found {found}")
    raise SystemExit(1)

for index, match in enumerate(sections):
    aip = int(match.group(1))
    if match.group(2) != titles[aip]:
        print(f"AIP-{aip} title is {match.group(2)!r}, expected {titles[aip]!r}")
        raise SystemExit(1)
    end = sections[index + 1].start() if index + 1 < len(sections) else len(reference)
    section = reference[match.start():end]
    requirements = {
        "state": rf"\*\*State:\*\* {re.escape(expected[aip])}\n",
        "applicability": r"\*\*Use when:\*\* \S",
        "guidance": r"\*\*Apply:\*\* \S",
        "source": rf"\*\*Source:\*\* https://google\.aip\.dev/{aip}\b",
    }
    for label, pattern in requirements.items():
        if not re.search(pattern, section):
            print(f"AIP-{aip} missing {label}")
            raise SystemExit(1)
PY
); then
  echo "  PASS  aip reference covers all General AIPs 1 through 236"
  PASS=$((PASS + 1))
else
  echo "  FAIL  aip reference covers all General AIPs 1 through 236"
  echo "        $_aip_reference_error"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: aip reference covers all General AIPs 1 through 236"
fi

HOOK="$REPO_ROOT/.claude/hooks/aip-proto-check.sh"
TMP_PROTO="$REPO_ROOT/.tmp-aip-eval.proto"
trap 'rm -f "$TMP_PROTO"' EXIT

run_file_eval "$HOOK" "aip-proto-check.sh exists"
run_executable_eval "$HOOK" "aip-proto-check.sh is executable"

cat > "$TMP_PROTO" <<'PROTO'
syntax = "proto3";
message LegacyGetBookRequest {
  string id = 1;
}
PROTO

run_hook_eval "$HOOK" \
  "$(jq -nc --arg f "$TMP_PROTO" --arg c 'message LegacyGetBookRequest { string id = 1; }' '{tool_name:"Write",tool_input:{file_path:$f,content:$c}}')" \
  0 \
  "aip hook warns on new id-based request identity" \
  "AIP proto nudge"

cat > "$TMP_PROTO" <<'PROTO'
syntax = "proto3";
import "google/api/resource.proto";
message Book {
  option (google.api.resource) = {
    type: "library.example.com/Book"
    singular: "book"
    plural: "books"
  };
}
PROTO

run_hook_eval "$HOOK" \
  "$(jq -nc --arg f "$TMP_PROTO" --rawfile c "$TMP_PROTO" '{tool_name:"Write",tool_input:{file_path:$f,content:$c}}')" \
  0 \
  "aip hook warns on resource annotation without pattern" \
  "resource option lacks pattern"

cat > "$TMP_PROTO" <<'PROTO'
syntax = "proto3";
message Book {
  string name = 1 [(google.api.field_behavior) = IDENTIFIER];
}
PROTO

run_hook_eval "$HOOK" \
  "$(jq -nc --arg f "$TMP_PROTO" --rawfile c "$TMP_PROTO" '{tool_name:"Write",tool_input:{file_path:$f,content:$c}}')" \
  0 \
  "aip hook stays quiet for canonical name" 

rm -f "$TMP_PROTO"
