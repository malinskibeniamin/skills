---
title: /connect-query
description: >-
  使用 Connect Query 和 Protobuf v2 建立具型別的 ConnectRPC 資料流。適用於 API 呼叫、資料異動、查詢
  Hook、傳輸層、快取失效或產生的用戶端。
type: skill
sidebar:
  label: /connect-query
---
![／connect-query 技能示意圖](/diagrams/skills/connect-query.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/connect-query.excalidraw)

在確立目前的 ConnectRPC、Connect Query 或 Protobuf API 指引之前，先執行 `/read-the-damn-docs`。
## 此技能會攔截的問題

- **禁止從 `@tanstack/react-query` 直接使用 `useQuery`／`useMutation`**：當檔案使用 ConnectRPC 時，請改用 Connect Query（例外：`useTransport`／`callUnaryMethod` 模式）
- **禁止不帶引數的 `invalidateQueries()`**：必須指定查詢鍵
- **針對 `axios`／`fetch()` 發出警告**：優先使用 ConnectRPC 傳輸層
- **Protobuf v2**：禁止 `new Message()`，改用 `create(Schema)`。禁止 `PlainMessage`／`PartialMessage`，改用 `MessageShape`／`MessageInitShape`。禁止手動撰寫 `$typeName` 字面值。

例外註解：`// allow: direct-query [reason]`

## 查詢層規範（整理自 4 年的程式碼審查紀錄）

- **使用快取層級，而非魔術數字**：在單一檔案中定義 2 至 3 個語意化常數（`SHORT/MEDIUM/LONG_LIVED_CACHE_STALE_TIME`）；僅當資料只會透過你自己的快取失效操作而變更時，才能使用 `Infinity`。重試政策統一設定在 QueryClient（針對 5xx／網路錯誤重試，絕不針對 4xx 重試）。
- **在 Hook 中使用 `transform`／`select`，絕不在元件中解析**——元件接收可直接顯示的資料；頁面大小由 Hook 強制規範，而非在呼叫端解析。
- **使快取失效，不要重新擷取；而且一律等待完成**——射後不理的快取失效會與導覽產生競態，導致下一個畫面呈現過期快取。查詢鍵：依服務／方法廣泛設定（無限查詢需考量基數），絕不過度具體。
- **載入器 <-> Hook 的查詢鍵必須一致**——若路由載入器使用略有不同的查詢鍵預先擷取資料，便會在不易察覺的情況下重複擷取。請在測試中斷言查詢鍵相等。
- **每個 RPC 使用一個 Hook；拆分包含多個 RPC 的頁面**，讓每個服務呼叫各自對應一個資料 Hook。資料異動 Hook 的名稱以 `Mutation` 結尾（若由其負責顯示提示訊息，則以 `WithToast` 結尾）。
- **驗證方向**：用戶端的 proto 驗證（protovalidate）適用於你送出的內容。回應已由伺服器驗證，因此不要再次驗證讀取結果。
- **Proto 選用欄位應為 `undefined`，絕不可為 `null`**；無上限的清單應使用無限查詢搭配「載入更多」；輪詢應使用內建的 `refetchInterval`，不要自行實作計時器。

Protobuf 注意事項（Timestamp、Duration、Any、快取模式）：[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/connect-query/REFERENCE.md)。設定方式：[SETUP.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/connect-query/SETUP.md)。
