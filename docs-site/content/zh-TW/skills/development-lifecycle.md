---
title: /development-lifecycle
description: 將 React、TypeScript 與 UI 實作從高階成果一路推進至自行驗證。
type: skill
sidebar:
  label: /development-lifecycle
---
![「/development-lifecycle」技能的流程圖](/diagrams/skills/development-lifecycle.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/development-lifecycle.excalidraw)

負責一項成果。使用[溝通規則](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md)及[相依指引載入規則](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)。

## 成果契約 [#outcome-contract]

編輯前，先陳述：

- **目標** -- 高階的最終狀態。
- **護欄** -- 無法推斷的限制、保留給使用者決定的事項，以及不可逆的界線。
- **驗證** -- 可執行的檢查或可觀察的行為，用以區分確實完成與看似可行。
- **停止條件** -- 要求的終點，以及確實需要使用者介入的情況。

陳述契約；建置、修正或實作請求應立即繼續。

## 執行迴圈 [#loop]

**檢查 -> 行動 -> 驗證 -> 重複**

### 檢查 [#inspect]

根據來源證據釐清盲點或易變的未知事項。遵循現有慣例與已展現的規模；將事項分類為查詢、原型、可逆假設或暫停觸發條件。

編輯前，載入 [quantify-impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md)並尋找有用的證據。任何可見變更都應使用 [PR 視覺證據](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)擷取基準狀態並盤點各個介面。微小的文案／樣式變更及共用 UI 的影響也包含在內。

### 行動 [#act]

一位負責者；委派與背景工作需要使用者明確授權。做出最小且明確的變更；新增機制前，先刪除或重複使用既有內容。對實質行為載入 [tdd](https://github.com/malinskibeniamin/skills/blob/main/tdd/SKILL.md)，在公開契約層級執行 RED -> 最小 GREEN -> REFACTOR；靜態接線或維持行為不變的刪除僅需進行聚焦驗證。當證據改變時，重新規劃受影響的部分。除非會阻礙驗證，否則相鄰的清理工作僅需回報。

### 驗證 [#verify]

執行儲存庫適用的測試、型別檢查、lint、建置與靜態檢查。對實質且可執行的行為載入 [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md)；測試其實際進入點及一條可信的失敗或復原路徑。依據目標、護欄與可信風險審查結果。失敗成為下一步行動；修正並重複。

若缺少可重複執行的進入點：以可拋棄的測試工具證明，再將長期缺口交由 `/create-verification-skill` 處理。

## 界線 [#boundaries]

只有在涉及保留給使用者決定的事項，或不可逆的正式環境、法律／隱私、破壞性或高安全性操作時才詢問。對目前由使用者擁有的分支，可直接提交、推送、執行 rebase，並使用 `--force-with-lease`，無須再次詢問許可。未經明確許可，絕不可合併、使用一般的強制推送、建立額外的 PR，或改寫預設、共用、他人擁有或正由他人並行使用的分支。

在 main/master/develop 分支上編寫程式碼前，請使用 `scripts/mux-worktree.sh <type>/<branch-name>` 建立隔離的 worktree。[ETHOS：Worktree 隔離]

將長期工作的證據與暫停觸發條件記錄於被 git 忽略的 `.context/implementation-notes.md`。

## 完成 [#completion]

所有退出條件通過後，在要求的終點停止。驗證或交付時參閱 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/REFERENCE.md)；要求透過 Git 交付時載入 [commit-push-pr](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/SKILL.md)。
