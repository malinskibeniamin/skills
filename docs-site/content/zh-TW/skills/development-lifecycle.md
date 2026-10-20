---
description: 將 React、TypeScript 與 UI 實作從高階成果一路推進至自行驗證。
related:
  - /skills/tdd
  - /skills/review
search:
  boost: 3
  keywords:
    - development lifecycle
    - work
    - implementation
    - development workflow
sidebar:
  label: /development-lifecycle
title: /development-lifecycle
type: skill
---
![「/development-lifecycle」技能的流程圖](/diagrams/skills/development-lifecycle.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/development-lifecycle.excalidraw)

作者入口：`/work`。負責一個結果；自動選擇輔助技能。編輯前閱讀[作者交付](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md)，明確歸屬、隔離和端點。遵循[溝通約定](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md)及[相依載入規則](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)。

## 成果契約 [#outcome-contract]

編輯前，先陳述：

- **目標** -- 高階的最終狀態。
- **護欄** -- 無法推斷的限制、保留給使用者決定的事項，以及不可逆的界線。
- **驗證** -- 可執行的檢查或可觀察的行為，用以區分確實完成與看似可行。
- **停止條件** -- 要求的終點，以及確實需要使用者介入的情況。

陳述契約；建置、修正或實作請求應立即繼續。
在該終點範圍內[自動補齊使用端儲存庫的審查保障](https://github.com/malinskibeniamin/skills/blob/main/shared/review-enforcement.md)。

## 執行迴圈 [#loop]

**檢查 -> 行動 -> 驗證 -> 重複**

### 檢查 [#inspect]

根據來源證據釐清盲點或易變的未知事項。遵循現有慣例與已展現的規模；將事項分類為查詢、原型、可逆假設或暫停觸發條件。

編輯前載入[變更證據路由](https://github.com/malinskibeniamin/skills/blob/main/shared/change-evidence.md)及適用的負責技能。按比例評估影響；可見編輯前先擷取基準，包括細小文案和共用 UI 的影響。

### 行動 [#act]

一位負責者；委派與背景工作需要使用者明確授權。做出最小且明確的變更；新增機制前，先刪除或重複使用既有內容。對實質行為載入 [tdd](https://github.com/malinskibeniamin/skills/blob/main/tdd/SKILL.md)，在公開契約層級執行 RED -> 最小 GREEN -> REFACTOR；靜態接線或維持行為不變的刪除僅需進行聚焦驗證。當證據改變時，重新規劃受影響的部分。除非會阻礙驗證，否則相鄰的清理工作僅需回報。

### 驗證 [#verify]

執行儲存庫適用的測試、型別檢查、lint、建置與靜態檢查。對實質且可執行的行為載入 [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md)；測試其實際進入點及一條可信的失敗或復原路徑。依據目標、護欄與可信風險審查結果。失敗成為下一步行動；修正並重複。

若缺少可重複執行的進入點：以可拋棄的測試工具證明，再將長期缺口交由 `/create-verification-skill` 處理。

## 界線 [#boundaries]

僅對使用者保留的決定，或不可逆的正式環境、法律/隱私、破壞性、高安全風險操作詢問。將證據和暫停條件保存在已忽略的 `.context/implementation-notes.md`。

## 完成 [#completion]

閱讀並執行[作者交付](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md)：內嵌自我審查、適用證據、發布以及要求的 CI/回饋跟進。重用目前驗證；所有退出條件滿足後，在要求的端點停止。[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/REFERENCE.md)包含針對任務的探查。
