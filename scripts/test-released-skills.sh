#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd -P)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/repo/scripts" "$tmp/workspace"
export SKILLS_RELEASE_HOME="$tmp/state"
export TEST_RELEASE_TAG="$tmp/latest" TEST_CALLS="$tmp/calls"
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0="url.file://$tmp/repo.insteadOf"
export GIT_CONFIG_VALUE_0=https://github.com/malinskibeniamin/skills.git
export PATH="$tmp/bin:$PATH"
cat >"$tmp/bin/gh" <<'EOF'
#!/bin/sh
[ "$1 $2" = "release view" ] || exit 9
cat "$TEST_RELEASE_TAG"
EOF
cat >"$tmp/bin/agy" <<'EOF'
#!/bin/bash
set -eu
case "$1 $2" in
  "plugin validate") test -f "$3/plugin.json" ;;
  "plugin install") jq -er .version "$3/plugin.json" >> "$TEST_CALLS" ;;
  *) exit 9 ;;
esac
EOF
chmod +x "$tmp/bin/gh" "$tmp/bin/agy"
cat >"$tmp/repo/scripts/build-antigravity-plugin.py" <<'PY'
import pathlib, shutil, sys
out = pathlib.Path(sys.argv[1])
out.mkdir()
shutil.copy(pathlib.Path(__file__).resolve().parents[1] / "skill-manifest.json", out / "plugin.json")
PY
git -C "$tmp/repo" init -q
git -C "$tmp/repo" config user.name Fixture
git -C "$tmp/repo" config user.email fixture@example.test
new_release() {
  printf '{"version":"%s"}\n' "$1" >"$tmp/repo/skill-manifest.json"
  git -C "$tmp/repo" add .
  git -C "$tmp/repo" commit -qm "$1"
  git -C "$tmp/repo" tag -a "v$1" -m "$1"
  printf 'v%s\n' "$1" >"$TEST_RELEASE_TAG"
}
update() {
  bash "$root/scripts/update-released-skills.sh" --antigravity --antigravity-workspace "$tmp/workspace"
}
new_release 4.45.1
update
update
test "$(cat "$TEST_CALLS")" = "4.45.1"
new_release 4.45.2
update
test "$(tail -1 "$TEST_CALLS")" = "4.45.2"
test "$(jq -r .version "$tmp/workspace/.agents/plugins/frontend-skills/plugin.json")" = "4.45.2"
test "$(wc -l <"$TEST_CALLS" | tr -d ' ')" = 2
mkdir -p "$tmp/unmanaged/.agents/plugins/frontend-skills"
printf '%s\n' untouched >"$tmp/unmanaged/.agents/plugins/frontend-skills/custom"
if bash "$root/scripts/update-released-skills.sh" --antigravity-workspace "$tmp/unmanaged"; then
  echo "Replaced an unmanaged bundle" >&2; exit 1
fi
test "$(cat "$tmp/unmanaged/.agents/plugins/frontend-skills/custom")" = untouched
# A moved tag or downgrade must not touch a client or replace its bundle.
git -C "$tmp/repo" tag -f v4.45.2 HEAD^
if update; then echo "Accepted a moved tag" >&2; exit 1; fi
printf 'v4.45.1\n' >"$TEST_RELEASE_TAG"
if update; then echo "Accepted a downgrade" >&2; exit 1; fi
test "$(wc -l <"$TEST_CALLS" | tr -d ' ')" = 2
echo "PASS: released updates, repeat no-op, moved-tag rejection and downgrade rejection"
