---
description: 揪出變更宣稱做到卻未做到的事：憑空捏造的 API 或宣稱、假裝成功的程式碼、不可能失敗的測試、未經要求的變更，以及容易被複製的反模式。適用於每個 PR。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - lie detector
sidebar:
  label: /lie-detector
title: /lie-detector
type: skill
---
![/lie-detector 技能示意圖](/diagrams/skills/lie-detector.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/lie-detector.excalidraw)


將變更視為尚未獲得證實。為「這不應該合併」建立最強論點，再讓差異中的
證據反駁它。可獨立執行，也可在 `/review` 中以 **lie-detector 角色**檢查每一份
差異；優先關注面向客戶的介面（UI、文案、CLI 輸出、公開 API、報告）。
程式碼缺陷由 `/review` 處理；價值由 `/product` 評估。使用固定的審查範圍，
若請求包含 WIP，則納入明確擷取的 WIP。

## 1. 缺乏證據的宣稱 [#1-claims-without-evidence]

列出 PR 標題、內文、提交紀錄、程式碼註解、文件及代理摘要中的每一項宣稱。
每一項都需要差異中的程式碼行、指令輸出或第一手文件佐證：

- 不存在的介面元素：匯入的符號、prop、hook、CLI 旗標、設定鍵、環境變數、設計
  token、路由或選項，在已安裝的版本中並不存在。檢查鎖定檔、
  `node_modules` 型別或第一手文件，別依賴記憶。
- 「已測試」、「已驗證」、「修正 X」、「未改變行為」：需要指令與輸出，或
  一組先失敗再通過的測試結果。
- 引用的檔案與行號、議題或文件，內容並不支持該宣稱。

## 2. 假裝完成工作的程式碼 [#2-code-that-pretends]

追蹤每條變更的執行路徑，確認使用者或呼叫端實際得到什麼。標記宣稱
完成了實際上未完成之工作的程式碼：

- 工作完成前就回報成功：在資料異動、
  寫入或快取失效處理完成前，就顯示提示訊息、重新導向或回傳 `200`；
- 吞掉錯誤、只記錄錯誤，或退回預設值、預留內容或快取資料，
  但 UI 卻顯示成功；
- 將佔位實作、TODO、寫死或模擬的資料，或停用的分支當作已完成的功能交付；
- 沒有任何程式碼路徑讀取的旗標、選項或設定鍵；
- 名稱、註解、型別或型別轉換，與其描述的程式碼不符；
- 無法進入或永不結束的載入、空白或錯誤狀態。

## 3. 不可能失敗的測試 [#3-tests-that-cannot-fail]

針對每個新增或修改的測試：

1. 依[審查隔離](https://github.com/malinskibeniamin/skills/blob/v4.41.0/review/REFERENCE.md#source-snapshots-and-mutation-tests)在可丟棄的快照中
   破壞測試宣稱保護的行為：反轉變更條件、移除算繪元素或改變使用者可見的值。
   只破壞串接關係會漏掉恆真斷言。在快照中重新執行測試；保持原始檔案、
   索引和分支不變。仍然通過：測試在說謊。RED 必須來自斷言失敗，
   而非環境設定失敗。記錄指令與失敗；無法隔離時應明確報告證據缺口，
   而不是修改目前的工作目錄。
2. 對照 [test-audit 垃圾測試模式](https://github.com/malinskibeniamin/skills/blob/v4.41.0/test-audit/SKILL.md#junk-patterns)，檢查其餘通過上述檢驗的測試。
3. 行為變更若沒有曾經失敗的測試，也沒有從實際進入點重播驗證（`/dogfood`），
   就尚未獲得證實。

## 4. 沒人要求的變更 [#4-changes-nobody-asked-for]

將每個差異區塊與聲明的範圍比對。標記所有未加說明、會改變可觀察行為或削弱防護的區塊：刪除、略過或放寬測試；重新產生快照；`@ts-ignore` 或停用 lint 檢查；變更預設值、文案、路由、旗標、錯誤處理、重試或逾時；擴大排除範圍、放寬編譯器或 lint 規則，或將 shell、CI 的失敗結束碼轉為成功；鎖定檔或設定的反覆變動；手動編輯產生的檔案；沒有螢幕截圖的視覺變更。將變更的檢查及設定與其評判的實作分別審查；合理的規則修正需要透過實際指令驗證已知錯誤與有效案例。

針對授權證明型別，將建立過程追溯至可信的檢查模組。斷言、匯出的未經檢查建構函式，或宣稱安全的註解，都不能取代授權檢查；型別檢查通過本身不代表可信模組正確。
遇到鏈式斷言、遭捨棄的型別證據或擬採用的 anti-slop 規則時，使用 [anti-slop 檢查清單](https://github.com/malinskibeniamin/skills/blob/v4.41.0/shared/anti-slop.md)；僅憑上游偏好不能構成審查問題。

## 5. 會擴散的模式 [#5-patterns-that-will-spread]

人與代理都會複製最容易找到的範例。針對差異引入的每一種慣用寫法，使用
`rg` 尋找先例，並與根目錄及適用範圍內的 `CLAUDE.md`/`AGENTS.md`、`exemplars/`
和技術堆疊登錄表比對。違反文件明定的規則或儲存庫主要慣用寫法：列為問題；
嚴重程度取決於複製影響範圍：共用元件、hook、fixture、測試輔助函式、範本、
產生器、典範範例或技能為 P1；末端程式碼為 P2。從源頭修正：採用核准的
模式，或在同一個 PR 中更新規則，並說明原因。兩種風格並存本身就是缺陷。

## 6. 最強反方論證關卡 [#6-steelman-gate]

以「這個 PR 應該合併」為前提，遵循 [steelman/SKILL.md](https://github.com/malinskibeniamin/skills/blob/v4.41.0/steelman/SKILL.md)。
根據 [product](https://github.com/malinskibeniamin/skills/blob/v4.41.0/product/SKILL.md) 的判定、上述問題
及 `/review` 的問題，提出最有力的反對論證。只有同時滿足以下三項，才算**可合併**：

- 價值：`product:` 判定為 `justified`；
- 真實性：此處沒有 P1，且每個變更的行為都有先失敗再通過的測試，或
  從實際進入點重播驗證；
- 實作：`/review` 未回報 P0/P1。

其他情況一律為**尚未證實**；指出哪一項證據足以改變判定。捨棄任何
沒有檔案與行號或指令輸出佐證的反對論點。絕不因個人偏好而阻擋合併。

## 嚴重程度 [#severity]

- **P1**：與程式碼或文件矛盾的宣稱；不存在的 API；程式碼回報實際上
  未達成的成功；行為已損壞卻仍通過的測試；未加說明的行為變更或
  防護弱化；位於容易被複製之處的反模式。
- **P2**：尚未驗證但合理的宣稱；誤導的名稱或註解；末端程式碼中的
  反模式；與有效斷言並列、必然成立的斷言。
- **P3**：僅列於摘要。

最多回報五個問題，優先列出會影響合併決策的問題。

## 輸出 [#output]

一律以一行判定開頭：

`lie-detector: <truthful|suspect|lying> -- merge <ready|not proven> -- <evidence, at most 20 words>`

`truthful`：沒有問題。`suspect`：只有 P2。`lying`：存在任何 P1。接著輸出
`[P1|P2|P3] <file:line> <section> -- <lie and proof>; <smallest fix>`。全部通過時，
只輸出判定行。
