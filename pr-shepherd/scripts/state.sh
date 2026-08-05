#!/bin/bash
set -euo pipefail

# Persist and classify SHA-bound PR shepherd evidence. This script never calls GitHub;
# callers supply one `gh pr list --json ...` snapshot so its behavior is deterministic.

usage() {
  cat >&2 <<'EOF'
Usage:
  state.sh classify --repo OWNER/REPO --snapshot FILE [--state-file FILE]
  state.sh acknowledge --repo OWNER/REPO --snapshot FILE --pr NUMBER_OR_URL \
    --review-status pass|skipped|deferred \
    --dogfood-status pass|skipped|blocked \
    --threads-status clean|deferred \
    [--deferred-thread ID ...] [--state-file FILE]
EOF
  exit 2
}

command -v jq >/dev/null 2>&1 || { echo "jq required" >&2; exit 2; }

command_name="${1:-}"
[ -n "$command_name" ] || usage
shift

repo=""
snapshot=""
state_file="${PR_SHEPHERD_STATE_FILE:-${XDG_STATE_HOME:-${HOME:-}/.local/state}/frontend-skills/pr-shepherd/state.json}"
pr=""
review_status=""
dogfood_status=""
threads_status=""
deferred_threads='[]'

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      [ "$#" -ge 2 ] || usage
      repo=$2
      shift 2
      ;;
    --snapshot)
      [ "$#" -ge 2 ] || usage
      snapshot=$2
      shift 2
      ;;
    --state-file)
      [ "$#" -ge 2 ] || usage
      state_file=$2
      shift 2
      ;;
    --pr)
      [ "$#" -ge 2 ] || usage
      pr=$2
      shift 2
      ;;
    --review-status)
      [ "$#" -ge 2 ] || usage
      review_status=$2
      shift 2
      ;;
    --dogfood-status)
      [ "$#" -ge 2 ] || usage
      dogfood_status=$2
      shift 2
      ;;
    --threads-status)
      [ "$#" -ge 2 ] || usage
      threads_status=$2
      shift 2
      ;;
    --deferred-thread)
      [ "$#" -ge 2 ] || usage
      deferred_threads=$(printf '%s' "$deferred_threads" | jq -c --arg id "$2" '. + [$id] | unique')
      shift 2
      ;;
    *) usage ;;
  esac
done

[ -n "$repo" ] && [ -n "$snapshot" ] && [ -n "$state_file" ] || usage
[ -f "$snapshot" ] || { echo "snapshot not found: $snapshot" >&2; exit 2; }
printf '%s' "$repo" | grep -Eq '^[^/[:space:]]+/[^/[:space:]]+$' || {
  echo "repo must be OWNER/REPO" >&2
  exit 2
}
jq -e 'type == "array" and all(.[]; (.number | type) == "number" and (.url | type) == "string" and (.headRefOid | type) == "string")' \
  "$snapshot" >/dev/null || { echo "invalid PR snapshot" >&2; exit 2; }

empty_state='{"schema_version":1,"repositories":{}}'
temporary_state_input=false
lock_dir=""
lock_owned=false
state_tmp=""

cleanup() {
  if [ "$temporary_state_input" = true ] && [ -n "${state_input:-}" ]; then
    rm -f "$state_input"
  fi
  if [ -n "$state_tmp" ]; then
    rm -f "$state_tmp"
  fi
  if [ "$lock_owned" = true ] && [ -n "$lock_dir" ] && [ -d "$lock_dir" ]; then
    rm -f "$lock_dir/pid"
    rmdir "$lock_dir" 2>/dev/null || true
  fi
}
trap cleanup EXIT

if [ "$command_name" = "acknowledge" ]; then
  state_dir=$(dirname "$state_file")
  umask 077
  mkdir -p "$state_dir"
  lock_dir="${state_file}.lock"
  if ! mkdir "$lock_dir" 2>/dev/null; then
    lock_pid=$(cat "$lock_dir/pid" 2>/dev/null || true)
    if printf '%s' "$lock_pid" | grep -Eq '^[0-9]+$' && ! kill -0 "$lock_pid" 2>/dev/null; then
      rm -f "$lock_dir/pid"
      rmdir "$lock_dir" 2>/dev/null || true
      mkdir "$lock_dir" 2>/dev/null || {
        echo "PR shepherd state is busy; rerun the sweep" >&2
        exit 3
      }
    else
      echo "PR shepherd state is busy; rerun the sweep" >&2
      exit 3
    fi
  fi
  lock_owned=true
  printf '%s\n' "$$" > "$lock_dir/pid"
fi

if [ -f "$state_file" ]; then
  jq -e '.schema_version == 1 and (.repositories | type) == "object"' "$state_file" >/dev/null || {
    echo "invalid PR shepherd state: $state_file" >&2
    exit 2
  }
  state_input=$state_file
else
  umask 077
  state_input=$(mktemp)
  temporary_state_input=true
  printf '%s\n' "$empty_state" > "$state_input"
fi

case "$command_name" in
  classify)
    jq --arg repo "$repo" --slurpfile snapshot "$snapshot" '
      def ci_state:
        (.statusCheckRollup // []) as $checks
        | if ($checks | length) == 0 then "none"
          elif any($checks[];
            ((.conclusion // "") | IN("FAILURE", "CANCELLED", "TIMED_OUT", "ACTION_REQUIRED", "STALE"))) then "failure"
          elif any($checks[];
            (.status // "") != "COMPLETED" or ((.conclusion // "") == "")) then "pending"
          else "success"
          end;
      def normalized:
        {
          number,
          url,
          title,
          head_branch: .headRefName,
          head_sha: .headRefOid,
          updated_at: .updatedAt,
          is_draft: (.isDraft // false),
          mergeable: (.mergeable // "UNKNOWN"),
          merge_state_status: (.mergeStateStatus // "UNKNOWN"),
          review_decision: (.reviewDecision // ""),
          human_review_required: ((.reviewDecision // "") == "REVIEW_REQUIRED"),
          ci_state: ci_state
        };
      def reasons($current; $prior):
        ([
          if $prior == null then "new_pr" else empty end,
          if $prior != null and $prior.head_sha != $current.head_sha then "head_changed" else empty end,
          if $prior != null and $prior.updated_at != $current.updated_at then "activity_changed" else empty end,
          if $current.ci_state == "failure" then "ci_failing"
          elif $current.ci_state == "pending" then "ci_pending"
          elif $prior != null and $prior.ci_state != $current.ci_state then "ci_changed"
          else empty end,
          if $current.mergeable == "CONFLICTING" or $current.merge_state_status == "DIRTY"
          then "merge_conflict" else empty end,
          if $current.review_decision == "CHANGES_REQUESTED" then "changes_requested" else empty end,
          if $prior == null
            or $prior.review.sha != $current.head_sha
            or (($prior.review.status // "") | IN("pass", "skipped", "deferred") | not)
          then "review_stale" else empty end,
          if $prior == null
            or $prior.dogfood.sha != $current.head_sha
            or (($prior.dogfood.status // "") | IN("pass", "skipped") | not)
          then (if ($prior.dogfood.status // "") == "blocked" then "dogfood_blocked" else "dogfood_stale" end)
          else empty end,
          if $prior == null then "threads_unknown"
          elif $prior.threads.sha != $current.head_sha then "threads_stale"
          elif (($prior.threads.status // "") | IN("clean", "deferred") | not)
          then "threads_unknown" else empty end
        ] | unique);
      . as $state
      | [
        $snapshot[0][]
        | normalized as $current
        | ($state.repositories[$repo].prs[$current.url] // null) as $prior
        | reasons($current; $prior) as $reasons
        | ($current.human_review_required
          or ($prior != null and ($prior.review.status == "deferred" or $prior.threads.status == "deferred"))) as $deferred
        | $current + {
            classification: (
              if ($reasons | length) > 0 then "active"
              elif $deferred then "deferred"
              else "quiet"
              end
            ),
            reasons: $reasons,
            review: ($prior.review // {sha: null, status: "unknown"}),
            dogfood: ($prior.dogfood // {sha: null, status: "unknown"}),
            threads: ($prior.threads // {sha: null, status: "unknown", deferred_thread_ids: []}),
            deferred_thread_ids: ($prior.threads.deferred_thread_ids // [])
          }
      ] as $prs
      | {
          schema_version: 1,
          repository: $repo,
          prs: $prs,
          active_count: ([$prs[] | select(.classification == "active")] | length),
          deferred_count: ([$prs[] | select(.classification == "deferred")] | length),
          quiet_count: ([$prs[] | select(.classification == "quiet")] | length)
        }
    ' "$state_input"
    ;;
  acknowledge)
    [ -n "$pr" ] && [ -n "$review_status" ] && [ -n "$dogfood_status" ] && [ -n "$threads_status" ] || usage
    printf '%s' "$review_status" | grep -Eq '^(pass|skipped|deferred)$' || usage
    printf '%s' "$dogfood_status" | grep -Eq '^(pass|skipped|blocked)$' || usage
    printf '%s' "$threads_status" | grep -Eq '^(clean|deferred)$' || usage
    if [ "$threads_status" = "clean" ] && [ "$deferred_threads" != '[]' ]; then
      echo "clean threads cannot carry deferred thread IDs" >&2
      exit 2
    fi
    if [ "$threads_status" = "deferred" ] && [ "$deferred_threads" = '[]' ]; then
      echo "deferred threads require at least one --deferred-thread" >&2
      exit 2
    fi

    acknowledged_at=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    entry=$(jq -c --arg pr "$pr" --arg review "$review_status" --arg dogfood "$dogfood_status" \
      --arg threads "$threads_status" --argjson deferred "$deferred_threads" --arg at "$acknowledged_at" '
        def ci_state:
          (.statusCheckRollup // []) as $checks
          | if ($checks | length) == 0 then "none"
            elif any($checks[];
              ((.conclusion // "") | IN("FAILURE", "CANCELLED", "TIMED_OUT", "ACTION_REQUIRED", "STALE"))) then "failure"
            elif any($checks[];
              (.status // "") != "COMPLETED" or ((.conclusion // "") == "")) then "pending"
            else "success"
            end;
        map(select((.number | tostring) == $pr or .url == $pr))[0]
        | if . == null then error("PR not found in snapshot") else . end
        | {
            number,
            url,
            title,
            head_branch: .headRefName,
            head_sha: .headRefOid,
            updated_at: .updatedAt,
            is_draft: (.isDraft // false),
            mergeable: (.mergeable // "UNKNOWN"),
            merge_state_status: (.mergeStateStatus // "UNKNOWN"),
            review_decision: (.reviewDecision // ""),
            ci_state: ci_state,
            review: {sha: .headRefOid, status: $review},
            dogfood: {sha: .headRefOid, status: $dogfood},
            threads: {sha: .headRefOid, status: $threads, deferred_thread_ids: $deferred},
            acknowledged_at: $at
          }
      ' "$snapshot") || { echo "PR not found in snapshot: $pr" >&2; exit 2; }

    state_tmp=$(mktemp "$state_dir/.state.XXXXXX")
    umask 077
    jq --arg repo "$repo" --arg url "$(printf '%s' "$entry" | jq -r .url)" --argjson entry "$entry" '
        .repositories[$repo] = (.repositories[$repo] // {prs: {}})
        | .repositories[$repo].prs = (
            (.repositories[$repo].prs // {})
            | .[$url] = $entry
          )
      ' "$state_input" > "$state_tmp"
    chmod 600 "$state_tmp"
    mv "$state_tmp" "$state_file"
    state_tmp=""
    printf '%s\n' "$entry"
    ;;
  *) usage ;;
esac
