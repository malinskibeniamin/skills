---
name: redpanda-ai-gateway
description: Run Claude and Codex through the Redpanda AI Gateway with rpk ai.
disable-model-invocation: true
---

Explicit `rpk ai` wrapper for Redpanda AI Gateway; desktop Claude/Codex/ChatGPT remain unchanged. Docs: https://docs.redpanda.com/agentic-data-plane/cli/

## Setup once

```bash
rpk ai install
rpk cloud login --no-profile
rpk ai auth login
rpk ai env list
rpk ai env use <environment>
rpk ai llm list
```

Local: `rpk ai env add local --ai-gateway-url http://localhost:8090 --auth-mode none`.

## Run

Arguments after `--` pass through unchanged:

```bash
rpk ai run claude --llmprovider claude-code-enterprise-local
rpk ai run claude --llmprovider claude-code-enterprise-local -- --dangerously-skip-permissions
rpk ai run codex --llmprovider <provider> -- exec -s read-only "<prompt>"
```

Use `--dangerously-skip-permissions` only in sandboxed/throwaway environments. Choose providers from `rpk ai llm list` (`-o json|yaml|wide`; `RPAI_FORMAT` default). Cluster override: `rpk ai --rpai-endpoint https://aigw.<cluster-id>.clusters.cloud.redpanda.com ...`.

## Resources

`rpk ai llm|mcp|oauth-provider|oauth-client|agent` support create/get/list/update/delete; `model` is read-only. Create LLMs with secret references, for example `rpk ai llm create --name openai --type openai --api-key-ref OPENAI_API_KEY`. Never paste raw keys.

## Triage

- Unknown `rpk ai`: install then retry.
- 401/expired: `rpk ai auth login`; gateway auth differs from cloud auth.
- Missing provider: verify selected environment and its resources.
- Gateway runs retain the underlying model identity for cross-model policy.
