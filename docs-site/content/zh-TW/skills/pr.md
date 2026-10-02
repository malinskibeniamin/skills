---
title: /pr
description: 在撰寫 PR 說明時使用。
type: skill
sidebar:
  label: /pr
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

省略所有開場白並保持文字精簡。使用 `CONTEXT.md` 中使用者的領域語言。

### 摘要 [#summary]

先說明價值與審查重點，而不是羅列變更。區分已觀察到的結果和預期。
接著選擇能說明要點的最小視圖；省略無法增進理解的視覺內容。

從 [SUMMARY-VIEWS.md](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md) 中選擇最小視圖。

#### 指引 [#guidance]

將視覺內容放在其支持的文字旁。只顯示關鍵呼叫、檔案、屬性、狀態與邊界。

僅使用能增進理解的視圖。

### 證據 [#evidence]

提供變更有效的具體證據，呈現變更前後對照。列明未執行的檢查與剩餘不確定性；測試通過不代表人工審查或共識。

對於任何前端變更，可直接在頁面內播放的實際 UI 流程前後對照影片（包含點擊、輸入及操作後的狀態，絕不能只是靜止頁面）搭配截圖，是最高等級且必備的證據。將其放在摘要正下方，讓審查者在閱讀說明前先看到變更。依照 [commit-push-pr 視覺證據](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)的指引錄製、編排並託管。

以執行為基礎的證據次之：測試結果、主控台輸出。以虛擬碼呈現先前失敗、現在通過的確切測試。

### 合併風險 [#merge-danger]

說明回復路徑。雙向門容易退回；破壞性或難以逆轉的決策屬於單向門。

列明受影響的使用者、呼叫端、契約及可信的失敗模式，包括共用的使用端。
