---
title: /redpanda-ai-gateway
description: 透過 Redpanda AI Gateway 使用 rpk ai 執行 Claude 與 Codex。
type: skill
sidebar:
  label: /redpanda-ai-gateway
---
![/redpanda-ai-gateway 技能示意圖](/diagrams/skills/redpanda-ai-gateway.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/redpanda-ai-gateway.excalidraw)

Agentic Data Plane CLI 的隔離包裝器：透過 Redpanda AI Gateway 與 LLM 供應商通訊，而非直接使用供應商 API。桌面應用程式（Claude/Codex/ChatGPT）會維持原有運作方式——此技能僅涵蓋明確透過閘道執行的呼叫。文件：https://docs.redpanda.com/agentic-data-plane/cli/

## 設定（每台機器僅需一次）

```bash
rpk ai install                 # install the ai plugin into rpk
rpk cloud login --no-profile   # Redpanda Cloud auth (prerequisite)
rpk ai auth login              # OAuth device flow; credentials cached at ~/.rpai/credentials
rpk ai env list                # environments available to you
rpk ai env use <environment>   # pick one (independent of rpk cloud sessions)
rpk ai llm list                # verify: providers visible = auth works
```

本機閘道（不使用雲端）：`rpk ai env add local --ai-gateway-url http://localhost:8090 --auth-mode none`

## 透過閘道執行 AI CLI

`--` 之後的所有內容都會原封不動地傳遞給底層工具：

```bash
rpk ai run claude --llmprovider claude-code-enterprise-local
rpk ai run claude --llmprovider claude-code-enterprise-local -- --dangerously-skip-permissions   # ONLY in sandboxed/throwaway envs: this disables Claude Code approval prompts
rpk ai run codex  --llmprovider <provider-name> -- exec -s read-only "<prompt>"
```

從 `rpk ai llm list` 選擇 `--llmprovider`（使用 `-o json|yaml|wide` 查看詳細資訊；`RPAI_FORMAT` 可設定預設值）。需要時可覆寫叢集：`rpk ai --rpai-endpoint https://aigw.<cluster-id>.clusters.cloud.redpanda.com ...`

## 供應商與資源管理

`rpk ai llm|mcp|oauth-provider|oauth-client|agent` 各自支援 `create|get|list|update|delete`；`rpk ai model` 是唯讀目錄。

```bash
rpk ai llm create --name openai --type openai --api-key-ref OPENAI_API_KEY
```

金鑰一律為祕密的*參照*——CLI 絕不會接收原始 API 金鑰。切勿貼上金鑰。

## 失敗問題排查

- `rpk ai` 未知命令 -> 執行 `rpk ai install`，然後重試。
- 401／已過期 -> 再次執行 `rpk ai auth login`（閘道憑證與 `rpk cloud` 分開）。
- `rpk ai llm list` 中缺少供應商 -> 環境錯誤（`rpk ai env use`），或尚未在此環境中建立供應商。
- 此技能不會變更模型路由原則：透過閘道執行的 claude/codex，在跨模型審查時仍視為其底層模型。
