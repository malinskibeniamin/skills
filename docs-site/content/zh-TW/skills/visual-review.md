---
title: /visual-review
description: 從視覺證據審查面向客戶的介面。適用於網頁、行動裝置、CLI、TUI、桌面應用程式、報表、初始設定、表單或其他可見行為有所變更時。
type: skill
sidebar:
  label: /visual-review
---
![「/visual-review」技能示意圖](/diagrams/skills/visual-review.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/visual-review.excalidraw)


以產品、設計、工程與 QA 的角度審查面向客戶的介面。以瀏覽器為基礎的前端審查最常見；行動裝置畫面、CLI/TUI、桌面應用程式與產生的報表也包含在內。[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/visual-review/REFERENCE.md) 是 **設計語言調整點** 與詳細資訊的依據。模式：`plan`、`implemented`、`regression`、`release`。可單獨觸發。

## 流程

1. **找出介面：** 判定 PR 的基底（適用時使用堆疊中的父項），並檢查合併基底...HEAD，以及已暫存、未暫存和相關的未追蹤變更；僅使用 `git diff --name-only HEAD` 會遺漏已提交的工作。將路由／元件對應至 URL，並將 CLI／報表對應至命令。納入 shadcn/ui 或 `@/components/ui`、共用消費端、文案、樣式、資產，以及間接的資料／設定影響。任何可見變更都不會小到可以忽略。
2. **建立情境脈絡：** 閱讀權杖／主題及一個介面；判定其屬於品牌或產品語域。
3. **蒐集證據：** 使用存放庫工具、`scripts/skills-browser.sh`、Playwright、測試資料、螢幕截圖與輸出。僅針對直接指標使用 `/quantify-impact`。
4. 執行**審查路線：** 評析層級／任務流程；稽核無障礙功能／效能；潤飾發布品質／系統一致性。
5. **各角色觀點：** 產品：使用者價值；設計：層級／文案／狀態；工程：韌性／平台；QA：可重現的證據／非預期路徑。
6. **追蹤 UI 生命週期：** 閒置／未請求 -> 等待中／載入中／提交中 -> 成功／錯誤 -> 穩定／已關閉。要求副作用成功時獲得確認，而失敗的副作用會持續顯示。
7. **壓力測試：** Chromium 桌面版與 Chromium 行動版；`Tab, Shift+Tab, Enter, Space, Escape`；載入、空白、錯誤、密集資料；表單提交路徑；通知／快顯通知路徑；主控台／網路。當風險需要時，加入 Firefox 桌面版、WebKit、減少動態效果、強制色彩、文字縮放、RTL／在地化長文字、慢速網路／媒體節流，以及各種主題。
8. **結案：** 引用證據、指出設計調整點、修正或接受 P0-P1，並記錄可確定重現的自動化候選項目。

已實作／發布：遵循 [PR 視覺證據](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)：以擷取畫面與視覺測試核對每個受影響的介面／狀態，在更新預期的基準前檢查快照差異，依正常方式重新執行，並在編輯後更新證據。螢幕截圖不是視覺測試；通過的測試也不是嵌入式的前後對照證據。

HTML 優先。生命週期勝過螢幕截圖。狀態勝過順利路徑。動態效果就是互動。內容壓力測試更有價值。無障礙自動化只能涵蓋部分情況。效能是可見的。若出現兩次，就將其自動化。

如有需要，使用 `/excalidraw-diagram`；螢幕截圖仍是主要證據，Mermaid 則作為備用方案。

## 輸出

撰寫簡潔的 Markdown。若為發布或非小型審查，建立 `$TMPDIR/visual-review-<timestamp>.html`。

```markdown
## Visual review
State trace: | Surface | Trigger | Pending | Success | Error | Persistence | Evidence |
Findings: | Severity | Hat | Surface | Evidence | Impact | Fix | Automate? |
Design findings: | Severity | Surface | Handle | Current read | Desired read | Adjustment |
Automation candidates: <hook/eval/test>
```

P0 會阻礙使用、造成安全性問題、資料遺失或無限迴圈；P1 會阻擋 PR。在問題已修正或獲得接受、證據已備妥，且可重複發生的缺口已受到追蹤後，即告完成。
