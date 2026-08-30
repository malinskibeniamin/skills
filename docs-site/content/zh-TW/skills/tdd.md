---
title: /tdd
description: 透過紅燈—綠燈—重構進行開發。適用於撰寫測試、建立功能、修正錯誤、設計測試接縫、防止非同步洩漏，或取代以持續時間為基礎的等待。
type: skill
sidebar:
  label: /tdd
---
![／tdd 技能示意圖](/diagrams/skills/tdd.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/tdd.excalidraw)


TDD 保護有意義的行為。針對變更的領域規則、分支、狀態、解析、驗證、非同步副作用及整合契約，使用 RED -> GREEN -> REFACTOR。型別、重新匯出、串接、靜態文案／樣式，以及不改變行為的刪除，可能只需要執行聚焦驗證。涵蓋率可以揭露疑似的測試盲點，但絕不是目標。

## 測試接縫與反模式

- **接縫：**在公開邊界進行測試。先記下接縫；若問題與慣例未能明確指出接縫，請向使用者確認事先議定的接縫。不得針對未經確認的內部實作進行測試。請使用 `/codebase-design`，不要為了方便而憑空建立接縫。
- **恆真式測試：**預期值必須具備獨立的事實來源：常值、完整推導的範例、測試資料、規格或觀察到的行為。
- **原始文字替代測試：**刪除會讀取實作原始碼、CSS、標記或設定，並將權杖或正規表示式斷言為執行階段行為證明的測試。若仍存在可信的契約，請改為在公開接縫進行測試；若語法本身就是契約，請使用靜態分析。只有在檔案或序列化文字本身就是公開輸出時，才保留內容斷言。
- **垂直切片：**使用垂直切片：每次完成一個 RED 測試與 GREEN 實作；批次撰寫的測試會編碼想像中的行為。

## 工作流程

### 契約

- 說明公開介面上可觀察到的行為；遵循領域詞彙表與 ADR。
- 選擇一個最小的測試，確保行為一旦失效，測試就會失敗。只有在存在獨立且可信的風險時才新增案例。
- 對於高基數／狀態序列不變條件，請閱讀 [PROPERTY-BASED-TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/tdd/PROPERTY-BASED-TESTING.md)；必須具備獨立的判定依據與可重播的失敗案例。
- 對於長時間存續的瀏覽器資源生命週期，請使用可重複的往返操作，並閱讀 [SOAK-TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/SOAK-TESTING.md)；全新的情境無法揭露累積效應。
- 對於外部契約，請使用 `/read-the-damn-docs`；當測試形式不明確時，請閱讀 [tests.md](https://github.com/malinskibeniamin/skills/blob/main/tdd/tests.md)。

### RED

撰寫一個行為測試，並確認它會基於預期原因而失敗。優先使用真實的公開介面；只有無法使用的外部邊界才使用模擬。

### GREEN

撰寫能通過測試的最小實作。優先刪除或重用；接著優先採用語言、平台或已安裝的相依套件。遵循相關 `exemplars/` 檔案的慣例，而不是其規模。

### REFACTOR

只有在語意會變得更清楚，或能消除實際重複時，才改善命名與結構。維持綠燈；絕不可弱化斷言。標記執行時間超過 500ms 的單元測試，以及超過 2s 的整合測試；優先使用批次輸入，而不是逐鍵模擬。對實質且維持綠燈的切片執行 `/dogfood`；缺陷將成為 RED。

### REPEAT

只有在存在另一項契約或獨立且可信的風險時才重複進行。進行中的工作請使用 `vitest --watch`、條件式等待，並針對新的非同步工作使用 `--detectAsyncLeaks`。

## 視覺迴歸測試

當尚未涵蓋的客戶可見路由行為使用 `@vitest/browser` 時，請新增最小且實用的 `*.browser.test.tsx`；若是版面配置、重新導向或宣告式路由，則略過。

## 完成條件

相關測試通過且沒有警告；非同步工作沒有洩漏或以持續時間為基礎的等待；測試能承受內部重構；不存在僅為提高涵蓋率而新增的案例。如需條件式等待、選擇器、Portal、模擬、診斷，以及韌性範例，請參閱 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/tdd/REFERENCE.md)。
