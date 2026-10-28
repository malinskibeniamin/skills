---
description: >-
  設計並審查 Protobuf 結構描述及其使用端。適用於 .proto
  變更、Buf/程式碼產生設定、結構描述演進、Protovalidate/CEL、描述元或 protobuf 執行階段契約。Google 資源 API 慣例由
  aip 負責。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - protobuf
sidebar:
  label: /protobuf
title: /protobuf
type: skill
---
![Protobuf](/diagrams/skills/protobuf.svg)

[Excalidraw](/diagrams/skills/protobuf.excalidraw)

把結構描述視為序列化、產生程式碼、驗證及描述元驅動使用端的契約，而不只是傳輸 DTO。僅套用儲存庫實際使用的層。載入技能不代表獲准委派或遷移。

## 檢查契約 [#inspect-the-contract]

1. 固定審查基準與 HEAD；依要求包含工作目錄變更。涵蓋刪除和重新命名的結構描述、匯入、自訂選項、程式碼產生設定及受影響的輸出。
2. 確認語法/版本、編譯器與外掛程式、執行階段版本、Buf 模組與鎖定檔、產生命令、相容策略、持久化訊息及已部署的使用端。分別檢查二進位、ProtoJSON、產生原始碼及行為相容性。
3. 結構描述或程式碼產生變更需閱讀[相容性](https://github.com/malinskibeniamin/skills/blob/main/protobuf/references/compatibility.md)。沿受影響的描述元與訊息追蹤產生端、介接器、儲存及用戶端；產生的程式碼是證據，不應手動修改。
4. 只載入相關細節：
   - 驗證、必填語意或 CEL 變更：[驗證](https://github.com/malinskibeniamin/skills/blob/main/protobuf/references/validation.md)。
   - TS/Python 執行階段或 RPC 使用端：[執行階段](https://github.com/malinskibeniamin/skills/blob/main/protobuf/references/runtimes.md)。
   - 反射、自訂選項、表單或重複的結構描述資訊：[結構描述驅動能力](https://github.com/malinskibeniamin/skills/blob/main/protobuf/references/schema-driven.md)。
   - 採用 Google 資源慣例的 API：完整載入 [aip](https://github.com/malinskibeniamin/skills/blob/main/aip/SKILL.md)。`.proto` 副檔名不表示所有通用 AIP 都適用。
   - React Connect Query 資料流：載入 [connect-query](https://github.com/malinskibeniamin/skills/blob/main/connect-query/SKILL.md)。

## 驗證行為 [#verify-behavior]

使用儲存庫自己的命令與固定工具鏈。依現有設定執行 Buf 格式檢查、建置、lint、針對實際審查或部署基準的破壞性變更檢查、程式碼產生及受影響使用端的檢查。遵循模組根目錄與既有規則類別；回報被削弱的檢查及策略缺口，不要暗中修改策略。

審查維持唯讀：必要時將程式碼產生到暫存輸出或快照。說明無法使用的工具、缺少的基準及未測試的語言；僅通過 lint 或二進位檢查無法證明語意相容或執行階段驗證。

為變更契約尋找公開介面上的反例：舊資料搭配新讀取端、新資料搭配舊讀取端、未設定與明確預設值、無效請求到達伺服器，或編輯介接器遺失資訊。實作時先以測試證明該反例失敗，再修正，並透過真實使用端重播。

## 分開回報兩類結果 [#report-two-distinct-results]

- **缺陷：** 差異引入的失敗，包含受影響使用端/情境、證據、後果、最小相容修正及驗證。它們影響審查結論。
- **機會：** 基於實際重複或現有描述元使用端的選用結構描述驅動改進。說明效益、採用成本及最小實驗。不要放入行內缺陷評論或阻擋性發現。未採用 Protovalidate、自訂選項、AIP 慣例或較新執行階段，本身並不是錯誤。

遵循上層審查的發現格式；門檻審查將能力建議放入 `simplification_opportunities`，而非 `findings` 或 `testing_gaps`。回報驗證限制與發行風險；不要虛構獨立審查、跨語言一致性或符合性測試結果。
