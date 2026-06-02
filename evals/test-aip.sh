# Evals for /aip protobuf hook.

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
