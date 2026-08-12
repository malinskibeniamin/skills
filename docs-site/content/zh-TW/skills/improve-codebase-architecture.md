---
title: /improve-codebase-architecture
description: 重新設計模組邊界、所有權與狀態，讓反覆出現的錯誤類別無法發生。
type: skill
sidebar:
  label: /improve-codebase-architecture
---
![「/improve-codebase-architecture」技能的圖表](/diagrams/skills/improve-codebase-architecture.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/improve-codebase-architecture.excalidraw)

找出能讓整類錯誤無法發生的架構變更。深化設計，而不是只增加另一項檢查或迴歸測試。

此技能僅適用於架構。一般稽核、待辦事項、正確性、安全性、效能、相依套件或文件工作屬於 `/improve`。實作工作屬於 `/development-lifecycle`；此工作流程保持唯讀。

## 詞彙與標準

執行 `/codebase-design`。精確使用**模組**、**介面**、**實作**、**深度**、**深層**、**淺層**、**接縫**、**配接器**、**槓桿效益**與**區域性**這些詞彙。

- **刪除測試：**刪除深層模組會將其隱藏的複雜度分散到呼叫端。
- **介面就是測試表面：**測試透過穩定介面驗證設計。
- **兩個配接器才能證明接縫合理：**只有一個配接器時，抽象仍是假設性的。
- **單一真相來源：**衍生行為來自由其所有者管理的表示，而不是平行的清單、旗標、登錄表、驗證器或生命週期。
- **結構不變量：**建構與狀態轉換讓無效狀態在下游無法發生或無法表示。

若有 `CONTEXT.md` 與相關 ADR，請閱讀它們。領域語言為良好的模組與接縫命名；ADR 可避免在沒有新證據時反覆爭論長期決策。

## 1. 界定範圍並探索

**掃描前先界定範圍 -- YAGNI。**若使用者指定模組、錯誤模式或痛點，就採用該範圍。否則，使用 `git log --name-only --format=` 找出頻繁變動的熱點；只有在歷史紀錄分散時才擴大範圍。

預設直接在目前流程中探索。委派需要使用者明確同意。優先使用儲存庫原生的圖工具。整理模組介面、相依圖或呼叫圖、資料所有權、互相競爭的寫入者、狀態轉換、失敗路徑，以及目前介面上的測試。

## 2. 尋找結構性機會

閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/improve-codebase-architecture/REFERENCE.md)，了解架構分析視角與候選項目淘汰規則。優先選擇以下設計：以單一真相來源取代平行記帳、以經過驗證的建構取代重複驗證、以明確狀態取代不合法的旗標組合，並以一個深層模組介面取代由呼叫端負責的協調工作。

針對每個可疑點，說明**錯誤類別**、目前過於寬鬆的表示、提議的不變量，以及其他呼叫端為何無法再次造成同一錯誤。迴歸測試本身並不構成架構；測試應在建立目標不變量後驗證設計。

## 3. 提出候選方案

將自足的 HTML 報告寫入作業系統暫存目錄：`$TMPDIR/architecture-review-<timestamp>.html`，無法使用時退回 `/tmp` 或 `%TEMP%`。開啟報告並回傳絕對路徑。閱讀 [HTML-REPORT.md](https://github.com/malinskibeniamin/skills/blob/main/improve-codebase-architecture/HTML-REPORT.md)；當可編輯的前後對照圖有助於論證時，使用 `/excalidraw-diagram`。

每個候選方案都必須包含檔案與證據、錯誤類別、目前與提議的不變量、所有權變更、模組／介面／接縫變更、前後對照圖、區域性／槓桿效益／測試收益、遷移切片、復原方式、相容性風險，以及 `Strong|Worth exploring|Speculative` 信心水準。

以**首要建議**結尾。暫時不要提出最終介面。詢問要繼續探索哪個候選方案。

## 4. 深入檢驗所選設計

執行 `/grilling`。釐清所有權、不變量、模組形態、接縫、配接器、相依方向、過渡狀態、遷移、復原方式與可觀測測試。

- 新增或細化的領域詞彙 -> 由 `/domain-modeling` 更新 `CONTEXT.md`。
- 長期否決 -> 提議記錄 ADR。
- 相互競爭的介面 -> 使用 `/codebase-design` 的雙方案設計。
- 可供審查的視覺提案 -> `/visual-plan`；相互競爭的提案 -> `/plan-arbiter`。
- 實作請求 -> 將可逆的遷移順序交給 `/development-lifecycle`。

完成標準：所選不變量能說明為何錯誤類別無法透過未修改的呼叫路徑再次出現，且測試驗證了該公開契約。
