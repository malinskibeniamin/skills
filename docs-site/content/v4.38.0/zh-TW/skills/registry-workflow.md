---
title: /registry-workflow
description: 透過分類法與同步規範維護元件登錄庫。適用於變更 shadcn 登錄庫或設計系統、同步元件，或分析使用端差異。
type: skill
sidebar:
  label: /registry-workflow
---
![「/registry-workflow」技能示意圖](/diagrams/skills/registry-workflow.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/registry-workflow.excalidraw)

請閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/registry-workflow/REFERENCE.md)，以瞭解分類法範例、差異指令、篩選方式與
治理規範。

## 模式

### 元件分類

指定符合條件的最高層級，並依此決定測試深度。

| 層級 | 特徵 | 測試數量 |
|---|---|---|
| 原子 | 一個基礎元件、0 至 1 個狀態，無自訂鍵盤操作或入口網站 | 3 至 4 |
| 分子 | 2 至 3 個原子、最多 2 個狀態值、小型處理函式、可選的入口網站 | 5 至 8 |
| 有機體 | 3 個以上的狀態值、3 個以上的登錄庫匯入、自訂鍵盤操作、入口網站 | 8 至 15 |

Radix 提供的鍵盤導覽不算自訂程式碼。

### 分析使用端差異

1. 將登錄庫元件與使用端檔案進行配對。
2. 執行 `git diff --no-index --ignore-all-space`。
3. 篩除匯入別名、用戶端指令、註解與空白差異。
4. 對每個剩餘元件進行分類：
   - `Upstream`：可重複使用的功能變更。
   - `Skip-Import-Only`：路徑或指令造成的雜訊。
   - `Skip-Outdated`：使用端落後於登錄庫；向下同步。
   - `Skip-Business-Logic`：路由、端點、分析、功能旗標或領域值。
5. 每個元件回報一個狀態。若同時包含可重複使用的修正，請在上游重新乾淨地實作。

### 維護登錄庫

- 將登錄庫同步與功能開發分開交付。
- 將使用端專屬行為置於受管理檔案之外。
- 破壞性變更必須包含程式碼模組化修改工具、變更記錄項目、遷移範例及使用端
  冒煙測試。
- 讓登錄庫元件不依賴特定路由器或框架。
- 在元件 API 中修正使用端反覆出現的誤用。
- 將 changeset 撰寫為升級決策：受影響的元件、變更前後，以及理由。

## Hook 設定

將 `scripts/ui-registry-warn.sh` 與 `scripts/registry-check.sh` 複製到 `.claude/hooks/`，
設為可執行，然後註冊：

- PostToolUse `Edit|Write`：`ui-registry-warn.sh`
- Stop：`registry-check.sh`
- 維持共用的檔案拆分慣例：路由頁面使用 `*.page.tsx`；可重複使用的部分
  放在 `components/` 下。

## 完成條件

- 兩個 Hook 均可執行。
- 編輯元件目錄時會發出警告。
- 變更 `redpanda-ui/` 而未變更 `registry.json` 時會遭到阻擋。
- 更新 `registry.json` 而未提供 changeset 時會遭到阻擋。
