---
name: redpanda-ai-gateway
description: Run AI CLIs (claude, codex) through the Redpanda AI Gateway via rpk ai -- auth, environments, providers, gateway-backed sessions. Use on "rpk ai", "AI gateway", "run claude through the gateway", or gateway provider/auth asks.
disable-model-invocation: true
---

# Redpanda AI Gateway (`rpk ai`)

Isolated wrapper for the Agentic Data Plane CLI: talk to LLM providers through the Redpanda AI Gateway instead of provider-direct APIs. The desktop apps (Claude/Codex/ChatGPT) keep working as-is -- this skill only covers explicit gateway invocations. Docs: https://docs.redpanda.com/agentic-data-plane/cli/

## Setup (once per machine)

```bash
rpk ai install                 # install the ai plugin into rpk
rpk cloud login --no-profile   # Redpanda Cloud auth (prerequisite)
rpk ai auth login              # OAuth device flow; credentials cached at ~/.rpai/credentials
rpk ai env list                # environments available to you
rpk ai env use <environment>   # pick one (independent of rpk cloud sessions)
rpk ai llm list                # verify: providers visible = auth works
```

Local gateway (no cloud): `rpk ai env add local --ai-gateway-url http://localhost:8090 --auth-mode none`

## Run an AI CLI through the gateway

Everything after `--` passes through to the underlying tool untouched:

```bash
rpk ai run claude --llmprovider claude-code-enterprise-local -- --dangerously-skip-permissions
rpk ai run codex  --llmprovider <provider-name> -- exec -s read-only "<prompt>"
```

Pick `--llmprovider` from `rpk ai llm list` (`-o json|yaml|wide` for detail; `RPAI_FORMAT` sets a default). Cluster override when needed: `rpk ai --rpai-endpoint https://aigw.<cluster-id>.clusters.cloud.redpanda.com ...`

## Provider and resource management

`rpk ai llm|mcp|oauth-provider|oauth-client|agent` each support `create|get|list|update|delete`; `rpk ai model` is read-only catalog.

```bash
rpk ai llm create --name openai --type openai --api-key-ref OPENAI_API_KEY
```

Keys are always secret *references* -- the CLI never takes a raw API key. Never paste one.

## Failure triage

- `rpk ai` unknown command -> `rpk ai install`, then retry.
- 401/expired -> `rpk ai auth login` again (gateway credentials are separate from `rpk cloud`).
- Provider missing from `rpk ai llm list` -> wrong environment (`rpk ai env use`) or provider not created in this environment.
- This skill does not change model-routing doctrine: a gateway-run claude/codex still counts as its underlying model for cross-model review purposes.
