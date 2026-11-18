---
description: 在每個重要行為切片之後以及交接或釋出之前使用，透過真實入口體驗可執行工作。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - dogfood
sidebar:
  label: /dogfood
title: /dogfood
type: skill
---
![「/dogfood」技能示意圖](/diagrams/skills/dogfood.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/dogfood.excalidraw)


檢查行為或驗證器時，請閱讀 [Poteto](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#verification)。

在公共接縫上對每個重要的可執行切片和最終 PR 進行 dogfood。測試不是 dogfood。

## 清點 [#inventory]

1. 用下列指令確定比較基線：
   `BASE=$(PR_BASE_REF="${DOGFOOD_BASE_REF:-}" "${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")`。
2. 檢查完整 PR：從合併基點開始，涵蓋已提交、已暫存、未暫存和未追蹤工作。
3. 在真實入口涵蓋變更的分支，包括技能資源／指令碼和鉤子事件。
   獨立文件、測試和評估不要求體驗覆蓋。

## 迴圈 [#loop]

執行使用 -> 濫用 -> 修復 -> 重放。

### 使用 [#use]

完成預期路徑；檢查輸出、狀態轉換、副作用、主控台、網路和日誌。

使用代表性真實規模資料（形狀和基數接近正式環境）；比較預期與觀察到的
數量、順序、耗時、狀態和副作用；暴露累積問題。

對於缺陷，先在未修復行為上重放報告者的精確步驟。無法重現時，
在診斷前請求缺少的環境或證據。

### 濫用 [#abuse]

嘗試一種可信破壞方式：

- 粗心：空、無效、超大、重複或亂序輸入。
- 急躁：重複、雙擊提交、重新載入、離開、取消或中斷。
- 倒楣：陳舊或缺失資料、相依項目回應緩慢或失敗、部分完成。
- 真實資料：稀疏欄位、重複 ID、混合版本或租戶、長文字、Unicode、
  時區邊界、真實基數。
- 效能：對照基線或預算測量回應時間、網路、算繪、CPU 和記憶體。

觀察失敗和恢復。

UI 內容／版面配置風險：使用 Skill 工具呼叫 "break-ui"。在重放與回執中重用符合結構描述的測試資料
與證據；只測試尚未涵蓋的情況。無效輸入的驗證測試分開進行。

### 修復 [#repair]

缺陷會使檢查失敗。可自動化時，先新增 RED 公開契約測試，
透過 `/tdd` 修復並重新執行聚焦檢查。編輯會使證據失效。

### 重放 [#replay]

在真實入口重複預期使用和每項破壞嘗試。對於缺陷，重放完全相同的
原始步驟並驗證相鄰行為。對於有狀態缺陷或重現缺口，使用[重放資料包](https://github.com/malinskibeniamin/skills/blob/main/shared/verification-replay.md)。
PASS 繫結目前可執行狀態。

## 入口 [#entrypoints]

| 變更 | 操作 |
|---|---|
| Web/UI | 執行、導覽、操作、重新載入並檢查主控台/網路 |
| CLI/TUI | 呼叫真實、無效和中斷流程 |
| API/worker | 傳送真實請求/事件；檢查回應與副作用 |
| 程式庫 | 從最小使用端呼叫公開 API |
| 鉤子/自動化 | 用代表性測試資料觸發真實事件 |
| 技能/代理程式 | 在全新真實任務上使用並檢查行為 |
| 示範/原型 | 操作到問題取得可觀察的證據 |

全新代理程式需要明確授權委派。

如果存在專案本機的 `verify-*` 技能，使用其檢查、驅動、證據和清理功能。
僅限 T3 Code 簽出目錄中的 UI：先解析[原生脈絡](https://github.com/malinskibeniamin/skills/blob/main/shared/T3CODE-NATIVE.md#resolve-context)，再載入 [Web／桌面](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/test-t3-app/SKILL.md)或
[原生行動版](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/test-t3-mobile/SKILL.md)。缺少 Browser/Device 工具表示驗證 BLOCKED；
請勿安裝或切換至另一套驗證工具。
驗證器漂移交由 `/maintain-verification-skill` 處理；經證實反覆缺少的路徑則交由 `/create-verification-skill` 處理。

React：[執行階段檢查](https://github.com/malinskibeniamin/skills/blob/main/shared/react-devtools.md)。

## 瀏覽器與資料任務 [#browser-and-data-tasks]

請閱讀[瀏覽器預設設定](https://github.com/malinskibeniamin/skills/blob/main/shared/verification-replay.md#browser-and-data-tasks)。

## 回執 [#receipt]

`Verdict: PASS | FAIL | BLOCKED`；入口／操作／觀察：

- **入口：** 精確命令、URL、事件或使用端。
- **操作：** 操作流程和破壞嘗試。
- **觀察：** 資料、輸出、狀態、效果、主控台/網路/日誌和耗時。
- **修復：** 缺陷、RED 測試、修復和重放結果。
- **限制：** 未嘗試行為及原因。

PASS：每項行為都有直接證據；FAIL：已觀察到缺陷；BLOCKED：缺少存取權限、
環境、硬體或安全條件。
