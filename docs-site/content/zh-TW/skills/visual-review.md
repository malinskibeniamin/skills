---
title: /visual-review
description: 從視覺證據審查面向客戶的介面。適用於網頁、行動裝置、CLI、TUI、桌面應用程式、報表、初始設定、表單或其他可見行為有所變更時。
type: skill
sidebar:
  label: /visual-review
---
![「/visual-review」技能示意圖](/diagrams/skills/visual-review.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/visual-review.excalidraw)

以產品、設計、工程與 QA 的角度審查面向客戶的介面。
以瀏覽器為基礎的前端審查最常見；行動裝置畫面、CLI/TUI、桌面應用程式與產生的
報表也包含在內。請閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/visual-review/REFERENCE.md)，了解證據矩陣、設計
語言、平台檢查、報告規範與團隊品味。

模式：`plan`、`implemented`、`regression`、`release`。可單獨觸發。

## 流程

1. **找出介面：** 使用提示或 `git diff --name-only HEAD`；將路由／元件對應至
   URL，並將 CLI／報表變更對應至命令。納入 shadcn/ui 或 `@/components/ui`。
2. **建立情境脈絡：** 閱讀權杖／主題及一個具代表性的介面。評判前，先判定其屬於品牌
   或產品語域。
3. **蒐集證據：** 使用存放庫工具、`scripts/skills-browser.sh`、Playwright、測試資料、
   螢幕截圖與命令輸出。若存在直接的 UI 數值或
   效能指標，執行 `/quantify-impact`；對微小變更則略過形式化的量測流程。
4. **執行審查路線：** 評析（層級與任務流程）、稽核（無障礙功能、
   響應式行為、效能）、潤飾（發布品質與系統一致性）。
5. **套用各角色觀點：** 產品：使用者價值與阻力。設計：層級、操作暗示、文案、
   狀態、品味。工程：韌性、時序、平台、效能。
   QA：可重現的證據、非預期路徑、迴歸、自動化。
6. **追蹤 UI 生命週期：** 閒置／未請求 -> 等待中／載入中／提交中 -> 成功／錯誤 -> 穩定／已關閉。
   確認副作用成功時有明確回饋，而失敗的副作用會持續顯示。
7. **對矩陣進行壓力測試：** Chromium 桌面版與行動版；鍵盤 Tab、Shift+Tab、Enter、
   Space、Escape；載入、空白、錯誤、密集資料；表單提交路徑；通知／快顯通知
   路徑；主控台／網路。當風險需要時，加入 Firefox 桌面版、WebKit、減少動態效果、強制色彩、文字
   縮放、RTL／在地化長文字、慢速網路／媒體節流，以及深色／淺色模式。
8. **報告並結案：** 引用證據、指出設計調整點、修正 P0/P1 或記錄接受決定，
   並將可確定重現的步驟列為自動化候選項目。

使用參考檢查清單檢查安全區域與虛擬鍵盤行為、書寫模式、
表格、CSS 簡寫／複雜版面配置、僅在必要時使用 ARIA、靜態／通用元素、
密碼管理工具／自動填入、`aria-disabled`、焦點、巢狀按鈕／連結、`requestSubmit`、
快顯通知、媒體、WebView、bfcache、捲動、原生控制項行為、功能偵測、
響應式圖片／影片、長寬比、INP／長時間互動、字型載入，以及第三方
嵌入內容／指令碼。

啟發原則：HTML 優先。生命週期勝過螢幕截圖。狀態勝過順利路徑。動態效果就是互動。
內容壓力測試更有價值。無障礙自動化只能涵蓋部分情況。效能是可見的。若出現兩次，就將其自動化。

## 流程圖

當螢幕截圖無法說明複雜的狀態歷程、UI／系統邊界或
變更前後的結構時，使用 `/excalidraw-diagram` 製作一張簡潔的流程圖。仍以
螢幕截圖作為主要證據；流程圖用於說明關係，而非像素。將
其行內 SVG 或資料編碼 PNG 嵌入 HTML 報告，並附上相鄰的可編輯
`.excalidraw` 路徑。
若是簡單圖表或畫布無法使用，則以 Mermaid 作為備用方案，並記錄其限制。

## 輸出

撰寫簡潔的報告。若為複雜或發布審查，建立
`$TMPDIR/visual-review-<timestamp>.html`。

```markdown
## Visual review
Status: ready | needs fixes | blocked
Changed UI: <surfaces>
Checked: <browser/viewport/state/terminal evidence>
State trace: | Surface | Trigger | Pending | Success | Error | Persistence/dismissal | Evidence |
Findings: | Severity | Hat | Surface | Evidence | Why it matters | Fix | Automate? |
Design findings: | Severity | Surface | Handle | Current read | Desired read | Adjustment |
Screenshots: | View | Browser | Path | Notes |
Impact: <Proven impact table + verdict, or why measurement was not useful>
Automation candidates: <deterministic hook/eval/test candidates>
```

P0 會阻礙使用、造成安全性問題、資料遺失或無限迴圈。P1 會阻擋 PR。當 P0/P1 已修正或
獲得接受、證據已擷取或明確略過，且可重複發生的缺口已受到追蹤時，即告完成。
