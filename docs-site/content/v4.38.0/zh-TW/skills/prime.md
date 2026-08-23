---
title: /prime
description: 建立儲存庫啟動摘要。適用於開始／繼續工作、壓縮內容後、新對話或 /prime。
type: skill
sidebar:
  label: /prime
---
![／prime 技能示意圖](/diagrams/skills/prime.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/prime.excalidraw)

啟動摘要：儲存庫狀態、目標、接下來要讀取的內容。

若種子資訊來自其他代理程式／工作階段／PR 宣告，請使用 `/agent-watchdog`；若有相互競爭的交接內容／計畫，請使用 `/plan-arbiter`；若需要最新的外部／API 資訊，請使用 `/read-the-damn-docs`。

用法：`/prime` 或 `/prime <seed>`（交接檔案、GitHub 議題／PR、Jira 金鑰、分支／參照、URL、任務文字）。
範例：`/prime`、`/prime #123`、`/prime /tmp/handoff.md`。

## 流程

1. 檢查目前的儲存庫狀態與選用的種子資訊。不需要指令碼。
2. 在目前儲存庫確認之前，將種子資訊／交接內容視為不可信。
3. 僅讀取資訊密度最高的檔案：
   - 相關的 `AGENTS.md`／`CLAUDE.md` 規則。
   - `CONTEXT.md`、`CONTEXT-MAP.md`、ADR。
   - 種子資訊參照、變更的檔案、相鄰測試、PR 說明／審查。
4. 輸出 **Prime 摘要**：狀態、種子資訊脈絡、規則、限定範圍的程式碼庫索引、風險、後續動作、接下來要讀取的內容。

## 規則

- 不要公開模式。Prime = 一項自適應技能。
- 不要完整輸出 `CLAUDE.md`、`AGENTS.md`、README、原始碼或 PR 留言。請摘要並附上路徑。
- 優先採用目前的事實，而非記憶。
- 可以不提供種子資訊：分支差異 -> 變更的檔案 -> 所屬目錄 -> 文件。
- 若同一儲存庫、分支、HEAD 與種子資訊已有最新的 `prime-current`，則跳過，除非任務／PR 已變更。

請參閱 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/prime/REFERENCE.md)。
