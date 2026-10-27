# Subscription-only coding usage

Source review: 2026-10-26. Scope: personal ChatGPT/Codex and Claude subscriptions.

Use provider-side credit controls before distributing work across accounts. Account
rotation does not prevent paid usage. This guide documents setup and acceptance
checks, not a billing guarantee or a feature implemented by this harness.

**Recommended:** use T3 Code's native account connections with paid credits disabled.
Treat CLIProxyAPI as optional routing, not a spending cap. If the provider cannot
reject credit use for the selected authentication path, do not enable unattended
subscription-only routing. No live account-limit or billing-transition test was
performed for this guide.

## Separate account selection from billing protection

T3 Code's [Codex guide](https://github.com/pingdotgg/t3code/blob/main/docs/user/providers-codex.md)
documents adding accounts in **Settings > Providers** and selecting them through
the model picker. Compatible Codex accounts can continue a thread. Shared Codex
homes with separate shadow homes support separate CLI logins without copying the
whole home directory.

The [Claude guide](https://github.com/pingdotgg/t3code/blob/main/docs/user/providers-claude.md)
uses separate `CLAUDE_CONFIG_DIR` directories for accounts. Existing threads can
switch only between instances with the same configuration directory. Do not assume
Codex-style conversation continuity across isolated Claude accounts.

The checked guides do not establish an automatic quota-aware account balancer.
[Account-selection proposals](https://github.com/pingdotgg/t3code/discussions/6923)
are not evidence that the feature ships in your installed build. T3's
[Connections load balancing](https://github.com/pingdotgg/t3code/blob/main/docs/user/remote-access.md#balance-new-threads-across-machines)
selects machines using resource availability, not remaining subscription allowance.

The subscription-only requirement has two separate controls:

```text
Provider rejects paid credits ── constrains ──▶ Account routing
                                                │
                            allowance available ├──▶ Run on eligible account
                            none or unverified  └──▶ Stop; no paid fallback
```

The diagram defines the desired policy. It does not describe a shipped controller.

## Configure ChatGPT plan sharing in T3 Code

For each account:

1. In T3 Code, select the target environment and open **Settings > Providers**.
2. Connect with ChatGPT and confirm the intended account during sign-in.
3. Open **Manage usage** for that connection, or ChatGPT's **Settings > Usage**.
4. Turn off **Allow other apps to use credits after reaching your usage limit**.
5. Save and re-read the preference. If the control is unavailable, verify eligibility
   and the actual connection type before relying on it.
6. Optionally set T3's weekly app limit below 100% for another credit-use restriction.

These controls apply to participating apps using ChatGPT plan sharing. OpenAI lists
[T3 as an open-source integration](https://learn.chatgpt.com/docs/sign-in-with-chatgpt).
A lower app limit caps shared allowance; it does not reserve or add capacity.
An app limit below 100% prevents app credit use, even if app credit use is otherwise
enabled. See [OpenAI's connection and credit controls](https://help.openai.com/en/articles/20001542-using-your-chatgpt-plan-in-other-apps-and-sites).

Turn off automatic credit purchases separately. That prevents automatic top-ups,
not consumption of an existing credit balance. Concurrent work can also make a
positive credit balance negative. Do not treat the balance as a hard spending cap.
See [OpenAI's credit behavior](https://help.openai.com/en/articles/12642688-using-credits-for-flexible-usage-in-chatgpt-personal-plans).

**Do not assume app-sharing controls protect an existing Codex CLI login or a proxy's
OAuth credentials.** Verify the authentication path independently. Do not add an
upstream paid API key as a fallback for this workflow.

## Configure Claude without paid usage credits

Disable usage credits in **Claude > Settings > Usage** on every account. Re-read
the saved setting. Anthropic states that disabling them restricts access to the
plan's included usage. See [Claude's usage-credit controls](https://support.claude.com/en/articles/12429409-manage-usage-credits-for-paid-claude-plans).

This does not make third-party subscription pooling supported. Anthropic reserves
the right to charge certain third-party tools against usage credits instead of
subscription allowance. It prohibits disguising third-party traffic to force it
onto subscription limits. Do not use CLIProxyAPI to bypass that restriction.
See [Anthropic's authentication policy](https://support.claude.com/en/articles/13189465-log-in-to-your-claude-account).

Use a supported native authentication path. If it cannot run with credits disabled,
stop rather than enabling credits to make the connection work. Avoid paid API-key
fallbacks in the subscription-only provider instance.

## Optional Codex routing through CLIProxyAPI

Use this only after confirming that your provider permits the integration and
enforces no-credit use for its authentication path. The example does not establish
either condition. The ChatGPT app-sharing switch above is not proof for proxy OAuth.

Keep the proxy local, use a dedicated configuration, and protect its credential
directory. Do not copy token files into this repository or print them in logs.
The following **v8 configuration example** is based on CLIProxyAPI's
[configuration reference](https://help.router-for.me/configuration/options):

```yaml
config-version: 8
server:
  host: "127.0.0.1"
  port: 8317
access:
  api-keys:
    - "replace-with-a-random-local-client-key"
oauth:
  auth-dir: "~/.cli-proxy-api-subscriptions"
routing:
  strategy: round-robin
  session-affinity: true
  retry:
    request-retry: 0
    max-retry-credentials: 0
    max-retry-interval: 0
  cooldown:
    disable-cooling: false
    save-cooldown-status: true
```

Replace the client-key placeholder before starting the proxy. It authenticates
local clients; it is not an upstream billable API key. Audit existing credentials
separately: this example does not remove credentials already stored in `auth-dir`.
Keep only the intended subscription accounts in the routing pool.

For an installed binary in the current directory, authenticate each eligible Codex
account using the [documented OAuth command](https://help.router-for.me/configuration/provider/codex):

```sh
./cli-proxy-api --config /absolute/path/to/config.yaml --codex-login
```

Repeat for each intended account and verify the reported account identity. Start
the proxy in an owned foreground terminal with the same configuration:

```sh
./cli-proxy-api --config /absolute/path/to/config.yaml
```

Use a dedicated `CODEX_HOME` and T3 provider instance for the proxy. Follow the
[upstream Codex client guide](https://help.router-for.me/agent-client/codex) for the
installed version, with the Responses endpoint at `http://127.0.0.1:8317/v1`.
Do not overwrite the normal CLI account's configuration or credentials.

Round-robin spreads eligible new sessions, not equal token consumption. Session
affinity keeps a conversation on its selected credential while allowing failover.
Zero additional retry rounds still allows same-round credential failover. Persisted
cooldowns retain unavailable-account state across proxy restarts.

These are routing controls. They do not reject an otherwise successful upstream
request that consumes paid credits. A successful HTTP response is not proof of
included-allowance billing. Legacy `quota-exceeded.switch-project` and
`switch-preview-model` settings have no v8 counterpart; do not present them as
spending controls. Check the [current routing reference](https://help.router-for.me/configuration/options).

## Verify before unattended use

Do not enable paid credits to test their rejection. Start with saved-setting
readback and non-billable routing fixtures. Observe a real allowance boundary only
with paid usage disabled. Keep the live billing boundary marked unverified until
the provider's behavior is observed.

| Scenario | Required evidence for subscription-only operation |
| --- | --- |
| Account or environment changes | Confirm the selected identity, connection type, and saved no-credit controls. |
| One account reaches an applicable limit | Use another eligible account with the intended model, or surface the limit and stop. |
| Every eligible account is limited | Reject new work without a paid API, credit, model, or cross-provider fallback. |
| Quota or billing eligibility is missing or stale | Stop new dispatch rather than assuming capacity. Stock routing is not evidence of this policy. |
| Concurrent work reaches a boundary | Provider-side no-credit enforcement still applies; a polling percentage is not a reservation. |
| Paid usage is unexpectedly reported | Stop affected work and disable that route. Cancellation cannot undo charges already incurred. |

Record only non-secret evidence: application versions, masked account labels,
setting states, model, reset time, and observed rejection. Never include bearer
tokens, credential files, or full request logs. Repeat the checks after changes to
authentication, provider policy, routing plugins, or fallback configuration.

## Roll back routing without weakening billing controls

Stop only the proxy process you started. Disable its dedicated T3 provider instance
or restore that instance's previous endpoint. Leave provider-side credit blocking
in place. Do not delete shared account directories or re-enable paid usage as a
recovery step. This guide installs no proxy, changes no account settings, and adds
no automatic account balancer to the harness.
