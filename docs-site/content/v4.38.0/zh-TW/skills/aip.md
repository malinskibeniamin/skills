---
title: /aip
description: >-
  設計 Google AIP 資源 API。適用於 protobuf 或 REST 資源、標準方法、HTTP
  繫結、欄位、分頁、篩選、長時間執行作業、錯誤、相容性或批次 API。
type: skill
sidebar:
  label: /aip
---
![「/aip」技能圖解](/diagrams/skills/aip.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/aip.excalidraw)

以通用 AIP 作為事實依據。已核准的 AIP 具有規範效力。AIP-162（草案）與 AIP-182（審查中）僅供參考：應納入考量並加以標示，但絕不可將其表述為要求。

## 工作流程

1. 閱讀完整的提議介面及鄰近的既有 API。判定其屬於管理平面或資料平面。
2. 逐一檢視 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/aip/REFERENCE.md) 中全部 72 個 `Use when` 項目，以建立適用性清單；使用概念或 `AIP-N` 搜尋來取得詳細資訊，不要將其作為唯一的探索方式。記錄選用或排除每個 AIP 的原因。不要盲目套用所有 AIP。
3. 對每個適用的 AIP 開啟確切的官方 `https://google.aip.dev/{number}` 頁面，包括符合規範及僅供參考的項目。絕不可僅根據本機索引新增證據列。完成草稿後，以機械化方式比較適用項目的 URL 與研究軌跡，並在定稿前擷取所有遺漏項目。
4. 依下列順序解決衝突：目前已核准的 AIP、已記錄的本機相容性要求、先例例外。絕不可將違規內容複製為先例。以 `aip.dev/not-precedent` 標示必要的例外，並附上理由。
5. 根據確切的官方指引，制定針對該變更的檢查清單。涵蓋 proto/HTTP 結構、行為、錯誤、生命週期、相容性、文件及用戶端易用性，而不僅是語法。
6. 設計或審查符合規範的最小介面，不要默默刪除預期提供給使用者的功能。除非版本或穩定性政策允許破壞性變更，否則應維持線路相容性。
7. 若可行，使用存放區既有的命令與設定執行 `api-linter`。將其視為最低標準：仍須手動審查其無法編碼的適用規則。
8. 每個適用的 AIP 各以一列 `AIP | state | applicability | result | evidence/exception` 回報；絕不可將多個 AIP 合併於同一列，也不可省略符合規範的通過項目。另行列出因不適用而排除的 AIP，接著驗證這兩組項目是否恰好各自涵蓋全部 72 個已發布的編號一次。將規範性失敗與參考性建議分開呈現。

## 基準

- 將管理 API 建模為無環階層中的具名資源，並優先採用標準方法。
- 為資源提供包含完整服務相對路徑的標準相對資源 `name`，並加上 `(google.api.resource)` 註解；顯示文字應保留給 `display_name`。
- 為參照既有資源的請求 `name` 欄位加上 `resource_reference.type` 註解。若父項類型未宣告或可能改變，請為巢狀 List/Create 的 `parent` 加上 `resource_reference.child_type` 註解；否則應使用父項的 `type`，絕不可將其 `type` 指向子項。
- 確保 HTTP 路徑、請求欄位、方法簽章、資源參照、欄位行為、分頁、篩選、遮罩、錯誤及長時間執行作業中繼資料彼此一致。
- 確保修正後的結構描述可獨立運作：為每個新增的註解或訊息加入其定義匯入。
- 保留相對到期功能：將原始 TTL 數值替換為包含可作為輸入的 `google.protobuf.Timestamp expire_time` 與 `google.protobuf.Duration ttl [(google.api.field_behavior) = INPUT_ONLY]` 的 `oneof expiration`；不可只保留 `expire_time`，且 `expire_time` 不得為 `OUTPUT_ONLY`，因為用戶端可能會提供確切時間。
- 驗證異動後的行為能達到方法或作業所承諾的穩定狀態。
- 審查每項變更的相容性，而不只是欄位編號的重複使用：名稱、類型、格式、語意、HTTP 繫結、資源模式、必填性及用戶端行為都很重要。
- 記錄使用者可見的語意、驗證、預設值、排序、限制、副作用、錯誤、保留政策及例外。

## 防護措施

- 不要為尚未指派的編號捏造指引；此範圍包含 72 個已發布的通用 AIP，而非 236 份文件。
- 不要將範例視為普遍要求。僅在符合觸發條件時套用條件式 AIP。
- 不要弱化已核准 AIP 中的 **必須**/**不得**。應區分 **應該** 類建議與已有文件記錄的例外。
- 不要僅憑 `api-linter` 或此檢查清單便宣稱符合規範。
- 重新檢查已知陷阱：AIP-122 的相對名稱與父項參照方向；HTTP 轉碼資源方法所適用的 AIP-127 與 AIP-130；AIP-134 的選用更新遮罩；AIP-154 未加註解的資源 etag；AIP-161 應忽略僅供輸出的輸入；AIP-192 要求每個公開宣告都必須有註解；AIP-203 的 `IDENTIFIER` 名稱及請求欄位行為；`method_signature` 所需的 `client.proto`；以及 AIP-214 中可作為輸入的 `expire_time` 加上僅供輸入的 `ttl` oneof。
- 對於舊有介面，應優先採用明確的相容性配接器，而非延伸不符合規範的模式。
