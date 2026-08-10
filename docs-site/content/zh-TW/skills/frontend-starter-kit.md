---
title: /frontend-starter-kit
description: 啟動前端工具鏈、程式碼檢查、品質關卡、React 技術棧、資料技術棧與 CI。
type: skill
sidebar:
  label: /frontend-starter-kit
---
![「/frontend-starter-kit」技能示意圖](/diagrams/skills/frontend-starter-kit.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/frontend-starter-kit.excalidraw)

所有啟動建置工作皆由一項技能負責。各工具的安裝步驟位於
`references/<tool>/README.md`（若有，另包含 `SETUP.md`/`REFERENCE.md`）——僅在所要求的設定檔需要時
才讀取。所有步驟皆具冪等性。

外掛使用者已隨附並接好所有 hook——對他們而言，複製 hook 的步驟
不會執行任何操作；只需執行設定與工具配置步驟。對於未安裝此外掛的純儲存庫
（「匯出工具套件」），完整複製則很重要。

## 設定檔

- **完整**（預設）：依下列順序安裝所有工具，並以
  [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/frontend-starter-kit/REFERENCE.md) 中的標準技術棧為目標（React 19 + Rsbuild + Tailwind + TanStack Router/Query +
  Connect Query + shadcn/Base UI + Vitest/Playwright + Biome/Ultracite + TypeScript 7 `tsc`）。
- **最小**：工具鏈、Biome、品質關卡、環境變數驗證、慣例式提交。
- **Redpanda**：完整設定 + `references/redpanda/README.md`（登錄檔工作流程、Redpanda 元件
  分類法、`REDPANDA_KIT=1`）。
- **`<tool>`**：僅使用該工具的參考文件。

## 工具（完整設定依序執行）

| 工具 | 參考文件 | 設定內容 |
|---|---|---|
| 工具鏈 | `references/toolchain/` | 強制使用 bun + TypeScript 7 `tsc`，以及破壞性指令防護 |
| TanStack Intent | `references/tanstack-intent/` | 與版本相符的 TanStack 套件指引 + 官方編輯關卡 |
| Biome | `references/biome/` | Biome + Ultracite、自動修正 hook |
| 品質關卡 | `references/quality-gate/` | quality:gate 指令碼、CI 工作流程、Stop hook、套件大小防護 |
| 代理程式設定 | `references/agent-config/` | AI_AGENT=1、輸出截斷 |
| React Compiler | `references/react-compiler/` | React Compiler + 記憶化檢查 |
| Zustand | `references/zustand/` | 雙括號 create、useShallow、persist |
| React 規則 | `references/react-rules/` | 禁止原始 HTML、TS 規避手段、XSS、桶狀匯入 |
| 環境變數驗證 | `references/env-validation/` | t3-env + zod；透過 Biome noProcessEnv 禁止 process.env |
| 慣例式提交 | `references/conventional-commits/` | 強制執行 type(scope): description 格式 |
| React Doctor | `references/react-doctor/` | 變更診斷關卡 + Stop hook |
| CI 管線 | `references/ci-pipeline/` | GitHub Actions CI、覆蓋率關卡、快取 |
| Redpanda | `references/redpanda/` | Redpanda 登錄檔工作流程 + 元件分類法 |

執行階段指引技能（日常工作，非設定用途）：`/accessibility`、`/tanstack-router`、
`/connect-query`、`/e2e-testing`、`/registry-workflow`、`/ux-copy`。選用基礎設施：
`/setup-routines`、`/setup-atlassian-workflow`（僅限斜線指令）。

## 步驟

1. 確認設定檔（預設為完整）。執行到各工具時，再視需要讀取其參考文件。
2. 當儲存庫需要嚴格的 effect 規則時，在 session-env.sh 中設定 `REACT_RULES_BAN_USEEFFECT=1`。
3. 工作流程技能（development-lifecycle、tdd、grilling、triage、
   diagnosing-bugs、prototype、domain-modeling）已隨此外掛提供——無須安裝任何項目。

## 驗證

- [ ] `.claude/settings.json` 包含所有 hook；安裝 TanStack 套件時也包含 TanStack Intent；`biome.jsonc` + `src/env.ts` 均存在
- [ ] 指令碼：lint、lint:fix、type:check、test、quality:gate
- [ ] `.github/workflows/quality-gate.yml` 存在，且所有 hook 均可執行
