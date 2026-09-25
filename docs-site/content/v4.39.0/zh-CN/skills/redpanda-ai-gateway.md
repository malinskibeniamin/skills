---
title: /redpanda-ai-gateway
description: 通过 Redpanda AI Gateway 使用 rpk ai 运行 Claude 和 Codex。
type: skill
sidebar:
  label: /redpanda-ai-gateway
---
![/redpanda-ai-gateway 技能示意图](/diagrams/skills/redpanda-ai-gateway.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/redpanda-ai-gateway.excalidraw)

Agentic Data Plane CLI 的隔离封装器：通过 Redpanda AI Gateway 与大语言模型提供商通信，而不是直接调用提供商的 API。桌面应用（Claude/Codex/ChatGPT）仍可照常使用——此技能仅涵盖明确的网关调用。文档：https://docs.redpanda.com/agentic-data-plane/cli/

## 设置（每台机器一次）

```bash
rpk ai install                 # install the ai plugin into rpk
rpk cloud login --no-profile   # Redpanda Cloud auth (prerequisite)
rpk ai auth login              # OAuth device flow; credentials cached at ~/.rpai/credentials
rpk ai env list                # environments available to you
rpk ai env use <environment>   # pick one (independent of rpk cloud sessions)
rpk ai llm list                # verify: providers visible = auth works
```

本地网关（无需云服务）：`rpk ai env add local --ai-gateway-url http://localhost:8090 --auth-mode none`

## 通过网关运行 AI CLI

`--` 后的所有内容都会原样传递给底层工具：

```bash
rpk ai run claude --llmprovider claude-code-enterprise-local
rpk ai run claude --llmprovider claude-code-enterprise-local -- --dangerously-skip-permissions   # ONLY in sandboxed/throwaway envs: this disables Claude Code approval prompts
rpk ai run codex  --llmprovider <provider-name> -- exec -s read-only "<prompt>"
```

从 `rpk ai llm list` 中选择 `--llmprovider`（使用 `-o json|yaml|wide` 查看详细信息；`RPAI_FORMAT` 用于设置默认格式）。需要时可覆盖集群：`rpk ai --rpai-endpoint https://aigw.<cluster-id>.clusters.cloud.redpanda.com ...`

## 提供商和资源管理

`rpk ai llm|mcp|oauth-provider|oauth-client|agent` 均支持 `create|get|list|update|delete`；`rpk ai model` 是只读目录。

```bash
rpk ai llm create --name openai --type openai --api-key-ref OPENAI_API_KEY
```

密钥始终是机密信息的*引用*——CLI 从不接收原始 API 密钥。切勿粘贴原始密钥。

## 故障排查

- `rpk ai` 未知命令 -> 运行 `rpk ai install`，然后重试。
- 401/已过期 -> 再次运行 `rpk ai auth login`（网关凭据与 `rpk cloud` 的凭据相互独立）。
- `rpk ai llm list` 中缺少提供商 -> 环境有误（`rpk ai env use`），或尚未在此环境中创建该提供商。
- 此技能不会改变模型路由原则：通过网关运行的 claude/codex 在跨模型审查时，仍按其底层模型计算。
