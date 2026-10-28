---
description: 啟動前端工具鏈、程式碼檢查、品質關卡、React 技術棧、資料技術棧與 CI。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - frontend starter kit
sidebar:
  label: /frontend-starter-kit
title: /frontend-starter-kit
type: skill
---
![「/frontend-starter-kit」技能示意圖](/diagrams/skills/frontend-starter-kit.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/frontend-starter-kit.excalidraw)


以冪等方式執行啟動建置。僅讀取所要求的 `references/<tool>/README.md` 與其中連結的指南。在外掛中，複製 hook 不會執行任何操作；純儲存庫則需要複製匯出工具套件。

## 設定檔 [#profiles]

- **完整**（預設）：採用 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.41.0/frontend-starter-kit/REFERENCE.md) 中的標準技術棧，依下列順序執行。
- **最小：**工具鏈、Biome、品質關卡、環境變數驗證、慣例式提交。
- **Redpanda：**完整設定 + `references/redpanda/README.md`、分類法、`REDPANDA_KIT=1`。
- **`<tool>`：**僅使用該工具的參考文件。

## 完整設定順序 [#full-order]

| 工具 | 用途 |
|---|---|
| `toolchain` | `references/toolchain/`：bun、TS 7 `tsc`/tsrs、破壞性指令防護 |
| `tanstack-intent` | 與版本相符的指引／編輯關卡 |
| `biome` | Biome、Ultracite、自動修正 hook |
| `quality-gate` | 指令碼、CI、Stop hook、套件大小防護 |
| `agent-config` | `AI_AGENT=1`、輸出截斷 |
| `react-compiler` | Compiler、記憶化檢查 |
| `zustand` | `create<T>()()`、`useShallow`、persist |
| `react-rules` | 禁止原始 HTML、TS 規避手段、XSS、桶狀匯入 |
| `env-validation` | t3-env/zod、`noProcessEnv` |
| `conventional-commits` | `type(scope): description` |
| `react-doctor` | 變更診斷關卡、Stop hook |
| `ci-pipeline` | Actions、覆蓋率、快取 |
| `redpanda` | 登錄檔工作流程／分類法 |

執行階段指引技能，非設定用途：`/accessibility`、`/tanstack-router`、`/connect-query`、`/e2e-testing`、`/registry-workflow`、`/ux-copy`。選用基礎設施（僅限斜線指令）：`/setup-routines`、`/setup-atlassian-workflow`。

## 步驟 [#steps]

1. 確認設定檔；若為完整設定，依序處理表格，並僅在需要時讀取參考文件。
2. 僅在選擇嚴格 effect 規則的儲存庫中設定 `REACT_RULES_BAN_USEEFFECT=1`。
3. 在每個使用端儲存庫中[自動設定審查保障](https://github.com/malinskibeniamin/skills/blob/v4.41.0/shared/review-enforcement.md)；遵守獲授權的終點範圍。
4. 工作流程技能已隨此外掛提供；無須額外安裝任何項目。

## 驗證 [#verify]

- `.claude/settings.json` 包含 hook，且安裝 TanStack 套件時也包含 TanStack Intent；`biome.jsonc` 與 `src/env.ts` 均存在。
- 指令碼：lint、lint:fix、type:check、test、quality:gate。
- `.github/workflows/quality-gate.yml` 存在；所有 hook 均可執行。
