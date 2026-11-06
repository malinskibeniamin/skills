---
description: 透過紅燈—綠燈—重構進行開發。適用於撰寫測試、建立功能、修正錯誤、設計測試接縫、防止非同步洩漏，或取代以持續時間為基礎的等待。
related:
  - /skills/development-lifecycle
  - /skills/review
search:
  boost: 3
  keywords:
    - tdd
    - test driven development
    - red green refactor
sidebar:
  label: /tdd
title: /tdd
type: skill
---
![／tdd 技能示意圖](/diagrams/skills/tdd.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/tdd.excalidraw)

驗證變更後的行為或維護驗證流程時，請閱讀 [Poteto 適配指南](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#verification)。

當下方工作流程需要模型可呼叫的技能時，請為每個相依技能分別呼叫 Skill 工具。沒有此工具的宿主應依[相依技能載入規則](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)完整閱讀標準 `SKILL.md`。僅供使用者呼叫的技能應建議由使用者執行，不要自動呼叫。

使用 `GLOSSARY.md` 中的領域術語並遵循相關 ADR。若存在 `GLOSSARY-MAP.md`，依對照找到相應脈絡的詞彙表。

處理 T3 或 Effect 測試時，以 `tdd` 為入口解析[原生脈絡](https://github.com/malinskibeniamin/skills/blob/main/shared/T3CODE-NATIVE.md#resolve-context)；遵循目標專案的時鐘、工作器和渲染生命週期契約。


遵循[適度驗證](https://github.com/malinskibeniamin/skills/blob/main/shared/verifiability.md#proportionate-verification)。可信回歸需要新增涵蓋時使用 RED -> GREEN -> REFACTOR；對於已涵蓋行為、型別、串接、文案、樣式及不改變行為的刪除，重用現有檢查。不是每次編輯或相依套件呼叫都需要新測試。涵蓋率絕不是目標。

針對每個建議的測試接縫，說明它能捕捉什麼，以及會漏掉什麼。

## 測試接縫與反模式 [#test-seams-and-anti-patterns]

- **接縫：**在公開邊界進行測試。先記下接縫；若問題與慣例未能明確指出接縫，請向使用者確認事先議定的接縫。不得針對未經確認的內部實作進行測試。請使用 `/codebase-design`，不要為了方便而憑空建立接縫。
- **恆真式測試：**預期值必須具備獨立的事實來源：常值、完整推導的範例、測試資料、規格或觀察到的行為。
- **重複測試相依套件：**信任程式庫已有文件說明的工具函式；只在領域選擇與整合假設引入獨立風險時測試它們。擴充現有涵蓋，而非在各層重複相同契約。
- **原始文字替代測試：**刪除會掃描實作、CSS、標記或設定，並將權杖或正規表示式視為執行階段行為證明的測試。若行為確實重要，請改為在公開接縫進行測試；若是語法，請使用靜態分析。只有在公開輸出時，才保留內容斷言。
- **垂直切片：**使用垂直切片：每次完成一個 RED 測試與 GREEN 實作；批次撰寫的測試會編碼想像中的行為。

## 工作流程 [#workflow]

### 契約 [#contract]

- 說明公開行為；遵循領域詞彙表與 ADR。
- 選擇一個最小的測試，確保行為一旦失效，測試就會失敗；每個新增或變更的測試都必須通過[撰寫檢核](https://github.com/malinskibeniamin/skills/blob/main/test-audit/SKILL.md#authoring-gate)。
- 對於高基數／狀態序列不變條件，請閱讀 [PROPERTY-BASED-TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/tdd/PROPERTY-BASED-TESTING.md)；必須具備獨立的判定依據與可重播的失敗案例。
- 對於長時間存續的瀏覽器資源生命週期，請使用可重複的往返操作，並閱讀 [SOAK-TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/SOAK-TESTING.md)；全新的情境無法揭露累積效應。
- 對於外部契約，請使用 `/read-the-damn-docs`；當測試形式不明確時，請閱讀 [tests.md](https://github.com/malinskibeniamin/skills/blob/main/tdd/tests.md)。

### RED

撰寫一個行為測試，並確認它會基於預期原因而失敗。使用公開介面；只有無法使用的外部邊界才使用模擬。

### GREEN

撰寫能通過測試的最小實作。優先刪除或重用；接著優先採用語言、平台或已安裝的相依套件。遵循相關 `exemplars/` 檔案的慣例，而不是其規模。

### REFACTOR

遵循[可驗證性優先於可讀性](https://github.com/malinskibeniamin/skills/blob/main/shared/verifiability.md)：改善獨立檢查、領域命名、狀態擁有權或經量測的效能，而非大小或複雜度評分。維持綠燈；絕不可弱化斷言。標記執行時間超過 500ms 的單元測試，以及超過 2s 的整合測試；優先使用批次輸入，而不是逐鍵模擬。對實質且維持綠燈的切片，以 "dogfood" 呼叫 Skill 工具；缺陷將成為 RED。

### REPEAT

只有在存在另一項契約或獨立且可信的風險時才重複進行。進行中的工作請使用 `vitest --watch`、條件式等待，並針對新的非同步工作使用 `--detectAsyncLeaks`。

## 視覺迴歸測試 [#visual-regression]

針對視覺風險，重用現有截圖斷言工具中的相關案例；審查預期更新後正常重跑。只為可信且未涵蓋的回歸新增案例。小型文案或樣式變更需要檢查，不應自動新增快照或測試工具。在比較有助於審查或明確要求時使用 [PR 視覺證據](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)。不可見變更不需要截圖。

## 完成條件 [#done]

測試通過且沒有警告、非同步洩漏或以持續時間為基礎的等待；測試能承受重構。如需條件式等待、選擇器、Portal、模擬、診斷，以及韌性範例，請參閱 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/tdd/REFERENCE.md)。

當驗收條件涉及型別推斷、可指派性、多載或型別顯示時，載入[測試開發](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/test-development/SKILL.md)。執行階段回歸仍需執行階段測試；一般宣告只需型別檢查。
