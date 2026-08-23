---
title: /golang-review
description: 依據實證規則檢查 Go 的邊界、API、並行處理、錯誤、安全性、測試與推出流程。適用於 Go 差異、PR、分支、模組或後端 proto。
type: skill
sidebar:
  label: /golang-review
---
![「/golang-review」技能示意圖](/diagrams/skills/golang-review.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/golang-review.excalidraw)

單一審查面向：這個 Go 差異是否遵循
[RULES.md](https://github.com/malinskibeniamin/skills/blob/main/golang-review/RULES.md) 中有實證支持的慣例，以及適用的版本化語言契約？目錄中的每條規則都附有匿名彙總的支持數量。版本特定的發現事項會引用
`/golang` 中的官方契約，因此兩者都不依賴審查者的個人偏好。

可針對任何 Go 差異獨立執行，也可在 `/review` 中以 **golang hat** 身分執行。明確
委派或 `/swarm` 可將此技能用作範圍明確的審查工作流契約。

## 非目標

- 目標儲存庫中的 `golangci-lint` 已經強制執行的任何項目——請先讀取其設定並略過這些項目。
- 沒有 RULES.md 或官方版本契約依據的一般 Go 風格（gofmt、命名、註解文法）。
- 前端、產生的檔案（`*.pb.go`、`*_pb.go`、`*.connect.go`、`@generated`/`DO NOT EDIT`）、第三方納管程式碼。
- 重新爭論目錄內容：若你不同意某條規則，應針對目錄提供意見，而不是提出與規則相反的發現事項。

## 程序

1. **界定範圍**：從固定點到 HEAD 的差異，檢查 Go 與 proto 檔案，以及語言或工具鏈版本可能變更時的 `go.mod` 或
   `go.work`。記錄儲存庫 `.golangci.yml` 中啟用的 linter；其強制執行的任何項目都不在範圍內。
2. **分類**差異所屬領域：proto/API 介面、公開 SDK／函式庫 API、
   服務處理常式、Temporal 工作流程／活動、Kubernetes 控制器、測試、
   設定／推出流程、面向租戶的安全性路徑、並行處理／生命週期。
3. **載入** [RULES.md](https://github.com/malinskibeniamin/skills/blob/main/golang-review/RULES.md) 中相符的章節，以及 `/golang`
   中相符的領域檔案（PROTO-API、CONCURRENCY、ERRORS、TESTING、TEMPORAL、SECURITY、ROLLOUT、
   STRUCTURE、CONTROLLERS）。若涉及 Go 1.27 泛型方法、SDK／函式庫相容性或
   goroutine 洩漏分析，也請載入 [GO-1.27.md](https://github.com/malinskibeniamin/skills/blob/main/golang/GO-1.27.md)。套用範圍內的每條
   S/A 規則；明確違反時套用 B；只有在差異明顯違反陳述時才套用 C/D。
   只有當模組版本與變更的介面將其納入範圍時，才套用發布契約。
4. 撰寫發現事項前，先**檢查 RULES.md 與 `/golang` SKILL.md 中的衝突清單**
   ——正向布林值與失敗時關閉、列舉子集 switch、keepalive、
   篩選器物件與字串之間的選擇皆取決於情境，並不一定構成違規。
5. **回報**發現事項，每項須包含：目錄規則 ID 或發布契約 ID、檔案:行號、
   差異所做的變更、必要的修正，以及優先級。作為面板 hat 時最多 400 字；
   獨立執行時可更長，但仍須以來源為依據。

## 嚴重程度

- **P0**：失敗時放行的安全性判斷條件、租戶輸出流量繞過 safedial、儲存／傳回／記錄
  明文祕密、在持久化處理前提交進度、未版本化的變更破壞現行 Temporal 歷程。
- **P1**：任何其他 S/A 違規——由租戶控制且無上限的成長、在公開介面暴露原始內部
  錯誤、缺少分階段移除、以模擬物件宣稱完成整合測試；
  Go 1.27 語法超出已宣告或支援的使用端最低版本。
- **P2**：B 級違規；需要作者判斷並回答的 S/A 情況；
  與已證實的介面或反射邊界衝突的泛型方法，
  或聲稱乾淨的洩漏分析結果足以證明不存在洩漏。
- **P3**：C/D 級的措辭與潤飾。

已確認的錯誤無論修正規模大小，都維持為 P0/P1。

## 輸出

標準 hat 契約：發現事項必須由差異引入、會影響使用者、可採取行動，
且每項都可直接作為 PR 留言（問題內容、依目錄規則或發布契約說明原因、建議修正、一次性提示詞）。
若範圍內沒有違反任何規則或發布契約：
`APPROVED -- <已檢查的領域>, no catalog or version-contract violations.`
