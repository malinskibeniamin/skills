# LaunchDarkly flags via ldcli

Use the official `ldcli` for all LaunchDarkly flag management: reads, creation,
targeting, rollouts, updates, and deletion. Application SDK evaluation and
documentation research stay unchanged.

## Preflight

1. Check `command -v ldcli` and `ldcli --version`. If missing on macOS, use
   `brew tap launchdarkly/homebrew-tap && brew install ldcli`; elsewhere follow
   the [official installation guide](https://launchdarkly.com/docs/home/getting-started/ldcli).
2. Reuse configured authentication. If unavailable, request `ldcli login` or
   approved secret provisioning. Never print tokens, dump CLI config, or put
   credentials in commands, logs, tracked files, or replies. Report an unresolved
   installation/authentication blocker; do not switch to MCP, raw HTTP, or UI.
3. Resolve exact project, environment, and flag keys from the request or existing
   repo configuration. Never assume `default` or `production`.
4. Run `ldcli flags <subcommand> --help` for installed-version options. Use
   `--output json` and select necessary fields with `jq`.

## Read

```bash
ldcli flags list --project <project-key> --env <environment-key> --limit 20 --output json
ldcli flags get --project <project-key> --flag <flag-key> --env <environment-key> --output json
```

Follow list pagination when completeness matters. `--env` filters reads;
`flags update` uses the environment in its patch payload instead.

## Change

Read the current flag first. Confirm the requested change, exact scope, and
rollback; production targeting/rollout changes require explicit authorization.
Discover create/update/delete syntax with `--help`. For targeting, consult
`ldcli flags update --help` and its semantic-patch instructions; do not guess
variation indexes or patch paths. Keep unrelated environments and rules intact.

Read back the same flag and environment after each successful write. On uncertain
outcomes, read before retrying. Verify the requested postcondition; report the
project, environment, flag, observed result, and any blocker without secrets.

[Official CLI commands](https://launchdarkly.com/docs/home/getting-started/ldcli-commands)
are the upstream reference; installed `--help` owns version-specific syntax.
