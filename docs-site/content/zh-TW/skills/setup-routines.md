---
title: /setup-routines
description: 設定 Claude Code 常規任務，用於 PR 審查、程式碼庫健康狀況、議題分類及文件偏移檢查。
type: skill
sidebar:
  label: /setup-routines
---
![「/setup-routines」技能示意圖](/diagrams/skills/setup-routines.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/setup-routines.excalidraw)

設定 [Claude Code 常規任務](https://claude.ai/code/routines)——由排程、GitHub 事件或 API 觸發的雲端託管自動工作階段。常規任務會複製儲存庫，並以完整的 Claude Code 工作階段執行。鉤子與 CLAUDE.md 規則會自動強制執行規範。

## 運作方式

```
Routine fires -> clones repo -> SessionStart hooks -> CLAUDE.md loads
-> routine prompt executes -> PostToolUse hooks enforce on every edit
-> Stop hooks run quality gates -> session ends
```

### 強制執行模型

鉤子 = 強制執行層｜常規任務提示詞 = 任務層。規範會在
儲存庫中演進（鉤子與 CLAUDE.md），而常規任務提示詞則維持穩定。每個常規任務
工作階段都會執行與互動式開發工作階段相同的 PostToolUse/Stop 閘門，
因此常規任務無法發布開發人員無法在本機發布的程式碼。
針對常規任務輸出，請新增 `/agent-watchdog` 稽核步驟。只有在
常規任務要求明確包含該產出項目時，才新增 `/visual-recap`。


常規任務是由排程／Webhook／API 觸發的雲端託管工作階段——
即使筆記型電腦闔上，也必須持續運作的週期性自動化。

## 可用範本

| 範本 | 觸發條件 | 功能 |
|---|---|---|
| [pr-review](https://github.com/malinskibeniamin/skills/blob/main/setup-routines/routines/pr-review.md) | `pull_request.opened` | 根據規範審查 PR，並發布行內留言 |
| [pr-feedback-resolve](https://github.com/malinskibeniamin/skills/blob/main/setup-routines/routines/pr-feedback-resolve.md) | `pull_request.review_submitted` | 讀取尚未解決的討論串、修正程式碼、回覆並標記為已解決 |
| [issue-triage](https://github.com/malinskibeniamin/skills/blob/main/setup-routines/routines/issue-triage.md) | `issues.opened` | 探索程式碼庫、分類、加上標籤，並發布調查結果 |
| [weekly-health](https://github.com/malinskibeniamin/skills/blob/main/setup-routines/routines/weekly-health.md) | 排程：每週 | 執行品質檢查、衡量偏移情形，並建立健康狀況報告議題 |
| [docs-drift](https://github.com/malinskibeniamin/skills/blob/main/setup-routines/routines/docs-drift.md) | 排程：每週 | 從近期變更中偵測過時文件，並建立修正 PR 或議題 |

## 設定

### 1. 必要條件

- 可存取網路的 Claude Code（[claude.ai/code](https://claude.ai/code)）
- 已連接 GitHub（在 CLI 中執行 `/web-setup`）
- Pro、Max、Team 或 Enterprise 方案

### 2. 選擇常規任務

| 若你已有 | 建議的常規任務 |
|---|---|
| 已安裝任何鉤子 | pr-review |
| resolve-pr-feedback 技能 | pr-feedback-resolve |
| triage 技能 | issue-triage |
| 品質閘門鉤子／指令碼 | weekly-health |
| REFERENCE.md 或其他文件 | docs-drift |

### 3. 透過網頁建立（建議）

1. [claude.ai/code/routines](https://claude.ai/code/routines) -> **新增常規任務**
2. 輸入名稱（例如「PR 審查 -- [儲存庫名稱]」）
3. 貼上 `routines/*.md` 中的範本——自訂 `OWNER`/`REPO` 預留位置
4. 選擇儲存庫與環境
5. 新增觸發條件（GitHub 事件｜排程｜API）
6. 檢查連接器——移除不需要的項目
7. 建立

### 4. 透過 CLI 建立

```bash
/schedule daily codebase health check at 9am
```

CLI 僅支援排程常規任務。若要使用 GitHub/API 觸發條件，請使用網頁介面。

### 5. 自訂提示詞

範本是起點。可自訂：

- **專案特定檢查**：參照鉤子所強制執行的模式
- **標籤**：符合議題標籤分類法
- **範圍界線**：「僅審查 `src/`」或「略過產生的檔案」
- **連接器動作**：「將摘要發布至 #engineering Slack」

自訂範例與 API 觸發設定請參閱 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/setup-routines/REFERENCE.md)。

### 6. 測試

在信任觸發條件之前，先手動執行一次：

1. 網頁：在常規任務詳細資料頁面按一下 **立即執行**
2. CLI：`/schedule run`
3. 透過回傳的 URL 即時查看工作階段
4. 檢查輸出——若執行偏離目標，請調整提示詞
請參閱 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/setup-routines/REFERENCE.md)：強制執行模型、觸發條件／API／自訂設定及疑難排解。
