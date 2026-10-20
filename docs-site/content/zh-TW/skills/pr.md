---
description: 在撰寫 PR 說明時使用。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - pr
sidebar:
  label: /pr
title: /pr
type: skill
---
![/pr 技能的示意圖](/diagrams/skills/pr.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/pr.excalidraw)


閱讀[保護讀者注意力的契約](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md)。使用以下範本撰寫 PR 說明：

```markdown
## Summary

<outcome and why it matters to the affected user or caller>
<reviewer focus or specific question; say if no special input is needed>
<smallest useful diagram, diff-sketch, or tree>

## Evidence

<frontend: before/after flow video playing inline (user-attachments URL), then screenshot table>

- **Before:** <screenshot/output/failing test run>
  **After:** <screenshot/output/passing test run>

## Merge Danger

**Door:** <one-way or two-way>

<optional: description>

**Blast Radius:** <affected users, callers, or contracts>

<rollback path and unresolved risks, when applicable>
```

## 各區段 [#sections]

省略所有開場白並保持文字精簡。使用 `GLOSSARY.md` 中使用者的領域語言。

### 摘要 [#summary]

區分核心變更與產生或機械性檔案；指出有用的審查入口，不逐一羅列檔案。

先說明價值與審查重點，而不是羅列變更。區分已觀察到的結果和預期。
接著選擇能說明要點的最小視圖；省略無法增進理解的視覺內容。

從 [SUMMARY-VIEWS.md](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md) 中選擇最小視圖。

#### 決策變更 [#changed-decisions]

當實作相對於已記錄的計畫或成果契約出現實質偏離，影響範圍、契約、驗證方式或推出風險時，請說明這些變更。沿用既有筆記或意圖圖：
先前選擇 -> 新證據 -> 目前選擇 -> 對審查的影響。
讓 PR 說明本身完整清楚；省略空泛的變更歷程，絕不虛構先前計畫或共識。

工作階段摘錄僅為選用背景資訊。只使用相關、已獲授權、已遮蔽敏感資料且審查者可存取的摘錄；否則提供安全、完整的理由說明。
不要只為提供連結而擴大分享範圍或執行權限。工作階段長度或互動輪數無法證明正確性或用心程度；請依據目前差異與執行證據核實各項說法。

#### 指引 [#guidance]

將視覺內容放在其支持的文字旁。只顯示關鍵呼叫、檔案、屬性、狀態與邊界。

僅使用能增進理解的視圖。

### 證據 [#evidence]

提供變更有效的具體證據，呈現變更前後對照。列明未執行的檢查與剩餘不確定性；測試通過不代表人工審查或共識。

對於後端架構、資料流程、API 契約或工作流程變更，請遵循[後端圖表](https://github.com/malinskibeniamin/skills/blob/main/excalidraw-diagram/PR-WORKFLOW.md)指引並呼叫 `excalidraw-diagram`。提供聚焦的前後對照與可編輯原始檔連結；更新相關的持續維護圖表。圖表失敗時回報警告並繼續，絕不阻擋 PR，也不能取代測試證據。

對於任何前端變更，可直接在頁面內播放的實際 UI 流程前後對照影片（包含點擊、輸入及操作後的狀態，絕不能只是靜止頁面）搭配截圖，是最高等級且必備的證據。將其放在摘要正下方，讓審查者在閱讀說明前先看到變更。依照 [commit-push-pr 視覺證據](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)的指引錄製、編排並託管。

以執行為基礎的證據次之：測試結果、主控台輸出。以虛擬碼呈現先前失敗、現在通過的確切測試。

### 合併風險 [#merge-danger]

說明回復路徑。雙向門容易退回；破壞性或難以逆轉的決策屬於單向門。

列明受影響的使用者、呼叫端、契約及可信的失敗模式，包括共用的使用端。
