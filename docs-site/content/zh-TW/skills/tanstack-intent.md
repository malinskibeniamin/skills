---
title: /tanstack-intent
description: >-
  提及、引用或處理 TanStack 套件時，請使用 TanStack Intent。在回答或變更 Router、Query、Table 或其他
  TanStack 程式碼之前，先載入版本相符的指引。
type: skill
sidebar:
  label: /tanstack-intent
---
![/tanstack-intent 技能示意圖](/diagrams/skills/tanstack-intent.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/tanstack-intent.excalidraw)

在回答、規劃、審查或編輯之前，先詢問 TanStack Intent 哪些已安裝套件的文件適用。只要提及、引用或處理 TanStack 套件，即使任務未指名本機 TanStack 技能，也適用此規則。

## 載入套件指引

1. 從請求、匯入項目與最近的 `package.json` 中，識別每個相關的 `@tanstack/*` 套件。請以已安裝的相依套件為準，而不是憑記憶使用主要版本。
2. 從套件根目錄探索其隨附的技能：

   ```bash
   bunx @tanstack/intent@latest list --json
   ```

3. 根據傳回的 `skills[].packageName`、`description` 與 `use` 欄位，為每項任務找出相符項目。完全依照傳回內容載入每個相符的 `use` ID：

   ```bash
   bunx @tanstack/intent@latest load "$use_id"
   ```

4. 套用技能之前，先載入該技能指定的所有 `requires`。若是組合使用，請載入每個相關套件負責方的指引，例如 Table 加上 Query，或 Router 加上 Query。

若儲存庫使用的命令執行工具不是 Bun，請改用該工具。請勿猜測技能 ID，也不要選擇名稱相近的框架套件。

## 權威依據

- 已安裝且版本相符的 Intent 指引，是 TanStack API 語法、版本狀態、遷移步驟與框架特定行為的權威依據。
- 本機 `/tanstack-router` 與 `/tanstack-table` 指引僅在 Intent 載入後，補充儲存庫政策與確定性檢查。
- 如果本機指引或掛鉤與已安裝的 Intent 技能衝突，請將其視為測試框架缺陷。應遵循套件指引並修復測試框架，而不是撰寫程式碼來規避衝突。
- 如果套件尚未安裝或未提供相符技能，請說明 Intent 無法提供版本相符的指引，接著使用 `/read-the-damn-docs` 查閱 TanStack 官方來源。絕不可默默憑記憶填補缺漏。

若要設定專案，請閱讀 [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/tanstack-intent/SETUP.md)。完成證據須列出已載入的 `package@version` 與 `use` ID。
