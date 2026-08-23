---
title: /golang
description: 套用以證據為基礎的 Go 規則，涵蓋界限、API、錯誤、並行處理、Temporal、測試、發布及控制器。適用於變更 Go 服務、處理常式、工作流程或測試時。
type: skill
sidebar:
  label: /golang
---
![「/golang」技能示意圖](/diagrams/skills/golang.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/golang.excalidraw)

彙整自兩年來對多個儲存庫的審查慣例：共 102 條規則，每條皆有至少三個獨立範例佐證。本檔案包含核心內容；領域檔案包含實務指引；匿名彙總的佐證則收錄於 `/golang-review` 的[規則目錄](https://github.com/malinskibeniamin/skills/blob/main/golang-review/RULES.md)。`/aip` 負責 proto 資源的*設計*；本技能則負責其周邊的 Go *實作*。

## 不可妥協的規則（S 級）

- **為所有由工作負載或租戶控制的項目設定界限**：記憶體、基數、扇出、並行度、回應大小。無界限的輸入會導致 OOM 與基數失控。
- **使用產生的 getter 巡訪 proto**——`a.GetB().GetC()`，絕不可使用逐層 nil 檢查。
- **欄位契約由 proto 註解定義**（行為、必要性、界限）；絕不可在處理常式中重複驗證。
- **僅在語意上需要表達存在性時使用 `optional`**：如果零是合法值，就不要使用 `optional`；更新意圖應由遮罩表達。
- **集合使用 `List`**——必須可分頁及篩選；`Get` 只回傳一項資源。
- **在 API 邊界轉譯錯誤**：記錄內部原因，回傳具有穩定原因與公開欄位路徑的結構化 Connect/gRPC 錯誤。傳遞過程中須保留上游通訊協定的粒度（Kafka 的個別分割區、個別項目）。
- **安全性判斷條件應採封閉式失敗**：設定缺失、授權或 authz 後端發生錯誤、政策狀態不完整時一律拒絕——絕不可預設允許。
- **密碼必須使用參照**：絕不可接受、儲存、回傳或記錄明文密碼資料。
- **重試與退避必須符合作業生命週期**：加入抖動、限制最大值，且累計時間範圍須位於所屬逾時期限內。
- **設定應使用具語意的型別**：重複使用儲存庫的設定結構（`config.TLS`、持續時間、列舉），絕不可使用單純字串與布林值組合。
- **使用功能旗標保護有風險的混合版本發布**；旗標是遷移工具，應在整個叢集版本收斂後移除。
- **伺服器與啟動程序檔案負責接線；套件負責行為**——`server.go` 僅能包含建構與接線。
- **整合測試必須跨越真實邊界**；模擬物無法證明供應商、計費或序列化相容性。
- **測試應斷言穩定且可觀察的行為**，而非執行路徑或附帶的訊息文字。

## 權衡——依情境決定，不可一概而論

- 為提升可讀性，設定應使用正向布林值——**但**若 Go 零值在安全性路徑上必須採封閉式失敗，則使用負向的 `disabled` 欄位才是正確做法。
- 只有在列舉的 switch 宣稱涵蓋完整領域時，才應對未知值報錯；刻意選取的子集則應記錄並忽略其餘值。
- gRPC keepalive 取決於每個中介層是否都支援，並不存在通用設定。
- 相容 AIP 的介面應使用有界限的篩選字串；既有的強型別篩選 API 則應保留其物件形狀以維持相容性。
- 單元測試可自由模擬相依性；一旦測試宣稱可驗證邊界相容性，就必須跨越真實的通訊協定、角色、供應商或容器。

## 領域檔案

| 正在處理 | 閱讀 |
|---|---|
| Proto、處理常式、Connect/gRPC 介面、公開錯誤 | [PROTO-API.md](https://github.com/malinskibeniamin/skills/blob/main/golang/PROTO-API.md) |
| Goroutine、通道、快取、關閉流程、共享狀態 | [CONCURRENCY.md](https://github.com/malinskibeniamin/skills/blob/main/golang/CONCURRENCY.md) |
| 錯誤包裝與分類、記錄、指標 | [ERRORS.md](https://github.com/malinskibeniamin/skills/blob/main/golang/ERRORS.md) |
| 任何 `_test.go`、測試資料、CI 行為 | [TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/golang/TESTING.md) |
| Temporal 工作流程、活動、訊號 | [TEMPORAL.md](https://github.com/malinskibeniamin/skills/blob/main/golang/TEMPORAL.md) |
| 租戶輸入、對外連線、authz、密碼、破壞性操作 | [SECURITY.md](https://github.com/malinskibeniamin/skills/blob/main/golang/SECURITY.md) |
| 設定介面、旗標、棄用、結構描述或欄位移除 | [ROLLOUT.md](https://github.com/malinskibeniamin/skills/blob/main/golang/ROLLOUT.md) |
| 套件邊界、儲存層、介面 | [STRUCTURE.md](https://github.com/malinskibeniamin/skills/blob/main/golang/STRUCTURE.md) |
| Kubernetes 運算子與協調器 | [CONTROLLERS.md](https://github.com/malinskibeniamin/skills/blob/main/golang/CONTROLLERS.md) |
| Go 1.27 泛型方法、公開 SDK／程式庫相容性、goroutine 洩漏剖析 | [GO-1.27.md](https://github.com/malinskibeniamin/skills/blob/main/golang/GO-1.27.md) |

## 掛鉤

編輯時會執行兩項機械式檢查；兩者都只會發出警告，不會阻擋：

- `go-proto-reserved`：移除已發布的 proto 欄位時，必須加入 `reserved N;` 與
  `reserved "name";`；重新編號絕不安全。略過方式：`// allow: proto-unshipped [reason]`。
- `go-test-image-pin`：測試或容器映像必須固定為受支援的版本標籤，絕不可使用
  `:latest`/`:main`/`:master`。略過方式：`// allow: floating-image [reason]`。

若是在審查差異而非撰寫程式碼，請使用 `/golang-review`。
