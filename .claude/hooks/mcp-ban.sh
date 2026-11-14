#!/bin/bash
set -euo pipefail
_lib="$(dirname "$0")/_hook-lib.sh"; if [ -f "$_lib" ]; then source "$_lib"; else exit 0; fi

# PreToolUse: deny-list ONLY the token-expensive MCP servers that have a
# cheap CLI equivalent (Atlassian->acli, Gmail/Calendar/Drive->gog,
# browser->agent-browser, Blacksmith->gh, Buildkite->bk, Box->box,
# M365->m365, LaunchDarkly->ldcli). Every other MCP server is ALLOWED (default case exits 0)
# -- including the Builder.io Plan server used by /visual-plan and the local
# TraceDecay graph used for code exploration. The opt-in react-devtools server
# has a narrow exception for isolated local React inspection; see shared/react-devtools.md.
#
# Data: mcp__claude_ai_Atlassian__editJiraIssue averaged 23k chars/call,
# mcp__claude_ai_Gmail__gmail_search_messages 15k chars/call. CLI output
# is terse + pipeable + jq-composable. Same pattern as Playwright ban.

_hook_input=$(cat)
tool_name=$(echo "$_hook_input" | jq -r '.tool_name // empty' 2>/dev/null || true)
case "$tool_name" in
  mcp__claude_in_chrome__*) tool_name="mcp__claude-in-chrome__${tool_name#mcp__claude_in_chrome__}" ;;
  mcp__chrome_devtools__*) tool_name="mcp__chrome-devtools__${tool_name#mcp__chrome_devtools__}" ;;
esac

case "$tool_name" in
  # Dedicated, opt-in server: page lifecycle plus React inspection, not arbitrary JS.
  mcp__react[-_]devtools__list_pages|mcp__react[-_]devtools__new_page|mcp__react[-_]devtools__select_page|mcp__react[-_]devtools__close_page|mcp__react[-_]devtools__navigate_page|mcp__react[-_]devtools__take_snapshot|mcp__react[-_]devtools__take_screenshot|mcp__react[-_]devtools__click|mcp__react[-_]devtools__fill|mcp__react[-_]devtools__press_key|mcp__react[-_]devtools__wait_for|mcp__react[-_]devtools__list_console_messages|mcp__react[-_]devtools__list_3p_developer_tools)
    exit 0
    ;;
  mcp__react[-_]devtools__execute_3p_developer_tool)
    react_tool=$(echo "$_hook_input" | jq -r '.tool_input.toolName // empty' 2>/dev/null || true)
    case "$react_tool" in
      react_get_component_tree|react_find_components|react_get_component_by_uid|react_get_component_by_dom_element|react_get_parent_stack|react_get_owner_stack|react_get_owner_stack_trace|react_get_component_source|react_start_profiling|react_stop_profiling|react_get_trace_overview|react_get_commit_report)
        exit 0
        ;;
      *)
        msg='React DevTools accepts only the supported React inspection and profiling tools. Discover their schemas with list_3p_developer_tools. Other third-party tools and arbitrary scripts are outside this exception. Read shared/react-devtools.md.'
        ;;
    esac
    ;;

  # LaunchDarkly flag management always uses the official CLI, reads included.
  mcp__*[Ll]aunch[Dd]arkly*__*|mcp__codex_apps__launchdarkly_*)
    msg='LaunchDarkly MCP blocked. Use ldcli flags get --project <project-key> --flag <flag-key> --env <environment-key> --output json. For changes: ldcli flags update --help; verify scope and read back afterward. Missing CLI: brew tap launchdarkly/homebrew-tap && brew install ldcli. Auth: ldcli login. No MCP, direct HTTP, or browser fallback. Read shared/ldcli.md.'
    ;;

  # ── Atlassian / Jira ───────────────────────────────────────────
  mcp__claude_ai_Atlassian__editJiraIssue)
    msg='Jira MCP banned. Use: acli jira workitem edit --key KEY-123 --summary ... --description .... 23x smaller output. Install: brew install atlassian/cli/acli. Auth: acli jira auth login.'
    ;;
  mcp__claude_ai_Atlassian__getJiraIssue)
    msg='Jira MCP banned. Use: acli jira workitem view KEY-123 --fields summary,status,assignee. Key is positional (no --key). Default fields include description; narrow with --fields for less output.'
    ;;
  mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql)
    msg='Jira MCP banned. Use: acli jira workitem search --jql "project = ABC" --fields key,summary,status --json --limit 25. Add --csv for terser output.'
    ;;
  mcp__claude_ai_Atlassian__addCommentToJiraIssue)
    msg='Jira MCP banned. Use: acli jira workitem comment create --key KEY-123 --body "text". Subcommand is "comment create" (space).'
    ;;
  mcp__claude_ai_Atlassian__transitionJiraIssue)
    msg='Jira MCP banned. Use: acli jira workitem transition --key KEY-123 --status "Done" --yes.'
    ;;
  mcp__claude_ai_Atlassian__getTransitionsForJiraIssue)
    msg='Jira MCP banned. Use: acli jira workitem view KEY-123 --fields status --json to see current status; transitions list via acli jira workitem transition --help.'
    ;;
  mcp__claude_ai_Atlassian__createJiraIssue)
    msg='Jira MCP banned. Use: acli jira workitem create --project ABC --type Task --summary "..." --description "...".'
    ;;
  mcp__claude_ai_Atlassian__getJiraProjectIssueTypesMetadata|mcp__claude_ai_Atlassian__getJiraIssueTypeMetaWithFields)
    msg='Jira MCP banned. Use: acli jira project view KEY or acli jira field list for metadata.'
    ;;
  mcp__claude_ai_Atlassian__lookupJiraAccountId|mcp__claude_ai_Atlassian__getAccessibleAtlassianResources)
    msg='Jira MCP banned. Use: acli jira auth status or acli jira organization list.'
    ;;
  mcp__claude_ai_Atlassian__*)
    msg='Atlassian MCP banned. Use acli (brew install atlassian/cli/acli). Docs: https://developer.atlassian.com/cloud/acli/reference/commands/'
    ;;

  # ── Gmail / Google Workspace ──────────────────────────────────
  mcp__claude_ai_Gmail__gmail_search_messages)
    msg='Gmail MCP banned. Use: gog gmail search <query> --max 5 --readonly --gmail-no-send --no-input --json. Searches threads and keeps output parseable for agents.'
    ;;
  mcp__claude_ai_Gmail__gmail_read_message)
    msg='Gmail MCP banned. Use: gog gmail get <messageId> --readonly --gmail-no-send --no-input --json --format metadata --headers From --headers Subject --headers Date. For body text use --format full --wrap-untrusted.'
    ;;
  mcp__claude_ai_Gmail__gmail_list_labels|mcp__claude_ai_Gmail__list_labels)
    msg='Gmail MCP banned. Use: gog gmail labels list --readonly --gmail-no-send --no-input --json.'
    ;;
  mcp__claude_ai_Gmail__gmail_get_profile)
    msg='Gmail MCP banned. Use: gog me --readonly --no-input --json.'
    ;;
  mcp__claude_ai_Gmail__create_draft|mcp__claude_ai_Gmail__create_label|mcp__claude_ai_Gmail__list_drafts|mcp__claude_ai_Gmail__get_thread|mcp__claude_ai_Gmail__search_threads|mcp__claude_ai_Gmail__label_message|mcp__claude_ai_Gmail__label_thread|mcp__claude_ai_Gmail__unlabel_message|mcp__claude_ai_Gmail__unlabel_thread)
    msg='Gmail MCP banned. Use gog gmail commands. Discover commands with: gog gmail --help or gog schema --json.'
    ;;
  mcp__claude_ai_Gmail__*)
    msg='Gmail MCP banned. Use gog. Install: brew install gogcli. Auth: gog auth setup.'
    ;;

  # ── Browser automation (Playwright / Chrome DevTools / claude-in-chrome) ──
  mcp__claude-in-chrome__*|mcp__chrome-devtools__*|mcp__playwright__*|mcp__react[-_]devtools__*)
    msg='Legacy browser MCP blocked. Default to agent-browser in a task-owned session: open <url>, then snapshot -i and act on current refs. For repeated safe reads, check flow --help support and inspect flow list --json before browser navigation. Missing setup is a visible blocker, not a silent tool switch. Preserve host-required browser tools, the scoped React DevTools exception and Playwright Test suites. Read shared/verification-replay.md#browser-and-data-tasks; record any permitted fallback tool and reason.'
    ;;

  # ── Blacksmith (CI) = GitHub Actions replacement → use gh CLI ──
  mcp__blacksmith__list_runs)
    msg='Blacksmith MCP banned. Blacksmith runs ARE GitHub Actions. Use: gh run list --limit 20 --json databaseId,status,conclusion,workflowName,displayTitle. Avg MCP 16k chars vs gh ~1k chars.'
    ;;
  mcp__blacksmith__list_jobs)
    msg='Blacksmith MCP banned. Use: gh run view <run-id> --json jobs or gh api /repos/{owner}/{repo}/actions/runs/<id>/jobs.'
    ;;
  mcp__blacksmith__get_cache_entries)
    msg='Blacksmith MCP banned. Use: gh cache list --limit 20 --json id,key,sizeInBytes,createdAt.'
    ;;
  mcp__blacksmith__get_job_logs)
    msg='Blacksmith MCP banned. Use: gh run view <run-id> --log --job <job-id> | tail -c 4000. Strip ANSI with sed "s/\\x1b\\[[0-9;]*m//g".'
    ;;
  mcp__blacksmith__*)
    msg='Blacksmith MCP banned. Use gh CLI (GitHub Actions API covers it). gh run/cache/api.'
    ;;

  # ── Google Calendar (via gog) ──
  mcp__claude_ai_Google_Calendar__list_events)
    msg='Calendar MCP banned. Use: gog calendar events primary --readonly --no-input --json --from <ISO> --max 10.'
    ;;
  mcp__claude_ai_Google_Calendar__create_event)
    msg='Calendar MCP banned. Use: gog calendar create primary --no-input --json --summary <title> --from <start> --to <end>.'
    ;;
  mcp__claude_ai_Google_Calendar__get_event|mcp__claude_ai_Google_Calendar__update_event|mcp__claude_ai_Google_Calendar__delete_event|mcp__claude_ai_Google_Calendar__respond_to_event)
    msg='Calendar MCP banned. Use: gog calendar event primary <eventId>, gog calendar update primary <eventId>, or gog calendar delete primary <eventId>.'
    ;;
  mcp__claude_ai_Google_Calendar__list_calendars|mcp__claude_ai_Google_Calendar__suggest_time)
    msg='Calendar MCP banned. Use: gog calendar calendars --readonly --json or gog calendar freebusy primary --readonly --json --from <ISO> --to <ISO>.'
    ;;
  mcp__claude_ai_Google_Calendar__*)
    msg='Calendar MCP banned. Use gog calendar. Discover commands with: gog calendar --help or gog schema --json.'
    ;;

  # ── Google Drive (via gog) ──
  mcp__claude_ai_Google_Drive__*)
    msg='Drive MCP banned. Use: gog drive search <query> --max 10 --readonly --no-input --json. Get metadata: gog drive get <fileId> --readonly --json. Get content: gog drive download <fileId> --out - --readonly.'
    ;;

  # ── Buildkite → bk CLI ──
  mcp__claude_ai_Buildkite_read-only__*|mcp__buildkite__*)
    msg='Buildkite MCP banned. Use: bk build list --pipeline <name> --limit 10 --json. Install: brew install buildkite/buildkite/cli. Auth: bk configure.'
    ;;

  # ── Box → box CLI ──
  mcp__claude_ai_Box__*|mcp__box__*)
    msg='Box MCP banned. Use: box files:get <FILE_ID> --json / box folders:items 0 --json. Install: brew install boxcli.'
    ;;

  # ── Microsoft 365 → m365 CLI ──
  mcp__claude_ai_Microsoft_365__*|mcp__microsoft365__*|mcp__m365__*)
    msg='M365 MCP banned. Use installed m365 teams/outlook/sharepoint with -o json. If unavailable, prefix the same subcommands with bunx @pnp/cli-microsoft365; authenticate with bunx @pnp/cli-microsoft365 login.'
    ;;

  *)
    exit 0
    ;;
esac

_hook_track_violation "mcp-ban" 2>/dev/null || true
_hook_log_entry "deny" "mcp-ban" 2>/dev/null || true

# Build JSON safely via jq so embedded quotes/specials are escaped correctly.
printf '%s' "$msg" | jq -Rs '{hookSpecificOutput:{permissionDecision:"deny"},systemMessage:.}' >&2
exit 2
