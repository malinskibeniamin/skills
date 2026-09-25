---
title: /tanstack-table
description: 透過 TanStack Intent 載入已安裝套件的指引後，套用儲存庫專屬的 TanStack Table 規範。適用於建置、審查或遷移表格與資料網格。
type: skill
sidebar:
  label: /tanstack-table
---
![「/tanstack-table」技能示意圖](/diagrams/skills/tanstack-table.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/tanstack-table.excalidraw)

請先遵循 `/tanstack-intent`。找出已安裝的 Table 轉接器與核心套件，
然後載入所有符合任務的 `use` id。Intent 負責提供目前的 API 語法、版本狀態、
遷移指引、狀態語意，以及框架專屬模式。

## 本機規範

`tanstack-table-check` hook 是依版本啟用的迴歸基準，而非 API
文件。它會解析最近宣告或安裝的套件版本，且僅對 V9 專案套用
其 V9 檢查。已安裝的 Intent 指引仍是最具權威性的依據。

若 hook 與已載入的套件指引衝突，請停止作業並修正測試框架及其評估。
請勿為了通過 hook 而繞過官方 API，或保留過時的本機說明文字。

完成證據包括已安裝的套件版本、已載入的 Intent `use` id、
聚焦於 Table 的測試、型別檢查及程式碼檢查。
