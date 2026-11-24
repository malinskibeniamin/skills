#!/bin/bash
# Stage a published release once, then refresh explicitly opted-in clients.
set -euo pipefail
umask 077
repo=malinskibeniamin/skills
remote="https://github.com/$repo.git"
state="${SKILLS_RELEASE_HOME:-$HOME/.local/state/frontend-skills-release}"
codex=false claude=false agy=false
workspaces=()
case "$state" in /*) ;; *) echo "SKILLS_RELEASE_HOME must be absolute" >&2; exit 2;; esac
while [ "$#" -gt 0 ]; do
  case "$1" in
    --codex) codex=true ;;
    --claude) claude=true ;;
    --antigravity) agy=true ;;
    --antigravity-workspace)
      [ "$#" -ge 2 ] && [[ "$2" = /* ]] && [ -d "$2" ] ||
        { echo "An existing absolute Antigravity workspace is required" >&2; exit 2; }
      workspaces+=("$(cd "$2" && pwd -P)")
      shift ;;

    *) echo "Usage: $0 [--codex] [--claude] [--antigravity] [--antigravity-workspace /project]" >&2; exit 2 ;;
  esac
  shift
done
mkdir -p "$state"
state="$(cd "$state" && pwd -P)"
checkout="$state/source"
lock="$state/update.lock"
mkdir "$lock" || { echo "Skills update already running or lock needs inspection: $lock" >&2; exit 1; }
trap 'rmdir "$lock"' EXIT
tag="$(gh release view --repo "$repo" --json tagName,isDraft,isPrerelease \
  --jq 'select(.isDraft == false and .isPrerelease == false) | .tagName')"
[[ "$tag" =~ ^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]] || {
  echo "No stable published skills release" >&2; exit 1;
}
if [ ! -e "$checkout" ]; then
  git clone --branch "$tag" --depth=1 --no-tags --filter=blob:none "$remote" "$checkout"
  git -C "$checkout" fetch --no-tags --depth=1 origin "refs/tags/$tag:refs/tags/$tag"
fi
[ ! -L "$checkout" ] && [ -d "$checkout/.git" ] &&
  [ "$(git -C "$checkout" config --get remote.origin.url)" = "$remote" ] &&
  [ -z "$(git -C "$checkout" status --porcelain)" ] || {
    echo "Refusing to update a modified or unmanaged checkout: $checkout" >&2; exit 1;
  }
if ! git -C "$checkout" show-ref --verify --quiet "refs/tags/$tag"; then
  git -C "$checkout" fetch --no-tags --depth=1 origin "refs/tags/$tag:refs/tags/$tag"
fi
sha="$(git -C "$checkout" rev-parse "refs/tags/$tag^{commit}")"
remote_refs="$(git ls-remote "$remote" "refs/tags/$tag" "refs/tags/$tag^{}")"
remote_sha="$(awk -v tag="refs/tags/$tag" '$2==tag {direct=$1} $2==tag "^{}" {peeled=$1} END {print peeled ? peeled : direct}' <<<"$remote_refs")"
[ "$sha" = "$remote_sha" ] || { echo "Release tag moved; refusing to update" >&2; exit 1; }
git -C "$checkout" show "$sha:skill-manifest.json" |
  jq -e --arg version "${tag#v}" '.version == $version' >/dev/null
if [ "$(git -C "$checkout" rev-parse HEAD)" != "$sha" ]; then
  current="$(jq -er .version "$checkout/skill-manifest.json")"
  python3 - "$current" "${tag#v}" <<'PYTHON'
import sys
old, new = (tuple(map(int, v.split("."))) for v in sys.argv[1:])
if new <= old:
    raise SystemExit("Release version did not advance; refusing to replace the staged version")
PYTHON
  git -C "$checkout" checkout --detach "$sha"
fi
cd "$state" # no project-scoped installs or startup settings
version="${tag#v}"
echo "Verified $tag ($sha); marketplace root: $checkout"

update_codex() {
  codex plugin marketplace list --json |
    jq -e --arg root "$checkout" 'any(.marketplaces[]; .name == "skills" and .root == $root and .marketplaceSource.sourceType == "local")' >/dev/null ||
    { echo "Codex: register the release checkout as the skills marketplace first" >&2; return 1; }
  local installed
  installed="$(codex plugin list --json)" || return 1
  jq -e 'any(.installed[]; .pluginId == "frontend-skills@skills" and .enabled)' <<<"$installed" >/dev/null ||
    { echo "Codex: an enabled user install is required" >&2; return 1; }
  if ! jq -e --arg v "$version" 'any(.installed[]; .pluginId == "frontend-skills@skills" and .enabled and .version == $v)' <<<"$installed" >/dev/null; then
    codex plugin add frontend-skills@skills --json |
      jq -e --arg v "$version" '.pluginId == "frontend-skills@skills" and .version == $v' >/dev/null || return 1
    echo "Codex: installed $tag; restart to reload"
  fi
}

update_claude() {
  if ! jq -e '.plugins[] | select(.name == "frontend-skills") | .source == "./"' "$checkout/.claude-plugin/marketplace.json" >/dev/null; then
    echo "Claude: this release does not provide a release-local plugin source" >&2
    return 1
  fi
  claude plugin marketplace list --json |
    jq -e --arg root "$checkout" 'any(.[]; .name == "skills" and .source == "directory" and .path == $root)' >/dev/null ||
    { echo "Claude: register the release checkout as the user skills marketplace first" >&2; return 1; }
  local installed
  installed="$(claude plugin list --json)" || return 1
  jq -e 'any(.[]; .id == "frontend-skills@skills" and .scope == "user" and .enabled)' <<<"$installed" >/dev/null ||
    { echo "Claude: an enabled user install is required" >&2; return 1; }
  if ! jq -e --arg v "$version" 'any(.[]; .id == "frontend-skills@skills" and .scope == "user" and .enabled and .version == $v)' <<<"$installed" >/dev/null; then
    claude plugin update frontend-skills@skills --scope user || return 1
    claude plugin list --json |
      jq -e --arg v "$version" 'any(.[]; .id == "frontend-skills@skills" and .scope == "user" and .enabled and .version == $v)' >/dev/null || return 1
    echo "Claude: installed $tag; reload plugins"
  fi
}

update_antigravity() (
  # The standalone CLI is separate from T3 ACP workspace discovery.
  local bundle receipt
  receipt="$state/antigravity-release"
  if [ -f "$receipt" ] && [ "$(cat "$receipt")" = "$sha" ]; then return 0; fi
  [ -f "$checkout/scripts/build-antigravity-plugin.py" ] ||
    { echo "Antigravity: $tag predates the bundle builder" >&2; return 1; }
  bundle="$(mktemp -d "$state/antigravity.XXXXXX")" || return 1
  trap 'rm -rf "$bundle"' EXIT
  python3 "$checkout/scripts/build-antigravity-plugin.py" "$bundle/frontend-skills" || return 1
  agy plugin validate "$bundle/frontend-skills" || return 1
  agy plugin install "$bundle/frontend-skills" || return 1
  printf '%s\n' "$sha" > "$receipt"
  echo "Antigravity standalone: installed $tag; reload the session"
)

update_workspace() (
  local project="$1" dest stage
  dest="$project/.agents/plugins/frontend-skills"
  [ ! -L "$project/.agents" ] && [ ! -L "$project/.agents/plugins" ] && [ ! -L "$dest" ] ||
    { echo "Antigravity: refusing symlinked workspace destination" >&2; return 1; }
  if [ -e "$dest" ]; then
    [ -f "$dest/.release-ref" ] ||
      { echo "Antigravity: move the unmanaged bundle aside before opting in: $dest" >&2; return 1; }
    if [ "$(cat "$dest/.release-ref")" = "$sha" ]; then return 0; fi
  fi
  mkdir -p "$(dirname "$dest")" || return 1
  stage="$(mktemp -d "$(dirname "$dest")/.skills-stage.XXXXXX")" || return 1
  trap 'rm -rf "$stage"' EXIT
  python3 "$checkout/scripts/build-antigravity-plugin.py" "$stage/new" || return 1
  printf '%s\n' "$sha" > "$stage/new/.release-ref" || return 1
  if [ -e "$dest" ]; then mv "$dest" "$stage/previous" || return 1; fi
  if ! mv "$stage/new" "$dest"; then
    if [ -e "$stage/previous" ] && ! mv "$stage/previous" "$dest"; then
      trap - EXIT
      echo "Previous bundle retained at $stage/previous" >&2
    fi
    return 1
  fi
  echo "Antigravity workspace: installed $tag in $project; start a new thread"
)

failed=0
if "$codex"; then update_codex || failed=1; fi
if "$claude"; then update_claude || failed=1; fi
if "$agy"; then update_antigravity || failed=1; fi
for workspace in "${workspaces[@]+${workspaces[@]}}"; do
  update_workspace "$workspace" || failed=1
done
exit "$failed"
