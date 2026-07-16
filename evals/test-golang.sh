# Evals for /golang hooks: proto reserved fields + pinned test images.

PROTO_HOOK="$REPO_ROOT/.claude/hooks/go-proto-reserved-check.sh"
IMAGE_HOOK="$REPO_ROOT/.claude/hooks/go-test-image-pin-check.sh"
TMP_PROTO="$REPO_ROOT/.tmp-golang-eval.proto"
TMP_TEST_GO="$REPO_ROOT/.tmp-golang-eval_test.go"
TMP_GO="$REPO_ROOT/.tmp-golang-eval.go"
trap 'rm -f "$TMP_PROTO" "$TMP_TEST_GO" "$TMP_GO"' EXIT

run_file_eval "$PROTO_HOOK" "go-proto-reserved-check.sh exists"
run_executable_eval "$PROTO_HOOK" "go-proto-reserved-check.sh is executable"
run_file_eval "$IMAGE_HOOK" "go-test-image-pin-check.sh exists"
run_executable_eval "$IMAGE_HOOK" "go-test-image-pin-check.sh is executable"

run_file_eval "$REPO_ROOT/golang/SKILL.md" "golang skill exists"
run_file_eval "$REPO_ROOT/golang-review/SKILL.md" "golang-review skill exists"
run_file_eval "$REPO_ROOT/golang-review/RULES.md" "golang-review rule catalog exists"

# --- proto reserved-field hook ---

# Removing a shipped field without reserving its number and name warns.
cat > "$TMP_PROTO" <<'PROTO'
syntax = "proto3";
message Cluster {
  string name = 1;
}
PROTO

run_hook_eval "$PROTO_HOOK" \
  "$(jq -nc --arg f "$TMP_PROTO" \
    --arg o 'message Cluster {
  string name = 1;
  string legacy_id = 3;
}' \
    --arg n 'message Cluster {
  string name = 1;
}' '{tool_name:"Edit",tool_input:{file_path:$f,old_string:$o,new_string:$n}}')" \
  0 \
  "proto hook warns when removed field is not reserved" \
  "reserve"

# Removal accompanied by reserved number + name stays quiet.
cat > "$TMP_PROTO" <<'PROTO'
syntax = "proto3";
message Cluster {
  reserved 3;
  reserved "legacy_id";
  string name = 1;
}
PROTO

run_hook_eval "$PROTO_HOOK" \
  "$(jq -nc --arg f "$TMP_PROTO" \
    --arg o 'message Cluster {
  string name = 1;
  string legacy_id = 3;
}' \
    --arg n 'message Cluster {
  reserved 3;
  reserved "legacy_id";
  string name = 1;
}' '{tool_name:"Edit",tool_input:{file_path:$f,old_string:$o,new_string:$n}}')" \
  0 \
  "proto hook stays quiet when removal is reserved"

# A field that merely moves (same name and number re-added) stays quiet.
cat > "$TMP_PROTO" <<'PROTO'
syntax = "proto3";
message Cluster {
  string legacy_id = 3;
  string name = 1;
}
PROTO

run_hook_eval "$PROTO_HOOK" \
  "$(jq -nc --arg f "$TMP_PROTO" \
    --arg o 'message Cluster {
  string name = 1;
  string legacy_id = 3;
}' \
    --arg n 'message Cluster {
  string legacy_id = 3;
  string name = 1;
}' '{tool_name:"Edit",tool_input:{file_path:$f,old_string:$o,new_string:$n}}')" \
  0 \
  "proto hook stays quiet when a field only moves"

# Re-adding a removed field name under a new number is a renumber.
cat > "$TMP_PROTO" <<'PROTO'
syntax = "proto3";
message Cluster {
  string legacy_id = 4;
}
PROTO

run_hook_eval "$PROTO_HOOK" \
  "$(jq -nc --arg f "$TMP_PROTO" \
    --arg o 'message Cluster {
  string legacy_id = 3;
}' \
    --arg n 'message Cluster {
  string legacy_id = 4;
}' '{tool_name:"Edit",tool_input:{file_path:$f,old_string:$o,new_string:$n}}')" \
  0 \
  "proto hook warns on renumbered field" \
  "renumber"

# A removed field with a trailing comment still warns.
cat > "$TMP_PROTO" <<'PROTO'
syntax = "proto3";
message Cluster {
  string name = 1;
}
PROTO

run_hook_eval "$PROTO_HOOK" \
  "$(jq -nc --arg f "$TMP_PROTO" \
    --arg o 'message Cluster {
  string name = 1;
  string legacy_id = 3; // deprecated since 24.2
}' \
    --arg n 'message Cluster {
  string name = 1;
}' '{tool_name:"Edit",tool_input:{file_path:$f,old_string:$o,new_string:$n}}')" \
  0 \
  "proto hook warns on removed field with trailing comment" \
  "reserve"

# Enum value removal is not a field removal; stays quiet.
cat > "$TMP_PROTO" <<'PROTO'
syntax = "proto3";
enum State {
  STATE_UNSPECIFIED = 0;
}
PROTO

run_hook_eval "$PROTO_HOOK" \
  "$(jq -nc --arg f "$TMP_PROTO" \
    --arg o 'enum State {
  STATE_UNSPECIFIED = 0;
  STATE_LEGACY = 3;
}' \
    --arg n 'enum State {
  STATE_UNSPECIFIED = 0;
}' '{tool_name:"Edit",tool_input:{file_path:$f,old_string:$o,new_string:$n}}')" \
  0 \
  "proto hook ignores enum value removal"

# --- test image pin hook ---

# Floating image tag in a Go test file warns.
cat > "$TMP_TEST_GO" <<'GO'
package foo

const testImage = "example/service:latest"
GO

run_hook_eval "$IMAGE_HOOK" \
  "$(jq -nc --arg f "$TMP_TEST_GO" \
    --arg o 'package foo' \
    --arg n 'package foo

const testImage = "example/service:latest"' '{tool_name:"Edit",tool_input:{file_path:$f,old_string:$o,new_string:$n}}')" \
  0 \
  "image hook warns on floating :latest in test file" \
  "pin"

# Pinned release tag stays quiet.
cat > "$TMP_TEST_GO" <<'GO'
package foo

const testImage = "example/service:v1.2.3"
GO

run_hook_eval "$IMAGE_HOOK" \
  "$(jq -nc --arg f "$TMP_TEST_GO" \
    --arg o 'package foo' \
    --arg n 'package foo

const testImage = "example/service:v1.2.3"' '{tool_name:"Edit",tool_input:{file_path:$f,old_string:$o,new_string:$n}}')" \
  0 \
  "image hook stays quiet on pinned tag"

# Non-test Go files are out of scope.
cat > "$TMP_GO" <<'GO'
package foo

const image = "example/service:latest"
GO

run_hook_eval "$IMAGE_HOOK" \
  "$(jq -nc --arg f "$TMP_GO" \
    --arg o 'package foo' \
    --arg n 'package foo

const image = "example/service:latest"' '{tool_name:"Edit",tool_input:{file_path:$f,old_string:$o,new_string:$n}}')" \
  0 \
  "image hook ignores non-test go files"

# A tag merely starting with "latest" is not floating.
cat > "$TMP_TEST_GO" <<'GO'
package foo

const testImage = "example/service:latest-snapshot"
GO

run_hook_eval "$IMAGE_HOOK" \
  "$(jq -nc --arg f "$TMP_TEST_GO" \
    --arg o 'package foo' \
    --arg n 'package foo

const testImage = "example/service:latest-snapshot"' '{tool_name:"Edit",tool_input:{file_path:$f,old_string:$o,new_string:$n}}')" \
  0 \
  "image hook ignores tags that merely start with latest"

# A :main string with no image shape stays quiet.
cat > "$TMP_TEST_GO" <<'GO'
package foo

const ref = "branch:main"
GO

run_hook_eval "$IMAGE_HOOK" \
  "$(jq -nc --arg f "$TMP_TEST_GO" \
    --arg o 'package foo' \
    --arg n 'package foo

const ref = "branch:main"' '{tool_name:"Edit",tool_input:{file_path:$f,old_string:$o,new_string:$n}}')" \
  0 \
  "image hook ignores non-image floating strings"

# Escape hatch silences the image hook.
cat > "$TMP_TEST_GO" <<'GO'
package foo

// allow: floating-image chasing an upstream regression on main
const testImage = "example/service:latest"
GO

run_hook_eval "$IMAGE_HOOK" \
  "$(jq -nc --arg f "$TMP_TEST_GO" \
    --arg o 'package foo' \
    --arg n 'package foo

const testImage = "example/service:latest"' '{tool_name:"Edit",tool_input:{file_path:$f,old_string:$o,new_string:$n}}')" \
  0 \
  "image hook honors floating-image escape hatch"

rm -f "$TMP_PROTO" "$TMP_TEST_GO" "$TMP_GO"
