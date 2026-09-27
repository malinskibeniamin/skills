---
title: /pr
description: 在撰寫 PR 說明時使用。
type: skill
sidebar:
  label: /pr
---
![/pr 技能的示意圖](/diagrams/skills/pr.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/pr.excalidraw)


使用此範本撰寫 PR 說明：

```markdown
## Summary

<diagram, diff-sketch, or tree>

## Evidence

<frontend: before/after flow video playing inline (user-attachments URL), then screenshot table>

- **Before:** <screenshot/output/failing test run>
  **After:** <screenshot/output/passing test run>

## Merge Danger

**Door:** <one-way or two-way>

<optional: description>

**Blast Radius:** <one-word description>

<optional: potential ramifications of merge>
```

## 各區段 [#sections]

省略所有開場白並保持文字精簡。使用 `CONTEXT.md` 中使用者的領域語言。

### 摘要 [#summary]

選擇能清楚呈現重點的最小視圖。

從 [SUMMARY-VIEWS.md](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md) 中的視圖挑選：虛擬碼、呼叫樹、元件樹、檔案樹、Mermaid、diff 或完整區塊。

#### 指引 [#guidance]

將每個視覺內容放在其所支援的簡短文字旁。只保留回答使用者目前問題，或解決目前討論重點所需的呼叫、檔案、屬性、狀態與邊界。

你可以使用其中一種，也可以使用數種，但不太可能全部用上。請自行判斷，不要讓過多資訊造成使用者負擔。

### 證據 [#evidence]

證明變更有效的具體證據。呈現變更前後的對照。

對於任何前端變更，可直接在頁面內播放的實際 UI 流程前後對照影片（包含點擊、輸入及操作後的狀態，絕不能只是靜止頁面）搭配截圖，是最高等級且必備的證據。將其放在摘要正下方，讓審查者在閱讀說明前先看到變更。依照 [commit-push-pr 視覺證據](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)的指引錄製、編排並託管。

以執行為基礎的證據次之：測試結果、主控台輸出。以虛擬碼呈現先前失敗、現在通過的確切測試。

### 合併風險 [#merge-danger]

說明這是單向門還是雙向門。雙向門可以退回，單向門則不行。容易回復的 PR 風險較低。涉及破壞性操作或難以逆轉之決策的變更屬於單向門。

影響範圍是此 PR 所引入變更的潛在影響或波及面。考慮所有可能性，例如版面位移、對使用端造成的破壞、行動裝置響應式呈現等。
