---
title: /lie-detector
description: >-
  揪出變更宣稱做到卻未做到的事：不可能失敗的測試、憑空捏造的 API、未經要求的變更，以及容易被複製的反模式。適用於面向使用者的差異，也應在宣告 PR
  可合併前使用。
type: skill
sidebar:
  label: /lie-detector
---
![/lie-detector 技能示意圖](/diagrams/skills/lie-detector.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/lie-detector.excalidraw)


將變更視為尚未獲得證實。為「這不應該合併」建立最強論點，再讓差異中的
證據反駁它。可獨立執行，也可在 `/review` 中以 **lie-detector 角色**檢查每一份
面向客戶的差異（UI、文案、CLI 輸出、公開 API、報告）。程式碼缺陷由
`/review` 處理；價值由 `/jb` 評估。

在已提交的工作樹上操作；將 `BASE` 設為合併基準。

## 1. 不可能失敗的測試 [#1-tests-that-cannot-fail]

針對每個涵蓋面向使用者行為的新增或修改測試：

1. 破壞它宣稱保護的行為：執行 `git diff "$BASE" -- <src> | git apply -R`、
   反轉變更的條件、移除算繪出的元素，或變更使用者
   看到的值（文案、計數、狀態）；只破壞串接關係，會漏掉必然成立的斷言。執行測試，然後執行
   `git checkout HEAD -- <src>`。程式碼壞了卻仍通過：這個測試在說謊。測試失敗必須
   來自斷言，而非匯入、編譯或設定錯誤。記錄指令與
   測試失敗訊息。
2. 對照 [test-audit 垃圾測試模式](https://github.com/malinskibeniamin/skills/blob/main/test-audit/SKILL.md#junk-patterns)，檢查其餘通過上述檢驗的測試。
3. 面向使用者的行為變更，若沒有曾經失敗的測試，也沒有從實際進入點
   重播驗證（`/dogfood`），就尚未獲得證實。

## 2. 缺乏證據的宣稱 [#2-claims-without-evidence]

列出 PR 標題、內文、提交紀錄、程式碼註解、文件及代理摘要中的每一項宣稱。
每一項都需要差異中的程式碼行、指令輸出或第一手文件佐證：

- 不存在的介面元素：匯入的符號、prop、hook、CLI 旗標、設定鍵、環境變數、設計
  token、路由或選項，在已安裝的版本中並不存在。檢查鎖定檔、
  `node_modules` 型別或第一手文件，別依賴記憶。
- 「已測試」、「已驗證」、「未改變行為」、「修正 X」：需要指令與輸出，或
  一組先失敗再通過的測試結果。
- 引用的檔案與行號、議題或文件，內容並不支持該宣稱。

## 3. 沒人要求的變更 [#3-changes-nobody-asked-for]

將每個差異區塊與聲明的範圍比對。標記所有未加說明、會改變可觀察
行為或削弱防護的區塊：刪除、略過或放寬測試；重新產生快照；型別斷言、
`@ts-ignore`、停用 lint 檢查；變更預設值、文案、路由、旗標、錯誤處理、
重試或逾時；鎖定檔或設定的反覆變動；手動編輯產生的檔案；沒有螢幕截圖的視覺
變更。

## 4. 會擴散的模式 [#4-patterns-that-will-spread]

人與代理都會複製最容易找到的範例。針對差異引入的每一種慣用寫法：

- 使用 `rg` 尋找先例；與根目錄及適用範圍內的 `CLAUDE.md`/`AGENTS.md`、
  `exemplars/` 和技術堆疊登錄表比對。
- 違反文件明定的規則或儲存庫主要慣用寫法：列為問題。嚴重程度取決於複製
  影響範圍：共用元件、hook、fixture、測試輔助函式、範本、產生器、典範範例或
  技能為 P1；末端程式碼為 P2。
- 從源頭修正：採用核准的模式，或在同一個 PR 中更新規則，並說明
  新模式為何更好。兩種風格並存本身就是缺陷。

## 5. 最強反方論證關卡 [#5-steelman-gate]

以「這個 PR 應該合併」為前提，遵循 [steelman/SKILL.md](https://github.com/malinskibeniamin/skills/blob/main/steelman/SKILL.md)。
根據 [jb](https://github.com/malinskibeniamin/skills/blob/main/jb/SKILL.md) 的判定、上述問題
及 `/review` 的問題，提出最有力的反對論證。只有同時滿足以下三項，才算**可合併**：

- 價值：`jb:` 判定為 `justified`；
- 真實性：此處沒有 P1，且每個面向使用者的行為都有先失敗再通過的測試，或
  從實際進入點重播驗證；
- 實作：`/review` 未回報 P0/P1。

其他情況一律為**尚未證實**；指出哪一項證據足以改變判定。捨棄任何
沒有檔案與行號或指令輸出佐證的反對論點。絕不因個人偏好而阻擋合併。

## 嚴重程度 [#severity]

- **P1**：行為已損壞卻仍通過的測試；與程式碼或文件矛盾的宣稱；不存在的
  API；未加說明的行為變更或防護弱化；位於容易被複製之處的反模式。
- **P2**：尚未驗證但合理的宣稱；末端程式碼中的反模式；與有效斷言並列、
  必然成立的斷言。
- **P3**：僅列於摘要。

最多回報五個問題，優先列出會影響合併決策的問題。

## 輸出 [#output]

一律以一行判定開頭：

`lie-detector: <truthful|suspect|lying> -- merge <ready|not proven> -- <evidence, at most 20 words>`

`truthful`：沒有問題。`suspect`：只有 P2。`lying`：存在任何 P1。接著輸出
`[P1|P2|P3] <file:line> <section> -- <lie and proof>; <smallest fix>`。全部通過時，
只輸出判定行。
