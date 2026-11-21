---
description: 從視覺證據審查面向客戶的介面。適用於網頁、行動裝置、CLI、TUI、桌面應用程式、報表、初始設定、表單或其他可見行為有所變更時。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - visual review
sidebar:
  label: /visual-review
title: /visual-review
type: skill
---
![「/visual-review」技能示意圖](/diagrams/skills/visual-review.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/visual-review.excalidraw)

全面審查網頁介面時，載入 [better-interface](https://github.com/malinskibeniamin/skills/blob/main/jakubkrehel-skills/better-interface/SKILL.md)，涵蓋六個設計領域。其相容契約保留本技能的範圍、證據與報告職責；重用現有截圖並按根因去重。


以瀏覽器為基礎的前端審查：採用產品、設計、工程與 QA 四種觀點。[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/visual-review/REFERENCE.md) 是 **設計語言調整點** 與詳細資訊的依據。模式：`plan`、`implemented`、`regression`、`release`。可單獨觸發。

## 流程 [#flow]

根據受影響介面與可信風險，依[適度驗證](https://github.com/malinskibeniamin/skills/blob/main/shared/verifiability.md#proportionate-verification)調整審查深度。例行文案或樣式變更只需聚焦的畫面檢查，不需要完整裝置與狀態矩陣，也不需要新報告。重用 dogfood 觀察與截圖；僅在假設變更時擴大範圍。

1. **找出介面：** 判定 PR 的基底（適用時使用堆疊中的父項），並檢查合併基底...HEAD，以及已暫存、未暫存和相關的未追蹤變更；僅使用 `git diff --name-only HEAD` 會遺漏已提交的工作。將路由／元件對應至 URL，並將 CLI／報表對應至命令。納入 shadcn/ui 或 `@/components/ui`、共用消費端、文案、樣式、資產，以及間接的資料／設定影響。任何可見變更都不會小到可以忽略。
2. **建立情境脈絡：** 閱讀權杖／主題及一個介面；判定其屬於品牌或產品語域。
3. **蒐集證據：** 使用存放庫工具、`scripts/skills-browser.sh`、Playwright、測試資料、螢幕截圖與輸出。僅針對直接指標使用 `/quantify-impact`。
4. 執行**審查路線：** 評析層級／任務流程；稽核無障礙功能／效能；潤飾發布品質／系統一致性。針對評分比較或重複比較，使用[審查校準](https://github.com/malinskibeniamin/skills/blob/main/visual-review/REFERENCE.md#review-calibration)。
5. **各角色觀點：** 產品：使用者價值；設計：層級／文案／狀態；工程：韌性／平台；QA：可重現的證據／非預期路徑。
6. **追蹤 UI 生命週期：** 閒置／未請求 -> 等待中／載入中／提交中 -> 成功／錯誤 -> 穩定／已關閉。要求副作用成功時獲得確認，而失敗的副作用會持續顯示。
7. **壓力測試：**依風險檢查受影響行為：相關檢視區、鍵盤與焦點、載入、空白資料、錯誤、密集資料、表單、通知及主控台／網路。僅在存在可信的受影響風險或專案要求時增加瀏覽器、減少動態效果、強制色彩、縮放、RTL、節流或主題。
8. **結案：** 引用證據、指出設計調整點、修正或接受 P0-P1，並記錄可確定重現的自動化候選項目。

內容／版面配置壓力測試：使用 Skill 工具呼叫 "break-ui"。重用目前 dogfood 測試資料與螢幕截圖；
只測試尚未涵蓋的情況。保留唯讀或已獲授權修復的執行邊界。

已實作／發布：只在擷取畫面有助於審查或明確要求時使用 [PR 視覺證據](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)。在預期更新前審查相關快照差異，再正常重跑。只在需要定位差異時加上標註；唯讀審查回報缺口。截圖不是測試；測試也不是前後比較證據。

比對已核准的影像或宣稱已修復視覺問題時，使用[目標與證據檢查](https://github.com/malinskibeniamin/skills/blob/main/visual-review/REFERENCE.md#target-and-evidence-checks)：保留目標影像，確認擷取畫面可比較，並在適用時使用隨附工具驗證產物與 PNG 差異。量測用於定位差異，不代表正確性。

畫面呈現行為優先。生命週期勝過截圖。狀態勝過順利路徑。動態效果就是互動。無障礙自動化只能涵蓋部分情況。當風險足以支持維護成本時，再將重複檢查自動化。

如有需要，使用 `/excalidraw-diagram`；螢幕截圖仍是主要證據，Mermaid 則作為備用方案。

## 輸出 [#output]

直接使用簡潔 Markdown，省略空表。只有使用者要求時才另外撰寫 HTML 報告。

```markdown
## Visual review
State trace: | Surface | Trigger | Pending | Success | Error | Persistence | Evidence |
Findings: | Severity | Hat | Surface | Evidence | Impact | Fix | Automate? |
Design findings: | Severity | Surface | Handle | Current read | Desired read | Adjustment |
Automation candidates: <hook/eval/test>
```

P0 會阻礙使用、造成安全性問題、資料遺失或無限迴圈；P1 會阻擋 PR。在問題已修正或獲得接受、證據已備妥，且可重複發生的缺口已受到追蹤後，即告完成。
