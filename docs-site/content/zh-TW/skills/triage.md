---
title: /triage
description: "讓問題在分診角色之間流轉，並準備可由智慧體執行的工作。"
type: skill
sidebar:
  label: /triage
---
![「/triage」技能的流程圖](/diagrams/skills/triage.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/triage.excalidraw)

透過小型角色狀態機移動問題。對於已配置的外部 PR，PR 是附帶程式碼的問題；透過跟蹤器解析裸編號。
使用領域詞彙表和相關 ADR。透過 `/read-the-damn-docs` 閱讀當前外部文件；用 `/plan-arbiter` 仲裁競爭方案，用 `/visual-plan` 展示大型史詩。

## 評論不變數

每條釋出的分診評論必須以下列內容開頭：

```markdown
> *此內容由 AI 在分診期間生成。*
```

## 跟蹤器與角色

從倉庫說明和遠端地址檢測跟蹤器：

- GitHub：按 [tracker-github.md](https://github.com/malinskibeniamin/skills/blob/main/triage/tracker-github.md) 使用 `gh`。
- Jira：按 [tracker-jira.md](https://github.com/malinskibeniamin/skills/blob/main/triage/tracker-jira.md) 使用 `acli`。
- 兩者都可能時，詢問哪個擁有該事項。

每個已分診事項恰好有一個類別（`bug` 或 `enhancement`）和一個狀態：`needs-triage`、`needs-info`、`ready-for-agent`、`ready-for-human` 或 `wontfix`。
將標準角色對映到現有標籤或狀態。狀態衝突必須先決策再修改。

## 待關注佇列

按最舊優先查詢：

1. 無標籤或無狀態事項。
2. `needs-triage` 事項。
3. 報告者有新活動的 `needs-info` 事項。

包含已配置的外部事項，並將每行標記為 `[PR]` 或 `[issue]`；協作者的活躍 PR 不屬於發現工作。明確指定的 PR 始終在範圍內。顯示數量，由維護者選擇。

## 分診一個事項

1. **收集。** 閱讀正文、評論、標籤或狀態、報告者、日期、舊分診記錄，以及 PR 差異。不要重複已回答的問題。
2. **探索。** 按領域概念搜尋冗餘或已有實現。檢查 `.out-of-scope/` 中的舊拒絕記錄。
3. **建議。** 給出類別、狀態、理由和程式碼證據；等待方向。
4. **驗證主張。** 復現缺陷，或檢出並測試 PR。報告已確認、失敗或證據不足。根因和 RED/GREEN 計劃見 [TDD 修復計劃模式](https://github.com/malinskibeniamin/skills/blob/main/triage/REFERENCE.md#tdd-fix-plan-mode)。
5. **必要時追問。** 對未決判斷或領域語言使用 `/grilling`。
6. **應用。** 就緒狀態使用 [AGENT-BRIEF.md](https://github.com/malinskibeniamin/skills/blob/main/triage/AGENT-BRIEF.md)，`needs-info` 使用 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/triage/REFERENCE.md)。對於 `wontfix`：
   - 已實現：連結實現並關閉，不寫拒絕歷史；
   - 缺陷：解釋後關閉；
   - 增強：按 [OUT-OF-SCOPE.md](https://github.com/malinskibeniamin/skills/blob/main/triage/OUT-OF-SCOPE.md) 記錄，連結並關閉。
   除非要記錄部分進展，應用 `needs-triage` 時不評論。

## 覆蓋與恢復

對於明確狀態覆蓋，先說明變更再執行，跳過追問。僅在沒有智慧體簡報卻移動到 `ready-for-agent` 時詢問是否編寫。
恢復時讀取舊記錄和新回覆，再展示當前狀態，不重複提問。

完整模板和狀態轉換見 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/triage/REFERENCE.md)。
